import CoreData
import Foundation

final class CoreDataWatchlistRepository: WatchlistRepository {
    private let persistence: PersistenceController
    private var ctx: NSManagedObjectContext { persistence.viewContext }

    init(persistence: PersistenceController) {
        self.persistence = persistence
    }

    func createWatchlist(name: String) throws {
        let wl = Watchlist(context: ctx)
        wl.id = UUID()
        wl.name = name
        wl.createdAt = Date()
        try persistence.saveIfNeeded()
    }

    func renameWatchlist(id: UUID, name: String) throws {
        guard let wl = try fetchWatchlist(id: id) else { return }
        wl.name = name
        try persistence.saveIfNeeded()
    }

    func deleteWatchlist(id: UUID) throws {
        guard let wl = try fetchWatchlist(id: id) else { return }
        ctx.delete(wl)
        try persistence.saveIfNeeded()
    }

    func addCoin(coinId: String, to watchlistId: UUID) throws {
        guard let wl = try fetchWatchlist(id: watchlistId) else { return }
        let item = WatchlistItem(context: ctx)
        item.id = UUID()
        item.coinId = coinId
        item.addedAt = Date()
        item.watchlist = wl
        try persistence.saveIfNeeded()
    }

    func removeCoin(coinId: String, from watchlistId: UUID) throws {
        let req: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        req.predicate = NSPredicate(format: "watchlist.id == %@ AND coinId == %@", watchlistId as CVarArg, coinId)
        req.fetchLimit = 1
        if let item = try ctx.fetch(req).first {
            ctx.delete(item)
            try persistence.saveIfNeeded()
        }
    }

    private func fetchWatchlist(id: UUID) throws -> Watchlist? {
        let req: NSFetchRequest<Watchlist> = Watchlist.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        req.fetchLimit = 1
        return try ctx.fetch(req).first
    }
}
