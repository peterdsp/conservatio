import Foundation
import SwiftUI

@Observable
class ProjectStore {
    var projects: [Project] = []

    private let fileName = "projects.json"

    init() { load() }

    func add(_ project: Project) {
        projects.append(project)
        save()
    }

    func delete(id: String) {
        projects.removeAll { $0.id == id }
        save()
    }

    func update(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            save()
        }
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
