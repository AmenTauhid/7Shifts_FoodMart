import SwiftUI

struct FoodListView: View {
    @StateObject private var viewModel = FoodListViewModel(
        repository: FoodRepository(networkService: NetworkService())
    )

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.loadingState {
                case .idle, .loading:
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .success:
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.foodItems) { item in
                                FoodItemCard(
                                    item: item,
                                    categoryName: categoryName(for: item)
                                )
                            }
                        }
                        .padding()
                    }

                case .error(let message):
                    ErrorView(message: message, onRetry: viewModel.retry)
                }
            }
            .navigationTitle("Food")
        }
        .task {
            await viewModel.fetchData()
        }
    }

    private func categoryName(for item: FoodItem) -> String? {
        viewModel.categories.first { $0.id == item.categoryId }?.name
    }
}

#Preview {
    FoodListView()
}
