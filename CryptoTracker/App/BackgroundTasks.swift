import BackgroundTasks
import UserNotifications
import Foundation

/// Register BG tasks in `application(_:didFinishLaunchingWithOptions:)` if using UIKit lifecycle.
/// With SwiftUI lifecycle, you can use `BGTaskScheduler.shared.register` in an `@MainActor` initializer
/// and add permitted identifiers to Info.plist.
/// This file provides a starting point for price-alert polling.
///
/// NOTE: CoinGecko free tier rate limits; keep background fetch conservative.
enum BackgroundTasks {
    static let refreshTaskId = "com.yourorg.CryptoTracker.refresh"

    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: refreshTaskId, using: nil) { task in
            handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }

    static func schedule() {
        let req = BGAppRefreshTaskRequest(identifier: refreshTaskId)
        req.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 30) // ~30 min
        try? BGTaskScheduler.shared.submit(req)
    }

    private static func handleAppRefresh(task: BGAppRefreshTask) {
        schedule()
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        // TODO: fetch enabled alerts, poll prices, trigger local notifications.
        task.setTaskCompleted(success: true)
    }

    static func requestNotificationPermissions() async {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
    }
}
