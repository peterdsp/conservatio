import Foundation

struct ConservationObject: Identifiable, Codable {
    let id: UUID
    var title: String
    var objectType: ObjectType
    var materials: [String]
    var dimensions: Dimensions?
    var ownerName: String?
    var locationDescription: String?
    var acquisitionDate: Date?
    var inventoryNumber: String?
    var description: String?
    var imageIds: [String]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String = "",
        objectType: ObjectType = .other,
        materials: [String] = [],
        dimensions: Dimensions? = nil,
        ownerName: String? = nil,
        locationDescription: String? = nil,
        acquisitionDate: Date? = nil,
        inventoryNumber: String? = nil,
        description: String? = nil,
        imageIds: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.objectType = objectType
        self.materials = materials
        self.dimensions = dimensions
        self.ownerName = ownerName
        self.locationDescription = locationDescription
        self.acquisitionDate = acquisitionDate
        self.inventoryNumber = inventoryNumber
        self.description = description
        self.imageIds = imageIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum ObjectType: String, Codable, CaseIterable, Identifiable {
    case painting = "PAINTING"
    case icon = "ICON"
    case wallPainting = "WALL_PAINTING"
    case sculpture = "SCULPTURE"
    case ceramic = "CERAMIC"
    case metal = "METAL"
    case textile = "TEXTILE"
    case paper = "PAPER"
    case wood = "WOOD"
    case stone = "STONE"
    case glass = "GLASS"
    case mosaic = "MOSAIC"
    case archaeologicalFind = "ARCHAEOLOGICAL_FIND"
    case furniture = "FURNITURE"
    case other = "OTHER"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .painting: return "Painting"
        case .icon: return "Icon"
        case .wallPainting: return "Wall Painting"
        case .sculpture: return "Sculpture"
        case .ceramic: return "Ceramic"
        case .metal: return "Metal"
        case .textile: return "Textile"
        case .paper: return "Paper"
        case .wood: return "Wood"
        case .stone: return "Stone"
        case .glass: return "Glass"
        case .mosaic: return "Mosaic"
        case .archaeologicalFind: return "Archaeological Find"
        case .furniture: return "Furniture"
        case .other: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .painting: return "paintbrush"
        case .icon: return "photo.artframe"
        case .wallPainting: return "rectangle.split.3x3"
        case .sculpture: return "figure.stand"
        case .ceramic: return "cup.and.saucer"
        case .metal: return "hammer"
        case .textile: return "tshirt"
        case .paper: return "doc.text"
        case .wood: return "leaf"
        case .stone: return "mountain.2"
        case .glass: return "sparkles"
        case .mosaic: return "square.grid.3x3"
        case .archaeologicalFind: return "fossil.shell"
        case .furniture: return "chair"
        case .other: return "questionmark.circle"
        }
    }
}

struct Dimensions: Codable {
    var height: Double?
    var width: Double?
    var depth: Double?
    var diameter: Double?
    var weight: Double?
    var unit: MeasurementUnit

    init(
        height: Double? = nil,
        width: Double? = nil,
        depth: Double? = nil,
        diameter: Double? = nil,
        weight: Double? = nil,
        unit: MeasurementUnit = .cm
    ) {
        self.height = height
        self.width = width
        self.depth = depth
        self.diameter = diameter
        self.weight = weight
        self.unit = unit
    }
}

enum MeasurementUnit: String, Codable, CaseIterable {
    case cm = "CM"
    case mm = "MM"
    case m = "M"
    case inch = "INCH"
    case kg = "KG"
    case g = "G"

    var displayName: String {
        switch self {
        case .cm: return "cm"
        case .mm: return "mm"
        case .m: return "m"
        case .inch: return "in"
        case .kg: return "kg"
        case .g: return "g"
        }
    }
}
