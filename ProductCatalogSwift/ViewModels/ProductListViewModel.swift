import Foundation
import Combine

@MainActor
final class ProductListViewModel: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var deletingIDs = Set<Int>()
    @Published var loadError: String?
    @Published var deleteErrorMessage = ""
    @Published var showDeleteError = false

    private let api: DummyJSONClient
    private var deletedIDs = Set<Int>()

    init(api: DummyJSONClient) {
        self.api = api
    }

    func loadProducts() async {
        guard !isLoading else { return }
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        do {
            let response = try await api.getProducts()
            // DummyJSON simulates DELETE and doesn't persist it.
            products = response.products.filter { !deletedIDs.contains($0.id) }
        } catch {
            loadError = error.localizedDescription
        }
    }

    func deleteProduct(id: Int) async {
        guard !deletingIDs.contains(id) else { return }
        deletingIDs.insert(id)
        defer { deletingIDs.remove(id) }

        do {
            try await api.deleteProduct(id: id)
            deletedIDs.insert(id)
            products.removeAll { $0.id == id }
        } catch {
            deleteErrorMessage = error.localizedDescription
            showDeleteError = true
        }
    }
}
