import Foundation

enum AlertType: String, CaseIterable, Identifiable {
    case above, below
    var id: String { rawValue }
}

protocol AlertRepository {
    func createAlert(coinId: String, symbol: String, targetPrice: Double, type: AlertType) throws
    func deleteAlert(id: UUID) throws
    func setEnabled(id: UUID, isEnabled: Bool) throws
}
