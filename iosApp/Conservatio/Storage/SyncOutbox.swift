import Foundation

/// The record types Conservatio syncs to the server.
enum SyncEntity: String, Codable, CaseIterable {
    case object
    case report
    case client
    case project
}

/// The kind of change waiting to be pushed.
enum SyncOperation: String, Codable {
    case create
    case update
    case delete
}

/// One durable, replayable unit of work: "push this change for this record".
/// Payload is the JSON-encoded request body for create/update, nil for delete.
struct PendingChange: Codable, Identifiable, Equatable {
    let id: UUID
    var entity: SyncEntity
    var entityId: String
    var operation: SyncOperation
    var payload: Data?
    var createdAt: Date
    var updatedAt: Date
    var attemptCount: Int
    var lastError: String?

    init(
        id: UUID = UUID(),
        entity: SyncEntity,
        entityId: String,
        operation: SyncOperation,
        payload: Data?,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        attemptCount: Int = 0,
        lastError: String? = nil
    ) {
        self.id = id
        self.entity = entity
        self.entityId = entityId
        self.operation = operation
        self.payload = payload
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.attemptCount = attemptCount
        self.lastError = lastError
    }
}

/// A durable queue of pending changes, persisted to disk so nothing is lost
/// across app restarts or crashes. Changes for the same record are coalesced so
/// the server is never asked to create a record twice and redundant updates
/// collapse into one, which is what keeps sync from producing duplicates.
///
/// This is deliberately plain Foundation + a JSON file, matching the app's
/// existing store pattern (`ObjectStore`, `ReportStore`). No SQLDelight/KMP
/// migration is required to track pending work durably at this scale.
final class SyncOutbox {
    private(set) var changes: [PendingChange] = []
    private let fileURL: URL

    init(directory: URL? = nil, fileName: String = "sync_outbox.json") {
        let dir = directory ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = dir.appendingPathComponent(fileName)
        load()
    }

    var count: Int { changes.count }

    func all() -> [PendingChange] { changes }

    /// Whether a record has an unpushed change. Used both to show pending state
    /// in the UI and to protect local edits from being overwritten by a pull.
    func hasPending(_ entity: SyncEntity, id: String) -> Bool {
        changes.contains { $0.entity == entity && $0.entityId == id }
    }

    func pendingCount(for entity: SyncEntity) -> Int {
        changes.filter { $0.entity == entity }.count
    }

    /// Adds a change, coalescing with any existing change for the same record so
    /// the queue always holds at most one pending change per record.
    func enqueue(_ entity: SyncEntity, id: String, operation: SyncOperation, payload: Data?) {
        let now = Date()
        if let index = changes.firstIndex(where: { $0.entity == entity && $0.entityId == id }) {
            var existing = changes[index]
            switch (existing.operation, operation) {
            case (.create, .delete):
                // Never synced, so drop it entirely: nothing exists on the server.
                changes.remove(at: index)
                save()
                return
            case (.create, .update), (.create, .create):
                // Still a create; just carry the newest payload.
                existing.payload = payload
            case (.delete, .create), (.delete, .update):
                // Resurrected after a pending delete: push the latest content.
                existing.operation = .update
                existing.payload = payload
            default:
                existing.operation = operation
                existing.payload = payload
            }
            existing.updatedAt = now
            existing.attemptCount = 0
            existing.lastError = nil
            changes[index] = existing
        } else {
            changes.append(
                PendingChange(entity: entity, entityId: id, operation: operation, payload: payload, createdAt: now, updatedAt: now)
            )
        }
        save()
    }

    func remove(_ id: UUID) {
        changes.removeAll { $0.id == id }
        save()
    }

    /// Records a failed attempt so retries are bounded and the error is visible.
    func markFailed(_ id: UUID, error: String) {
        guard let index = changes.firstIndex(where: { $0.id == id }) else { return }
        changes[index].attemptCount += 1
        changes[index].lastError = error
        changes[index].updatedAt = Date()
        save()
    }

    func clear() {
        changes = []
        save()
    }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(changes)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save sync outbox: \(error)")
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            changes = try JSONDecoder().decode([PendingChange].self, from: data)
        } catch {
            print("Failed to load sync outbox: \(error)")
        }
    }
}
