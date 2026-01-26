import SwiftUI
import Charts

struct CoinDetailView: View {
    let coinId: String
    let coinName: String

    @StateObject private var vm: CoinDetailViewModel

    init(coinId: String,
         coinName: String,
         fetchDetail: FetchCoinDetailUseCase,
         fetchHistory: FetchCoinHistoryUseCase) {

        self.coinId = coinId
        self.coinName = coinName
        _vm = StateObject(wrappedValue: CoinDetailViewModel(
            coinID: coinId,
            fetchDetail: fetchDetail,
            fetchHistory: fetchHistory
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                detailSection
                chartSection
            }
            .padding()
        }
        .navigationTitle(coinName)
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load() }
        .onChange(of: vm.range, perform: { _ in
            Task { await vm.loadHistory() }
        })
    }

    @ViewBuilder private var detailSection: some View {
        switch vm.detailState {
        case .idle, .loading:
            ProgressView()
        case .failed(let e):
            Text(e.localizedDescription)
        case .loaded(let d):
            HStack(spacing: 12) {
                AsyncImage(url: d.imageURL) { $0.resizable().scaledToFit() } placeholder: { ProgressView() }
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading) {
                    Text(d.name).font(.title2).bold()
                    Text(d.symbol).foregroundStyle(.secondary)
                }
            }

            if let txt = d.description, !txt.isEmpty {
                Text(txt).lineLimit(6)
            }

            if let url = d.homepageURL {
                Link("Website", destination: url)
            }
        }
    }

    @ViewBuilder private var chartSection: some View {
        Picker("Range", selection: $vm.range) {
            Text("24h").tag(HistoryRange.h24)
            Text("7d").tag(HistoryRange.d7)
            Text("30d").tag(HistoryRange.d30)
            Text("1y").tag(HistoryRange.y1)
        }
        .pickerStyle(.segmented)

        switch vm.historyState {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity)
        case .failed(let e):
            Text(e.localizedDescription)
        case .loaded(let points):
            Chart(points) { p in
                LineMark(x: .value("Date", p.date), y: .value("Price", p.priceUSD))
            }
            .frame(height: 220)
        }
    }
}
