import Flutter
import Security
import UIKit
import WatchConnectivity

class SceneDelegate: FlutterSceneDelegate {
  private let watchSyncHandler = WatchSyncHandler()
  private var watchSyncChannel: FlutterMethodChannel?

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "com.a-know.pixelaButtons/watch_sync",
      binaryMessenger: controller.binaryMessenger
    )
    watchSyncChannel = channel
    channel.setMethodCallHandler { [watchSyncHandler] call, result in
      switch call.method {
      case "syncCards":
        guard let payload = call.arguments as? [String: Any] else {
          result(FlutterError(
            code: "invalid_arguments",
            message: "Expected a dictionary payload.",
            details: nil
          ))
          return
        }
        do {
          try watchSyncHandler.sync(payload: payload)
          result(nil)
        } catch {
          result(FlutterError(
            code: "watch_sync_failed",
            message: error.localizedDescription,
            details: nil
          ))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

private final class WatchSyncHandler: NSObject, WCSessionDelegate {
  private var session: WCSession?
  private var pendingContext: [String: Any]?
  private let storageKey = "watch_card_sync_context"
  private let usernameKey = "watch_card_sync_username"
  private let tokenService = "com.a-know.pixelaButtons.watchSync"
  private let tokenAccount = "pixela_token"

  override init() {
    super.init()
    guard WCSession.isSupported() else {
      return
    }
    let session = WCSession.default
    session.delegate = self
    session.activate()
    self.session = session
    pendingContext = restoreContext()
  }

  func sync(payload: [String: Any]) throws {
    guard let session else {
      return
    }
    let context = makeContext(from: payload)
    store(context)

    guard session.activationState == .activated else {
      pendingContext = context
      return
    }

    try send(context, using: session)
    Task {
      await refreshAndSendTodayValues(for: context)
    }
  }

  private func send(_ context: [String: Any], using session: WCSession) throws {
    try session.updateApplicationContext(context)
    session.transferUserInfo(context)
    pendingContext = nil
  }

  private func refreshAndSendTodayValues(for context: [String: Any]? = nil) async {
    let baseContext = context ?? restoreContext() ?? session?.applicationContext ?? [:]
    guard let enrichedContext = await contextWithTodayValues(baseContext) else {
      return
    }
    store(enrichedContext)

    guard let session, session.activationState == .activated else {
      pendingContext = enrichedContext
      return
    }
    do {
      try send(enrichedContext, using: session)
    } catch {
      pendingContext = enrichedContext
    }
  }

  private func contextWithTodayValues(_ context: [String: Any]) async -> [String: Any]? {
    guard let cards = context["cards"] as? [[String: Any]], !cards.isEmpty else {
      return context
    }

    let credentials = restoreCredentials()
    guard !credentials.username.isEmpty, !credentials.token.isEmpty else {
      return context
    }

    var todayValues: [String: Any] = context["todayValues"] as? [String: Any] ?? [:]
    var todayValueDates: [String: Any] = context["todayValueDates"] as? [String: Any] ?? [:]
    for card in cards {
      guard let cardId = card["id"] as? String,
            let graphId = card["graphId"] as? String
      else {
        continue
      }
      do {
        todayValues[cardId] = try await fetchPixelaTodayValue(
          username: credentials.username,
          token: credentials.token,
          graphId: graphId
        )
        todayValueDates[cardId] = todayDateStamp(for: card)
      } catch {
        todayValues.removeValue(forKey: cardId)
        todayValueDates.removeValue(forKey: cardId)
        continue
      }
    }

    var enrichedContext = context
    enrichedContext["todayValues"] = todayValues
    enrichedContext["todayValueDates"] = todayValueDates
    enrichedContext["updatedAt"] = Date().timeIntervalSince1970
    return enrichedContext
  }

  private func makeContext(from payload: [String: Any]) -> [String: Any] {
    let cards = (payload["cards"] as? [[String: Any]] ?? []).map { card in
      propertyListDictionary(from: card)
    }
    storeCredentials(username: payload["username"] as? String ?? "", token: payload["token"] as? String ?? "")
    return [
      "username": payload["username"] as? String ?? "",
      "cards": cards,
      "updatedAt": Date().timeIntervalSince1970,
    ]
  }

  private func todayDateStamp(for card: [String: Any]) -> String {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyyMMdd"
    if let timezone = card["timezone"] as? String,
       let timeZone = TimeZone(identifier: timezone) {
      formatter.timeZone = timeZone
    }
    return formatter.string(from: Date())
  }

  private func propertyListDictionary(from dictionary: [String: Any]) -> [String: Any] {
    dictionary.reduce(into: [String: Any]()) { result, item in
      guard let value = propertyListValue(from: item.value) else {
        return
      }
      result[item.key] = value
    }
  }

  private func propertyListValue(from value: Any) -> Any? {
    if value is NSNull {
      return nil
    }
    if value is String || value is NSNumber || value is Date || value is Data {
      return value
    }
    if let array = value as? [Any] {
      return array.compactMap { propertyListValue(from: $0) }
    }
    if let dictionary = value as? [String: Any] {
      return propertyListDictionary(from: dictionary)
    }
    return nil
  }

  private func store(_ context: [String: Any]) {
    guard JSONSerialization.isValidJSONObject(context),
          let data = try? JSONSerialization.data(withJSONObject: context)
    else {
      return
    }
    UserDefaults.standard.set(data, forKey: storageKey)
  }

  private func restoreContext() -> [String: Any]? {
    guard
      let data = UserDefaults.standard.data(forKey: storageKey),
      let object = try? JSONSerialization.jsonObject(with: data),
      let context = object as? [String: Any]
    else {
      return nil
    }
    return context
  }

  private func storeCredentials(username: String, token: String) {
    UserDefaults.standard.set(username, forKey: usernameKey)
    if token.isEmpty {
      deleteToken()
    } else {
      storeToken(token)
    }
  }

  private func restoreCredentials() -> (username: String, token: String) {
    return (
      UserDefaults.standard.string(forKey: usernameKey) ?? "",
      restoreToken() ?? ""
    )
  }

  private func storeToken(_ token: String) {
    guard let data = token.data(using: .utf8) else {
      return
    }
    deleteToken()
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: tokenService,
      kSecAttrAccount as String: tokenAccount,
      kSecValueData as String: data,
    ]
    SecItemAdd(query as CFDictionary, nil)
  }

  private func restoreToken() -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: tokenService,
      kSecAttrAccount as String: tokenAccount,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
    ]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status == errSecSuccess,
          let data = item as? Data
    else {
      return nil
    }
    return String(data: data, encoding: .utf8)
  }

  private func deleteToken() {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: tokenService,
      kSecAttrAccount as String: tokenAccount,
    ]
    SecItemDelete(query as CFDictionary)
  }

  private func recordButton(message: [String: Any]) async throws {
    guard let cardId = message["cardId"] as? String,
          let buttonId = message["buttonId"] as? String
    else {
      throw WatchRecordError.invalidMessage
    }

    let credentials = restoreCredentials()
    guard !credentials.username.isEmpty, !credentials.token.isEmpty else {
      throw WatchRecordError.missingCredentials
    }

    let context = restoreContext() ?? session?.applicationContext ?? [:]
    guard let cards = context["cards"] as? [[String: Any]],
          let card = cards.first(where: { $0["id"] as? String == cardId }),
          let graphId = card["graphId"] as? String,
          let buttons = card["buttons"] as? [[String: Any]],
          let button = buttons.first(where: { $0["id"] as? String == buttonId }),
          let value = (button["value"] as? NSNumber)?.doubleValue
    else {
      throw WatchRecordError.cardNotFound
    }

    try await sendPixelaRecord(
      username: credentials.username,
      token: credentials.token,
      graphId: graphId,
      value: value
    )
    await refreshAndSendTodayValues()
  }

  private func todayValue(message: [String: Any]) async throws -> Double {
    guard let cardId = message["cardId"] as? String else {
      throw WatchRecordError.invalidMessage
    }

    let credentials = restoreCredentials()
    guard !credentials.username.isEmpty, !credentials.token.isEmpty else {
      throw WatchRecordError.missingCredentials
    }

    let context = restoreContext() ?? session?.applicationContext ?? [:]
    guard let cards = context["cards"] as? [[String: Any]],
          let card = cards.first(where: { $0["id"] as? String == cardId }),
          let graphId = card["graphId"] as? String
    else {
      throw WatchRecordError.cardNotFound
    }

    return try await fetchPixelaTodayValue(
      username: credentials.username,
      token: credentials.token,
      graphId: graphId
    )
  }

  private func todayValueDate(message: [String: Any]) -> String {
    guard let cardId = message["cardId"] as? String else {
      return todayDateStamp(for: [:])
    }

    let context = restoreContext() ?? session?.applicationContext ?? [:]
    guard let cards = context["cards"] as? [[String: Any]],
          let card = cards.first(where: { $0["id"] as? String == cardId })
    else {
      return todayDateStamp(for: [:])
    }

    return todayDateStamp(for: card)
  }

  private func sendPixelaRecord(username: String, token: String, graphId: String, value: Double) async throws {
    let escapedUsername = username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? username
    let escapedGraphId = graphId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? graphId
    let action = value >= 0 ? "add" : "subtract"
    guard let url = URL(string: "https://pixe.la/v1/users/\(escapedUsername)/graphs/\(escapedGraphId)/\(action)") else {
      throw WatchRecordError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue(token, forHTTPHeaderField: "X-USER-TOKEN")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("PixelaButtons WatchConnectivity", forHTTPHeaderField: "User-Agent")
    request.httpBody = try JSONSerialization.data(withJSONObject: [
      "quantity": quantityString(abs(value)),
    ])

    let maxRetries = 30
    for attempt in 0...maxRetries {
      let (data, response) = try await URLSession.shared.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse else {
        throw WatchRecordError.requestFailed("No HTTP response.")
      }
      if (200..<300).contains(httpResponse.statusCode) {
        return
      }
      if httpResponse.statusCode == 503,
         attempt < maxRetries,
         isRejectedResponse(data) {
        try await Task.sleep(nanoseconds: 500_000_000)
        continue
      }
      throw WatchRecordError.requestFailed(responseMessage(from: data, statusCode: httpResponse.statusCode))
    }
  }

  private func fetchPixelaTodayValue(username: String, token: String, graphId: String) async throws -> Double {
    let escapedUsername = username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? username
    let escapedGraphId = graphId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? graphId
    guard let url = URL(string: "https://pixe.la/v1/users/\(escapedUsername)/graphs/\(escapedGraphId)/today") else {
      throw WatchRecordError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(token, forHTTPHeaderField: "X-USER-TOKEN")
    request.setValue("PixelaButtons WatchConnectivity", forHTTPHeaderField: "User-Agent")

    let maxRetries = 30
    for attempt in 0...maxRetries {
      let (data, response) = try await URLSession.shared.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse else {
        throw WatchRecordError.requestFailed("No HTTP response.")
      }
      if (200..<300).contains(httpResponse.statusCode) {
        return try todayValue(from: data)
      }
      if httpResponse.statusCode == 503,
         attempt < maxRetries,
         isRejectedResponse(data) {
        try await Task.sleep(nanoseconds: 500_000_000)
        continue
      }
      throw WatchRecordError.requestFailed(responseMessage(from: data, statusCode: httpResponse.statusCode))
    }

    throw WatchRecordError.requestFailed("Pixela API request failed.")
  }

  private func todayValue(from data: Data) throws -> Double {
    guard let object = try? JSONSerialization.jsonObject(with: data),
          let dictionary = object as? [String: Any],
          let quantity = dictionary["quantity"]
    else {
      throw WatchRecordError.requestFailed("Pixela today value response was invalid.")
    }
    if let number = quantity as? NSNumber {
      return number.doubleValue
    }
    if let string = quantity as? String,
       let value = Double(string) {
      return value
    }
    throw WatchRecordError.requestFailed("Pixela today value response was invalid.")
  }

  private func quantityString(_ value: Double) -> String {
    value == value.rounded(.towardZero) ? String(Int(value)) : String(value)
  }

  private func isRejectedResponse(_ data: Data) -> Bool {
    guard let object = try? JSONSerialization.jsonObject(with: data),
          let dictionary = object as? [String: Any]
    else {
      return false
    }
    return dictionary["isRejected"] as? Bool == true
  }

  private func responseMessage(from data: Data, statusCode: Int) -> String {
    if let object = try? JSONSerialization.jsonObject(with: data),
       let dictionary = object as? [String: Any],
       let message = dictionary["message"] as? String,
       !message.isEmpty {
      return "Pixela API \(statusCode): \(message)"
    }
    if let text = String(data: data, encoding: .utf8),
       !text.isEmpty {
      return "Pixela API \(statusCode): \(text)"
    }
    return "Pixela API request failed with status \(statusCode)."
  }

  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    guard activationState == .activated, let pendingContext else {
      return
    }
    do {
      try send(pendingContext, using: session)
      Task {
        await refreshAndSendTodayValues(for: pendingContext)
      }
    } catch {
      self.pendingContext = pendingContext
    }
  }

  func sessionDidBecomeInactive(_ session: WCSession) {}

  func sessionDidDeactivate(_ session: WCSession) {
    session.activate()
  }

  func session(
    _ session: WCSession,
    didReceiveMessage message: [String: Any],
    replyHandler: @escaping ([String: Any]) -> Void
  ) {
    switch message["type"] as? String {
    case "requestCards":
      replyHandler(restoreContext() ?? session.applicationContext)
    case "recordButton":
      Task {
        do {
          try await recordButton(message: message)
          replyHandler(["ok": true])
        } catch {
          replyHandler([
            "ok": false,
            "error": error.localizedDescription,
          ])
        }
      }
    case "requestTodayValue":
      Task {
        do {
          let value = try await todayValue(message: message)
          let date = todayValueDate(message: message)
          replyHandler([
            "ok": true,
            "value": value,
            "date": date,
          ])
        } catch {
          replyHandler([
            "ok": false,
            "error": error.localizedDescription,
          ])
        }
      }
    default:
      replyHandler([:])
    }
  }
}

private enum WatchRecordError: LocalizedError {
  case invalidMessage
  case missingCredentials
  case cardNotFound
  case invalidURL
  case requestFailed(String)

  var errorDescription: String? {
    switch self {
    case .invalidMessage:
      return "Invalid record request."
    case .missingCredentials:
      return "Pixela credentials are not available on iPhone."
    case .cardNotFound:
      return "Card setting was not found on iPhone."
    case .invalidURL:
      return "Invalid Pixela API URL."
    case .requestFailed(let message):
      return message
    }
  }
}
