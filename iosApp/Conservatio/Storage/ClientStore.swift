import Foundation
import SwiftUI

@Observable
class ClientStore {
    var clients: [Client] = []

    private let fileName = "clients.json"

    init() { load() }

    @MainActor
    func add(_ client: Client) {
        clients.append(client)
        save()
        SyncEngine.shared.enqueue(.client, id: client.id, operation: .create, body: Self.request(for: client))
    }

    @MainActor
    func delete(id: String) {
        clients.removeAll { $0.id == id }
        save()
        SyncEngine.shared.enqueueDelete(.client, id: id)
    }

    @MainActor
    func update(_ client: Client) {
        guard let index = clients.firstIndex(where: { $0.id == client.id }) else { return }
        var updated = client
        updated.updatedAt = Date()
        clients[index] = updated
        save()
        SyncEngine.shared.enqueue(.client, id: updated.id, operation: .update, body: Self.request(for: updated))
    }

    /// Pushes pending changes, then pulls and merges. Local wins where a change
    /// is pending or the record is local-only, so unsynced edits survive.
    @MainActor
    func syncFromServer() async {
        guard APIClient.shared.isLoggedIn else { return }
        await SyncEngine.shared.flush()
        do {
            let serverClients = try await APIClient.shared.fetchClients()
            merge(serverClients.map { $0.client })
            save()
        } catch {
            print("Failed to pull clients: \(error)")
        }
    }

    @MainActor
    private func merge(_ serverClients: [Client]) {
        var byId: [String: Client] = [:]
        for server in serverClients { byId[server.id] = server }
        for local in clients where SyncEngine.shared.hasPending(.client, id: local.id) || byId[local.id] == nil {
            byId[local.id] = local
        }
        clients = byId.values.sorted { $0.updatedAt > $1.updatedAt }
    }

    static func request(for client: Client) -> CreateClientRequest {
        CreateClientRequest(
            id: client.id,
            name: client.name,
            type: client.type.rawValue,
            contactPerson: client.contactPerson.isEmpty ? nil : client.contactPerson,
            email: client.email.isEmpty ? nil : client.email,
            phone: client.phone.isEmpty ? nil : client.phone,
            address: client.address.isEmpty ? nil : client.address,
            notes: client.notes.isEmpty ? nil : client.notes
        )
    }

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(clients)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save clients: \(error)")
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            clients = try JSONDecoder().decode([Client].self, from: data)
        } catch {
            print("Failed to load clients: \(error)")
        }
    }
}

private extension ServerClient {
    var client: Client {
        let formatter = ISO8601DateFormatter()
        return Client(
            id: id,
            name: name,
            type: ClientType(rawValue: type) ?? .other,
            contactPerson: contactPerson ?? "",
            email: email ?? "",
            phone: phone ?? "",
            address: address ?? "",
            notes: notes ?? "",
            createdAt: formatter.date(from: createdAt ?? "") ?? Date(),
            updatedAt: formatter.date(from: updatedAt ?? "") ?? Date()
        )
    }
}
