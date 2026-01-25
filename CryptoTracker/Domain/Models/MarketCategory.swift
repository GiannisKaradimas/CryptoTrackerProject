import Foundation

enum MarketCategory: String, CaseIterable, Identifiable {
    case top100
    case gainers
    case losers
    case trending

    var id: String { rawValue }
}
