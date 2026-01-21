import SwiftUI
import CoreData

struct WatchlistsView: View {
    @Environment(\.managedObjectContext) private var ctx

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: true)])
    private var watchlists: FetchedResults<Watchlist>

    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(watchlists, id: \.objectID) { wl in
                    NavigationLink {
                        WatchlistDetailView(watchlist: wl)
                    } label: {
                        Text(wl.name ?? "Untitled")
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Watchlists")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
                ToolbarItem(placement: .topBarLeading) { EditButton() }
            }
            .sheet(isPresented: $showAdd) { AddWatchlistSheet() }
        }
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { watchlists[$0] }.forEach(ctx.delete)
        try? ctx.save()
    }
}

private struct AddWatchlistSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var container: AppContainer
    @State private var name = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Watchlist name", text: $name)
            }
            .navigationTitle("New Watchlist")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        try? container.watchlistRepository.createWatchlist(name: name.isEmpty ? "Watchlist" : name)
                        dismiss()
                    }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

private struct WatchlistDetailView: View {
    @EnvironmentObject private var container: AppContainer
    @Environment(\.managedObjectContext) private var ctx
    @ObservedObject var watchlist: Watchlist

    @FetchRequest private var items: FetchedResults<WatchlistItem>

    init(watchlist: Watchlist) {
        self.watchlist = watchlist
        _items = FetchRequest(sortDescriptors: [NSSortDescriptor(key: "addedAt", ascending: false)],
                              predicate: NSPredicate(format: "watchlist == %@", watchlist))
    }

    var body: some View {
        List {
            ForEach(items, id: \.objectID) { item in
                Text(item.coinId ?? "")
            }
            .onDelete { idx in
                idx.map { items[$0] }.forEach(ctx.delete)
                try? ctx.save()
            }
        }
        .navigationTitle(watchlist.name ?? "Watchlist")
    }
}
