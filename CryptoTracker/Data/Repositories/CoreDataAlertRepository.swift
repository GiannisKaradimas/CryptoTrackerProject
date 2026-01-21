import CoreData
import Foundation

final class CoreDataAlertRepository: AlertRepository {
    private let persistence: PersistenceController
    private var ctx: NSManagedObjectContext { persistence.viewContext }

    init(persistence: PersistenceController) {
        self.persistence = persistence
    }

    func createAlert(coinId: String, symbol: String, targetPrice: Double, type: AlertType) throws {
        let a = PriceAlert(context: ctx)
        a.id = UUID()
        a.coinId = coinId
        a.coinSymbol = symbol
        a.targetPrice = targetPrice
        a.type = type.rawValue
        a.isEnabled = true
        a.createdAt = Date()
        try persistence.saveIfNeeded()
    }

    func deleteAlert(id: UUID) throws {
        let req: NSFetchRequest<PriceAlert> = PriceAlert.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        req.fetchLimit = 1
        if let a = try ctx.fetch(req).first {
            ctx.delete(a)
            try persistence.saveIfNeeded()
        }
    }

    func setEnabled(id: UUID, isEnabled: Bool) throws {
        let req: NSFetchRequest<PriceAlert> = PriceAlert.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        req.fetchLimit = 1
        if let a = try ctx.fetch(req).first {
            a.isEnabled = isEnabled
            try persistence.saveIfNeeded()
        }
    }
}
