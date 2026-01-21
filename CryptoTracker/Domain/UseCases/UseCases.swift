import Foundation

struct FetchMarketCoinsUseCase {
    let repo: CoinRepository
    func callAsFunction(category: MarketCategory, page: Int, pageSize: Int) async throws -> [Coin] {
        if category == .trending { return try await repo.trendingCoins() }
        return try await repo.marketCoins(category: category, page: page, pageSize: pageSize)
    }
}

struct FetchCoinDetailUseCase {
    let repo: CoinRepository
    func callAsFunction(id: String) async throws -> CoinDetail {
        try await repo.coinDetail(id: id)
    }
}

struct FetchCoinHistoryUseCase {
    let repo: CoinRepository
    func callAsFunction(id: String, days: String) async throws -> [PricePoint] {
        try await repo.history(id: id, days: days)
    }
}
