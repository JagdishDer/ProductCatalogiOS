import Foundation

struct LoginRequest: Encodable {
    let username: String
    let password: String
    let expiresInMins: Int
}

struct LoginResponse: Decodable {
    let accessToken: String
}

struct ServerError: Decodable {
    let message: String?
}
