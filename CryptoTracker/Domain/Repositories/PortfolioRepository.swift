import Foundation

protocol PortfolioRepository {
    func allHoldings() throws -> [HoldingModel]
    func addHolding(_ holding: HoldingModel) throws
    func deleteHolding(id: UUID) throws
}
