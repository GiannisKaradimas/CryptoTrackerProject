import Foundation

final class UserDefaultsAlertRepository: AlertRepository {
    private let key = "alerts.v1"
    private let store = UserDefaultsStore.shared

    func allAlerts() throws -> [PriceAlertModel] {
        store.load(key, as: [PriceAlertModel].self) ?? []
    }

    func createAlert(coinId: String, symbol: String, targetPrice: Double, type: AlertType) throws {
        var all = try allAlerts()
        all.append(PriceAlertModel(coinId: coinId, symbol: symbol, targetPrice: targetPrice, type: type))
        store.save(all, key: key)
    }

    func deleteAlert(id: UUID) throws {
        var all = try allAlerts()
        all.removeAll { $0.id == id }
        store.save(all, key: key)
    }

    func setEnabled(id: UUID, isEnabled: Bool) throws {
        var all = try allAlerts()
        guard let idx = all.firstIndex(where: { $0.id == id }) else { return }
        all[idx].isEnabled = isEnabled
        store.save(all, key: key)
    }
}
