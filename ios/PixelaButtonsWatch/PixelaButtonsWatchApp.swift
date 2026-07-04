import SwiftUI
import WatchKit

@main
struct PixelaButtonsWatchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        WKNotificationScene(
            controller: ReminderNotificationController.self,
            category: "record_reminder"
        )
    }
}
