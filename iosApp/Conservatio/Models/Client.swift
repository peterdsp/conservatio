import Foundation

enum ClientType: String, CaseIterable, Codable {
    case privateCollector = "Private Collector"
    case museum = "Museum"
    case gallery = "Gallery"
    case church = "Church"
    case monastery = "Monastery"
    case municipality = "Municipality"
    case archaeologicalService = "Archaeological Service"
    case university = "University"
    case foundation = "Foundation"
    case architect = "Architect"
    case insuranceCompany = "Insurance Company"
    case other = "Other"

    var icon: String {
        switch self {
        case .privateCollector: return "person"
        case .museum: return "building.columns"
        case .gallery: return "photo.artframe"
        case .church: return "cross"
        case .monastery: return "building"
        case .municipality: return "building.2"
        case .archaeologicalService: return "map"
        case .university: return "graduationcap"
        case .foundation: return "hands.clap"
        case .architect: return "ruler"
        case .insuranceCompany: return "shield"
        case .other: return "person.crop.circle"
        }
    }
}

struct Client: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String = ""
    var type: ClientType = .other
    var contactPerson: String = ""
    var email: String = ""
    var phone: String = ""
    var address: String = ""
    var notes: String = ""
    var createdAt: Date = Date()
}
