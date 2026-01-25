import Foundation

struct TrendingDTO: Decodable {
    let coins: [ItemWrapper]
    struct ItemWrapper: Decodable { let item: Item }
    struct Item: Decodable { let id: String }
}
