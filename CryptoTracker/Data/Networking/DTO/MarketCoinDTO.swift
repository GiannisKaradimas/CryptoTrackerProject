struct MarketCoinDTO: Decodable {
    let id: String
    let symbol: String
    let name: String
    let image: String?
    let currentPrice: Double?
    let priceChangePercentage24H: Double?
    let marketCap: Double?
    let totalVolume: Double?
    let sparklineIn7D: SparklineDTO?

    struct SparklineDTO: Decodable {
        let price: [Double]?
    }
}
