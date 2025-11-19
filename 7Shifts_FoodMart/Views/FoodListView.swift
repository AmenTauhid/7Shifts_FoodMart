import SwiftUI

struct FoodListView: View {
    @StateObject private var viewModel = FoodListViewModel(
        repository: FoodRepository(networkService: NetworkService())
    )
    @State private var showingFilterSheet = false

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

    private func categoryName(for item: FoodItem) -> String? {
        viewModel.categories.first { $0.id == item.categoryId }?.name
    }
}

#Preview {
    FoodListView()
}
