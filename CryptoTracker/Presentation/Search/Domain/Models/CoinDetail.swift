import Foundation

struct CoinDetail: Equatable {
    let id: String
    let name: String
    let symbol: String
    let imageURL: URL?
    let description: String?
    let homepageURL: URL?
    let marketCapUSD: Double?
    let volumeUSD: Double?
    let circulatingSupply: Double?
    let maxSupply: Double?
    let athUSD: Double?
    let atlUSD: Double?

    let priceChange24h: Double?
    let priceChange7d: Double?
    let priceChange30d: Double?
    let priceChange1y: Double?
}
