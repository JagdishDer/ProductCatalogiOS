import SwiftUI

struct ProductListView: View {
    private let token: String
    private let onLogout: () -> Void
    @StateObject private var viewModel: ProductListViewModel

    init(token: String, onLogout: @escaping () -> Void) {
        self.token = token
        self.onLogout = onLogout
        _viewModel = StateObject(
            wrappedValue: ProductListViewModel(api: DummyJSONClient(token: token))
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.products.isEmpty {
                    ProgressView("Loading products...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.loadError,
                          viewModel.products.isEmpty {
                    VStack(spacing: 16) {
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.red)
                        Button("Retry") {
                            Task { await viewModel.loadProducts() }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.products.isEmpty {
                    Text("No products found")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.products) { product in
                            NavigationLink {
                                ProductDetailView(id: product.id, token: token)
                            } label: {
                                ProductRow(product: product)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    Task {
                                        await viewModel.deleteProduct(id: product.id)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .disabled(viewModel.deletingIDs.contains(product.id))
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.loadProducts()
                    }
                }
            }
            .navigationTitle("Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout", action: onLogout)
                }
            }
            .task {
                await viewModel.loadProducts()
            }
            .alert("Delete failed", isPresented: $viewModel.showDeleteError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.deleteErrorMessage)
            }
        }
    }
}

private struct ProductRow: View {
    let product: Product

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: product.thumbnail ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .empty:
                    ProgressView()
                case .failure:
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                @unknown default:
                    Image(systemName: "photo")
                }
            }
            .frame(width: 64, height: 64)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(product.category.replacingOccurrences(of: "-", with: " ").capitalized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
}
