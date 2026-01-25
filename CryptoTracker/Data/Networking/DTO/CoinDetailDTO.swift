import Foundation

struct CoinDetailDTO: Decodable {
    let id: String
    let name: String
    let symbol: String
    let image: ImageDTO?
    let description: DescriptionDTO?
    let links: LinksDTO?
    let marketData: MarketDataDTO?
    
    struct ImageDTO: Decodable { let large: String? }
    struct DescriptionDTO: Decodable { let en: String? }
    struct LinksDTO: Decodable { let homepage: [String]? }
    struct MarketDataDTO: Decodable {
        let marketCap: [String: Double]?
        let totalVolume: [String: Double]?
        let circulatingSupply: Double?
        let ath: [String: Double]?
        let atl: [String: Double]?
    }
}
