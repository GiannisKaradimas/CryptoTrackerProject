import Foundation
import Combine

@MainActor
final class CoinDetailViewModel: ObservableObject {
    private(set) var detailState: Loadable<CoinDetail> = .idle
    private(set) var historyState: Loadable<[PricePoint]> = .idle
    var range: HistoryRange = .d7

    private let coinID: String
    private let fetchDetail: FetchCoinDetailUseCase
    private let fetchHistory: FetchCoinHistoryUseCase

    init(coinID: String, fetchDetail: FetchCoinDetailUseCase, fetchHistory: FetchCoinHistoryUseCase) {
        self.coinID = coinID
        self.fetchDetail = fetchDetail
        self.fetchHistory = fetchHistory
    }

    func load() async {
        await loadDetail()
        await loadHistory()
    }

    func loadDetail() async {
        detailState = .loading
        do { detailState = .loaded(try await fetchDetail(id: coinID)) }
        catch let e as AppError { detailState = .failed(e) }
        catch { detailState = .failed(.unknown(error.localizedDescription)) }
    }

    func loadHistory() async {
        historyState = .loading
        do { historyState = .loaded(try await fetchHistory(id: coinID, range: range)) }
        catch let e as AppError { historyState = .failed(e) }
        catch { historyState = .failed(.unknown(error.localizedDescription)) }
    }
}

