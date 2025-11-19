import SwiftUI

struct FoodItemCard: View {
    let item: FoodItem
    let categoryName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: item.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay {
                            ProgressView()
                        }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        }
                @unknown default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .clipped()
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.price.formatted)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                if let categoryName = categoryName {
                    Text(categoryName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    FoodItemCard(
        item: FoodItem(
            id: "1",
            name: "Bananas",
            price: 1.49,
            categoryId: "cat-1",
            imageUrl: "https://7shifts.github.io/mobile-takehome/images/bananas.png"
        ),
        categoryName: "Produce"
    )
    .frame(width: 160)
    .padding()
}
