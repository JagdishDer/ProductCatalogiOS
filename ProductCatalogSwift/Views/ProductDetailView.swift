import SwiftUI

struct ProductDetailView: View {
    let id: Int
    let token: String

    @State private var product: Product?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading product details...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage {
                VStack(spacing: 16) {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await loadDetail() }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let product {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        AsyncImage(url: URL(string: product.thumbnail ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFit()
                            case .empty:
                                ProgressView()
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                            @unknown default:
                                Image(systemName: "photo")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 260)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        Text(product.title)
                            .font(.title2.bold())

                        Text("Category: \(product.category.capitalized)")
                            .foregroundStyle(.secondary)

                        if let price = product.price {
                            Text(price, format: .currency(code: "USD"))
                                .font(.title3.bold())
                        }

                        Text(product.description ?? "No description available.")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: id) {
            await loadDetail()
        }
    }

    @MainActor
    private func loadDetail() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            // Separate GET /products/{id}; never rely only on list data.
            product = try await DummyJSONClient(token: token).getProduct(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
