import Foundation
import SwiftUI

@Observable
class ProjectStore {
    var projects: [Project] = []

    private let fileName = "projects.json"

    init() { load() }

    @MainActor
    func add(_ project: Project) {
        projects.append(project)
        save()
        SyncEngine.shared.enqueue(.project, id: project.id, operation: .create, body: Self.request(for: project))
    }

    @MainActor
    func delete(id: String) {
        projects.removeAll { $0.id == id }
        save()
        SyncEngine.shared.enqueueDelete(.project, id: id)
    }

    @MainActor
    func update(_ project: Project) {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else { return }
        var updated = project
        updated.updatedAt = Date()
        projects[index] = updated
        save()
        SyncEngine.shared.enqueue(.project, id: updated.id, operation: .update, body: Self.request(for: updated))
    }

    /// Pushes pending changes, then pulls and merges. Local wins where a change
    /// is pending or the record is local-only, so unsynced edits survive.
    @MainActor
    func syncFromServer() async {
        guard APIClient.shared.isLoggedIn else { return }
        await SyncEngine.shared.flush()
        do {
            let serverProjects = try await APIClient.shared.fetchProjects()
            merge(serverProjects.map { $0.project })
            save()
        } catch {
            print("Failed to pull projects: \(error)")
        }
    }

    @MainActor
    private func merge(_ serverProjects: [Project]) {
        var byId: [String: Project] = [:]
        for server in serverProjects { byId[server.id] = server }
        for local in projects where SyncEngine.shared.hasPending(.project, id: local.id) || byId[local.id] == nil {
            byId[local.id] = local
        }
        projects = byId.values.sorted { $0.updatedAt > $1.updatedAt }
    }

    static func request(for project: Project) -> CreateProjectRequest {
        let formatter = ISO8601DateFormatter()
        return CreateProjectRequest(
            id: project.id,
            title: project.title,
            // The local model stores a free-text client name, while the server
            // expects a client id reference; until a client is linked by id we
            // leave this nil rather than send an invalid reference.
            clientId: nil,
            objectIds: project.objectIds,
            status: project.status.rawValue,
            startDate: project.startDate.map { formatter.string(from: $0) },
            endDate: project.endDate.map { formatter.string(from: $0) },
            description: project.description.isEmpty ? nil : project.description,
            totalBudget: project.budget,
            currency: project.currency
        )
    }

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(projects)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save projects: \(error)")
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            projects = try JSONDecoder().decode([Project].self, from: data)
        } catch {
            print("Failed to load projects: \(error)")
        }
    }
}

#if DEBUG
extension ProjectStore {
    /// A handful of projects across the statuses, for screenshots and manual
    /// testing.
    func loadSampleProjects() {
        let day: TimeInterval = 86_400
        let now = Date()
        projects = [
            Project(title: "Iconostasis survey, Agios Nikolaos", clientName: "Agios Nikolaos Church",
                    status: .inProgress, startDate: now.addingTimeInterval(-21 * day),
                    endDate: now.addingTimeInterval(40 * day), budget: 4800,
                    description: "Condition survey of the iconostasis and its panel icons before the winter closure.",
                    createdAt: now.addingTimeInterval(-25 * day)),
            Project(title: "Lekythos reassembly", clientName: "Municipal Collection",
                    status: .approved, startDate: now.addingTimeInterval(7 * day), budget: 1250,
                    description: "Remove the yellowed adhesive and rejoin the fragments.",
                    createdAt: now.addingTimeInterval(-12 * day)),
            Project(title: "Marble relief desalination", clientName: "Municipal Collection",
                    status: .quoted, budget: 2100,
                    description: "Poultice desalination and removal of the iron pin.",
                    createdAt: now.addingTimeInterval(-9 * day)),
            Project(title: "Textile remounting", clientName: "Private collection",
                    status: .inquiry,
                    description: "Remount the silk fragment on an inert support.",
                    createdAt: now.addingTimeInterval(-3 * day)),
            Project(title: "Gospel leaf consolidation", clientName: "Monastery library",
                    status: .completed, startDate: now.addingTimeInterval(-90 * day),
                    endDate: now.addingTimeInterval(-30 * day), budget: 900,
                    description: "Flaking pigment consolidated and the leaf housed in a folder.",
                    createdAt: now.addingTimeInterval(-95 * day)),
        ]
        save()
    }
}
#endif

private extension ServerProject {
    var project: Project {
        let formatter = ISO8601DateFormatter()
        return Project(
            id: id,
            title: title,
            // The server tracks a client id, not the local free-text name.
            clientName: "",
            status: ProjectStatus(rawValue: status) ?? .inquiry,
            objectIds: objectIds,
            startDate: startDate.flatMap { formatter.date(from: $0) },
            endDate: endDate.flatMap { formatter.date(from: $0) },
            budget: totalBudget,
            currency: currency ?? "EUR",
            description: description ?? "",
            createdAt: formatter.date(from: createdAt ?? "") ?? Date(),
            updatedAt: formatter.date(from: updatedAt ?? "") ?? Date()
        )
    }
}
