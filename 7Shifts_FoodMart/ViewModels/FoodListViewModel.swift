import Foundation
import Combine

@MainActor
final class FoodListViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = []
    @Published var categories: [FoodCategory] = []
    @Published var filteredItems: [FoodItem] = []
    @Published var selectedCategoryIds: Set<String> = []
    @Published var loadingState: LoadingState = .idle

    private let repository: FoodRepositoryProtocol

    init(repository: FoodRepositoryProtocol) {
        self.repository = repository
    }

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

    func toggleCategory(_ categoryId: String) {
        if selectedCategoryIds.contains(categoryId) {
            selectedCategoryIds.remove(categoryId)
        } else {
            selectedCategoryIds.insert(categoryId)
        }
        applyFilters()
    }

    private func applyFilters() {
        if selectedCategoryIds.isEmpty {
            filteredItems = foodItems
        } else {
            filteredItems = foodItems.filter { selectedCategoryIds.contains($0.categoryId) }
        }
    }

    func retry() {
        Task {
            await fetchData()
        }
    }

    func clearFilters() {
        selectedCategoryIds.removeAll()
        applyFilters()
    }
}
