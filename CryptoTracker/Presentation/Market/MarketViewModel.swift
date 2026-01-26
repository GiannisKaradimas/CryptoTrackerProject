//
//  Untitled.swift
//  
//
//  Created by Georgios Motsias on 22/1/26.
//
import Foundation
import Combine

@MainActor
final class MarketViewModel: ObservableObject {

    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case failed(String)
    }

    @Published private(set) var state: ViewState = .idle
    @Published private(set) var coins: [Coin] = []
    @Published var category: MarketCategory = .trending

    private let fetchMarketCoins: FetchMarketCoinsUseCase

    private var page: Int = 1
    private let pageSize: Int = 50
    private var isLoadingMore = false

    init(fetchMarketCoins: FetchMarketCoinsUseCase) {
        self.fetchMarketCoins = fetchMarketCoins
    }

    func load() async {
        page = 1
        state = .loading

        do {
            let result = try await fetchMarketCoins(category: category, page: page, perPage: pageSize)
            coins = result
            state = result.isEmpty ? .empty : .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func changeCategory(_ newCategory: MarketCategory) async {
        category = newCategory
        await load()
    }

    func loadMoreIfNeeded(current coin: Coin) async {
        guard !isLoadingMore else { return }
        guard coin.id == coins.last?.id else { return }
        guard state == .loaded else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            page += 1
            let next = try await fetchMarketCoins(category: category, page: page, perPage: pageSize)
            if !next.isEmpty {
                coins.append(contentsOf: next)
            }
        } catch {
            // Δεν ρίχνουμε όλο το screen σε error για pagination failure
        }
    }
}
