import SwiftUI

struct WatchlistsView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var watchlists: [WatchlistModel] = []
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(watchlists) { wl in
                    NavigationLink {
                        WatchlistDetailView(watchlistId: wl.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(wl.name).font(.headline)
                            Text("\(wl.coinIds.count) coins")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Watchlists")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddWatchlistSheet { name in
                    try? container.watchlistRepository.createWatchlist(name: name)
                    reload()
                }
            }
            .onAppear { reload() }
        }
    }

    private func reload() {
        watchlists = (try? container.watchlistRepository.allWatchlists()) ?? []
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { watchlists[$0].id }.forEach { id in
            try? container.watchlistRepository.deleteWatchlist(id: id)
        }
        reload()
    }
}

private struct AddWatchlistSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    let onCreate: (String) -> Void

    var body: some View {
        NavigationStack {
            Form { TextField("Watchlist name", text: $name) }
                .navigationTitle("New Watchlist")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Create") {
                            let final = name.trimmingCharacters(in: .whitespacesAndNewlines)
                            onCreate(final.isEmpty ? "Watchlist" : final)
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct WatchlistDetailView: View {
    @EnvironmentObject private var container: AppContainer
    let watchlistId: UUID

    @State private var watchlist: WatchlistModel?
    @State private var coinIdToAdd: String = ""

    var body: some View {
        List {
            Section {
                HStack {
                    TextField("CoinGecko id (e.g. bitcoin)", text: $coinIdToAdd)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button("Add") { addCoin() }
                        .disabled(coinIdToAdd.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }

            Section(header: Text("Coins")) {
                ForEach(watchlist?.coinIds ?? [], id: \.self) { id in
                    Text(id)
                }
                .onDelete(perform: removeCoins)
            }
        }
        .navigationTitle(watchlist?.name ?? "Watchlist")
        .onAppear { reload() }
    }

    private func reload() {
        let all = (try? container.watchlistRepository.allWatchlists()) ?? []
        watchlist = all.first(where: { $0.id == watchlistId })
    }

    private func addCoin() {
        let id = coinIdToAdd.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty else { return }
        try? container.watchlistRepository.addCoin(coinId: id, to: watchlistId)
        coinIdToAdd = ""
        reload()
    }

    private func removeCoins(at offsets: IndexSet) {
        guard let wl = watchlist else { return }
        offsets.map { wl.coinIds[$0] }.forEach { coinId in
            try? container.watchlistRepository.removeCoin(coinId: coinId, from: watchlistId)
        }
        reload()
    }
}
