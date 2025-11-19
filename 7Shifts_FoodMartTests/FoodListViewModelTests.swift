import Testing
import Foundation
@testable import _Shifts_FoodMart

// MARK: - Mock Repository

/// Mock repository for ViewModel testing.
/// Returns predefined data without network calls.
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

/// Tests for ViewModel business logic.
/// Demonstrates: @MainActor testing, state management, filtering logic.
struct FoodListViewModelTests {

    /// Verifies successful data fetch updates state correctly.
    /// Key test: Shows full data flow from fetch to UI state.
    @Test @MainActor func fetchDataUpdatesStateOnSuccess() async {
        // Arrange
        let mockRepo = MockFoodRepository()
        mockRepo.mockItems = [
            FoodItem(id: "1", name: "Bananas", price: 1.49, categoryId: "produce", imageUrl: "")
        ]
        mockRepo.mockCategories = [
            FoodCategory(id: "produce", name: "Produce")
        ]

        let viewModel = FoodListViewModel(repository: mockRepo)

        // Act
        await viewModel.fetchData()

        // Assert
        #expect(viewModel.loadingState == .success)
        #expect(viewModel.foodItems.count == 1)
        #expect(viewModel.filteredItems.count == 1)
    }

    /// Verifies error updates state with error message.
    /// Key test: Shows error handling flow.
    @Test @MainActor func fetchDataUpdatesStateOnError() async {
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

    /// Verifies filtering returns only matching items.
    /// Key test: Shows core filtering business logic.
    @Test @MainActor func filteringReturnsMatchingItems() async {
        let mockRepo = MockFoodRepository()
        mockRepo.mockItems = [
            FoodItem(id: "1", name: "Bananas", price: 1.49, categoryId: "produce", imageUrl: ""),
            FoodItem(id: "2", name: "Chicken", price: 9.99, categoryId: "meat", imageUrl: "")
        ]

        let viewModel = FoodListViewModel(repository: mockRepo)
        await viewModel.fetchData()

        // Select produce category
        viewModel.toggleCategory("produce")

        #expect(viewModel.filteredItems.count == 1)
        #expect(viewModel.filteredItems[0].name == "Bananas")
    }

    /// Verifies toggle adds/removes category from selection.
    /// Key test: Shows toggle state management.
    @Test @MainActor func toggleCategoryUpdatesSelection() {
        let viewModel = FoodListViewModel(repository: MockFoodRepository())

        // Toggle on
        viewModel.toggleCategory("produce")
        #expect(viewModel.selectedCategoryIds.contains("produce"))

        // Toggle off
        viewModel.toggleCategory("produce")
        #expect(!viewModel.selectedCategoryIds.contains("produce"))
    }

    /// Verifies clearFilters removes all selections and shows all items.
    /// Key test: Shows reset functionality.
    @Test @MainActor func clearFiltersResetsToAllItems() async {
        let mockRepo = MockFoodRepository()
        mockRepo.mockItems = [
            FoodItem(id: "1", name: "Bananas", price: 1.49, categoryId: "produce", imageUrl: ""),
            FoodItem(id: "2", name: "Chicken", price: 9.99, categoryId: "meat", imageUrl: "")
        ]

        let viewModel = FoodListViewModel(repository: mockRepo)
        await viewModel.fetchData()

        // Apply filter
        viewModel.toggleCategory("produce")
        #expect(viewModel.filteredItems.count == 1)

        // Clear filters
        viewModel.clearFilters()
        #expect(viewModel.selectedCategoryIds.isEmpty)
        #expect(viewModel.filteredItems.count == 2)
    }

    /// Verifies multiple categories can be selected simultaneously.
    /// Key test: Shows multi-select filtering behavior.
    @Test @MainActor func multipleCategortSelectionFiltersCorrectly() async {
        let mockRepo = MockFoodRepository()
        mockRepo.mockItems = [
            FoodItem(id: "1", name: "Bananas", price: 1.49, categoryId: "produce", imageUrl: ""),
            FoodItem(id: "2", name: "Chicken", price: 9.99, categoryId: "meat", imageUrl: ""),
            FoodItem(id: "3", name: "Milk", price: 3.99, categoryId: "dairy", imageUrl: "")
        ]

        let viewModel = FoodListViewModel(repository: mockRepo)
        await viewModel.fetchData()

        // Select two categories
        viewModel.toggleCategory("produce")
        viewModel.toggleCategory("dairy")

        #expect(viewModel.selectedCategoryIds.count == 2)
        #expect(viewModel.filteredItems.count == 2)
        #expect(viewModel.filteredItems.contains { $0.name == "Bananas" })
        #expect(viewModel.filteredItems.contains { $0.name == "Milk" })
        #expect(!viewModel.filteredItems.contains { $0.name == "Chicken" })
    }

    /// Verifies empty results when filtering by non-matching category.
    /// Key test: Shows edge case handling.
    @Test @MainActor func filteringWithNoMatchesReturnsEmpty() async {
        let mockRepo = MockFoodRepository()
        mockRepo.mockItems = [
            FoodItem(id: "1", name: "Bananas", price: 1.49, categoryId: "produce", imageUrl: "")
        ]

        let viewModel = FoodListViewModel(repository: mockRepo)
        await viewModel.fetchData()

        // Filter by non-existent category
        viewModel.toggleCategory("meat")

        #expect(viewModel.filteredItems.isEmpty)
    }

    /// Verifies loading state transitions correctly during fetch.
    /// Key test: Shows state machine behavior.
    @Test @MainActor func loadingStateTransitionsCorrectly() async {
        let mockRepo = MockFoodRepository()
        mockRepo.mockItems = [FoodItem(id: "1", name: "Test", price: 1.0, categoryId: "cat", imageUrl: "")]

        let viewModel = FoodListViewModel(repository: mockRepo)

        // Initial state
        #expect(viewModel.loadingState == .idle)

        // After fetch
        await viewModel.fetchData()
        #expect(viewModel.loadingState == .success)
    }
}
