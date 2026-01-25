import Foundation

protocol CoinRepository {
    func fetchMarket(category: MarketCategory, page: Int, perPage: Int) async throws -> [Coin]
    func fetchTrending() async throws -> [Coin] // must include real prices
    func fetchCoinDetail(id: String) async throws -> CoinDetail
    func fetchHistory(id: String, days: HistoryRange) async throws -> [PricePoint]
    func fetchSimplePriceUSD(ids: [String]) async throws -> [String: Double]
}
