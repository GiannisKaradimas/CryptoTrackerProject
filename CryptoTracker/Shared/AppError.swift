import Foundation

enum AppError: LocalizedError, Equatable {
    case network(String)
    case decoding(String)
    case rateLimited(retryAfterSeconds: Int?)
    case persistence(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .network(let msg): return msg
        case .decoding(let msg): return msg
        case .rateLimited(let s):
            if let s { return "Rate limited. Try again in \(s)s." }
            return "Rate limited. Please try again."
        case .persistence(let msg): return msg
        case .unknown(let msg): return msg
        }
    }
}
