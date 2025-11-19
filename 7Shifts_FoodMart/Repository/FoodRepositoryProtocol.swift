import Foundation

protocol FoodRepositoryProtocol {
    func fetchFoodItems() async throws -> [FoodItem]
    func fetchCategories() async throws -> [FoodCategory]
    func fetchAllData() async throws -> (items: [FoodItem], categories: [FoodCategory])
}
