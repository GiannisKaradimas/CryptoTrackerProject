import Foundation

@MainActor
final class CoinDetailViewModel: ObservableObject {
    @Published private(set) var detail: Loadable<CoinDetail> = .idle
    @Published private(set) var history: Loadable<[PricePoint]> = .idle
    @Published var range: HistoryRange = .d7

    enum HistoryRange: String, CaseIterable, Identifiable {
        case d1 = "1"
        case d7 = "7"
        case d30 = "30"
        case y1 = "365"
        var id: String { rawValue }
        var title: String {
            switch self {
            case .d1: return "24h"
            case .d7: return "7d"
            case .d30: return "30d"
            case .y1: return "1y"
            }
        }
    }

    private let coinId: String
    private let fetchDetail: FetchCoinDetailUseCase
    private let fetchHistory: FetchCoinHistoryUseCase

    init(coinId: String, fetchDetail: FetchCoinDetailUseCase, fetchHistory: FetchCoinHistoryUseCase) {
        self.coinId = coinId
        self.fetchDetail = fetchDetail
        self.fetchHistory = fetchHistory
    }

    func load() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadDetail() }
            group.addTask { await self.loadHistory() }
        }
    }

    func loadDetail() async {
        detail = .loading
        do { detail = .loaded(try await fetchDetail(id: coinId)) }
        catch let e as AppError { detail = .failed(e) }
        catch { detail = .failed(.unknown("Failed to load coin.")) }
    }

    func loadHistory() async {
        history = .loading
        do { history = .loaded(try await fetchHistory(id: coinId, days: range.rawValue)) }
        catch let e as AppError { history = .failed(e) }
        catch { history = .failed(.unknown("Failed to load chart.")) }
    }
}
