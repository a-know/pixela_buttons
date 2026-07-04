import Flutter
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
  }

  private func send(_ context: [String: Any], using session: WCSession) throws {
    try session.updateApplicationContext(context)
    session.transferUserInfo(context)
    pendingContext = nil
  }

  private func makeContext(from payload: [String: Any]) -> [String: Any] {
    let cards = (payload["cards"] as? [[String: Any]] ?? []).map { card in
      propertyListDictionary(from: card)
    }
    return [
      "username": payload["username"] as? String ?? "",
      "cards": cards,
      "updatedAt": Date().timeIntervalSince1970,
    ]
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
    guard message["type"] as? String == "requestCards" else {
      replyHandler([:])
      return
    }
    replyHandler(restoreContext() ?? session.applicationContext)
  }
}
