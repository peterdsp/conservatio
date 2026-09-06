import XCTest
@testable import Conservatio

/// A scriptable stand-in for the API so the engine can be driven through
/// offline, interrupted, auth-failure, and conflict scenarios deterministically.
final class MockSyncAPI: SyncAPI {
    var loggedIn = true
    var isLoggedIn: Bool { loggedIn }

    // Behaviour hooks for objects (the entity the tests exercise).
    var createObjectHandler: ((CreateObjectRequest) throws -> Void)?
    var updateObjectHandler: ((CreateObjectRequest) throws -> Void)?
    var deleteObjectHandler: ((String) throws -> Void)?

    private(set) var createObjectCount = 0
    private(set) var updateObjectCount = 0
    private(set) var deleteObjectCount = 0

    func createObject(_ object: CreateObjectRequest) async throws -> ServerObject {
        createObjectCount += 1
        try createObjectHandler?(object)
        return Self.dummyObject(id: object.id ?? "")
    }

    func updateObject(id: String, _ object: CreateObjectRequest) async throws -> ServerObject {
        updateObjectCount += 1
        try updateObjectHandler?(object)
        return Self.dummyObject(id: id)
    }

    func deleteObject(id: String) async throws {
        deleteObjectCount += 1
        try deleteObjectHandler?(id)
    }

    // Other entities: trivial success (not exercised by these tests).
    func createReport(_ report: CreateReportRequest) async throws {}
    func updateReport(id: String, _ report: CreateReportRequest) async throws {}
    func deleteReport(id: String) async throws {}
    func createClient(_ client: CreateClientRequest) async throws -> ServerClient { Self.dummyClient(id: client.id ?? "") }
    func updateClient(id: String, _ client: CreateClientRequest) async throws -> ServerClient { Self.dummyClient(id: id) }
    func deleteClient(id: String) async throws {}
    func createProject(_ project: CreateProjectRequest) async throws -> ServerProject { Self.dummyProject(id: project.id ?? "") }
    func updateProject(id: String, _ project: CreateProjectRequest) async throws -> ServerProject { Self.dummyProject(id: id) }
    func deleteProject(id: String) async throws {}

    static func dummyObject(id: String) -> ServerObject {
        ServerObject(id: id, title: "", objectType: "OTHER", materials: nil, height: nil, width: nil, depth: nil, measurementUnit: nil, ownerName: nil, locationDescription: nil, inventoryNumber: nil, description: nil, imageIds: nil, createdAt: nil, updatedAt: nil)
    }
    static func dummyClient(id: String) -> ServerClient {
        ServerClient(id: id, name: "", type: "Other", contactPerson: nil, email: nil, phone: nil, address: nil, notes: nil, createdAt: nil, updatedAt: nil)
    }
    static func dummyProject(id: String) -> ServerProject {
        ServerProject(id: id, title: "", clientId: nil, objectIds: [], status: "Inquiry", startDate: nil, endDate: nil, description: nil, totalBudget: nil, currency: nil, createdAt: nil, updatedAt: nil)
    }
}

@MainActor
final class SyncEngineTests: XCTestCase {

    private func tempDir() -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func objectRequest(id: String, title: String = "Panel") -> CreateObjectRequest {
        CreateObjectRequest(id: id, title: title, objectType: "ICON", materials: [], height: nil, width: nil, depth: nil, measurementUnit: nil, ownerName: nil, locationDescription: nil, inventoryNumber: nil, description: nil, imageIds: [])
    }

    // MARK: Offline edits are durable and survive restart

    func testOfflineEditPersistsAndSurvivesRestart() async {
        let dir = tempDir()
        let mock = MockSyncAPI()
        mock.loggedIn = false

        let engine = SyncEngine(api: mock, outbox: SyncOutbox(directory: dir))
        engine.outbox.enqueue(.object, id: "A", operation: .create, payload: try? JSONEncoder().encode(objectRequest(id: "A")))
        await engine.flush() // offline: nothing sent, nothing lost
        XCTAssertEqual(engine.pendingCount, 1)
        XCTAssertEqual(mock.createObjectCount, 0)

        // Simulate app restart: a fresh outbox from the same directory.
        let reopened = SyncOutbox(directory: dir)
        XCTAssertEqual(reopened.count, 1)
        XCTAssertTrue(reopened.hasPending(.object, id: "A"))
    }

    // MARK: Successful flush clears the queue

    func testFlushPushesAndClears() async {
        let mock = MockSyncAPI()
        let engine = SyncEngine(api: mock, outbox: SyncOutbox(directory: tempDir()))
        engine.outbox.enqueue(.object, id: "A", operation: .create, payload: try? JSONEncoder().encode(objectRequest(id: "A")))

        await engine.flush()

        XCTAssertEqual(mock.createObjectCount, 1)
        XCTAssertEqual(engine.pendingCount, 0)
        XCTAssertEqual(engine.status, .idle)
        XCTAssertNotNil(engine.lastSyncedAt)
    }

    // MARK: Interrupted request is retried, not lost

    func testInterruptedRequestRetries() async {
        let mock = MockSyncAPI()
        let engine = SyncEngine(api: mock, outbox: SyncOutbox(directory: tempDir()))
        engine.outbox.enqueue(.object, id: "A", operation: .create, payload: try? JSONEncoder().encode(objectRequest(id: "A")))

        // First attempt: network drops mid-request.
        mock.createObjectHandler = { _ in throw URLError(.networkConnectionLost) }
        await engine.flush()
        XCTAssertEqual(engine.pendingCount, 1, "change is kept for retry")
        XCTAssertEqual(engine.status, .offline)
        XCTAssertEqual(engine.outbox.all().first?.attemptCount, 1)

        // Connectivity returns: retry succeeds.
        mock.createObjectHandler = nil
        await engine.flush()
        XCTAssertEqual(engine.pendingCount, 0)
        XCTAssertEqual(mock.createObjectCount, 2)
        XCTAssertEqual(engine.status, .idle)
    }

    // MARK: Auth failure keeps data and asks for sign-in

    func testAuthFailureKeepsChanges() async {
        let mock = MockSyncAPI()
        let engine = SyncEngine(api: mock, outbox: SyncOutbox(directory: tempDir()))
        engine.outbox.enqueue(.object, id: "A", operation: .create, payload: try? JSONEncoder().encode(objectRequest(id: "A")))

        mock.createObjectHandler = { _ in throw APIError.unauthorized }
        await engine.flush()

        XCTAssertEqual(engine.status, .authRequired)
        XCTAssertEqual(engine.pendingCount, 1, "unsynced work is preserved through an auth failure")
    }

    // MARK: Conflicting create becomes an update (no duplicate record)

    func testDuplicateCreateFallsBackToUpdate() async {
        let mock = MockSyncAPI()
        let engine = SyncEngine(api: mock, outbox: SyncOutbox(directory: tempDir()))
        engine.outbox.enqueue(.object, id: "A", operation: .create, payload: try? JSONEncoder().encode(objectRequest(id: "A")))

        // Server rejects the create because the id already exists (PK violation -> 500).
        mock.createObjectHandler = { _ in throw APIError.serverError(500) }

        await engine.flush()

        XCTAssertEqual(mock.createObjectCount, 1)
        XCTAssertEqual(mock.updateObjectCount, 1, "duplicate create is resolved as an update")
        XCTAssertEqual(engine.pendingCount, 0, "no duplicate left queued")
        XCTAssertEqual(engine.status, .idle)
    }

    func testUpdateOfMissingRecordFallsBackToCreate() async {
        let mock = MockSyncAPI()
        let engine = SyncEngine(api: mock, outbox: SyncOutbox(directory: tempDir()))
        engine.outbox.enqueue(.object, id: "A", operation: .update, payload: try? JSONEncoder().encode(objectRequest(id: "A")))

        mock.updateObjectHandler = { _ in throw APIError.serverError(404) }
        await engine.flush()

        XCTAssertEqual(mock.updateObjectCount, 1)
        XCTAssertEqual(mock.createObjectCount, 1, "updating a missing record creates it")
        XCTAssertEqual(engine.pendingCount, 0)
    }

    func testDeleteOfMissingRecordIsSuccess() async {
        let mock = MockSyncAPI()
        let engine = SyncEngine(api: mock, outbox: SyncOutbox(directory: tempDir()))
        engine.outbox.enqueue(.object, id: "A", operation: .delete, payload: nil)

        mock.deleteObjectHandler = { _ in throw APIError.serverError(404) }
        await engine.flush()

        XCTAssertEqual(engine.pendingCount, 0, "already-deleted record clears cleanly")
        XCTAssertEqual(engine.status, .idle)
    }

    // MARK: Coalescing avoids duplicate work

    func testCreateThenUpdateCoalesceToSingleCreate() {
        let outbox = SyncOutbox(directory: tempDir())
        outbox.enqueue(.object, id: "A", operation: .create, payload: Data("v1".utf8))
        outbox.enqueue(.object, id: "A", operation: .update, payload: Data("v2".utf8))

        XCTAssertEqual(outbox.count, 1)
        let change = outbox.all().first
        XCTAssertEqual(change?.operation, .create, "still a create")
        XCTAssertEqual(change?.payload, Data("v2".utf8), "carries the latest content")
    }

    func testCreateThenDeleteRemovesEverything() {
        let outbox = SyncOutbox(directory: tempDir())
        outbox.enqueue(.object, id: "A", operation: .create, payload: Data("v1".utf8))
        outbox.enqueue(.object, id: "A", operation: .delete, payload: nil)
        XCTAssertEqual(outbox.count, 0, "a never-synced create that is deleted needs no server call")
    }

    func testUpdateThenDeleteBecomesDelete() {
        let outbox = SyncOutbox(directory: tempDir())
        outbox.enqueue(.object, id: "A", operation: .update, payload: Data("v1".utf8))
        outbox.enqueue(.object, id: "A", operation: .delete, payload: nil)
        XCTAssertEqual(outbox.count, 1)
        XCTAssertEqual(outbox.all().first?.operation, .delete)
    }

    // MARK: Multiple records flush independently

    func testMixedEntitiesAllPush() async {
        let mock = MockSyncAPI()
        let engine = SyncEngine(api: mock, outbox: SyncOutbox(directory: tempDir()))
        engine.outbox.enqueue(.object, id: "A", operation: .create, payload: try? JSONEncoder().encode(objectRequest(id: "A")))
        engine.outbox.enqueue(.object, id: "B", operation: .delete, payload: nil)

        await engine.flush()
        XCTAssertEqual(mock.createObjectCount, 1)
        XCTAssertEqual(mock.deleteObjectCount, 1)
        XCTAssertEqual(engine.pendingCount, 0)
    }
}
