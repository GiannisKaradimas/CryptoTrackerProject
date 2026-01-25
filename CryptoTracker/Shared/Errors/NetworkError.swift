import Foundation

enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .invalidResponse: return "Invalid server response."
        case .httpStatus(let code): return "Server error (HTTP \(code))."
        case .transport(let msg): return "Network error: \(msg)"
        }
    }
}
