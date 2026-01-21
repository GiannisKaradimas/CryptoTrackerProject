import SwiftUI
import CoreData
import Charts

struct PortfolioView: View {
    @Environment(\.managedObjectContext) private var ctx
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "purchasedAt", ascending: false)])
    private var holdings: FetchedResults<Holding>

    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                summaryCard
                List {
                    ForEach(holdings, id: \.objectID) { h in
                        VStack(alignment: .leading) {
                            Text("\(h.coinName ?? "") (\(h.coinSymbol ?? ""))").font(.headline)
                            Text("Qty: \(h.quantity, format: .number)  @  \(h.purchasePrice, format: .currency(code: "USD"))")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Portfolio")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
                ToolbarItem(placement: .topBarLeading) { EditButton() }
            }
            .sheet(isPresented: $showAdd) { AddHoldingSheet() }
        }
    }

    private var summaryCard: some View {
        let totalCost = holdings.reduce(0) { $0 + ($1.quantity * $1.purchasePrice) }
        return VStack(alignment: .leading, spacing: 8) {
            Text("Total Cost").font(.caption).foregroundStyle(.secondary)
            Text(totalCost, format: .currency(code: "USD")).font(.title2).bold()
            Text("Tip: wire live prices to compute P/L (see PortfolioVM in TODOs).")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding([.horizontal, .top])
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { holdings[$0] }.forEach(ctx.delete)
        try? ctx.save()
    }
}

private struct AddHoldingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var container: AppContainer
    @State private var coinId = "bitcoin"
    @State private var symbol = "BTC"
    @State private var name = "Bitcoin"
    @State private var qty = ""
    @State private var price = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Coin id (CoinGecko)", text: $coinId)
                TextField("Symbol", text: $symbol)
                TextField("Name", text: $name)
                TextField("Quantity", text: $qty).keyboardType(.decimalPad)
                TextField("Purchase price (USD)", text: $price).keyboardType(.decimalPad)
            }
            .navigationTitle("Add Holding")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let q = Double(qty) ?? 0
                        let p = Double(price) ?? 0
                        try? container.portfolioRepository.addHolding(
                            coinId: coinId, symbol: symbol, name: name,
                            quantity: q, purchasePrice: p, date: Date()
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}
