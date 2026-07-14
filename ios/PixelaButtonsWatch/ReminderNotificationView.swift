import SwiftUI
import UserNotifications
import WatchKit

struct ReminderNotificationView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Image("PixelaMono")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .accessibilityHidden(true)

            Text(title.isEmpty ? "Pixela Buttons" : title)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(message.isEmpty ? "Open Pixela Buttons" : message)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

final class ReminderNotificationController: WKUserNotificationHostingController<ReminderNotificationView> {
    private var notificationTitle = "Pixela Buttons"
    private var notificationBody = "Open Pixela Buttons"

    override var body: ReminderNotificationView {
        ReminderNotificationView(
            title: notificationTitle,
            message: notificationBody
        )
    }

    override func didReceive(_ notification: UNNotification) {
        notificationTitle = notification.request.content.title
        notificationBody = notification.request.content.body
    }
}
