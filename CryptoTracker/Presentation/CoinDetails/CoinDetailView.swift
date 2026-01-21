import SwiftUI
import Charts

struct CoinDetailView: View {
    @EnvironmentObject private var container: AppContainer
    let coinId: String
    let coinName: String

    @StateObject private var vm: CoinDetailViewModel

    init(coinId: String, coinName: String) {
        self.coinId = coinId
        self.coinName = coinName
        _vm = StateObject(wrappedValue: CoinDetailViewModel(
            coinId: coinId,
            fetchDetail: AppContainer().fetchCoinDetail,
            fetchHistory: AppContainer().fetchCoinHistory
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                chartCard

                statsCard

                linksCard

                descriptionCard
            }
            .padding()
        }
        .navigationTitle(coinName)
        .navigationBarTitleDisplayMode(.inline)
        .task { await bindAndLoad() }
        .onChange(of: vm.range) { _, _ in Task { await vm.loadHistory() } }
    }

    @ViewBuilder
    private var header: some View {
        switch vm.detail {
        case .loaded(let d):
            HStack(spacing: 12) {
                AsyncImage(url: d.imageURL) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFit()
                    default: RoundedRectangle(cornerRadius: 12).fill(.quaternary)
                    }
                }
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading) {
                    Text(d.name).font(.title2).bold()
                    Text(d.symbol).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                if let p = d.price {
                    Text(p, format: .currency(code: "USD")).font(.title3).bold()
                }
            }
        default:
            ProgressView().frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Price").font(.headline)
                Spacer()
                Picker("Range", selection: $vm.range) {
                    ForEach(CoinDetailViewModel.HistoryRange.allCases) { r in
                        Text(r.title).tag(r)
                    }
                }
                .pickerStyle(.segmented)
            }

            switch vm.history {
            case .loaded(let points) where !points.isEmpty:
                Chart(points) { p in
                    LineMark(
                        x: .value("Time", p.date),
                        y: .value("Price", p.price)
                    )
                }
                .frame(height: 220)
            case .failed(let err):
                Text(err.localizedDescription).foregroundStyle(.secondary)
            default:
                ProgressView().frame(height: 220)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var statsCard: some View {
        Group {
            if case let .loaded(d) = vm.detail {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Stats").font(.headline)
                    statRow("Market Cap", d.marketCap)
                    statRow("Volume", d.volume)
                    statRow("ATH", d.ath)
                    statRow("ATL", d.atl)
                    if let ch = d.change24h {
                        HStack {
                            Text("24h Change")
                            Spacer()
                            Text(ch / 100, format: .percent)
                                .foregroundStyle(ch >= 0 ? .green : .red)
                        }
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private func statRow(_ title: String, _ value: Double?) -> some View {
        HStack {
            Text(title)
            Spacer()
            if let value { Text(value, format: .currency(code: "USD")) }
            else { Text("—").foregroundStyle(.secondary) }
        }
    }

    private var linksCard: some View {
        Group {
            if case let .loaded(d) = vm.detail {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Links").font(.headline)
                    if let url = d.homepage {
                        Link("Website", destination: url)
                    }
                    if let url = d.subreddit {
                        Link("Subreddit", destination: url)
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private var descriptionCard: some View {
        Group {
            if case let .loaded(d) = vm.detail, let html = d.descriptionHTML, !html.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("About").font(.headline)
                    Text(html.stripHTML().trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(6)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private func bindAndLoad() async {
        // Same preview-friendly binding trick as Market view
        let newVM = CoinDetailViewModel(
            coinId: coinId,
            fetchDetail: container.fetchCoinDetail,
            fetchHistory: container.fetchCoinHistory
        )
        _vm.wrappedValue = newVM
        await newVM.load()
    }
}

private extension String {
    func stripHTML() -> String {
        self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}
