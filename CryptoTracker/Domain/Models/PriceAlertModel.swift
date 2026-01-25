import Foundation

struct PriceAlertModel: Identifiable, Codable, Equatable {
    let id: UUID
    let coinId: String
    let symbol: String
    let targetPrice: Double
    let type: AlertType
    var isEnabled: Bool
    let createdAt: Date

    init(
        id: UUID = UUID(),
        coinId: String,
        symbol: String,
        targetPrice: Double,
        type: AlertType,
        isEnabled: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.coinId = coinId
        self.symbol = symbol
        self.targetPrice = targetPrice
        self.type = type
        self.isEnabled = isEnabled
        self.createdAt = createdAt
    }
}
