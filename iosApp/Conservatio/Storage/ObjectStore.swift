import Foundation
#if DEBUG
import UIKit
#endif

@Observable
class ObjectStore {
    private(set) var objects: [ConservationObject] = []
    private let fileURL: URL

    /// Whether the user is signed in and therefore able to sync with the server.
    var isSignedIn: Bool { APIClient.shared.isLoggedIn }

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = docs.appendingPathComponent("conservation_objects.json")
        load()
    }

    @MainActor
    func add(_ object: ConservationObject) {
        objects.insert(object, at: 0)
        save()
        SyncEngine.shared.enqueue(.object, id: object.id.uuidString, operation: .create, body: Self.request(for: object))
    }

    @MainActor
    func update(_ object: ConservationObject) {
        guard let index = objects.firstIndex(where: { $0.id == object.id }) else { return }
        var updated = object
        updated.updatedAt = Date()
        objects[index] = updated
        save()
        SyncEngine.shared.enqueue(.object, id: updated.id.uuidString, operation: .update, body: Self.request(for: updated))
    }

    @MainActor
    func delete(_ object: ConservationObject) {
        objects.removeAll { $0.id == object.id }
        save()
        SyncEngine.shared.enqueueDelete(.object, id: object.id.uuidString)
    }

    /// Pushes any pending local changes, then pulls the server and merges.
    /// Records with unpushed local edits, and records that only exist locally,
    /// are kept, so a pull never discards the user's unsynced work.
    @MainActor
    func syncFromServer() async {
        guard APIClient.shared.isLoggedIn else { return }
        await SyncEngine.shared.flush()
        do {
            let serverObjects = try await APIClient.shared.fetchObjects()
            merge(serverObjects.compactMap { $0.conservationObject })
            save()
        } catch {
            print("Failed to pull objects: \(error)")
        }
    }

    /// Merge policy: local wins for records with a pending change or that the
    /// server does not have; the server version is taken otherwise. Local-only
    /// records are never deleted by a pull.
    @MainActor
    private func merge(_ serverObjects: [ConservationObject]) {
        var byId: [UUID: ConservationObject] = [:]
        for server in serverObjects { byId[server.id] = server }
        for local in objects where SyncEngine.shared.hasPending(.object, id: local.id.uuidString) || byId[local.id] == nil {
            byId[local.id] = local
        }
        objects = byId.values.sorted { $0.updatedAt > $1.updatedAt }
    }

    static func request(for object: ConservationObject) -> CreateObjectRequest {
        CreateObjectRequest(
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
            imageIds: object.imageIds,
            latitude: object.latitude,
            longitude: object.longitude
        )
    }

    func object(for id: UUID) -> ConservationObject? {
        objects.first { $0.id == id }
    }

    func clearAllData() {
        objects = []
        save()
    }

    func loadSampleData() {
        objects = [
            ConservationObject(
                title: "Icon of the Virgin Hodegetria",
                objectType: .icon,
                materials: ["egg tempera", "gold leaf", "poplar panel"],
                dimensions: Dimensions(height: 38.5, width: 28.6, depth: 2.2),
                ownerName: "Agios Nikolaos Church",
                locationDescription: "North nave storage cabinet",
                inventoryNumber: "CN-1842-07",
                description: "Panel icon with edge abrasions, localized flaking, and surface grime requiring initial assessment."
            ),
            ConservationObject(
                title: "Black-figure lekythos",
                objectType: .ceramic,
                materials: ["terracotta", "black slip"],
                dimensions: Dimensions(height: 31.2, diameter: 10.4),
                ownerName: "Municipal Collection",
                locationDescription: "Case A, gallery 1",
                inventoryNumber: "MC-04-022",
                description: "Reassembled from fragments; old adhesive yellowing along the joins."
            ),
            ConservationObject(
                title: "Marble relief fragment",
                objectType: .stone,
                materials: ["Pentelic marble"],
                dimensions: Dimensions(height: 42.0, width: 31.0, depth: 9.5),
                ownerName: "Municipal Collection",
                locationDescription: "Stone store, shelf 3",
                inventoryNumber: "MC-11-305",
                description: "Head in high relief; surface sugaring and an old iron pin stain at the break."
            ),
            ConservationObject(
                title: "Bronze votive lamp",
                objectType: .metal,
                materials: ["bronze", "mineral deposits"],
                dimensions: Dimensions(height: 14.0, width: 9.5, depth: 21.0),
                ownerName: "Municipal Collection",
                locationDescription: "Case B, gallery 2",
                inventoryNumber: "MC-09-118",
                description: "Historic lamp with active corrosion checks pending before storage recommendation."
            ),
            ConservationObject(
                title: "Silk textile fragment",
                objectType: .textile,
                materials: ["silk", "metal thread"],
                dimensions: Dimensions(height: 27.0, width: 23.0),
                ownerName: "Private collection",
                locationDescription: "Studio, drawer 4",
                inventoryNumber: "PC-23-001",
                description: "Weakened weft and losses along the lower edge; mounted on acidic board."
            ),
            ConservationObject(
                title: "Gospel book leaf",
                objectType: .paper,
                materials: ["parchment", "ink", "gold leaf"],
                dimensions: Dimensions(height: 22.5, width: 16.0),
                ownerName: "Monastery library",
                locationDescription: "Manuscript room, folder 12",
                inventoryNumber: "ML-07-041",
                description: "Cockled parchment with flaking pigment on the evangelist figures."
            ),
            ConservationObject(
                title: "Carved iconostasis panel",
                objectType: .wood,
                materials: ["walnut", "gilding"],
                dimensions: Dimensions(height: 96.0, width: 54.0, depth: 6.0),
                ownerName: "Agios Nikolaos Church",
                locationDescription: "South aisle",
                inventoryNumber: "CN-1842-12",
                description: "Insect flight holes along the base and lifting gilding on the vine scroll."
            ),
        ]
        save()
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

#if DEBUG
extension ObjectStore {
    /// Photographs in Scripts/sample-photos (bundled into Debug builds only,
    /// see project.yml) by the inventory number of the sample object they
    /// show. credits.json beside them records title, author, licence and
    /// source.
    private static let samplePhotos: [String: String] = [
        "CN-1842-07": "icon",
        "MC-04-022": "ceramic",
        "MC-11-305": "marble",
        "MC-09-118": "lamp",
        "PC-23-001": "textile",
        "ML-07-041": "manuscript",
    ]

    /// Attaches the bundled photographs to the sample objects, for screenshots
    /// and manual testing of photo features.
    func attachSamplePhotos() {
        for index in objects.indices {
            guard let inventory = objects[index].inventoryNumber,
                  let name = Self.samplePhotos[inventory],
                  let url = Bundle.main.url(forResource: name, withExtension: "jpg", subdirectory: "sample-photos"),
                  let image = UIImage(contentsOfFile: url.path),
                  let id = ImageStore.shared.save(image) else { continue }
            objects[index].imageIds = [id]
        }
        save()
    }
}
#endif

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
            latitude: latitude,
            longitude: longitude,
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
