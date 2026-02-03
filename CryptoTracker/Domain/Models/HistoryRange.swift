import Foundation

enum HistoryRange: String, CaseIterable {
    case day1 = "1"
    case day7 = "7"
    case day30 = "30"
    case year1 = "365"
    
    var title: String {
        switch self {
        case .day1: return "24h"
        case .day7: return "7d"
        case .day30: return "30d"
        case .year1: return "1y"
        }
    }
}
