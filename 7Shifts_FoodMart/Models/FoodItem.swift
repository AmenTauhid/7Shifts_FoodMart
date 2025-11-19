import Foundation

struct FoodItem: Identifiable, Codable {
    let id: String
    let name: String
    let price: Double
    let categoryId: String
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case price
        case categoryId = "category_uuid"
        case imageUrl = "image_url"
    }

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: price)) ?? "$\(String(format: "%.2f", price))"
    }
}
