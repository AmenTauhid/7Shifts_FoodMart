import Testing
import Foundation
@testable import _Shifts_FoodMart

// MARK: - Mock

/// Mock implementation for testing without real network calls.
/// Demonstrates dependency injection pattern.
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

        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Tests

/// Tests for network service using mock implementation.
/// Demonstrates: async testing, mocking, dependency injection.
struct NetworkServiceTests {

    /// Verifies successful data fetching and JSON decoding.
    /// Key test: Shows mock injection pattern for async network calls.
    @Test func fetchDecodesJSONSuccessfully() async throws {
        // Arrange - Set up mock with test data
        let mockService = MockNetworkService()
        mockService.mockData = """
        [{"uuid": "1", "name": "Bananas", "price": 1.49, "category_uuid": "cat-1", "image_url": ""}]
        """.data(using: .utf8)

        // Act - Call the method under test
        let items: [FoodItem] = try await mockService.fetch(from: "https://example.com/api")

        // Assert - Verify results
        #expect(items.count == 1)
        #expect(items[0].name == "Bananas")
    }

    /// Verifies errors are properly thrown.
    /// Key test: Shows error handling in async context.
    @Test func fetchThrowsErrorOnFailure() async {
        let mockService = MockNetworkService()
        mockService.mockError = .noData

        do {
            let _: [FoodItem] = try await mockService.fetch(from: "")
            Issue.record("Expected error to be thrown")
        } catch is NetworkError {
            // Expected - error was thrown
        } catch {
            Issue.record("Wrong error type: \(error)")
        }
    }

    /// Verifies decoding fails gracefully with malformed JSON.
    /// Key test: Shows error propagation for invalid data.
    @Test func fetchThrowsDecodingErrorForMalformedJSON() async {
        let mockService = MockNetworkService()
        mockService.mockData = "not valid json".data(using: .utf8)

        do {
            let _: [FoodItem] = try await mockService.fetch(from: "https://example.com/api")
            Issue.record("Expected decoding error")
        } catch {
            // Expected - decoding should fail
        }
    }

    /// Verifies array of items decodes correctly.
    /// Key test: Shows handling of collection responses.
    @Test func fetchDecodesArrayOfCategories() async throws {
        let mockService = MockNetworkService()
        mockService.mockData = """
        [
            {"uuid": "1", "name": "Produce"},
            {"uuid": "2", "name": "Dairy"},
            {"uuid": "3", "name": "Meat"}
        ]
        """.data(using: .utf8)

        let categories: [FoodCategory] = try await mockService.fetch(from: "https://example.com/api")

        #expect(categories.count == 3)
        #expect(categories[0].name == "Produce")
        #expect(categories[2].name == "Meat")
    }
}
