import SwiftUI

/// Reusable card component displaying a food item.
/// Shows image, price, name, and category.
struct FoodItemCard: View {
    let item: FoodItem
    let categoryName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: item.imageUrl)) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray5))
                        .overlay {
                            ProgressView()
                        }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray5))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        }
                @unknown default:
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray5))
                }
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.top, 12)
            .padding(.horizontal, 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.formattedPrice)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)

                Text(item.name)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .lineLimit(2)

                if let categoryName = categoryName {
                    Text(categoryName)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
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
