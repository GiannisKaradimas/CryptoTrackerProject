import Foundation
import Combine

final class AppContainer: ObservableObject {
    
    let coinRepository: CoinRepository


    let watchlistRepository: WatchlistRepository
    let portfolioRepository: PortfolioRepository
    let alertRepository: AlertRepository

    
    lazy var fetchMarketCoins = FetchMarketCoinsUseCase(repo: coinRepository)
    lazy var fetchCoinDetail = FetchCoinDetailUseCase(repo: coinRepository)
    lazy var fetchCoinHistory = FetchCoinHistoryUseCase(repo: coinRepository)

    init() {
        let apiClient = CoinGeckoClient()
        self.coinRepository = CoinRepositoryImpl(api: apiClient)

        self.watchlistRepository = UserDefaultsWatchlistRepository()
        self.portfolioRepository = UserDefaultsPortfolioRepository()
        self.alertRepository = UserDefaultsAlertRepository()
    }
}
