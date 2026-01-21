import Foundation

final class CoinGeckoAPI {
    private let http: HTTPClientProtocol
    private let baseURL = URL(string: "https://api.coingecko.com/api/v3")!

    init(http: HTTPClientProtocol) {
        self.http = http
    }

    // MARK: - Endpoints

    func marketCoins(vsCurrency: String,
                     order: String,
                     perPage: Int,
                     page: Int,
                     sparkline: Bool,
                     priceChangePercentage: String? = "24h") async throws -> [CoinMarketDTO] {
        var components = URLComponents(url: baseURL.appendingPathComponent("coins/markets"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            .init(name: "vs_currency", value: vsCurrency),
            .init(name: "order", value: order),
            .init(name: "per_page", value: String(perPage)),
            .init(name: "page", value: String(page)),
            .init(name: "sparkline", value: sparkline ? "true" : "false")
        ]
        if let p = priceChangePercentage {
            components.queryItems?.append(.init(name: "price_change_percentage", value: p))
        }
        return try await request(components.url!, decode: [CoinMarketDTO].self)
    }

    func coinDetail(id: String) async throws -> CoinDetailDTO {
        var components = URLComponents(url: baseURL.appendingPathComponent("coins/\(id)"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            .init(name: "localization", value: "false"),
            .init(name: "tickers", value: "false"),
            .init(name: "market_data", value: "true"),
            .init(name: "community_data", value: "false"),
            .init(name: "developer_data", value: "false"),
            .init(name: "sparkline", value: "false")
        ]
        return try await request(components.url!, decode: CoinDetailDTO.self)
    }

    func coinMarketChart(id: String, vsCurrency: String, days: String) async throws -> MarketChartDTO {
        var components = URLComponents(url: baseURL.appendingPathComponent("coins/\(id)/market_chart"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            .init(name: "vs_currency", value: vsCurrency),
            .init(name: "days", value: days)
        ]
        return try await request(components.url!, decode: MarketChartDTO.self)
    }

    func trending() async throws -> TrendingDTO {
        let url = baseURL.appendingPathComponent("search/trending")
        return try await request(url, decode: TrendingDTO.self)
    }

    // MARK: - Core request w/ retries & rate limiting

    private func request<T: Decodable>(_ url: URL, decode: T.Type) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let maxAttempts = 3
        var attempt = 0
        var backoff: UInt64 = 400_000_000 // 0.4s

        while true {
            attempt += 1
            do {
                let (data, http) = try await http.data(for: request)

                if http.statusCode == 429 {
                    let retryAfter = http.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)
                    throw AppError.rateLimited(retryAfterSeconds: retryAfter)
                }
                guard (200..<300).contains(http.statusCode) else {
                    throw AppError.network("Server error (\(http.statusCode)).")
                }
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw AppError.decoding("Failed to decode response.")
                }
            } catch let err as AppError {
                if case .rateLimited = err { throw err }
                if attempt >= maxAttempts { throw err }
            } catch {
                if attempt >= maxAttempts {
                    throw AppError.network("Network request failed.")
                }
            }

            try await Task.sleep(nanoseconds: backoff)
            backoff *= 2
        }
    }
}
