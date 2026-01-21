import Foundation

protocol CoinRepository {
    func marketCoins(category: MarketCategory, page: Int, pageSize: Int) async throws -> [Coin]
    func trendingCoins() async throws -> [Coin]
    func coinDetail(id: String) async throws -> CoinDetail
    func history(id: String, days: String) async throws -> [PricePoint]
}

/// Coin list caching interface implemented by PersistenceController.
protocol CoinCache {
    func cacheMarketCoins(_ coins: [Coin], key: String) throws
    func cachedMarketCoins(key: String) throws -> [Coin]
    func cacheHistory(_ points: [PricePoint], coinId: String, days: String) throws
    func cachedHistory(coinId: String, days: String) throws -> [PricePoint]
}
