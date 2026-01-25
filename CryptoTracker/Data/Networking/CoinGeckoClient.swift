
import Foundation

final class CoinGeckoClient {
    private let session: URLSession
    private let baseURL = URL(string: "https://api.coingecko.com/api/v3")!

    init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024
        )
        self.session = URLSession(configuration: config)
    }

    func get<T: Decodable>(_ path: String, query: [URLQueryItem] = []) async throws -> T {
        guard var comps = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true) else {
            throw AppError.network(.invalidURL)
        }
        comps.queryItems = query.isEmpty ? nil : query
        guard let url = comps.url else { throw AppError.network(.invalidURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        return try await requestWithRetry(request)
    }

    private func requestWithRetry<T: Decodable>(_ request: URLRequest) async throws -> T {
        var attempt = 0
        var delay: UInt64 = 400_000_000 // 0.4s

        while true {
            do {
                let (data, response) = try await session.data(for: request)
                guard let http = response as? HTTPURLResponse else { throw AppError.network(.invalidResponse) }

                if http.statusCode == 429 {
                    let retryAfter = http.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)
                    throw AppError.rateLimited(retryAfterSeconds: retryAfter)
                }

                guard (200...299).contains(http.statusCode) else {
                    throw AppError.network(.httpStatus(http.statusCode))
                }

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw AppError.decoding
                }
            } catch let appErr as AppError {
                attempt += 1
                if attempt >= 3 { throw appErr }
                try await Task.sleep(nanoseconds: delay)
                delay *= 2
            } catch {
                attempt += 1
                if attempt >= 3 {
                    throw AppError.network(.transport(error.localizedDescription))
                }
                try await Task.sleep(nanoseconds: delay)
                delay *= 2
            }
        }
    }
}
