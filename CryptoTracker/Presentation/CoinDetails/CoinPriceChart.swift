import SwiftUI
import Charts

struct CoinPriceChart: View {
    let data: [PricePoint]

    var body: some View {
        Chart(data, id: \.date) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Price", point.priceUSD)
            )
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 220)
    }
}
