import Foundation
import SwiftUI
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

struct WatchRecordFeedback: Identifiable, Equatable {
    let id = UUID()
    let cardId: String
    let message: String
    let isSuccess: Bool
}

@MainActor
final class WatchSyncStore: NSObject, ObservableObject {
    static let shared = WatchSyncStore()

    @Published private(set) var username = ""
    @Published private(set) var cards: [WatchCardConfig] = []
    @Published private(set) var todayValues: [String: Double] = [:]
    @Published private(set) var recordingButtonId: String?
    @Published private var recordFeedback: WatchRecordFeedback?

    private let storageKey = "watch_card_sync_payload"
    private var session: WCSession?
    private var feedbackDismissTask: Task<Void, Never>?
    private let messageTimeoutSeconds: TimeInterval = 8

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
        todayValues = payload.todayValues
    }

    private func apply(context: [String: Any]) {
        let payload = SyncPayload(
            username: context["username"] as? String ?? "",
            cards: Self.cards(from: context["cards"] as? [[String: Any]] ?? []),
            todayValues: Self.todayValues(from: context["todayValues"] as? [String: Any] ?? [:])
        )
        username = payload.username
        cards = payload.cards
        todayValues.merge(payload.todayValues) { _, new in new }
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
                  let value = Self.doubleValue(from: reply["value"])
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
        recordFeedback = nil
        defer {
            recordingButtonId = nil
        }

        guard let session, session.activationState == .activated, session.isReachable else {
            showRecordFeedback(
                cardId: card.id,
                message: "Open Pixela Buttons on iPhone and try again.",
                isSuccess: false
            )
            WKInterfaceDevice.current().play(.failure)
            return
        }

        do {
            let reply = try await sendRecordMessage(session: session, card: card, button: button)
            guard reply["ok"] as? Bool == true else {
                throw WatchRecordError.remote(reply["error"] as? String)
            }
            showRecordFeedback(
                cardId: card.id,
                message: "Recorded \(Self.formatted(button.value)) \(card.unit)",
                isSuccess: true
            )
            await refreshTodayValue(card: card, session: session)
            WKInterfaceDevice.current().play(.success)
        } catch {
            showRecordFeedback(
                cardId: card.id,
                message: error.localizedDescription,
                isSuccess: false
            )
            WKInterfaceDevice.current().play(.failure)
        }
    }

    func isRecording(card: WatchCardConfig, button: WatchButtonConfig) -> Bool {
        recordingButtonId == Self.recordingId(card: card, button: button)
    }

    func recordFeedback(for card: WatchCardConfig) -> WatchRecordFeedback? {
        recordFeedback?.cardId == card.id ? recordFeedback : nil
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
        try await sendMessageWithTimeout(
            session: session,
            message: [
                "type": "recordButton",
                "cardId": card.id,
                "buttonId": button.id,
            ]
        )
    }

    private func sendTodayValueMessage(
        session: WCSession,
        card: WatchCardConfig
    ) async throws -> [String: Any] {
        try await sendMessageWithTimeout(
            session: session,
            message: [
                "type": "requestTodayValue",
                "cardId": card.id,
            ]
        )
    }

    private func sendMessageWithTimeout(session: WCSession, message: [String: Any]) async throws -> [String: Any] {
        try await withCheckedThrowingContinuation { continuation in
            let lock = NSLock()
            var didResume = false

            func resume(_ result: Result<[String: Any], Error>) {
                lock.lock()
                defer { lock.unlock() }
                guard !didResume else {
                    return
                }
                didResume = true
                switch result {
                case .success(let reply):
                    continuation.resume(returning: reply)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            session.sendMessage(message, replyHandler: { reply in
                resume(.success(reply))
            }, errorHandler: { error in
                resume(.failure(error))
            })

            DispatchQueue.global().asyncAfter(deadline: .now() + messageTimeoutSeconds) {
                resume(.failure(WatchRecordError.timeout))
            }
        }
    }

    private static func recordingId(card: WatchCardConfig, button: WatchButtonConfig) -> String {
        "\(card.id):\(button.id)"
    }

    private func showRecordFeedback(cardId: String, message: String, isSuccess: Bool) {
        feedbackDismissTask?.cancel()
        let feedback = WatchRecordFeedback(cardId: cardId, message: message, isSuccess: isSuccess)
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            recordFeedback = feedback
        }
        feedbackDismissTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            await MainActor.run {
                guard self?.recordFeedback?.id == feedback.id else {
                    return
                }
                withAnimation(.easeOut(duration: 0.2)) {
                    self?.recordFeedback = nil
                }
            }
        }
    }

    static func formatted(_ value: Double) -> String {
        value == value.rounded(.towardZero) ? String(Int(value)) : String(value)
    }

    private static func doubleValue(from value: Any?) -> Double? {
        if let value = value as? Double {
            return value
        }
        if let value = value as? NSNumber {
            return value.doubleValue
        }
        if let value = value as? String {
            return Double(value)
        }
        return nil
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

    private static func todayValues(from dictionary: [String: Any]) -> [String: Double] {
        dictionary.reduce(into: [String: Double]()) { result, item in
            guard let value = doubleValue(from: item.value) else {
                return
            }
            result[item.key] = value
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

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        guard session.isReachable else {
            return
        }
        Task { @MainActor in
            self.requestLatestCards()
            self.refreshTodayValues()
        }
    }
}

private struct SyncPayload: Codable {
    let username: String
    let cards: [WatchCardConfig]
    let todayValues: [String: Double]

    init(username: String, cards: [WatchCardConfig], todayValues: [String: Double]) {
        self.username = username
        self.cards = cards
        self.todayValues = todayValues
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decode(String.self, forKey: .username)
        cards = try container.decode([WatchCardConfig].self, forKey: .cards)
        todayValues = try container.decodeIfPresent([String: Double].self, forKey: .todayValues) ?? [:]
    }
}

private enum WatchRecordError: LocalizedError {
    case remote(String?)
    case timeout

    var errorDescription: String? {
        switch self {
        case .remote(let message):
            return message ?? "Record request failed."
        case .timeout:
            return "iPhone did not respond. Open Pixela Buttons on iPhone and try again."
        }
    }
}
