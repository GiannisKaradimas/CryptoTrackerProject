import CoreData

// NOTE: Generate these from Xcode (Editor > Create NSManagedObject Subclass...)
// after creating CryptoTrackerModel.xcdatamodeld.
// This file exists to make the template compile *after* generation.
// Remove it once Xcode generates the real classes.

@objc(CacheEntry) public class CacheEntry: NSManagedObject {}
@objc(Watchlist) public class Watchlist: NSManagedObject {}
@objc(WatchlistItem) public class WatchlistItem: NSManagedObject {}
@objc(Holding) public class Holding: NSManagedObject {}
@objc(PriceAlert) public class PriceAlert: NSManagedObject {}

extension CacheEntry {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CacheEntry> {
        NSFetchRequest<CacheEntry>(entityName: "CacheEntry")
    }
    @NSManaged public var key: String?
    @NSManaged public var data: Data?
    @NSManaged public var updatedAt: Date?
}

extension Watchlist {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Watchlist> {
        NSFetchRequest<Watchlist>(entityName: "Watchlist")
    }
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var items: NSSet?
}

extension WatchlistItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WatchlistItem> {
        NSFetchRequest<WatchlistItem>(entityName: "WatchlistItem")
    }
    @NSManaged public var id: UUID?
    @NSManaged public var coinId: String?
    @NSManaged public var addedAt: Date?
    @NSManaged public var watchlist: Watchlist?
}

extension Holding {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Holding> {
        NSFetchRequest<Holding>(entityName: "Holding")
    }
    @NSManaged public var id: UUID?
    @NSManaged public var coinId: String?
    @NSManaged public var coinSymbol: String?
    @NSManaged public var coinName: String?
    @NSManaged public var quantity: Double
    @NSManaged public var purchasePrice: Double
    @NSManaged public var purchasedAt: Date?
}

extension PriceAlert {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PriceAlert> {
        NSFetchRequest<PriceAlert>(entityName: "PriceAlert")
    }
    @NSManaged public var id: UUID?
    @NSManaged public var coinId: String?
    @NSManaged public var coinSymbol: String?
    @NSManaged public var targetPrice: Double
    @NSManaged public var type: String?
    @NSManaged public var isEnabled: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var lastTriggeredAt: Date?
}
