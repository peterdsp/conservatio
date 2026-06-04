import Foundation

@Observable
class APIClient {
    static let shared = APIClient()

    var baseURL: String {
        get { UserDefaults.standard.string(forKey: "serverURL") ?? "https://api.conservatio.peterdsp.dev" }
        set { UserDefaults.standard.set(newValue, forKey: "serverURL") }
    }

    var token: String? {
        get { UserDefaults.standard.string(forKey: "authToken") }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: "authToken")
            } else {
                UserDefaults.standard.removeObject(forKey: "authToken")
            }
        }
    }

    var isLoggedIn: Bool { token != nil }

    // MARK: - Auth

    func register(email: String, password: String, name: String) async throws {
        let body: [String: String] = ["email": email, "password": password, "displayName": name]
        let response: AuthResponse = try await post("/api/auth/register", body: body)
        token = response.token
    }

    func login(email: String, password: String) async throws {
        let body: [String: String] = ["email": email, "password": password]
        let response: AuthResponse = try await post("/api/auth/login", body: body)
        token = response.token
    }

    func socialLogin(provider: String, providerUserId: String, email: String?, name: String?, idToken: String?) async throws {
        let body: [String: String?] = [
            "provider": provider,
            "provider_user_id": providerUserId,
            "email": email,
            "name": name,
            "id_token": idToken
        ]
        let filtered = body.compactMapValues { $0 }
        let response: AuthResponse = try await post("/api/auth/social", body: filtered)
        token = response.token
    }

    func logout() {
        token = nil
    }

    // MARK: - Objects

    func fetchObjects() async throws -> [ServerObject] {
        try await get("/api/objects")
    }

    func createObject(_ object: CreateObjectRequest) async throws -> ServerObject {
        try await post("/api/objects", body: object)
    }

    func deleteObject(id: String) async throws {
        try await delete("/api/objects/\(id)")
    }

    func fetchClients() async throws -> [ServerClient] {
        try await get("/api/clients")
    }

    func createClient(_ client: CreateClientRequest) async throws -> ServerClient {
        try await post("/api/clients", body: client)
    }

    func fetchProjects() async throws -> [ServerProject] {
        try await get("/api/projects")
    }

    func createProject(_ project: CreateProjectRequest) async throws -> ServerProject {
        try await post("/api/projects", body: project)
    }

    func fetchReports() async throws -> [ServerReport] {
        try await get("/api/reports")
    }

    func createReport(_ report: CreateReportRequest) async throws {
        let _: EmptyResponse = try await post("/api/reports", body: report)
    }

    // MARK: - HTTP

    private func get<T: Decodable>(_ path: String) async throws -> T {
        var request = URLRequest(url: URL(string: baseURL + path)!)
        request.httpMethod = "GET"
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func post<B: Encodable, T: Decodable>(_ path: String, body: B) async throws -> T {
        var request = URLRequest(url: URL(string: baseURL + path)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func delete(_ path: String) async throws {
        var request = URLRequest(url: URL(string: baseURL + path)!)
        request.httpMethod = "DELETE"
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (_, response) = try await URLSession.shared.data(for: request)
        try checkResponse(response)
    }

    private func checkResponse(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        if http.statusCode == 401 {
            token = nil
            throw APIError.unauthorized
        }
        guard (200...299).contains(http.statusCode) else {
            throw APIError.serverError(http.statusCode)
        }
    }
}

enum APIError: LocalizedError {
    case unauthorized
    case serverError(Int)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .unauthorized: return "Session expired. Please log in again."
        case .serverError(let code): return "Server error (\(code))"
        case .networkError(let error): return error.localizedDescription
        }
    }
}

struct AuthResponse: Codable {
    let token: String
}

struct EmptyResponse: Codable {}

struct ServerObject: Codable, Identifiable {
    let id: String
    let title: String
    let objectType: String
    let materials: [String]?
    let height: Double?
    let width: Double?
    let depth: Double?
    let measurementUnit: String?
    let ownerName: String?
    let locationDescription: String?
    let inventoryNumber: String?
    let description: String?
    let imageIds: [String]?
    let createdAt: String?
    let updatedAt: String?
}

struct CreateObjectRequest: Codable {
    let id: String?
    let title: String
    let objectType: String
    let materials: [String]
    let height: Double?
    let width: Double?
    let depth: Double?
    let measurementUnit: String?
    let ownerName: String?
    let locationDescription: String?
    let inventoryNumber: String?
    let description: String?
    let imageIds: [String]
}

struct ServerClient: Codable, Identifiable {
    let id: String
    let name: String
    let type: String
    let contactPerson: String?
    let email: String?
    let phone: String?
    let address: String?
    let notes: String?
    let createdAt: String?
    let updatedAt: String?
}

struct CreateClientRequest: Codable {
    let id: String?
    let name: String
    let type: String
    let contactPerson: String?
    let email: String?
    let phone: String?
    let address: String?
    let notes: String?
}

struct ServerProject: Codable, Identifiable {
    let id: String
    let title: String
    let clientId: String?
    let objectIds: [String]
    let status: String
    let startDate: String?
    let endDate: String?
    let description: String?
    let totalBudget: Double?
    let currency: String?
    let createdAt: String?
    let updatedAt: String?
}

struct CreateProjectRequest: Codable {
    let id: String?
    let title: String
    let clientId: String?
    let objectIds: [String]
    let status: String
    let startDate: String?
    let endDate: String?
    let description: String?
    let totalBudget: Double?
    let currency: String?
}

struct ServerReport: Codable, Identifiable {
    let id: String
    let objectId: String
    let reportType: String
    let overallCondition: String
    let examiner: String
    let examinationDate: String
    let notes: String?
    let recommendations: String?
    let imageIds: [String]?
    let createdAt: String?
    let updatedAt: String?
}

struct CreateReportRequest: Codable {
    let id: String?
    let objectId: String
    let reportType: String
    let overallCondition: String
    let examiner: String
    let examinationDate: String
    let notes: String?
    let recommendations: String?
    let imageIds: [String]
}
