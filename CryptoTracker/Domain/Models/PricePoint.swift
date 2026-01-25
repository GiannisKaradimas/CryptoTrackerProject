import Foundation

struct PricePoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let priceUSD: Double
}
