import Foundation

final class FoodRepository: FoodRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func fetchFoodItems() async throws -> [FoodItem] {
        try await networkService.fetch(from: APIEndpoints.foodItems)
    }

    func fetchCategories() async throws -> [FoodCategory] {
        try await networkService.fetch(from: APIEndpoints.categories)
    }

    func fetchAllData() async throws -> (items: [FoodItem], categories: [FoodCategory]) {
        async let items = fetchFoodItems()
        async let categories = fetchCategories()

        return try await (items: items, categories: categories)
    }
}
