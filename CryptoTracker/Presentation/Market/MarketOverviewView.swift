import SwiftUI

struct MarketOverviewView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var vm: MarketOverviewViewModel

    init() {
        _vm = StateObject(wrappedValue: MarketOverviewViewModel(fetchMarket: AppContainer().fetchMarketCoins))
        // NOTE: we rebind in .onAppear with real container (Xcode preview friendliness)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Market")
                .toolbar {
                    Menu {
                        Picker("Category", selection: $vm.category) {
                            ForEach(MarketCategory.allCases) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                .searchable(text: $vm.query, prompt: "Search coins")
                .onChange(of: vm.category) { _, _ in Task { await vm.refresh() } }
                .onChange(of: vm.query) { _, _ in
                    // quick local filtering by reloading current state
                    if case let .loaded(coins) = vm.state { vm.state = .loaded(coins) }
                }
                .task { await bindAndLoadIfNeeded() }
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
                Button("Retry") { Task { await vm.refresh() } }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let coins):
            List(coins) { coin in
                NavigationLink {
                    CoinDetailView(coinId: coin.id, coinName: coin.name)
                } label: {
                    CoinRowView(coin: coin)
                }
                .task { await vm.loadMoreIfNeeded(current: coin) }
            }
            .listStyle(.plain)
            .refreshable { await vm.refresh() }
        }
    }

    private func bindAndLoadIfNeeded() async {
        // Rebind use case from the real environment container
        if vm.state == .idle {
            vm.objectWillChange.send()
            // Hacky: create a new VM using real container, preserving user selections.
            let newVM = MarketOverviewViewModel(fetchMarket: container.fetchMarketCoins)
            newVM.category = vm.category
            newVM.query = vm.query
            _vm.wrappedValue = newVM
            await newVM.refresh()
        }
    }
}

private struct CoinRowView: View {
    let coin: Coin

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: coin.imageURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFit()
                default:
                    RoundedRectangle(cornerRadius: 8).fill(.quaternary)
                }
            }
            .frame(width: 34, height: 34)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(coin.name).font(.headline)
                Text(coin.symbol).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(coin.price, format: .currency(code: "USD")).font(.headline)
                if let ch = coin.change24h {
                    Text(ch / 100, format: .percent)
                        .font(.caption)
                        .foregroundStyle(ch >= 0 ? .green : .red)
                }
            }
        }
    }
}
