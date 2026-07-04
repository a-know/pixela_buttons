import Foundation
import WatchKit
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
    @Published private(set) var todayValues: [String: Double] = [:]
    @Published private(set) var recordingButtonId: String?
    @Published private var recordMessage: String?
    @Published private var recordMessageCardId: String?

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
        refreshTodayValues()
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

    func refreshTodayValues() {
        guard let session, session.activationState == .activated, session.isReachable else {
            return
        }
        for card in cards {
            Task {
                await refreshTodayValue(card: card, session: session)
            }
        }
    }

    private func refreshTodayValue(card: WatchCardConfig, session: WCSession) async {
        do {
            let reply = try await sendTodayValueMessage(session: session, card: card)
            guard reply["ok"] as? Bool == true,
                  let value = (reply["value"] as? NSNumber)?.doubleValue
            else {
                return
            }
            todayValues[card.id] = value
        } catch {
        }
    }

    func record(card: WatchCardConfig, button: WatchButtonConfig) async {
        guard recordingButtonId == nil else {
            return
        }
        let recordingId = Self.recordingId(card: card, button: button)
        recordingButtonId = recordingId
        recordMessage = nil
        recordMessageCardId = card.id
        defer {
            recordingButtonId = nil
        }

        guard let session, session.activationState == .activated, session.isReachable else {
            recordMessage = "Open Pixela Buttons on iPhone and try again."
            WKInterfaceDevice.current().play(.failure)
            return
        }

        do {
            let reply = try await sendRecordMessage(session: session, card: card, button: button)
            guard reply["ok"] as? Bool == true else {
                throw WatchRecordError.remote(reply["error"] as? String)
            }
            recordMessage = "Recorded \(Self.formatted(button.value)) \(card.unit)"
            await refreshTodayValue(card: card, session: session)
            WKInterfaceDevice.current().play(.success)
        } catch {
            recordMessage = error.localizedDescription
            WKInterfaceDevice.current().play(.failure)
        }
    }

    func isRecording(card: WatchCardConfig, button: WatchButtonConfig) -> Bool {
        recordingButtonId == Self.recordingId(card: card, button: button)
    }

    func recordMessage(for card: WatchCardConfig) -> String? {
        recordMessageCardId == card.id ? recordMessage : nil
    }

    func todayText(for card: WatchCardConfig) -> String {
        let prefix = Self.todayPrefix
        if let value = todayValues[card.id] {
            return "\(prefix): \(Self.formatted(value)) \(card.unit)"
        }
        return "\(prefix): -- \(card.unit)"
    }

    private func sendRecordMessage(
        session: WCSession,
        card: WatchCardConfig,
        button: WatchButtonConfig
    ) async throws -> [String: Any] {
        try await withCheckedThrowingContinuation { continuation in
            session.sendMessage([
                "type": "recordButton",
                "cardId": card.id,
                "buttonId": button.id,
            ], replyHandler: { reply in
                continuation.resume(returning: reply)
            }, errorHandler: { error in
                continuation.resume(throwing: error)
            })
        }
    }

    private func sendTodayValueMessage(
        session: WCSession,
        card: WatchCardConfig
    ) async throws -> [String: Any] {
        try await withCheckedThrowingContinuation { continuation in
            session.sendMessage([
                "type": "requestTodayValue",
                "cardId": card.id,
            ], replyHandler: { reply in
                continuation.resume(returning: reply)
            }, errorHandler: { error in
                continuation.resume(throwing: error)
            })
        }
    }

    private static func recordingId(card: WatchCardConfig, button: WatchButtonConfig) -> String {
        "\(card.id):\(button.id)"
    }

    static func formatted(_ value: Double) -> String {
        value == value.rounded(.towardZero) ? String(Int(value)) : String(value)
    }

    private static var todayPrefix: String {
        Locale.current.language.languageCode?.identifier == "ja" ? "今日" : "Today"
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
            self.refreshTodayValues()
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

private enum WatchRecordError: LocalizedError {
    case remote(String?)

    var errorDescription: String? {
        switch self {
        case .remote(let message):
            return message ?? "Record request failed."
        }
    }
}
