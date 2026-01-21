# Core Data model (CryptoTrackerModel.xcdatamodeld)

Create a model named **CryptoTrackerModel** with these entities.

## CacheEntry
- key: String (Indexed, Unique if you want)
- data: Binary Data (Allows External Storage)
- updatedAt: Date

## Watchlist
- id: UUID
- name: String
- createdAt: Date
Relationship:
- items (to-many) -> WatchlistItem, delete rule: Cascade

## WatchlistItem
- id: UUID
- coinId: String
- addedAt: Date
Relationship:
- watchlist (to-one) -> Watchlist, inverse: items, delete rule: Nullify

## Holding
- id: UUID
- coinId: String
- coinSymbol: String
- coinName: String
- quantity: Double
- purchasePrice: Double
- purchasedAt: Date

## PriceAlert
- id: UUID
- coinId: String
- coinSymbol: String
- targetPrice: Double
- type: String  // "above" | "below"
- isEnabled: Bool
- createdAt: Date
- lastTriggeredAt: Date? (Optional)
