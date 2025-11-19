import Testing
import Foundation
@testable import _Shifts_FoodMart

// MARK: - Mock Network Service for Repository Tests

final class MockNetworkServiceForRepository: NetworkServiceProtocol {
    var foodItemsData: Data?
    var categoriesData: Data?
    var errorToThrow: NetworkError?

    func fetch<T: Decodable>(from urlString: String) async throws -> T {
        if let error = errorToThrow {
            throw error
        }

        let data: Data?
        if urlString.contains("food_items") {
            data = foodItemsData
        } else if urlString.contains("categories") {
            data = categoriesData
        } else {
            data = nil
        }

        guard let data = data else {
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

struct FoodRepositoryTests {

    // MARK: - Success Tests

    /// Fetches food items through repository.
    /// Expects successful decoding and correct item data.
    @Test func fetchFoodItemsSuccess() async throws {
        let mockService = MockNetworkServiceForRepository()
        mockService.foodItemsData = """
        [
            {
                "uuid": "a1f7b3e5-4c1d-42e9-8f2a-8cbb8b1f6f01",
                "name": "Bananas",
                "price": 1.49,
                "category_uuid": "b1f6d8a5-0e29-4d70-8d4f-1f8c1d7a5b12",
                "image_url": "https://example.com/bananas.png"
            },
            {
                "uuid": "e9f2c6d5-4b3e-41a7-8c4d-5e9f7a2b4a09",
                "name": "Apple",
                "price": 0.99,
                "category_uuid": "b1f6d8a5-0e29-4d70-8d4f-1f8c1d7a5b12",
                "image_url": "https://example.com/apple.png"
            }
        ]
        """.data(using: .utf8)

        let repository = FoodRepository(networkService: mockService)
        let items = try await repository.fetchFoodItems()

        #expect(items.count == 2)
        #expect(items[0].name == "Bananas")
        #expect(items[1].name == "Apple")
    }

    /// Fetches categories through repository.
    /// Expects successful decoding and correct category data.
    @Test func fetchCategoriesSuccess() async throws {
        let mockService = MockNetworkServiceForRepository()
        mockService.categoriesData = """
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

        let repository = FoodRepository(networkService: mockService)
        let categories = try await repository.fetchCategories()

        #expect(categories.count == 2)
        #expect(categories[0].name == "Produce")
        #expect(categories[1].name == "Meat")
    }

    /// Fetches all data concurrently using async let.
    /// Expects both items and categories to be fetched successfully.
    @Test func fetchAllDataConcurrently() async throws {
        let mockService = MockNetworkServiceForRepository()
        mockService.foodItemsData = """
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

        mockService.categoriesData = """
        [
            {
                "uuid": "b1f6d8a5-0e29-4d70-8d4f-1f8c1d7a5b12",
                "name": "Produce"
            }
        ]
        """.data(using: .utf8)

        let repository = FoodRepository(networkService: mockService)
        let (items, categories) = try await repository.fetchAllData()

        #expect(items.count == 1)
        #expect(items[0].name == "Bananas")
        #expect(categories.count == 1)
        #expect(categories[0].name == "Produce")
    }

    // MARK: - Error Tests

    /// Tests error propagation when fetching food items fails.
    /// Expects NetworkError.noData to be thrown.
    @Test func fetchFoodItemsErrorPropagation() async {
        let mockService = MockNetworkServiceForRepository()
        mockService.foodItemsData = nil

        let repository = FoodRepository(networkService: mockService)

        do {
            _ = try await repository.fetchFoodItems()
            Issue.record("Expected error to be thrown")
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

    /// Tests error propagation when fetching categories fails.
    /// Expects NetworkError.invalidURL to be thrown.
    @Test func fetchCategoriesErrorPropagation() async {
        let mockService = MockNetworkServiceForRepository()
        mockService.errorToThrow = .invalidURL

        let repository = FoodRepository(networkService: mockService)

        do {
            _ = try await repository.fetchCategories()
            Issue.record("Expected error to be thrown")
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

    /// Tests error propagation when fetchAllData fails on one endpoint.
    /// Expects error to propagate from the failing request.
    @Test func fetchAllDataErrorPropagation() async {
        let mockService = MockNetworkServiceForRepository()
        mockService.foodItemsData = """
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
        mockService.categoriesData = nil  // This will cause an error

        let repository = FoodRepository(networkService: mockService)

        do {
            _ = try await repository.fetchAllData()
            Issue.record("Expected error to be thrown")
        } catch {
            // Expected - error propagated from categories fetch
        }
    }
}
