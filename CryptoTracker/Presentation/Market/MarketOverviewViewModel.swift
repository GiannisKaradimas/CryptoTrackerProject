import Foundation
import Combine

@MainActor
final class MarketOverviewViewModel: ObservableObject {
    @Published private(set) var state: Loadable<[Coin]> = .idle
    @Published var query: String = ""
    @Published var category: MarketCategory = .top100

    private let fetchMarket: FetchMarketCoinsUseCase
    private var page = 1
    private let perPage = 50
    private var canLoadMore = true
    private var all: [Coin] = []

    init(fetchMarket: FetchMarketCoinsUseCase) {
        self.fetchMarket = fetchMarket
    }

    func loadFirstPage() async {
        page = 1
        canLoadMore = true
        all = []
        state = .loading
        await loadMoreIfNeeded(force: true)
    }

    func loadMoreIfNeeded(currentItem: Coin? = nil, force: Bool = false) async {
        guard canLoadMore else { return }
        if !force, let currentItem, currentItem.id != all.last?.id { return }

        do {
            let new = try await fetchMarket(category: category, page: page, perPage: perPage)
            if new.isEmpty { canLoadMore = false }
            all.append(contentsOf: new)
            page += 1
            state = .loaded(filtered(all))
        } catch let err as AppError {
            state = .failed(err)
        } catch {
            state = .failed(.unknown(error.localizedDescription))
        }
    }

    func applyQuery() {
        if case .loaded = state {
            state = .loaded(filtered(all))
        }
    }

    private func filtered(_ coins: [Coin]) -> [Coin] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return coins }
        return coins.filter { $0.name.lowercased().contains(q) || $0.symbol.lowercased().contains(q) }
    }
}
