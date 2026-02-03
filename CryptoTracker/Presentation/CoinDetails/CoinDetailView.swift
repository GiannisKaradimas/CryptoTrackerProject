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
                }
                
                // Related coins θα το προσθέσουμε μετά
            }
            .padding()
        }
        .navigationTitle(coin.name)
        .task { await vm.load() }
    }
}
