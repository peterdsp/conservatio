import Foundation

enum ProjectStatus: String, CaseIterable, Codable {
    case inquiry = "Inquiry"
    case quoted = "Quoted"
    case approved = "Approved"
    case inProgress = "In Progress"
    case onHold = "On Hold"
    case completed = "Completed"
    case archived = "Archived"

    var icon: String {
        switch self {
        case .inquiry: return "questionmark.circle"
        case .quoted: return "doc.text"
        case .approved: return "checkmark.circle"
        case .inProgress: return "hammer"
        case .onHold: return "pause.circle"
        case .completed: return "checkmark.seal"
        case .archived: return "archivebox"
        }
    }
}

struct Project: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String = ""
    var clientName: String = ""
    var status: ProjectStatus = .inquiry
    var objectIds: [String] = []
    var startDate: Date?
    var endDate: Date?
    var budget: Double?
    var currency: String = "EUR"
    var description: String = ""
    var createdAt: Date = Date()
}
