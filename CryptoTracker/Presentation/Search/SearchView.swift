import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var vm: SearchViewModel

    init() {
        _vm = StateObject(wrappedValue: SearchViewModel(fetchMarket: AppContainer().fetchMarketCoins))
    }

    var body: some View {
        NavigationStack {
            Group {
                switch vm.state {
                case .idle:
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Search history").font(.headline)
                        ForEach(vm.history, id: \.self) { item in
                            Button(item) { vm.query = item; Task { await vm.search() } }
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Spacer()
                    }
                    .padding()
                case .loading:
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                case .failed(let err):
                    VStack(spacing: 12) {
                        Text(err.localizedDescription)
                        Button("Retry") { Task { await vm.search() } }
                    }
                    .padding()
                case .loaded(let coins):
                    if vm.isGrid {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
                                ForEach(coins) { coin in
                                    NavigationLink {
                                        CoinDetailView(coinId: coin.id, coinName: coin.name)
                                    } label: {
                                        CoinGridCard(coin: coin)
                                    }
                                }
                            }
                            .padding()
                        }
                    } else {
                        List(coins) { coin in
                            NavigationLink {
                                CoinDetailView(coinId: coin.id, coinName: coin.name)
                            } label: {
                                Text("\(coin.name) (\(coin.symbol))")
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Search")
            .toolbar {
                Button { vm.isGrid.toggle() } label: {
                    Image(systemName: vm.isGrid ? "list.bullet" : "square.grid.2x2")
                }
            }
            .searchable(text: $vm.query)
            .onSubmit(of: .search) { Task { await vm.search() } }
            .task { _vm.wrappedValue = SearchViewModel(fetchMarket: container.fetchMarketCoins) }
        }
    }
}

private struct CoinGridCard: View {
    let coin: Coin
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AsyncImage(url: coin.imageURL) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFit()
                    default: RoundedRectangle(cornerRadius: 8).fill(.quaternary)
                    }
                }
                .frame(width: 28, height: 28)
                Spacer()
            }
            Text(coin.name).font(.headline).lineLimit(1)
            Text(coin.symbol).font(.caption).foregroundStyle(.secondary)
            Text(coin.price, format: .currency(code: "USD")).font(.subheadline)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
