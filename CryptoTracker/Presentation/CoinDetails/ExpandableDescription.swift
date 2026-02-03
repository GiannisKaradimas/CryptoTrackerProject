import SwiftUI

struct ExpandableDescription: View {
    @Binding var isExpanded: Bool
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(text)
                .lineLimit(isExpanded ? nil : 3)
                .animation(.easeInOut, value: isExpanded)

            Button(isExpanded ? "Show less" : "Read more") {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
    }
}
