
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

        print("🔵 Requesting:", request.url?.absoluteString ?? "nil")

        var attempt = 0
        var delay: UInt64 = 400_000_000

        while true {
            do {
                let (data, response) = try await session.data(for: request)

                guard let http = response as? HTTPURLResponse else {
                    throw AppError.network(.invalidResponse)
                }

                print("🟡 Status Code:", http.statusCode)

                if http.statusCode == 429 {
                    print("⛔ Rate limited")
                    let retryAfter = http.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)
                    throw AppError.rateLimited(retryAfterSeconds: retryAfter)
                }

                guard (200...299).contains(http.statusCode) else {
                    print("❌ Server error:", http.statusCode)
                    throw AppError.network(.httpStatus(http.statusCode))
                }

//                print("🟢 Raw JSON Response:")
//                print(String(data: data, encoding: .utf8) ?? "Invalid UTF8")

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decoded = try decoder.decode(T.self, from: data)
                    print("PRASINO", decoded)
                    return decoded
                } catch {
                    print("🔴 JSON DECODING ERROR:", error)
                    throw AppError.decoding
                }

            } catch {
                attempt += 1
                print("🔁 Retry attempt \(attempt) after error:", error)

                if attempt >= 3 { throw error }
                try await Task.sleep(nanoseconds: delay)
                delay *= 2
            }
        }
    }

}
