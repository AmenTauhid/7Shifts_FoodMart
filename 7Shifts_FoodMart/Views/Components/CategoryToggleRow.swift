import SwiftUI

struct CategoryToggleRow: View {
    let categoryName: String
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Text(categoryName)
                .font(.body)

            Spacer()

            Toggle("", isOn: Binding(
                get: { isSelected },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack {
        CategoryToggleRow(
            categoryName: "Produce",
            isSelected: true,
            onToggle: {}
        )
        CategoryToggleRow(
            categoryName: "Meat",
            isSelected: false,
            onToggle: {}
        )
    }
    .padding()
}
