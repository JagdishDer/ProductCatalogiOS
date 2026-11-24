import Foundation

struct Product: Identifiable, Decodable, Equatable {
    let id: Int
    let title: String
    let category: String
    let thumbnail: String?
    let description: String?
    let price: Double?
}

struct ProductListResponse: Decodable {
    let products: [Product]
    let total: Int
}

struct DeleteProductResponse: Decodable {
    let id: Int
    let isDeleted: Bool
}
