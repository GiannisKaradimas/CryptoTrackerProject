import Foundation
import Combine

@MainActor
final class PortfolioViewModel: ObservableObject {

    @Published private(set) var holdings: [HoldingModel] = []

    private let repo: PortfolioRepository

    init(repo: PortfolioRepository) {
        self.repo = repo
    }

    func load() {
        holdings = (try? repo.allHoldings()) ?? []
    }

    func addHolding(_ holding: HoldingModel) {
        try? repo.addHolding(holding)
        load()
    }

    func delete(at offsets: IndexSet) {
        offsets
            .map { holdings[$0].id }
            .forEach { id in
                try? repo.deleteHolding(id: id)
            }
        load()
    }

    var totalCostUSD: Double {
        holdings.reduce(0) { $0 + ($1.quantity * $1.purchasePrice) }
    }

    var totalHoldingsCount: Int {
        holdings.count
    }
}
