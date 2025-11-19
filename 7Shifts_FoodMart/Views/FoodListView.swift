import SwiftUI

/// Main view displaying a grid of food items with filtering capability.
/// Uses `@StateObject` to own the ViewModel lifecycle.
struct FoodListView: View {

    // MARK: - Properties

    /// ViewModel owned by this view - created once and persists across redraws
    @StateObject private var viewModel = FoodListViewModel(
        repository: FoodRepository(networkService: NetworkService())
    )

    /// Controls filter sheet presentation
    @State private var showingFilterSheet = false

    /// 2-column flexible grid layout
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.loadingState {
                case .idle, .loading:
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .success:
                    if viewModel.filteredItems.isEmpty {
                        // Empty state when filters return no results
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)

                            Text("No items found")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.semibold)

                            Text("Try adjusting your filters")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.secondary)

                            Button("Clear Filters") {
                                viewModel.clearFilters()
                            }
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(viewModel.filteredItems) { item in
                                    FoodItemCard(
                                        item: item,
                                        categoryName: categoryName(for: item)
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                        .background(Color(.systemBackground))
                        .refreshable {
                            await viewModel.fetchData()
                        }
                    }

                case .error(let message):
                    ErrorView(message: message, onRetry: viewModel.retry)
                }
            }
            .navigationTitle("Food")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFilterSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("Filter")
                            if !viewModel.selectedCategoryIds.isEmpty {
                                Text("\(viewModel.selectedCategoryIds.count)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .accessibilityIdentifier("FilterButton")
                }
            }
            .sheet(isPresented: $showingFilterSheet) {
                CategoryFilterSheet(viewModel: viewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }

    // MARK: - Helper Methods

    /// Looks up category name for a food item
    private func categoryName(for item: FoodItem) -> String? {
        viewModel.categories.first { $0.id == item.categoryId }?.name
    }
}

#Preview {
    FoodListView()
}
