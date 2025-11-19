import Testing
import Foundation
@testable import _Shifts_FoodMart

struct ModelTests {

    // MARK: - FoodItem Tests

    /// Decodes a single FoodItem from JSON.
    /// Expects all properties to map correctly via CodingKeys.
    @Test func foodItemDecoding() throws {
        let json = """
        {
            "uuid": "a1f7b3e5-4c1d-42e9-8f2a-8cbb8b1f6f01",
            "name": "Bananas",
            "price": 1.49,
            "category_uuid": "b1f6d8a5-0e29-4d70-8d4f-1f8c1d7a5b12",
            "image_url": "https://7shifts.github.io/mobile-takehome/images/bananas.png"
        }
        """.data(using: .utf8)!

        let item = try JSONDecoder().decode(FoodItem.self, from: json)

        #expect(item.id == "a1f7b3e5-4c1d-42e9-8f2a-8cbb8b1f6f01")
        #expect(item.name == "Bananas")
        #expect(item.price == 1.49)
        #expect(item.categoryId == "b1f6d8a5-0e29-4d70-8d4f-1f8c1d7a5b12")
        #expect(item.imageUrl == "https://7shifts.github.io/mobile-takehome/images/bananas.png")
    }

    /// Decodes an array of FoodItems from JSON.
    /// Expects correct count and item order preserved.
    @Test func foodItemArrayDecoding() throws {
        let json = """
        [
            {
                "uuid": "a1f7b3e5-4c1d-42e9-8f2a-8cbb8b1f6f01",
                "name": "Bananas",
                "price": 1.49,
                "category_uuid": "b1f6d8a5-0e29-4d70-8d4f-1f8c1d7a5b12",
                "image_url": "https://7shifts.github.io/mobile-takehome/images/bananas.png"
            },
            {
                "uuid": "e9f2c6d5-4b3e-41a7-8c4d-5e9f7a2b4a09",
                "name": "Apple",
                "price": 0.99,
                "category_uuid": "b1f6d8a5-0e29-4d70-8d4f-1f8c1d7a5b12",
                "image_url": "https://7shifts.github.io/mobile-takehome/images/apple.png"
            }
        ]
        """.data(using: .utf8)!

        let items = try JSONDecoder().decode([FoodItem].self, from: json)

        #expect(items.count == 2)
        #expect(items[0].name == "Bananas")
        #expect(items[1].name == "Apple")
    }

    /// Tests formattedPrice computed property with decimal value.
    /// Expects currency string containing "9.99" or "9,99".
    @Test func foodItemFormattedPrice() {
        let item = FoodItem(
            id: "test-id",
            name: "Test Item",
            price: 9.99,
            categoryId: "category-id",
            imageUrl: "https://example.com/image.png"
        )

        let formatted = item.formattedPrice
        #expect(formatted.contains("9.99") || formatted.contains("9,99"))
    }

    /// Tests formattedPrice with whole number value.
    /// Expects currency string containing "10".
    @Test func foodItemFormattedPriceWholeNumber() {
        let item = FoodItem(
            id: "test-id",
            name: "Test Item",
            price: 10.00,
            categoryId: "category-id",
            imageUrl: "https://example.com/image.png"
        )

        let formatted = item.formattedPrice
        #expect(formatted.contains("10"))
    }

    // MARK: - FoodCategory Tests

    /// Decodes a single FoodCategory from JSON.
    /// Expects uuid mapped to id and name preserved.
    @Test func foodCategoryDecoding() throws {
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

    /// Decodes an array of FoodCategories from JSON.
    /// Expects correct count and category order preserved.
    @Test func foodCategoryArrayDecoding() throws {
        let json = """
        [
            {
                "uuid": "b1f6d8a5-0e29-4d70-8d4f-1f8c1d7a5b12",
                "name": "Produce"
            },
            {
                "uuid": "f3a6c4e2-1d4c-4a3c-8d3d-6b8c15f0e2b9",
                "name": "Meat"
            }
        ]
        """.data(using: .utf8)!

        let categories = try JSONDecoder().decode([FoodCategory].self, from: json)

        #expect(categories.count == 2)
        #expect(categories[0].name == "Produce")
        #expect(categories[1].name == "Meat")
    }
}
