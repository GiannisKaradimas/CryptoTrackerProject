import SwiftUI

struct AlertsView: View {
    @EnvironmentObject private var container: AppContainer

    @State private var alerts: [PriceAlertModel] = []
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(alerts) { a in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(a.symbol).font(.headline)
                            Text("\(a.type.rawValue.capitalized) \(a.targetPriceUSD, format: .currency(code: "USD"))")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { a.isEnabled },
                            set: { newValue in
                                try? container.alertRepository.setEnabled(id: a.id, isEnabled: newValue)
                                reload()
                            }
                        ))
                        .labelsHidden()
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Alerts")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddAlertSheet { model in
                    try? container.alertRepository.createAlert(
                        coinId: model.coinId,
                        symbol: model.symbol,
                        targetPrice: model.targetPrice,
                        type: model.type
                    )
                    reload()
                }
            }
            .onAppear { reload() }
        }
    }

    private func reload() {
        alerts = (try? container.alertRepository.allAlerts()) ?? []
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { alerts[$0].id }.forEach { id in
            try? container.alertRepository.deleteAlert(id: id)
        }
        reload()
    }
}

private struct AddAlertSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var coinId = "bitcoin"
    @State private var symbol = "BTC"
    @State private var target = ""
    @State private var type: AlertType = .above

    let onSave: (PriceAlertModel) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Coin id (CoinGecko)", text: $coinId)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
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
                        onSave(PriceAlertModel(
                            coinId: coinId.trimmingCharacters(in: .whitespacesAndNewlines),
                            symbol: symbol.trimmingCharacters(in: .whitespacesAndNewlines),
                            targetPrice: t,
                            type: type
                        ))
                        dismiss()
                    }
                    .disabled(Double(target) == nil)
                }
            }
        }
    }
}
