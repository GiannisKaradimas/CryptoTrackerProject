import Foundation
import SwiftUI
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var state: Loadable<[Coin]> = .idle
    @Published var isGrid: Bool = false

    @AppStorage("search_history") private var historyRaw: String = ""
    var history: [String] {
        historyRaw.split(separator: "|").map(String.init)
    }

    private let fetchMarket: FetchMarketCoinsUseCase

    init(fetchMarket: FetchMarketCoinsUseCase) {
        self.fetchMarket = fetchMarket
    }

    func search() async {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard q.count >= 2 else {
            state = .idle
            return
        }
        state = .loading
        do {
            // Quick approach: pull top 250 and filter locally.
            // For production, add CoinGecko /search endpoint with paging.
            let coins = try await fetchMarket(category: .top100, page: 1, perPage: 250)
            let filtered = coins.filter { $0.name.lowercased().contains(q.lowercased()) || $0.symbol.lowercased().contains(q.lowercased()) }
            state = .loaded(filtered)
            saveHistory(q)
        } catch let e as AppError {
            state = .failed(e)
        } catch {
            state = .failed(.unknown("Search failed."))
        }
    }

    private func saveHistory(_ q: String) {
        var items = history
        items.removeAll(where: { $0.caseInsensitiveCompare(q) == .orderedSame })
        items.insert(q, at: 0)
        items = Array(items.prefix(10))
        historyRaw = items.joined(separator: "|")
    }
}
