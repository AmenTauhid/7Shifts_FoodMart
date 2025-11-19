import Foundation

/// Represents a food category from the API.
/// Used for filtering food items by category.
struct FoodCategory: Identifiable, Codable, Sendable {
    let id: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
    }
}
