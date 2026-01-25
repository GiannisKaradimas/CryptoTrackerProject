import Foundation

struct MarketCoinDTO: Decodable {
    let id: String
    let symbol: String
    let name: String
    let image: String?
    let currentPrice: Double?
    let priceChangePercentage24h: Double?
    let marketCap: Double?
    let totalVolume: Double?
    let sparklineIn7d: SparklineDTO?

    struct SparklineDTO: Decodable { let price: [Double]? }
}
