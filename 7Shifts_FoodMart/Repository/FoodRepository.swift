import Foundation

/// Repository layer that abstracts data fetching from the ViewModel.
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

    /// Fetches both items and categories concurrently for better performance.
    /// Uses `async let` to run both requests in parallel.
    func fetchAllData() async throws -> (items: [FoodItem], categories: [FoodCategory]) {
        async let items = fetchFoodItems()
        async let categories = fetchCategories()

        return try await (items: items, categories: categories)
    }
}
