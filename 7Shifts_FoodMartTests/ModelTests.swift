import Testing
import Foundation
@testable import _Shifts_FoodMart

/// Tests for data model JSON decoding and computed properties.
struct ModelTests {

    /// Verifies FoodItem correctly decodes API JSON with snake_case keys.
    /// This tests the CodingKeys mapping (uuid → id, category_uuid → categoryId, etc.)
    @Test func foodItemDecodesFromAPIJSON() throws {
        let json = """
        {
            "uuid": "a1f7b3e5-4c1d-42e9-8f2a-8cbb8b1f6f01",
            "name": "Bananas",
            "price": 1.49,
            "category_uuid": "b1f6d8a5-0e29-4d70-8d4f-1f8c1d7a5b12",
            "image_url": "https://example.com/bananas.png"
        }
        """.data(using: .utf8)!

        let item = try JSONDecoder().decode(FoodItem.self, from: json)

        #expect(item.id == "a1f7b3e5-4c1d-42e9-8f2a-8cbb8b1f6f01")
        #expect(item.name == "Bananas")
        #expect(item.price == 1.49)
        #expect(item.categoryId == "b1f6d8a5-0e29-4d70-8d4f-1f8c1d7a5b12")
    }

    /// Verifies formattedPrice returns currency string.
    /// Tests the computed property with static NumberFormatter.
    @Test func formattedPriceReturnsCurrencyString() {
        let item = FoodItem(
            id: "1",
            name: "Test",
            price: 9.99,
            categoryId: "cat-1",
            imageUrl: ""
        )

        #expect(item.formattedPrice.contains("9.99") || item.formattedPrice.contains("9,99"))
    }

    /// Verifies FoodCategory correctly decodes API JSON.
    @Test func foodCategoryDecodesFromAPIJSON() throws {
        let json = """
        {
            "uuid": "b1f6d8a5-0e29-4d70-8d4f-1f8c1d7a5b12",
            "name": "Produce"
        }
        """.data(using: .utf8)!

        let category = try JSONDecoder().decode(FoodCategory.self, from: json)

        #expect(category.id == "b1f6d8a5-0e29-4d70-8d4f-1f8c1d7a5b12")
        #expect(category.name == "Produce")
    }

    /// Verifies formattedPrice handles edge cases correctly.
    @Test func formattedPriceHandlesEdgeCases() {
        // Zero price
        let freeItem = FoodItem(id: "1", name: "Free", price: 0.0, categoryId: "cat-1", imageUrl: "")
        #expect(freeItem.formattedPrice.contains("0.00") || freeItem.formattedPrice.contains("0,00"))

        // Large price
        let expensiveItem = FoodItem(id: "2", name: "Expensive", price: 1234.56, categoryId: "cat-1", imageUrl: "")
        #expect(expensiveItem.formattedPrice.contains("1,234.56") || expensiveItem.formattedPrice.contains("1234,56"))
    }
}
