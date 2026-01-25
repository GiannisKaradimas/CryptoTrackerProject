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
    let athUSD: Double?
    let atlUSD: Double?
}

