import Foundation

protocol AlertRepository {
    func allAlerts() throws -> [PriceAlertModel]

    func createAlert(coinId: String, symbol: String, targetPrice: Double, type: AlertType) throws
    func deleteAlert(id: UUID) throws
    func setEnabled(id: UUID, isEnabled: Bool) throws
}
