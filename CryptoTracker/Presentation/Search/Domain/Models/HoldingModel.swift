
import Foundation

struct HoldingModel: Identifiable, Codable, Equatable {
    let id: UUID
    let coinId: String
    let symbol: String
    let name: String
    var quantity: Double
    var purchasePrice: Double
    let createdAt: Date

    init(
        id: UUID = UUID(),
        coinId: String,
        symbol: String,
        name: String,
        quantity: Double,
        purchasePrice: Double,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.coinId = coinId
        self.symbol = symbol
        self.name = name
        self.quantity = quantity
        self.purchasePrice = purchasePrice
        self.createdAt = createdAt
    }
}
