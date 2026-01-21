import Foundation

protocol WatchlistRepository {
    func createWatchlist(name: String) throws
    func renameWatchlist(id: UUID, name: String) throws
    func deleteWatchlist(id: UUID) throws

    func addCoin(coinId: String, to watchlistId: UUID) throws
    func removeCoin(coinId: String, from watchlistId: UUID) throws
}
