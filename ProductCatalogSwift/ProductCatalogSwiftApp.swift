import SwiftUI

@main
struct ProductCatalogSwiftApp: App {
    @StateObject private var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if let token = auth.accessToken {
                    ProductListView(
                        token: token,
                        onLogout: { auth.logout() }
                    )
                } else {
                    LoginView(viewModel: auth)
                }
            }
        }
    }
}
