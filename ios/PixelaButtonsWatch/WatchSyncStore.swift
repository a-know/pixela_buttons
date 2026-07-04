import Foundation
import WatchConnectivity

struct WatchButtonConfig: Identifiable, Codable, Equatable {
    let id: String
    let value: Double
}

struct WatchCardConfig: Identifiable, Codable, Equatable {
    let id: String
    let graphId: String
    let displayName: String
    let emoji: String
    let color: String
    let unit: String
    let timezone: String?
    let graphType: String?
    let buttons: [WatchButtonConfig]
}

@MainActor
final class WatchSyncStore: NSObject, ObservableObject {
    static let shared = WatchSyncStore()

    @Published private(set) var username = ""
    @Published private(set) var cards: [WatchCardConfig] = []

    private let storageKey = "watch_card_sync_payload"
    private var session: WCSession?

    private override init() {
        super.init()
        restore()
        guard WCSession.isSupported() else {
            return
        }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        self.session = session
        if !session.receivedApplicationContext.isEmpty {
            apply(context: session.receivedApplicationContext)
        }
    }

    private func restore() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let payload = try? JSONDecoder().decode(SyncPayload.self, from: data)
        else {
            return
        }
        username = payload.username
        cards = payload.cards
    }

    private func apply(context: [String: Any]) {
        let payload = SyncPayload(
            username: context["username"] as? String ?? "",
            cards: Self.cards(from: context["cards"] as? [[String: Any]] ?? [])
        )
        username = payload.username
        cards = payload.cards
        if let data = try? JSONEncoder().encode(payload) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func requestLatestCards() {
        guard let session, session.activationState == .activated, session.isReachable else {
            return
        }
        session.sendMessage(["type": "requestCards"], replyHandler: { reply in
            Task { @MainActor in
                self.apply(context: reply)
            }
        }, errorHandler: nil)
    }

    private static func cards(from dictionaries: [[String: Any]]) -> [WatchCardConfig] {
        dictionaries.compactMap { dictionary -> WatchCardConfig? in
            guard
                let id = dictionary["id"] as? String,
                let graphId = dictionary["graphId"] as? String,
                let displayName = dictionary["displayName"] as? String,
                let color = dictionary["color"] as? String,
                let unit = dictionary["unit"] as? String
            else {
                return nil
            }
            let buttons = (dictionary["buttons"] as? [[String: Any]] ?? []).compactMap { button -> WatchButtonConfig? in
                guard
                    let id = button["id"] as? String,
                    let value = button["value"] as? NSNumber
                else {
                    return nil
                }
                return WatchButtonConfig(id: id, value: value.doubleValue)
            }
            return WatchCardConfig(
                id: id,
                graphId: graphId,
                displayName: displayName,
                emoji: dictionary["emoji"] as? String ?? "",
                color: color,
                unit: unit,
                timezone: dictionary["timezone"] as? String,
                graphType: dictionary["graphType"] as? String,
                buttons: buttons
            )
        }
    }
}

extension WatchSyncStore: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        guard activationState == .activated else {
            return
        }
        Task { @MainActor in
            if !session.receivedApplicationContext.isEmpty {
                self.apply(context: session.receivedApplicationContext)
            }
            self.requestLatestCards()
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        Task { @MainActor in
            self.apply(context: applicationContext)
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any] = [:]
    ) {
        Task { @MainActor in
            self.apply(context: userInfo)
        }
    }
}

private struct SyncPayload: Codable {
    let username: String
    let cards: [WatchCardConfig]
}
