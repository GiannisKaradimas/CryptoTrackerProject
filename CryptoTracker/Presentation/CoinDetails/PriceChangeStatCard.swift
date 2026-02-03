import SwiftUI

struct PriceChangeStatCard: View {
    let title: String
    let value: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value != nil ? "\(value!.asPercentString())" : "--")
                .font(.headline)
                .foregroundColor(color(for: value))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func color(for value: Double?) -> Color {
        guard let v = value else { return .secondary }
        return v >= 0 ? .green : .red
    }
}
