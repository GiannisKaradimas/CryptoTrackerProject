import Foundation

final class UserDefaultsPortfolioRepository: PortfolioRepository {
    private let key = "holdings.v1"
    private let store = UserDefaultsStore.shared

    func allHoldings() throws -> [HoldingModel] {
        store.load(key, as: [HoldingModel].self) ?? []
    }

    func addHolding(_ holding: HoldingModel) throws {
        var all = try allHoldings()
        all.append(holding)
        store.save(all, key: key)
    }

    func deleteHolding(id: UUID) throws {
        var all = try allHoldings()
        all.removeAll { $0.id == id }
        store.save(all, key: key)
    }
}
