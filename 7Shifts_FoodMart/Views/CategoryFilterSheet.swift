import SwiftUI

struct CategoryFilterSheet: View {
    @ObservedObject var viewModel: FoodListViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.categories) { category in
                    CategoryToggleRow(
                        categoryName: category.name,
                        isSelected: viewModel.selectedCategoryIds.contains(category.id),
                        onToggle: { viewModel.toggleCategory(category.id) }
                    )
                }
            }
            .listStyle(.plain)
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.selectedCategoryIds.isEmpty {
                        Button("Clear") {
                            viewModel.clearFilters()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CategoryFilterSheet(
        viewModel: {
            let vm = FoodListViewModel(repository: FoodRepository(networkService: NetworkService()))
            return vm
        }()
    )
}
