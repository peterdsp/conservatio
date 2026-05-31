import Foundation

@Observable
class ObjectStore {
    private(set) var objects: [ConservationObject] = []
    private let fileURL: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = docs.appendingPathComponent("conservation_objects.json")
        load()
    }

    func add(_ object: ConservationObject) {
        objects.insert(object, at: 0)
        save()
    }

    func update(_ object: ConservationObject) {
        if let index = objects.firstIndex(where: { $0.id == object.id }) {
            var updated = object
            updated.updatedAt = Date()
            objects[index] = updated
            save()
        }
    }

    func delete(_ object: ConservationObject) {
        objects.removeAll { $0.id == object.id }
        save()
    }

    func object(for id: UUID) -> ConservationObject? {
        objects.first { $0.id == id }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(objects)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save objects: \(error)")
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            objects = try JSONDecoder().decode([ConservationObject].self, from: data)
        } catch {
            print("Failed to load objects: \(error)")
        }
    }
}
