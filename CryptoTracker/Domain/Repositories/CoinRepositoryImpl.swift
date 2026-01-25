import Foundation

final class CoinRepositoryImpl: CoinRepository {
    private let api: CoinGeckoClient
    init(api: CoinGeckoClient) { self.api = api }

    func fetchMarket(category: MarketCategory, page: Int, perPage: Int) async throws -> [Coin] {
        // Using /coins/markets with ordering; "gainers/losers" done client-side via sorting.
        let items: [MarketCoinDTO] = try await api.get(
            "coins/markets",
            query: [
                .init(name: "vs_currency", value: "usd"),
                .init(name: "order", value: "market_cap_desc"),
                .init(name: "per_page", value: "\(perPage)"),
                .init(name: "page", value: "\(page)"),
                .init(name: "sparkline", value: "true"),
                .init(name: "price_change_percentage", value: "24h")
            ]
        )

        let coins = items.map { $0.toDomain() }

        switch category {
        case .top100:
            return coins
        case .gainers:
            return coins.sorted { ($0.priceChange24hPct ?? -999) > ($1.priceChange24hPct ?? -999) }
        case .losers:
            return coins.sorted { ($0.priceChange24hPct ?? 999) < ($1.priceChange24hPct ?? 999) }
        case .trending:
            return try await fetchTrending()
        }
    }

    func fetchTrending() async throws -> [Coin] {
        let trending: TrendingDTO = try await api.get("search/trending")
        let ids = trending.coins.map { $0.item.id }
        guard !ids.isEmpty else { return [] }

        // IMPORTANT: trending endpoint doesn’t give prices; fetch markets by ids.
        let items: [MarketCoinDTO] = try await api.get(
            "coins/markets",
            query: [
                .init(name: "vs_currency", value: "usd"),
                .init(name: "ids", value: ids.joined(separator: ",")),
                .init(name: "order", value: "market_cap_desc"),
                .init(name: "per_page", value: "50"),
                .init(name: "page", value: "1"),
                .init(name: "sparkline", value: "true"),
                .init(name: "price_change_percentage", value: "24h")
            ]
        )
        return items.map { $0.toDomain() }
    }

    func fetchCoinDetail(id: String) async throws -> CoinDetail {
        let dto: CoinDetailDTO = try await api.get(
            "coins/\(id)",
            query: [
                .init(name: "localization", value: "false"),
                .init(name: "tickers", value: "false"),
                .init(name: "market_data", value: "true"),
                .init(name: "community_data", value: "false"),
                .init(name: "developer_data", value: "false"),
                .init(name: "sparkline", value: "false")
            ]
        )
        return dto.toDomain()
    }

    func fetchHistory(id: String, days: HistoryRange) async throws -> [PricePoint] {
        let dto: HistoryDTO = try await api.get(
            "coins/\(id)/market_chart",
            query: [
                .init(name: "vs_currency", value: "usd"),
                .init(name: "days", value: days.rawValue)
            ]
        )
        return dto.prices.compactMap { arr in
            guard arr.count >= 2 else { return nil }
            let ms = arr[0]
            let price = arr[1]
            return PricePoint(date: Date(timeIntervalSince1970: ms / 1000), priceUSD: price)
        }
    }

    func fetchSimplePriceUSD(ids: [String]) async throws -> [String : Double] {
        guard !ids.isEmpty else { return [:] }
        let dict: [String: [String: Double]] = try await api.get(
            "simple/price",
            query: [
                .init(name: "ids", value: ids.joined(separator: ",")),
                .init(name: "vs_currencies", value: "usd"),
                .init(name: "include_24hr_change", value: "true")
            ]
        )
        var out: [String: Double] = [:]
        for (k, v) in dict { out[k] = v["usd"] }
        return out
    }
}

private extension MarketCoinDTO {
    func toDomain() -> Coin {
        Coin(
            id: id,
            symbol: symbol.uppercased(),
            name: name,
            imageURL: image.flatMap(URL.init(string:)),
            currentPriceUSD: currentPrice,
            priceChange24hPct: priceChangePercentage24h,
            marketCapUSD: marketCap,
            totalVolumeUSD: totalVolume,
            sparkline7d: sparklineIn7d?.price
        )
    }
}

private extension CoinDetailDTO {
    func toDomain() -> CoinDetail {
        CoinDetail(
            id: id,
            name: name,
            symbol: symbol.uppercased(),
            imageURL: image?.large.flatMap(URL.init(string:)),
            description: description?.en,
            homepageURL: links?.homepage?.first.flatMap { URL(string: $0) },
            marketCapUSD: marketData?.marketCap?["usd"],
            volumeUSD: marketData?.totalVolume?["usd"],
            circulatingSupply: marketData?.circulatingSupply,
            athUSD: marketData?.ath?["usd"],
            atlUSD: marketData?.atl?["usd"]
        )
    }
}
