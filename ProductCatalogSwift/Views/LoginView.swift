import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel

    @State private var username = ""
    @State private var password = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer()

            Image(systemName: "shippingbox.fill")
                .font(.system(size: 46))
                .foregroundStyle(.blue)
                .frame(maxWidth: .infinity)

            Text("Product Catalog")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity)

            Text("Sign in to see products")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            TextField("Username", text: $username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.username)
                .textFieldStyle(.roundedBorder)
                .disabled(viewModel.isLoggingIn)

            SecureField("Password", text: $password)
                .textContentType(.password)
                .textFieldStyle(.roundedBorder)
                .disabled(viewModel.isLoggingIn)
                .onSubmit { signIn() }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .accessibilityIdentifier("loginError")
            }

            Button(action: signIn) {
                Group {
                    if viewModel.isLoggingIn {
                        ProgressView().tint(.white)
                    } else {
                        Text("Sign In").bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 36)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoggingIn)

            Text("Demo: emilys / emilyspass")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            Spacer()
            Spacer()
        }
        .padding(24)
    }

    private func signIn() {
        Task {
            await viewModel.login(username: username, password: password)
        }
    }
}
