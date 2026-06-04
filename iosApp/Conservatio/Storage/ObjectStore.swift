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
        Task { await syncCreatedObject(object) }
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
        Task { try? await APIClient.shared.deleteObject(id: object.id.uuidString) }
    }

    @MainActor
    func syncFromServer() async {
        guard APIClient.shared.isLoggedIn else { return }
        do {
            let serverObjects = try await APIClient.shared.fetchObjects()
            objects = serverObjects.compactMap { $0.conservationObject }
            save()
        } catch {
            print("Failed to sync objects: \(error)")
        }
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

    private func syncCreatedObject(_ object: ConservationObject) async {
        guard APIClient.shared.isLoggedIn else { return }
        let request = CreateObjectRequest(
            id: object.id.uuidString,
            title: object.title,
            objectType: object.objectType.rawValue,
            materials: object.materials,
            height: object.dimensions?.height,
            width: object.dimensions?.width,
            depth: object.dimensions?.depth,
            measurementUnit: object.dimensions?.unit.displayName,
            ownerName: object.ownerName,
            locationDescription: object.locationDescription,
            inventoryNumber: object.inventoryNumber,
            description: object.description,
            imageIds: object.imageIds
        )
        _ = try? await APIClient.shared.createObject(request)
    }
}

private extension ServerObject {
    var conservationObject: ConservationObject? {
        guard let uuid = UUID(uuidString: id) else { return nil }
        return ConservationObject(
            id: uuid,
            title: title,
            objectType: ObjectType(rawValue: objectType) ?? .other,
            materials: materials ?? [],
            dimensions: Dimensions(
                height: height,
                width: width,
                depth: depth,
                unit: MeasurementUnit(displayName: measurementUnit)
            ),
            ownerName: ownerName,
            locationDescription: locationDescription,
            inventoryNumber: inventoryNumber,
            description: description,
            imageIds: imageIds ?? [],
            createdAt: Date.apiDate(createdAt),
            updatedAt: Date.apiDate(updatedAt)
        )
    }
}

private extension MeasurementUnit {
    init(displayName: String?) {
        switch displayName {
        case "m", "M": self = .m
        case "in", "INCH": self = .inch
        case "mm", "MM": self = .mm
        default: self = .cm
        }
    }
}

private extension Date {
    static func apiDate(_ value: String?) -> Date {
        guard let value else { return Date() }
        return ISO8601DateFormatter().date(from: value) ?? Date()
    }
}
