import Foundation

struct FetchMarketCoinsUseCase {
    let repo: CoinRepository
    func callAsFunction(category: MarketCategory, page: Int, perPage: Int) async throws -> [Coin] {
        try await repo.fetchMarket(category: category, page: page, perPage: perPage)
    }
}

struct FetchCoinDetailUseCase {
    let repo: CoinRepository
    func callAsFunction(id: String) async throws -> CoinDetail {
        try await repo.fetchCoinDetail(id: id)
    }
}

struct FetchCoinHistoryUseCase {
    let repo: CoinRepository
    func callAsFunction(id: String, range: HistoryRange) async throws -> [PricePoint] {
        try await repo.fetchHistory(id: id, days: range)
    }
}
