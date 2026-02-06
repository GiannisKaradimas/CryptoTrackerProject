import Foundation

struct Coin: Identifiable, Equatable {
    let id: String
    let symbol: String
    let name: String
    let imageURL: URL?
    let currentPriceUSD: Double?
    let priceChange24hPct: Double?
    let marketCapUSD: Double?
    let totalVolumeUSD: Double?
    let sparkline7d: [Double]?
}
