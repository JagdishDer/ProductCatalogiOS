import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

enum CatalogAPIError: LocalizedError {
    case invalidResponse
    case invalidProductID
    case httpError(status: Int, message: String?)
    case invalidDeleteResponse

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid response."
        case .invalidProductID:
            return "Invalid product ID."
        case let .httpError(status, message):
            if let message, !message.isEmpty {
                return message
            }
            return "Request failed (HTTP \(status))."
        case .invalidDeleteResponse:
            return "The server did not confirm deletion."
        }
    }
}

struct DummyJSONClient {
    private let token: String?
    private let session: URLSession
    private let baseURL = URL(string: "https://dummyjson.com")!

    init(token: String? = nil, session: URLSession = .shared) {
        self.token = token
        self.session = session
    }

    private func request<Response: Decodable>(
        _ path: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> Response {
        guard let url = URL(string: path, relativeTo: baseURL)?.absoluteURL else {
            throw CatalogAPIError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CatalogAPIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let serverError = try? JSONDecoder().decode(ServerError.self, from: data)
            throw CatalogAPIError.httpError(
                status: httpResponse.statusCode,
                message: serverError?.message
            )
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }

    func login(username: String, password: String) async throws -> LoginResponse {
        let body = try JSONEncoder().encode(
            LoginRequest(
                username: username,
                password: password,
                expiresInMins: 60
            )
        )
        return try await request("/auth/login", method: "POST", body: body)
    }

    func getProducts() async throws -> ProductListResponse {
        try await request("/products?limit=30&skip=0")
    }

    func getProduct(id: Int) async throws -> Product {
        guard id > 0 else { throw CatalogAPIError.invalidProductID }
        return try await request("/products/\(id)")
    }

    func deleteProduct(id: Int) async throws {
        guard id > 0 else { throw CatalogAPIError.invalidProductID }
        let result: DeleteProductResponse = try await request(
            "/products/\(id)",
            method: "DELETE"
        )
        guard result.id == id, result.isDeleted else {
            throw CatalogAPIError.invalidDeleteResponse
        }
    }
}
