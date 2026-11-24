import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var accessToken: String?
    @Published private(set) var isLoggingIn = false
    @Published var errorMessage: String?

    private let api = DummyJSONClient()

    func login(username: String, password: String) async {
        guard !isLoggingIn else { return }

        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter a username and password."
            return
        }

        errorMessage = nil
        isLoggingIn = true
        defer { isLoggingIn = false }

        do {
            let response = try await api.login(
                username: trimmedUsername,
                password: password
            )
            guard !response.accessToken.isEmpty else {
                throw CatalogAPIError.invalidResponse
            }
            accessToken = response.accessToken
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        accessToken = nil
        errorMessage = nil
    }
}
