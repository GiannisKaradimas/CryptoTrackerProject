import Foundation

struct Coin: Identifiable, Equatable {
    let id: String
    let symbol: String
    let name: String
    let imageURL: URL?
    let price: Double
    let change24h: Double?
    let marketCapRank: Int?
    let sparkline7d: [Double]?
}

struct CoinDetail: Identifiable, Equatable {
    let id: String
    let symbol: String
    let name: String
    let imageURL: URL?
    let descriptionHTML: String?
    let homepage: URL?
    let subreddit: URL?

    let price: Double?
    let marketCap: Double?
    let volume: Double?
    let circulatingSupply: Double?
    let totalSupply: Double?
    let ath: Double?
    let atl: Double?
    let change24h: Double?
}

struct PricePoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let price: Double
}

enum MarketCategory: String, CaseIterable, Identifiable {
    case top100 = "Top 100"
    case trending = "Trending"
    case gainers = "Gainers"
    case losers = "Losers"
    var id: String { rawValue }
}
