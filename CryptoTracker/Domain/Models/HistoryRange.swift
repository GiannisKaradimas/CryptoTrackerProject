import Foundation

enum HistoryRange: String, CaseIterable, Identifiable {
    case h24 = "1"
    case d7  = "7"
    case d30 = "30"
    case y1  = "365"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .h24: return "24h"
        case .d7:  return "7d"
        case .d30: return "30d"
        case .y1:  return "1y"
        }
    }
}
