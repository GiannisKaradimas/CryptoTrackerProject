import Foundation
import SwiftUI

@MainActor
final class MarketOverviewViewModel: ObservableObject {
    @Published private(set) var state: Loadable<[Coin]> = .idle
    @Published var category: MarketCategory = .top100
    @Published var query: String = ""

    private var page = 1
    private let pageSize = 50
    private var canLoadMore = true

    private let fetchMarket: FetchMarketCoinsUseCase

    init(fetchMarket: FetchMarketCoinsUseCase) {
        self.fetchMarket = fetchMarket
    }

    func refresh() async {
        page = 1
        canLoadMore = true
        await load(reset: true)
    }

    func loadMoreIfNeeded(current coin: Coin?) async {
        guard let coin, canLoadMore, case let .loaded(coins) = state else { return }
        let thresholdIndex = coins.index(coins.endIndex, offsetBy: -8, limitedBy: coins.startIndex) ?? coins.startIndex
        if coins.firstIndex(where: { $0.id == coin.id }) == thresholdIndex {
            page += 1
            await load(reset: false)
        }
    }

    func load(reset: Bool) async {
        if reset { state = .loading }
        do {
            let result = try await fetchMarket(category: category, page: page, pageSize: pageSize)
            if reset || state.value == nil {
                state = .loaded(applyFilter(result))
            } else if case let .loaded(existing) = state {
                let merged = existing + result
                state = .loaded(applyFilter(merged))
            }
            canLoadMore = !result.isEmpty
        } catch let e as AppError {
            state = .failed(e)
        } catch {
            state = .failed(.unknown("Something went wrong."))
        }
    }

    private func applyFilter(_ coins: [Coin]) -> [Coin] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return coins }
        return coins.filter { $0.name.lowercased().contains(q) || $0.symbol.lowercased().contains(q) }
    }
}
