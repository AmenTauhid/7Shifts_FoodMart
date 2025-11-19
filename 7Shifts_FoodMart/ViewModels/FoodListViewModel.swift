import Foundation
import Combine

@MainActor
final class FoodListViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = []
    @Published var categories: [FoodCategory] = []
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
            loadingState = .success
        } catch let error as NetworkError {
            loadingState = .error(error.localizedDescription)
        } catch {
            loadingState = .error("An unexpected error occurred. Please try again.")
        }
    }

    func retry() {
        Task {
            await fetchData()
        }
    }
}
