import CoreData
import Foundation

final class CoreDataPortfolioRepository: PortfolioRepository {
    private let persistence: PersistenceController
    private var ctx: NSManagedObjectContext { persistence.viewContext }

    init(persistence: PersistenceController) {
        self.persistence = persistence
    }

    func addHolding(coinId: String, symbol: String, name: String, quantity: Double, purchasePrice: Double, date: Date) throws {
        let h = Holding(context: ctx)
        h.id = UUID()
        h.coinId = coinId
        h.coinSymbol = symbol
        h.coinName = name
        h.quantity = quantity
        h.purchasePrice = purchasePrice
        h.purchasedAt = date
        try persistence.saveIfNeeded()
    }

    func deleteHolding(id: UUID) throws {
        let req: NSFetchRequest<Holding> = Holding.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        req.fetchLimit = 1
        if let h = try ctx.fetch(req).first {
            ctx.delete(h)
            try persistence.saveIfNeeded()
        }
    }

    func allHoldings() throws -> [Holding] {
        let req: NSFetchRequest<Holding> = Holding.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "purchasedAt", ascending: false)]
        return try ctx.fetch(req)
    }
}
