import Foundation

/// Protocol defining data access operations for food items and categories.
/// Enables dependency injection for testing with mock implementations.
protocol FoodRepositoryProtocol {
    func fetchFoodItems() async throws -> [FoodItem]
    func fetchCategories() async throws -> [FoodCategory]
    func fetchAllData() async throws -> (items: [FoodItem], categories: [FoodCategory])
}
