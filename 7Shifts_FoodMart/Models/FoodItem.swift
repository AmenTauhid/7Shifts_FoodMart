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

    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }()

    var formattedPrice: String {
        return FoodItem.priceFormatter.string(from: NSNumber(value: price)) ?? "$\(String(format: "%.2f", price))"
    }
}
