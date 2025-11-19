import Testing
import Foundation
@testable import _Shifts_FoodMart

// MARK: - Mock Repository

final class MockFoodRepository: FoodRepositoryProtocol {
    var mockItems: [FoodItem] = []
    var mockCategories: [FoodCategory] = []
    var errorToThrow: NetworkError?

    func fetchFoodItems() async throws -> [FoodItem] {
        if let error = errorToThrow { throw error }
        return mockItems
    }

    func fetchCategories() async throws -> [FoodCategory] {
        if let error = errorToThrow { throw error }
        return mockCategories
    }

    func fetchAllData() async throws -> (items: [FoodItem], categories: [FoodCategory]) {
        if let error = errorToThrow { throw error }
        return (mockItems, mockCategories)
    }
}

// MARK: - Tests

struct FoodListViewModelTests {

    /// Verifies successful fetch updates state and populates data.
    @Test @MainActor func fetchDataSuccess() async {
        let mockRepo = MockFoodRepository()
        mockRepo.mockItems = [
            FoodItem(id: "1", name: "Bananas", price: 1.49, categoryId: "cat-1", imageUrl: "https://example.com/bananas.png")
        ]
        mockRepo.mockCategories = [
            FoodCategory(id: "cat-1", name: "Produce")
        ]

        let viewModel = FoodListViewModel(repository: mockRepo)
        await viewModel.fetchData()

        #expect(viewModel.loadingState == .success)
        #expect(viewModel.foodItems.count == 1)
        #expect(viewModel.foodItems[0].name == "Bananas")
        #expect(viewModel.categories.count == 1)
        #expect(viewModel.categories[0].name == "Produce")
    }

    /// Verifies error updates state with error message.
    @Test @MainActor func fetchDataError() async {
        let mockRepo = MockFoodRepository()
        mockRepo.errorToThrow = .noData

        let viewModel = FoodListViewModel(repository: mockRepo)
        await viewModel.fetchData()

        if case .error(let message) = viewModel.loadingState {
            #expect(message.contains("No data"))
        } else {
            Issue.record("Expected error state")
        }
    }

    /// Verifies retry triggers a new fetch.
    @Test @MainActor func retryFunctionality() async throws {
        let mockRepo = MockFoodRepository()
        mockRepo.errorToThrow = .noData

        let viewModel = FoodListViewModel(repository: mockRepo)
        await viewModel.fetchData()

        // Verify error state
        guard case .error = viewModel.loadingState else {
            Issue.record("Expected error state")
            return
        }

        // Fix the error and retry
        mockRepo.errorToThrow = nil
        mockRepo.mockItems = [
            FoodItem(id: "1", name: "Apple", price: 0.99, categoryId: "cat-1", imageUrl: "https://example.com/apple.png")
        ]

        viewModel.retry()
        try await Task.sleep(nanoseconds: 100_000_000) // Wait for retry to complete

        #expect(viewModel.loadingState == .success)
        #expect(viewModel.foodItems.count == 1)
    }

    // MARK: - Filtering Tests

    /// Verifies filteredItems returns all items when no category selected.
    @Test @MainActor func filterWithNoSelection() async {
        let mockRepo = MockFoodRepository()
        mockRepo.mockItems = [
            FoodItem(id: "1", name: "Bananas", price: 1.49, categoryId: "produce", imageUrl: ""),
            FoodItem(id: "2", name: "Chicken", price: 9.99, categoryId: "meat", imageUrl: "")
        ]

        let viewModel = FoodListViewModel(repository: mockRepo)
        await viewModel.fetchData()

        #expect(viewModel.filteredItems.count == 2)
    }

    /// Verifies filteredItems returns only matching items when category selected.
    @Test @MainActor func filterWithSingleCategory() async {
        let mockRepo = MockFoodRepository()
        mockRepo.mockItems = [
            FoodItem(id: "1", name: "Bananas", price: 1.49, categoryId: "produce", imageUrl: ""),
            FoodItem(id: "2", name: "Apple", price: 0.99, categoryId: "produce", imageUrl: ""),
            FoodItem(id: "3", name: "Chicken", price: 9.99, categoryId: "meat", imageUrl: "")
        ]

        let viewModel = FoodListViewModel(repository: mockRepo)
        await viewModel.fetchData()
        viewModel.toggleCategory("produce")

        #expect(viewModel.filteredItems.count == 2)
        #expect(viewModel.filteredItems.allSatisfy { $0.categoryId == "produce" })
    }

    /// Verifies filteredItems returns items from multiple selected categories.
    @Test @MainActor func filterWithMultipleCategories() async {
        let mockRepo = MockFoodRepository()
        mockRepo.mockItems = [
            FoodItem(id: "1", name: "Bananas", price: 1.49, categoryId: "produce", imageUrl: ""),
            FoodItem(id: "2", name: "Chicken", price: 9.99, categoryId: "meat", imageUrl: ""),
            FoodItem(id: "3", name: "Milk", price: 3.99, categoryId: "dairy", imageUrl: "")
        ]

        let viewModel = FoodListViewModel(repository: mockRepo)
        await viewModel.fetchData()
        viewModel.toggleCategory("produce")
        viewModel.toggleCategory("meat")

        #expect(viewModel.filteredItems.count == 2)
        #expect(viewModel.filteredItems.contains { $0.name == "Bananas" })
        #expect(viewModel.filteredItems.contains { $0.name == "Chicken" })
    }

    /// Verifies toggleCategory adds and removes category from selection.
    @Test @MainActor func toggleCategoryBehavior() {
        let viewModel = FoodListViewModel(repository: MockFoodRepository())

        viewModel.toggleCategory("produce")
        #expect(viewModel.selectedCategoryIds.contains("produce"))

        viewModel.toggleCategory("produce")
        #expect(!viewModel.selectedCategoryIds.contains("produce"))
    }

    /// Verifies clearFilters removes all selected categories.
    @Test @MainActor func clearFiltersBehavior() {
        let viewModel = FoodListViewModel(repository: MockFoodRepository())

        viewModel.toggleCategory("produce")
        viewModel.toggleCategory("meat")
        #expect(viewModel.selectedCategoryIds.count == 2)

        viewModel.clearFilters()
        #expect(viewModel.selectedCategoryIds.isEmpty)
    }
}
