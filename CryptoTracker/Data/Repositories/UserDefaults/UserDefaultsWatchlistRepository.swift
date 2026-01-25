import Foundation

final class UserDefaultsWatchlistRepository: WatchlistRepository {
    private let key = "watchlists.v1"
    private let store = UserDefaultsStore.shared

    func allWatchlists() throws -> [WatchlistModel] {
        store.load(key, as: [WatchlistModel].self) ?? []
    }

    func createWatchlist(name: String) throws {
        var all = try allWatchlists()
        all.append(WatchlistModel(name: name))
        store.save(all, key: key)
    }

    func renameWatchlist(id: UUID, name: String) throws {
        var all = try allWatchlists()
        guard let idx = all.firstIndex(where: { $0.id == id }) else { return }
        all[idx].name = name
        store.save(all, key: key)
    }

    func deleteWatchlist(id: UUID) throws {
        var all = try allWatchlists()
        all.removeAll { $0.id == id }
        store.save(all, key: key)
    }

    func addCoin(coinId: String, to watchlistId: UUID) throws {
        var all = try allWatchlists()
        guard let idx = all.firstIndex(where: { $0.id == watchlistId }) else { return }
        if !all[idx].coinIds.contains(coinId) {
            all[idx].coinIds.append(coinId)
            store.save(all, key: key)
        }
    }

    func removeCoin(coinId: String, from watchlistId: UUID) throws {
        var all = try allWatchlists()
        guard let idx = all.firstIndex(where: { $0.id == watchlistId }) else { return }
        all[idx].coinIds.removeAll { $0 == coinId }
        store.save(all, key: key)
    }
}
