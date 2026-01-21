import Foundation

/// Simple DI container.
/// In a larger app you may replace this with a more formal DI framework.
final class AppContainer: ObservableObject {
    let api: CoinGeckoAPI
    let persistence: PersistenceController

    // Repositories
    let coinRepository: CoinRepository
    let watchlistRepository: WatchlistRepository
    let portfolioRepository: PortfolioRepository
    let alertRepository: AlertRepository

    // Use cases
    lazy var fetchMarketCoins = FetchMarketCoinsUseCase(repo: coinRepository)
    lazy var fetchCoinDetail = FetchCoinDetailUseCase(repo: coinRepository)
    lazy var fetchCoinHistory = FetchCoinHistoryUseCase(repo: coinRepository)

    init() {
        self.persistence = PersistenceController.shared
        let http = HTTPClient()
        self.api = CoinGeckoAPI(http: http)

        self.coinRepository = DefaultCoinRepository(api: api, cache: persistence)
        self.watchlistRepository = CoreDataWatchlistRepository(persistence: persistence)
        self.portfolioRepository = CoreDataPortfolioRepository(persistence: persistence)
        self.alertRepository = CoreDataAlertRepository(persistence: persistence)
    }
}
