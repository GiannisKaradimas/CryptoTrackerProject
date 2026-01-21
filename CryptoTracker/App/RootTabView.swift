import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            MarketOverviewView()
                .tabItem { Label("Market", systemImage: "chart.line.uptrend.xyaxis") }

            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            WatchlistsView()
                .tabItem { Label("Watchlists", systemImage: "star") }

            PortfolioView()
                .tabItem { Label("Portfolio", systemImage: "briefcase") }

            AlertsView()
                .tabItem { Label("Alerts", systemImage: "bell") }
        }
    }
}
