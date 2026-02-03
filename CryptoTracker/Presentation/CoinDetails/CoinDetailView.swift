import SwiftUI

struct CoinDetailView: View {
    @StateObject private var vm: CoinDetailViewModel
    let coin: Coin
    
    init(
        coin: Coin,
        fetchDetail: FetchCoinDetailUseCase,
        fetchHistory: FetchCoinHistoryUseCase
    ) {
        _vm = StateObject(
            wrappedValue: CoinDetailViewModel(
                coinID: coin.id,
                fetchDetail: fetchDetail,
                fetchHistory: fetchHistory
            )
        )
        self.coin = coin
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                Text("$\(coin.currentPriceUSD ?? 0, specifier: "%.2f")")
                    .font(.system(size: 32, weight: .bold))
                
                
                CoinPriceChart(data: vm.history)
                
                Picker("", selection: $vm.selectedRange) {
                    ForEach(HistoryRange.allCases, id: \.self) {
                        Text($0.title)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: vm.selectedRange) { range in
                    Task { await vm.changeRange(range) }
                }
                
                Divider()
                
                if case let .loaded(detail) = vm.state {
                    ExpandableDescription(
                        isExpanded: $vm.isDescriptionExpanded,
                        text: detail.description ?? "No description."
                    )
                
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Market Stats")
                            .font(.title2).bold()
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            
                            CoinStatCard(
                                title: "Market Cap",
                                value: detail.marketCapUSD?.formattedWithAbbreviations() ?? "--"
                            )
                            
                            CoinStatCard(
                                title: "Volume 24h",
                                value: detail.volumeUSD?.formattedWithAbbreviations() ?? "--"
                            )
                            
                            CoinStatCard(
                                title: "Circulating Supply",
                                value: detail.circulatingSupply?.formattedWithAbbreviations() ?? "--"
                            )
                            
                            CoinStatCard(
                                title: "Max Supply",
                                value: detail.maxSupply?.formattedWithAbbreviations() ?? "--"
                            )
                            
                            CoinStatCard(
                                title: "All-Time High",
                                value: detail.athUSD?.formattedAsPrice() ?? "--"
                            )
                            
                            CoinStatCard(
                                title: "All-Time Low",
                                value: detail.atlUSD?.formattedAsPrice() ?? "--"
                            )
                        }
                    }
                    .padding(.top, 16)
                    
                    VStack(alignment: .leading, spacing: 16) {
                            Text("Price Change")
                                .font(.title2).bold()

                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {

                                PriceChangeStatCard(
                                    title: "24h",
                                    value: detail.priceChange24h
                                )

                                PriceChangeStatCard(
                                    title: "7d",
                                    value: detail.priceChange7d
                                )

                                PriceChangeStatCard(
                                    title: "30d",
                                    value: detail.priceChange30d
                                )

                                PriceChangeStatCard(
                                    title: "1y",
                                    value: detail.priceChange1y
                                )
                            }
                        }
                        .padding(.top, 16)
                    }
                }
            .padding()
        }
        .navigationTitle(coin.name)
        .task { await vm.load() }
    }
}
