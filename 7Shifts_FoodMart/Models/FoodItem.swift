import Foundation

/// Represents a food item from the API.
/// - Conforms to `Identifiable` for SwiftUI list rendering
/// - Conforms to `Codable` for JSON decoding
/// - Uses `CodingKeys` to map snake_case API fields to camelCase properties
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

    // MARK: - Price Formatting

    /// Static formatter for performance - created once, reused for all instances
    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter
    }()

    /// Returns price as formatted currency string (e.g., "$1.49")
    var formattedPrice: String {
        FoodItem.priceFormatter.string(from: NSNumber(value: price)) ?? "$\(String(format: "%.2f", price))"
    }
}
