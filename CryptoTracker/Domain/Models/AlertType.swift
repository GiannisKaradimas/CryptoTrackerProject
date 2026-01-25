import Foundation

enum AlertType: String, CaseIterable, Identifiable, Codable {
    case above
    case below

    var id: String { rawValue }
}
