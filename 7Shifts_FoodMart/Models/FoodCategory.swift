import Foundation

struct FoodCategory: Identifiable, Codable {
    let id: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
    }
}
