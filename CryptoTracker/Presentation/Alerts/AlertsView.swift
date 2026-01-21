import SwiftUI
import CoreData

struct AlertsView: View {
    @Environment(\.managedObjectContext) private var ctx
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: false)])
    private var alerts: FetchedResults<PriceAlert>

    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(alerts, id: \.objectID) { a in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(a.coinSymbol ?? "—").font(.headline)
                            Text("\((a.type ?? "").capitalized) \(a.targetPrice, format: .currency(code: "USD"))")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(get: { a.isEnabled }, set: { newValue in
                            a.isEnabled = newValue
                            try? ctx.save()
                        }))
                        .labelsHidden()
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Alerts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
                ToolbarItem(placement: .topBarLeading) { EditButton() }
            }
            .sheet(isPresented: $showAdd) { AddAlertSheet() }
        }
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { alerts[$0] }.forEach(ctx.delete)
        try? ctx.save()
    }
}

private struct AddAlertSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var container: AppContainer

    @State private var coinId = "bitcoin"
    @State private var symbol = "BTC"
    @State private var target = ""
    @State private var type: AlertType = .above

    var body: some View {
        NavigationStack {
            Form {
                TextField("Coin id (CoinGecko)", text: $coinId)
                TextField("Symbol", text: $symbol)
                TextField("Target price (USD)", text: $target).keyboardType(.decimalPad)
                Picker("Type", selection: $type) {
                    ForEach(AlertType.allCases) { t in
                        Text(t.rawValue.capitalized).tag(t)
                    }
                }
            }
            .navigationTitle("New Alert")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let t = Double(target) ?? 0
                        try? container.alertRepository.createAlert(coinId: coinId, symbol: symbol, targetPrice: t, type: type)
                        dismiss()
                    }.disabled(Double(target) == nil)
                }
            }
        }
    }
}
