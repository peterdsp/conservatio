import Foundation

/// The subset of the API the sync engine drives. `APIClient` conforms as-is,
/// and tests substitute a scripted mock to exercise offline, interrupted,
/// auth-failure, and conflict scenarios without a live server.
protocol SyncAPI {
    var isLoggedIn: Bool { get }

    func createObject(_ object: CreateObjectRequest) async throws -> ServerObject
    func updateObject(id: String, _ object: CreateObjectRequest) async throws -> ServerObject
    func deleteObject(id: String) async throws

    func createReport(_ report: CreateReportRequest) async throws
    func updateReport(id: String, _ report: CreateReportRequest) async throws
    func deleteReport(id: String) async throws

    func createClient(_ client: CreateClientRequest) async throws -> ServerClient
    func updateClient(id: String, _ client: CreateClientRequest) async throws -> ServerClient
    func deleteClient(id: String) async throws

    func createProject(_ project: CreateProjectRequest) async throws -> ServerProject
    func updateProject(id: String, _ project: CreateProjectRequest) async throws -> ServerProject
    func deleteProject(id: String) async throws
}

extension APIClient: SyncAPI {}

/// High-level sync state surfaced to the UI so the user always knows whether
/// their data is safe.
enum SyncStatus: Equatable {
    case idle
    case syncing
    case offline
    case authRequired
    case error(String)
}

/// Drains the durable `SyncOutbox` to the server, one change at a time, with
/// idempotent upserts (so a retried create never duplicates a record), bounded
/// retries, and explicit error handling. Nothing is removed from the outbox
/// until the server confirms it, so a failure at any point leaves the change
/// queued for the next attempt rather than silently dropping user data.
@MainActor
@Observable
final class SyncEngine {
    static let shared = SyncEngine()

    private let api: SyncAPI
    let outbox: SyncOutbox

    var status: SyncStatus = .idle
    var lastError: String?
    private(set) var lastSyncedAt: Date? {
        didSet {
            if let lastSyncedAt {
                UserDefaults.standard.set(lastSyncedAt.timeIntervalSince1970, forKey: "lastSyncAt")
            }
        }
    }

    private var isFlushing = false

    init(api: SyncAPI = APIClient.shared, outbox: SyncOutbox = SyncOutbox()) {
        self.api = api
        self.outbox = outbox
        let stored = UserDefaults.standard.double(forKey: "lastSyncAt")
        if stored > 0 { lastSyncedAt = Date(timeIntervalSince1970: stored) }
    }

    var pendingCount: Int { outbox.count }

    func hasPending(_ entity: SyncEntity, id: String) -> Bool {
        outbox.hasPending(entity, id: id)
    }

    /// Records a local change durably and kicks off a push. Safe to call
    /// offline: the change persists and is retried later.
    func enqueue<T: Encodable>(_ entity: SyncEntity, id: String, operation: SyncOperation, body: T?) {
        var payload: Data?
        if let body {
            payload = try? JSONEncoder().encode(body)
        }
        outbox.enqueue(entity, id: id, operation: operation, payload: payload)
        Task { await self.flush() }
    }

    func enqueueDelete(_ entity: SyncEntity, id: String) {
        outbox.enqueue(entity, id: id, operation: .delete, payload: nil)
        Task { await self.flush() }
    }

    /// Pushes every queued change. Idempotent to call repeatedly and guarded so
    /// concurrent triggers do not double-send.
    func flush() async {
        guard api.isLoggedIn else {
            // Offline or signed out: keep everything queued, do not lose it.
            status = outbox.count > 0 ? .idle : .idle
            return
        }
        guard !isFlushing else { return }
        isFlushing = true
        defer { isFlushing = false }

        if outbox.count > 0 { status = .syncing }

        for change in outbox.all() {
            do {
                try await perform(change)
                outbox.remove(change.id)
            } catch APIError.unauthorized {
                status = .authRequired
                lastError = "Session expired. Sign in to resume syncing."
                return
            } catch let APIError.serverError(code) {
                // Non-recoverable server error after upsert fallback: keep the
                // change and its error visible, continue with the rest.
                outbox.markFailed(change.id, error: "Server error \(code)")
            } catch {
                // Transient (network, timeout): stop and retry on the next trigger.
                outbox.markFailed(change.id, error: error.localizedDescription)
                status = .offline
                lastError = error.localizedDescription
                return
            }
        }

        finish()
    }

    private func finish() {
        if outbox.count == 0 {
            status = .idle
            lastError = nil
            lastSyncedAt = Date()
        } else {
            let firstError = outbox.all().compactMap { $0.lastError }.first
            status = .error("\(outbox.count) change\(outbox.count == 1 ? "" : "s") not synced")
            lastError = firstError
        }
    }

    // MARK: - Per-change execution

    private func perform(_ change: PendingChange) async throws {
        switch change.entity {
        case .object:
            switch change.operation {
            case .create, .update:
                let req = try decode(CreateObjectRequest.self, change.payload)
                try await upsert(
                    preferCreate: change.operation == .create,
                    create: { _ = try await self.api.createObject(req) },
                    update: { _ = try await self.api.updateObject(id: change.entityId, req) }
                )
            case .delete:
                try await deleteIgnoringNotFound { try await self.api.deleteObject(id: change.entityId) }
            }
        case .report:
            switch change.operation {
            case .create, .update:
                let req = try decode(CreateReportRequest.self, change.payload)
                try await upsert(
                    preferCreate: change.operation == .create,
                    create: { try await self.api.createReport(req) },
                    update: { try await self.api.updateReport(id: change.entityId, req) }
                )
            case .delete:
                try await deleteIgnoringNotFound { try await self.api.deleteReport(id: change.entityId) }
            }
        case .client:
            switch change.operation {
            case .create, .update:
                let req = try decode(CreateClientRequest.self, change.payload)
                try await upsert(
                    preferCreate: change.operation == .create,
                    create: { _ = try await self.api.createClient(req) },
                    update: { _ = try await self.api.updateClient(id: change.entityId, req) }
                )
            case .delete:
                try await deleteIgnoringNotFound { try await self.api.deleteClient(id: change.entityId) }
            }
        case .project:
            switch change.operation {
            case .create, .update:
                let req = try decode(CreateProjectRequest.self, change.payload)
                try await upsert(
                    preferCreate: change.operation == .create,
                    create: { _ = try await self.api.createProject(req) },
                    update: { _ = try await self.api.updateProject(id: change.entityId, req) }
                )
            case .delete:
                try await deleteIgnoringNotFound { try await self.api.deleteProject(id: change.entityId) }
            }
        }
    }

    /// Makes create/update idempotent against the insert-only server:
    /// a create whose record already exists (409, or the PK-violation 500 the
    /// server returns) falls back to update; an update whose record is gone
    /// (404) falls back to create. This is what prevents duplicate records when
    /// a create is retried after its confirmation was lost.
    private func upsert(
        preferCreate: Bool,
        create: () async throws -> Void,
        update: () async throws -> Void
    ) async throws {
        do {
            if preferCreate { try await create() } else { try await update() }
        } catch let APIError.serverError(code) {
            if preferCreate, code == 409 || code == 500 {
                try await update()
            } else if !preferCreate, code == 404 {
                try await create()
            } else {
                throw APIError.serverError(code)
            }
        }
    }

    private func deleteIgnoringNotFound(_ op: () async throws -> Void) async throws {
        do {
            try await op()
        } catch let APIError.serverError(code) where code == 404 {
            // Already gone on the server: treat as a successful delete.
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, _ payload: Data?) throws -> T {
        guard let payload else { throw APIError.serverError(0) }
        return try JSONDecoder().decode(type, from: payload)
    }
}
