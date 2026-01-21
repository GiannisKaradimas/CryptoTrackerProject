import Foundation

final class DefaultCoinRepository: CoinRepository {
    private let api: CoinGeckoAPI
    private let cache: CoinCache

    init(api: CoinGeckoAPI, cache: CoinCache) {
        self.api = api
        self.cache = cache
    }

    func marketCoins(category: MarketCategory, page: Int, pageSize: Int) async throws -> [Coin] {
        let cacheKey = "market_\(category.rawValue)_p\(page)_s\(pageSize)"
        do {
            let cached = try cache.cachedMarketCoins(key: cacheKey)
            if !cached.isEmpty { return cached }
        } catch { /* ignore cache read errors */ }

        let order: String
        switch category {
        case .top100: order = "market_cap_desc"
        case .gainers: order = "price_change_percentage_24h_desc"
        case .losers: order = "price_change_percentage_24h_asc"
        case .trending:
            // For trending we use /search/trending below; this branch should not be called.
            order = "market_cap_desc"
        }

        let dtos = try await api.marketCoins(
            vsCurrency: "usd",
            order: order,
            perPage: pageSize,
            page: page,
            sparkline: true,
            priceChangePercentage: "24h"
        )
        let coins = dtos.map { dto in
            Coin(
                id: dto.id,
                symbol: dto.symbol.uppercased(),
                name: dto.name,
                imageURL: dto.image.flatMap(URL.init(string:)),
                price: dto.currentPrice ?? 0,
                change24h: dto.priceChangePercentage24H,
                marketCapRank: dto.marketCapRank,
                sparkline7d: dto.sparklineIn7D?.price
            )
        }
        try? cache.cacheMarketCoins(coins, key: cacheKey)
        return coins
    }

    func trendingCoins() async throws -> [Coin] {
        let dto = try await api.trending()
        return dto.coins.map { item in
            Coin(
                id: item.item.id,
                symbol: item.item.symbol.uppercased(),
                name: item.item.name,
                imageURL: item.item.large.flatMap(URL.init(string:)),
                price: 0,
                change24h: nil,
                marketCapRank: item.item.marketCapRank,
                sparkline7d: nil
            )
        }
    }

    func coinDetail(id: String) async throws -> CoinDetail {
        let dto = try await api.coinDetail(id: id)
        let md = dto.marketData
        func usd(_ dict: [String: Double]?) -> Double? { dict?["usd"] }

        return CoinDetail(
            id: dto.id,
            symbol: dto.symbol.uppercased(),
            name: dto.name,
            imageURL: dto.image?.large.flatMap(URL.init(string:)),
            descriptionHTML: dto.description?.en,
            homepage: dto.links?.homepage?.first.flatMap(URL.init(string:)).flatMap { $0.absoluteString.isEmpty ? nil : $0 },
            subreddit: dto.links?.subredditUrl.flatMap(URL.init(string:)),
            price: usd(md?.currentPrice),
            marketCap: usd(md?.marketCap),
            volume: usd(md?.totalVolume),
            circulatingSupply: md?.circulatingSupply,
            totalSupply: md?.totalSupply,
            ath: usd(md?.ath),
            atl: usd(md?.atl),
            change24h: md?.priceChangePercentage24H
        )
    }

    func history(id: String, days: String) async throws -> [PricePoint] {
        do {
            let cached = try cache.cachedHistory(coinId: id, days: days)
            if !cached.isEmpty { return cached }
        } catch { /* ignore */ }

        let dto = try await api.coinMarketChart(id: id, vsCurrency: "usd", days: days)
        let points: [PricePoint] = dto.prices.compactMap { row in
            guard row.count >= 2 else { return nil }
            let ms = row[0]
            let price = row[1]
            return PricePoint(date: Date(timeIntervalSince1970: ms / 1000), price: price)
        }
        try? cache.cacheHistory(points, coinId: id, days: days)
        return points
    }
}
