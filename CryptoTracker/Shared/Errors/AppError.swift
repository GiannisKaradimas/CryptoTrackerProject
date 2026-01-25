import Foundation

enum AppError: Error, LocalizedError, Equatable {
    case network(NetworkError)
    case decoding
    case rateLimited(retryAfterSeconds: Int?)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .network(let e): return e.localizedDescription
        case .decoding: return "Failed to decode server response."
        case .rateLimited(let s):
            return s.map { "Rate limited. Try again in \($0)s." } ?? "Rate limited. Try again soon."
        case .unknown(let msg): return msg
        }
    }
}
