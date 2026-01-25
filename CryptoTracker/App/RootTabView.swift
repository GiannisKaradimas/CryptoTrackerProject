import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        TabView {
            // Market
            MarketOverviewView(
                vm: MarketOverviewViewModel(fetchMarket: container.fetchMarketCoins)
            )
            .tabItem {
                Label("Market", systemImage: "chart.line.uptrend.xyaxis")
            }

            // Watchlists
            WatchlistsView()
                .tabItem {
                    Label("Watchlists", systemImage: "star")
                }

            // Portfolio
            PortfolioView()
                .tabItem {
                    Label("Portfolio", systemImage: "briefcase")
                }

            // Alerts
            AlertsView()
                .tabItem {
                    Label("Alerts", systemImage: "bell")
                }
        }
    }
}

