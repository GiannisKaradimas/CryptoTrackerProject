import SwiftUI

struct MarketOverviewView: View {
    @StateObject var vm: MarketOverviewViewModel

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Market")
                .searchable(text: $vm.query)
                .onChange(of: vm.query) { _ in vm.applyQuery() }
                .toolbar {
                    Menu {
                        Button("Top 100") { vm.category = .top100 }
                        Button("Trending") { vm.category = .trending }
                        Button("Gainers") { vm.category = .gainers }
                        Button("Losers") { vm.category = .losers }
                    } label: {
                        Label("Category", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                .task { await vm.loadFirstPage() }
                .refreshable { await vm.loadFirstPage() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let err):
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                Text(err.localizedDescription).multilineTextAlignment(.center)
                Button("Retry") { Task { await vm.loadFirstPage() } }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let coins):
            if coins.isEmpty {
                ContentUnavailableView("No results", systemImage: "magnifyingglass", description: Text("Try another search."))
            } else {
                List(coins) { coin in
                    CoinRowView(coin: coin)
                        .onAppear { Task { await vm.loadMoreIfNeeded(currentItem: coin) } }
                }
                .listStyle(.plain)
            }
        }
    }
}

struct CoinRowView: View {
    let coin: Coin
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: coin.imageURL) { img in
                img.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 32, height: 32)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(coin.name).font(.headline)
                Text(coin.symbol).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(coin.currentPriceUSD.map { "$" + String(format: "%.2f", $0) } ?? "—")
                    .font(.headline)
                Text(coin.priceChange24hPct.map { String(format: "%.2f%%", $0) } ?? "—")
                    .font(.caption)
                    .foregroundStyle((coin.priceChange24hPct ?? 0) >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 4)
    }
}
