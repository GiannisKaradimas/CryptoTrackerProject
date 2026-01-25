import Foundation

final class CoinGeckoAPI {
    private let http: HTTPClientProtocol
    private let baseURL = URL(string: "https://api.coingecko.com/api/v3")!

    init(http: HTTPClientProtocol) {
        self.http = http
    }

    func marketCoins(
        vsCurrency: String,
        order: String,
        perPage: Int,
        page: Int,
        sparkline: Bool,
        priceChangePercentage: String? = "24h"
    ) async throws -> [MarketCoinDTO] {

        guard var components = URLComponents(
            url: baseURL.appendingPathComponent("coins/markets"),
            resolvingAgainstBaseURL: false
        ) else { throw AppError.network(.invalidURL) }

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

        guard let url = components.url else { throw AppError.network(.invalidURL) }
        return try await request(url, decode: [MarketCoinDTO].self)
    }

    func coinDetail(id: String) async throws -> CoinDetailDTO {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent("coins/\(id)"),
            resolvingAgainstBaseURL: false
        ) else { throw AppError.network(.invalidURL) }

        components.queryItems = [
            .init(name: "localization", value: "false"),
            .init(name: "tickers", value: "false"),
            .init(name: "market_data", value: "true"),
            .init(name: "community_data", value: "false"),
            .init(name: "developer_data", value: "false"),
            .init(name: "sparkline", value: "false")
        ]

        guard let url = components.url else { throw AppError.network(.invalidURL) }
        return try await request(url, decode: CoinDetailDTO.self)
    }

    func trending() async throws -> TrendingDTO {
        let url = baseURL.appendingPathComponent("search/trending")
        return try await request(url, decode: TrendingDTO.self)
    }

    private func request<T: Decodable>(_ url: URL, decode: T.Type) async throws -> T {
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let maxAttempts = 3
        var attempt = 0
        var backoff: UInt64 = 400_000_000 // 0.4s

        while true {
            attempt += 1
            do {
                let (data, httpResp) = try await http.data(for: req)

                if httpResp.statusCode == 429 {
                    let retryAfter = httpResp.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)
                    throw AppError.rateLimited(retryAfterSeconds: retryAfter)
                }

                guard (200..<300).contains(httpResp.statusCode) else {
                    throw AppError.network(.httpStatus(httpResp.statusCode))
                }

                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw AppError.decoding
                }

            } catch let err as AppError {
                if case .rateLimited = err { throw err }
                if attempt >= maxAttempts { throw err }
            } catch {
                if attempt >= maxAttempts {
                    throw AppError.network(.transport(error.localizedDescription))
                }
            }

            try await Task.sleep(nanoseconds: backoff)
            backoff *= 2
        }
    }
}
