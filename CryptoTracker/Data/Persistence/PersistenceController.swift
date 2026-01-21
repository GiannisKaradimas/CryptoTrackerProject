import CoreData
import Foundation

/// Core Data stack + lightweight caching.
/// You still need to create a .xcdatamodeld named **CryptoTrackerModel**
/// with entities described in `README_CoreData.md`.
final class PersistenceController: CoinCache {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext { container.viewContext }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CryptoTrackerModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Unresolved Core Data error: \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func saveIfNeeded() throws {
        let ctx = viewContext
        if ctx.hasChanges { try ctx.save() }
    }

    // MARK: - CoinCache

    func cacheMarketCoins(_ coins: [Coin], key: String) throws {
        // Store as JSON blob in CacheEntry
        let ctx = viewContext
        let entry = try fetchOrCreateCacheEntry(key: key, ctx: ctx)
        let data = try JSONEncoder().encode(coins.map(CoinCodable.init))
        entry.data = data
        entry.updatedAt = Date()
        try saveIfNeeded()
    }

    func cachedMarketCoins(key: String) throws -> [Coin] {
        let ctx = viewContext
        let req: NSFetchRequest<CacheEntry> = CacheEntry.fetchRequest()
        req.predicate = NSPredicate(format: "key == %@", key)
        req.fetchLimit = 1
        guard let entry = try ctx.fetch(req).first, let data = entry.data else { return [] }
        let decoded = try JSONDecoder().decode([CoinCodable].self, from: data)
        return decoded.map { $0.toDomain() }
    }

    func cacheHistory(_ points: [PricePoint], coinId: String, days: String) throws {
        let key = "history_\(coinId)_\(days)"
        let ctx = viewContext
        let entry = try fetchOrCreateCacheEntry(key: key, ctx: ctx)
        let data = try JSONEncoder().encode(points.map(PricePointCodable.init))
        entry.data = data
        entry.updatedAt = Date()
        try saveIfNeeded()
    }

    func cachedHistory(coinId: String, days: String) throws -> [PricePoint] {
        let key = "history_\(coinId)_\(days)"
        let ctx = viewContext
        let req: NSFetchRequest<CacheEntry> = CacheEntry.fetchRequest()
        req.predicate = NSPredicate(format: "key == %@", key)
        req.fetchLimit = 1
        guard let entry = try ctx.fetch(req).first, let data = entry.data else { return [] }
        let decoded = try JSONDecoder().decode([PricePointCodable].self, from: data)
        return decoded.map { $0.toDomain() }
    }

    private func fetchOrCreateCacheEntry(key: String, ctx: NSManagedObjectContext) throws -> CacheEntry {
        let req: NSFetchRequest<CacheEntry> = CacheEntry.fetchRequest()
        req.predicate = NSPredicate(format: "key == %@", key)
        req.fetchLimit = 1
        if let existing = try ctx.fetch(req).first { return existing }
        let entry = CacheEntry(context: ctx)
        entry.key = key
        entry.updatedAt = Date()
        return entry
    }
}

// MARK: - Codable helpers for caching (keeps Core Data model simple)

private struct CoinCodable: Codable {
    let id: String
    let symbol: String
    let name: String
    let imageURL: String?
    let price: Double
    let change24h: Double?
    let marketCapRank: Int?
    let sparkline7d: [Double]?

    init(_ c: Coin) {
        id = c.id; symbol = c.symbol; name = c.name
        imageURL = c.imageURL?.absoluteString
        price = c.price; change24h = c.change24h
        marketCapRank = c.marketCapRank; sparkline7d = c.sparkline7d
    }
    func toDomain() -> Coin {
        Coin(id: id, symbol: symbol, name: name, imageURL: imageURL.flatMap(URL.init(string:)),
             price: price, change24h: change24h, marketCapRank: marketCapRank, sparkline7d: sparkline7d)
    }
}

private struct PricePointCodable: Codable {
    let t: Double
    let p: Double
    init(_ pp: PricePoint) { t = pp.date.timeIntervalSince1970; p = pp.price }
    func toDomain() -> PricePoint { PricePoint(date: Date(timeIntervalSince1970: t), price: p) }
}
