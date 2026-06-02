import Foundation
import SwiftUI

@Observable
class ClientStore {
    var clients: [Client] = []

    private let fileName = "clients.json"

    init() { load() }

    func add(_ client: Client) {
        clients.append(client)
        save()
    }

    func delete(id: String) {
        clients.removeAll { $0.id == id }
        save()
    }

    func update(_ client: Client) {
        if let index = clients.firstIndex(where: { $0.id == client.id }) {
            clients[index] = client
            save()
        }
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
