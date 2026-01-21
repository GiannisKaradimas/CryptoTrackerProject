import SwiftUI

@main
struct CryptoTrackerApp: App {
    @StateObject private var appContainer = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appContainer)
                .environment(\.managedObjectContext, appContainer.persistence.viewContext)
        }
    }
}
