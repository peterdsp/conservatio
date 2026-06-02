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
        let body: [String: String] = ["email": email, "password": password, "name": name]
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

struct ServerObject: Codable, Identifiable {
    let id: String
    let title: String
    let objectType: String
    let materials: [String]?
    let ownerName: String?
    let locationDescription: String?
    let createdAt: String?
}

struct CreateObjectRequest: Codable {
    let title: String
    let objectType: String
    let materials: [String]
    let ownerName: String?
    let locationDescription: String?
    let inventoryNumber: String?
    let description: String?
}
