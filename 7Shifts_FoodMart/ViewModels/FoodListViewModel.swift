import Foundation
import Combine

/// ViewModel for the food list screen.
/// - `@MainActor`: Ensures all UI updates happen on main thread
/// - `ObservableObject`: Enables SwiftUI to observe changes
/// - Uses dependency injection for testability
@MainActor
final class FoodListViewModel: ObservableObject {

    // MARK: - Published Properties (UI State)

    @Published var foodItems: [FoodItem] = []
    @Published var categories: [FoodCategory] = []
    @Published var filteredItems: [FoodItem] = []
    @Published var selectedCategoryIds: Set<String> = []
    @Published var loadingState: LoadingState = .idle

    // MARK: - Dependencies

    private let repository: FoodRepositoryProtocol

    // MARK: - Initialization

    init(repository: FoodRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Data Loading

    /// Fetches food items and categories from the repository.
    func fetchData() async {
        loadingState = .loading

        do {
            let (items, categories) = try await repository.fetchAllData()
            self.foodItems = items
            self.categories = categories
            applyFilters()
            loadingState = .success
        } catch let error as NetworkError {
            loadingState = .error(error.localizedDescription)
        } catch {
            loadingState = .error("An unexpected error occurred. Please try again.")
        }
    }

    /// Retries data fetch after an error.
    func retry() {
        Task {
            await fetchData()
        }
    }

    // MARK: - Filtering

    /// Toggles a category filter on/off.
    func toggleCategory(_ categoryId: String) {
        if selectedCategoryIds.contains(categoryId) {
            selectedCategoryIds.remove(categoryId)
        } else {
            selectedCategoryIds.insert(categoryId)
        }
        applyFilters()
    }

    /// Clears all selected category filters.
    func clearFilters() {
        selectedCategoryIds.removeAll()
        applyFilters()
    }

    /// Updates filteredItems based on selected categories.
    private func applyFilters() {
        if selectedCategoryIds.isEmpty {
            filteredItems = foodItems
        } else {
            filteredItems = foodItems.filter { selectedCategoryIds.contains($0.categoryId) }
        }
    }
}
