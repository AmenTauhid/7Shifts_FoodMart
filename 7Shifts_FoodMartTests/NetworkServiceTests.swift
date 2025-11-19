import Testing
import Foundation
@testable import _Shifts_FoodMart

// MARK: - Mock Network Service

final class MockNetworkService: NetworkServiceProtocol {
    var mockData: Data?
    var mockError: NetworkError?

    func fetch<T: Decodable>(from urlString: String) async throws -> T {
        if let error = mockError {
            throw error
        }

        guard let data = mockData else {
            throw NetworkError.noData
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}

// MARK: - Tests

struct NetworkServiceTests {

    // MARK: - Success Tests

    /// Fetches FoodItems using mock service with valid JSON.
    /// Expects successful decoding and correct item count.
    @Test func fetchFoodItemsSuccess() async throws {
        let mockService = MockNetworkService()
        mockService.mockData = """
        [
            {
                "uuid": "a1f7b3e5-4c1d-42e9-8f2a-8cbb8b1f6f01",
                "name": "Bananas",
                "price": 1.49,
                "category_uuid": "b1f6d8a5-0e29-4d70-8d4f-1f8c1d7a5b12",
                "image_url": "https://example.com/bananas.png"
            }
        ]
        """.data(using: .utf8)

        let items: [FoodItem] = try await mockService.fetch(from: "https://example.com/api")

        #expect(items.count == 1)
        #expect(items[0].name == "Bananas")
        #expect(items[0].price == 1.49)
    }

    /// Fetches FoodCategories using mock service with valid JSON.
    /// Expects successful decoding and correct category data.
    @Test func fetchCategoriesSuccess() async throws {
        let mockService = MockNetworkService()
        mockService.mockData = """
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
        """.data(using: .utf8)

        let categories: [FoodCategory] = try await mockService.fetch(from: "https://example.com/api")

        #expect(categories.count == 2)
        #expect(categories[0].name == "Produce")
        #expect(categories[1].name == "Meat")
    }

    // MARK: - Error Tests

    /// Tests handling of no data error.
    /// Expects NetworkError.noData to be thrown.
    @Test func fetchNoDataError() async {
        let mockService = MockNetworkService()
        mockService.mockData = nil

        do {
            let _: [FoodItem] = try await mockService.fetch(from: "https://example.com/api")
            Issue.record("Expected noData error")
        } catch let error as NetworkError {
            if case .noData = error {
                // Expected error
            } else {
                Issue.record("Expected noData error, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    /// Tests handling of decoding error with invalid JSON.
    /// Expects NetworkError.decodingFailed to be thrown.
    @Test func fetchDecodingError() async {
        let mockService = MockNetworkService()
        mockService.mockData = "invalid json".data(using: .utf8)

        do {
            let _: [FoodItem] = try await mockService.fetch(from: "https://example.com/api")
            Issue.record("Expected decoding error")
        } catch let error as NetworkError {
            if case .decodingFailed = error {
                // Expected error
            } else {
                Issue.record("Expected decodingFailed error, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    /// Tests handling of invalid URL error.
    /// Expects NetworkError.invalidURL to be thrown.
    @Test func fetchInvalidURLError() async {
        let mockService = MockNetworkService()
        mockService.mockError = .invalidURL

        do {
            let _: [FoodItem] = try await mockService.fetch(from: "")
            Issue.record("Expected invalidURL error")
        } catch let error as NetworkError {
            if case .invalidURL = error {
                // Expected error
            } else {
                Issue.record("Expected invalidURL error, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    // MARK: - API Endpoints Tests

    /// Verifies API endpoint URLs are correctly configured.
    /// Expects valid URL strings for food items and categories.
    @Test func apiEndpointsConfiguration() {
        #expect(APIEndpoints.foodItems == "https://7shifts.github.io/mobile-takehome/api/food_items.json")
        #expect(APIEndpoints.categories == "https://7shifts.github.io/mobile-takehome/api/food_item_categories.json")
    }
}
