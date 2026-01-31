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

    struct SparklineDTO: Decodable {
        let price: [Double]?
    }

//    enum CodingKeys: String, CodingKey {
//        case id, symbol, name
//        case image
//        case currentPrice = "current_price"
//        case priceChangePercentage24h = "price_change_percentage_24h"
//        case marketCap = "market_cap"
//        case totalVolume = "total_volume"
//        case sparklineIn7d = "sparkline_in_7d"
//    }
}
