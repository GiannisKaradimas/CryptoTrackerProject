import Foundation
import Combine

@MainActor
final class WatchlistsViewModel: ObservableObject {

    @Published private(set) var watchlists: [WatchlistModel] = []
    @Published private(set) var selectedWatchlist: WatchlistModel?

    // Inputs for UI
    @Published var newWatchlistName: String = ""
    @Published var coinIdToAdd: String = ""

    private let repo: WatchlistRepository

    init(repo: WatchlistRepository) {
        self.repo = repo
    }

    // MARK: - Read

    func loadAll() {
        watchlists = (try? repo.allWatchlists()) ?? []
    }

    func loadWatchlist(id: UUID) {
        let all = (try? repo.allWatchlists()) ?? []
        selectedWatchlist = all.first(where: { $0.id == id })
    }

    // MARK: - Watchlists CRUD

    func createWatchlist(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let final = trimmed.isEmpty ? "Watchlist" : trimmed
        try? repo.createWatchlist(name: final)
        loadAll()
    }

    func deleteWatchlists(at offsets: IndexSet) {
        offsets
            .map { watchlists[$0].id }
            .forEach { id in
                try? repo.deleteWatchlist(id: id)
            }
        loadAll()
    }

    // MARK: - Coins in Watchlist

    func addCoin(to watchlistId: UUID) {
        let id = coinIdToAdd.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty else { return }
        try? repo.addCoin(coinId: id, to: watchlistId)
        coinIdToAdd = ""
        loadWatchlist(id: watchlistId)
        loadAll()
    }

    func removeCoins(from watchlistId: UUID, at offsets: IndexSet) {
        guard let wl = selectedWatchlist else { return }
        offsets
            .map { wl.coinIds[$0] }
            .forEach { coinId in
                try? repo.removeCoin(coinId: coinId, from: watchlistId)
            }
        loadWatchlist(id: watchlistId)
        loadAll()
    }
}
