import Foundation
import SwiftUI
import Combine

@MainActor
final class CoinDetailViewModel: ObservableObject {
    @Published var state: Loadable<CoinDetail> = .idle
    @Published var history: [PricePoint] = []
    @Published var selectedRange: HistoryRange = .day7
    @Published var isDescriptionExpanded = false
    
    private let fetchDetail: FetchCoinDetailUseCase
    private let fetchHistory: FetchCoinHistoryUseCase
    private let coinID: String
    
    init(
        coinID: String,
        fetchDetail: FetchCoinDetailUseCase,
        fetchHistory: FetchCoinHistoryUseCase
    ) {
        self.coinID = coinID
        self.fetchDetail = fetchDetail
        self.fetchHistory = fetchHistory
    }
    
    func load() async {
        state = .loading
        
        do {
            let detail = try await fetchDetail(id: coinID)
            let hist = try await fetchHistory(id: coinID, range: selectedRange)
            self.history = hist
            self.state = .loaded(detail)
        } catch {
            state = .failed(.unknown(error.localizedDescription))
        }
    }
    
    func changeRange(_ range: HistoryRange) async {
        selectedRange = range
        do {
            let hist = try await fetchHistory(id: coinID, range: range)
            withAnimation {
                self.history = hist
            }
        } catch {
            print("Failed to load chart for new range: \(error)")
        }
    }
}
