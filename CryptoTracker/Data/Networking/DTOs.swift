import Foundation

// MARK: - Markets (coins/markets)

struct CoinMarketDTO: Decodable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let image: String?
    let currentPrice: Double?
    let marketCap: Double?
    let marketCapRank: Int?
    let totalVolume: Double?
    let high24H: Double?
    let low24H: Double?
    let priceChangePercentage24H: Double?
    let sparklineIn7D: SparklineDTO?

    struct SparklineDTO: Decodable {
        let price: [Double]?
    }
}

// MARK: - Detail (coins/{id})

struct CoinDetailDTO: Decodable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let image: ImageDTO?
    let description: DescriptionDTO?
    let links: LinksDTO?
    let marketData: MarketDataDTO?

    struct ImageDTO: Decodable { let large: String? }
    struct DescriptionDTO: Decodable { let en: String? }

    struct LinksDTO: Decodable {
        let homepage: [String]?
        let blockchainSite: [String]?
        let officialForumUrl: [String]?
        let subredditUrl: String?
    }

    struct MarketDataDTO: Decodable {
        let currentPrice: [String: Double]?
        let marketCap: [String: Double]?
        let totalVolume: [String: Double]?
        let circulatingSupply: Double?
        let totalSupply: Double?
        let ath: [String: Double]?
        let atl: [String: Double]?
        let priceChangePercentage24H: Double?
    }
}

// MARK: - Market chart (coins/{id}/market_chart)

struct MarketChartDTO: Decodable {
    /// [[timestamp_ms, price], ...]
    let prices: [[Double]]
}

// MARK: - Trending (search/trending)

struct TrendingDTO: Decodable {
    let coins: [TrendingItemDTO]
    struct TrendingItemDTO: Decodable, Identifiable {
        let item: Item
        var id: String { item.id }
        struct Item: Decodable {
            let id: String
            let name: String
            let symbol: String
            let large: String?
            let marketCapRank: Int?
        }
    }
}
