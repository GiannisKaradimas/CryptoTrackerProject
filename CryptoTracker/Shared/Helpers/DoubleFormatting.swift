import Foundation

extension Double {
    func formattedWithAbbreviations() -> String {
        let num = abs(self)
        let sign = self < 0 ? "-" : ""

        switch num {
        case 1_000_000_000...:
            return "\(sign)\((num / 1_000_000_000).rounded(toPlaces: 2))B"
        case 1_000_000...:
            return "\(sign)\((num / 1_000_000).rounded(toPlaces: 2))M"
        case 1_000...:
            return "\(sign)\((num / 1_000).rounded(toPlaces: 2))K"
        default:
            return "\(sign)\(self.rounded(toPlaces: 2))"
        }
    }

    func formattedAsPrice() -> String {
        "$" + String(format: "%.2f", self)
    }

    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func asPercentString() -> String {
            String(format: "%.2f%%", self)
    }
}

