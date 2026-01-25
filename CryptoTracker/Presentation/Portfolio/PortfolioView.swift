import SwiftUI

struct PortfolioView: View {
    @EnvironmentObject private var container: AppContainer

    @State private var holdings: [HoldingModel] = []
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                summaryCard

                List {
                    ForEach(holdings) { h in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(h.coinId) (\(h.symbol))").font(.headline)
                            Text("Qty: \(h.quantity, format: .number) @ \(h.purchasePrice, format: .currency(code: "USD"))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Portfolio")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddHoldingSheet { model in
                    try? container.portfolioRepository.addHolding(model)
                    reload()
                }
            }
            .onAppear { reload() }
        }
    }

    private var summaryCard: some View {
        let totalCost = holdings.reduce(0) { $0 + ($1.quantity * $1.purchasePrice) }
        return VStack(alignment: .leading, spacing: 8) {
            Text("Total Cost").font(.caption).foregroundStyle(.secondary)
            Text(totalCost, format: .currency(code: "USD")).font(.title2).bold()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding([.horizontal, .top])
    }

    private func reload() {
        holdings = (try? container.portfolioRepository.allHoldings()) ?? []
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { holdings[$0].id }.forEach { id in
            try? container.portfolioRepository.deleteHolding(id: id)
        }
        reload()
    }
}

private struct AddHoldingSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var coinId = "bitcoin"
    @State private var symbol = "BTC"
    @State private var name = "Bitcoin"
    @State private var qty = ""
    @State private var price = ""

    let onSave: (HoldingModel) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Coin id (CoinGecko)", text: $coinId)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                TextField("Symbol", text: $symbol)
                    .textInputAutocapitalization(.characters)

                TextField("Name", text: $name)

                TextField("Quantity", text: $qty)
                    .keyboardType(.decimalPad)

                TextField("Purchase price (USD)", text: $price)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add Holding")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let trimmedId = coinId.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedSymbol = symbol.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

                        guard !trimmedId.isEmpty, !trimmedSymbol.isEmpty, !trimmedName.isEmpty else { return }

                        onSave(
                            HoldingModel(
                                coinId: trimmedId,
                                symbol: trimmedSymbol,
                                name: trimmedName,
                                quantity: Double(qty) ?? 0,
                                purchasePrice: Double(price) ?? 0,
                                createdAt: Date()          // ✅ correct label
                            )
                        )
                        dismiss()
                    }
                    .disabled(Double(qty) == nil || Double(price) == nil)
                }
            }
        }
    }
}
