import SwiftUI
import Foundation

struct SearchView: View {
    @StateObject private var vm: SearchViewModel

    // Inject the UseCase from RootTabView
    init(fetchMarket: FetchMarketCoinsUseCase) {
        _vm = StateObject(wrappedValue: SearchViewModel(fetchMarket: fetchMarket))
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Search")
                .toolbar {
                    Button { vm.isGrid.toggle() } label: {
                        Image(systemName: vm.isGrid ? "list.bullet" : "square.grid.2x2")
                    }
                }
                .searchable(text: $vm.query, prompt: "Search coins (e.g. bitcoin)")
                .onSubmit(of: .search) { Task { await vm.search() } }

                }
        }
    

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle:
            historyView

        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let err):
            VStack(spacing: 12) {
                Text(err.localizedDescription)
                    .multilineTextAlignment(.center)
                Button("Retry") { Task { await vm.search() } }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded(let coins):
            if vm.isGrid {
                gridResults(coins)
                
            } else {
                listResults(coins)
            }
        }
    }

    private var historyView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Search history").font(.headline)

            if vm.history.isEmpty {
                Text("No recent searches")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(vm.history, id: \.self) { item in
                    Button {
                        vm.query = item
                        Task { await vm.search() }
                    } label: {
                        Text(item)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func gridResults(_ coins: [Coin]) -> some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 160), spacing: 12)],
                spacing: 12
            ) {
                // :white_check_mark: explicit id eliminates overload ambiguity
                ForEach(coins, id: \.id) { coin in
                    NavigationLink {
                        CoinDetailView(coinId: coin.id, coinName: coin.name)
                    } label: {
                        CoinGridCard(coin: coin)
                    }
                }
            }
            .padding()
        }
    }

    private func listResults(_ coins: [Coin]) -> some View {
        // :white_check_mark: explicit id eliminates overload ambiguity
        List(coins, id: \.id) { coin in
            NavigationLink {
                CoinDetailView(coinId: coin.id, coinName: coin.name)
            } label: {
                row(coin)
            }
        }
        .listStyle(.plain)
    }

    private func row(_ coin: Coin) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: coin.imageURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFit()
                default:
                    RoundedRectangle(cornerRadius: 8).fill(.quaternary)
                }
            }
            .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(coin.name).font(.headline).lineLimit(1)
                Text(coin.symbol).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            if let price = coin.currentPriceUSD {
                Text(price, format: .currency(code: "USD"))
                    .font(.subheadline)
            } else {
                Text("--")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct CoinGridCard: View {
    let coin: Coin

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AsyncImage(url: coin.imageURL) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFit()
                    default:
                        RoundedRectangle(cornerRadius: 8).fill(.quaternary)
                    }
                }
                .frame(width: 28, height: 28)

                Spacer()
            }

            Text(coin.name).font(.headline).lineLimit(1)
            Text(coin.symbol).font(.caption).foregroundStyle(.secondary)

            if let price = coin.currentPriceUSD {
                Text(price, format: .currency(code: "USD"))
                    .font(.subheadline)
            } else {
                Text("--")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
