import UIKit
import Flutter
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let appGroupId = "group.com.momrise.app"
  private let sharedKey = "SharedData"
  private var pendingSharedData: [String: Any]? = nil

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Required for flutter_local_notifications on iOS 10+
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    // Set up method channel for sharing intent
    let controller = window?.rootViewController as? FlutterViewController
    if let controller = controller {
      let channel = FlutterMethodChannel(name: "com.momrise.app/sharing", binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { [weak self] call, result in
        switch call.method {
        case "getSharedData":
          if let data = self?.consumeSharedData() {
            result(data)
          } else {
            result(nil)
          }
        case "clearSharedData":
          self?.clearSharedData()
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    // Check for shared data on cold start
    checkForSharedData()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle incoming URL scheme from ShareExtension
  override func application(_ app: UIApplication, open url: URL,
      options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if url.scheme == "SharingMedia-com.momrise.app" {
      checkForSharedData()
      // Notify Flutter via event
      if let controller = window?.rootViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(name: "com.momrise.app/sharing", binaryMessenger: controller.binaryMessenger)
        if let data = consumeSharedData() {
          channel.invokeMethod("onSharedData", arguments: data)
        }
      }
      return true
    }
    return super.application(app, open: url, options: options)
  }

  private func checkForSharedData() {
    let userDefaults = UserDefaults(suiteName: appGroupId)
    if let data = userDefaults?.dictionary(forKey: sharedKey) {
      pendingSharedData = data
    }
  }

  private func consumeSharedData() -> [String: Any]? {
    checkForSharedData()
    let data = pendingSharedData
    pendingSharedData = nil
    clearSharedData()
    return data
  }

  private func clearSharedData() {
    let userDefaults = UserDefaults(suiteName: appGroupId)
    userDefaults?.removeObject(forKey: sharedKey)
    userDefaults?.synchronize()
  }
}
