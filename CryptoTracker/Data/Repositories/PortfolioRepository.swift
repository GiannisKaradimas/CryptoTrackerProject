import Foundation

struct PortfolioSummary: Equatable {
    let totalValue: Double
    let totalCost: Double
    var profitLoss: Double { totalValue - totalCost }
    var profitLossPct: Double { totalCost == 0 ? 0 : (profitLoss / totalCost) * 100 }
}

protocol PortfolioRepository {
    func addHolding(coinId: String, symbol: String, name: String, quantity: Double, purchasePrice: Double, date: Date) throws
    func deleteHolding(id: UUID) throws
    func allHoldings() throws -> [Holding]
}
