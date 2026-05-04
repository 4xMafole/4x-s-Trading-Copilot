import Flutter
import UIKit
import ActivityKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let liveActivityManager = TradingSessionLiveActivityManager()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "trading_copilot/live_activity",
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { [weak self] call, result in
        self?.handleLiveActivityMethod(call: call, result: result)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handleLiveActivityMethod(call: FlutterMethodCall, result: FlutterResult) {
    switch call.method {
    case "syncSessionActivity":
      guard
        let args = call.arguments as? [String: Any],
        let sessionLabel = args["sessionLabel"] as? String,
        let tradesRemaining = args["tradesRemaining"] as? Int,
        let eatTime = args["eatTime"] as? String
      else {
        result(false)
        return
      }

      liveActivityManager.sync(
        sessionLabel: sessionLabel,
        tradesRemaining: tradesRemaining,
        eatTime: eatTime
      )
      result(true)

    case "endSessionActivity":
      liveActivityManager.end()
      result(true)

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

private final class TradingSessionLiveActivityManager {
  @available(iOS 16.1, *)
  private var activity: Activity<TradingSessionActivityAttributes>?

  func sync(sessionLabel: String, tradesRemaining: Int, eatTime: String) {
    guard #available(iOS 16.1, *) else { return }

    let state = TradingSessionActivityAttributes.ContentState(
      sessionLabel: sessionLabel,
      tradesRemaining: tradesRemaining,
      eatTime: eatTime
    )

    Task {
      await syncOnSupportedOS(state: state)
    }
  }

  func end() {
    guard #available(iOS 16.1, *) else { return }
    Task {
      await endOnSupportedOS()
    }
  }

  @available(iOS 16.1, *)
  private func syncOnSupportedOS(state: TradingSessionActivityAttributes.ContentState) async {
    if let current = activity {
      if #available(iOS 16.2, *) {
        await current.update(ActivityContent(state: state, staleDate: nil))
      } else {
        await current.update(using: state)
      }
      return
    }

    do {
      let attributes = TradingSessionActivityAttributes(name: "4x Trades")
      if #available(iOS 16.2, *) {
        let content = ActivityContent(state: state, staleDate: nil)
        activity = try Activity.request(
          attributes: attributes,
          content: content,
          pushType: nil
        )
      } else {
        activity = try Activity.request(
          attributes: attributes,
          contentState: state,
          pushType: nil
        )
      }
    } catch {
      // Live activity creation is best-effort.
    }
  }

  @available(iOS 16.1, *)
  private func endOnSupportedOS() async {
    guard let current = activity else { return }

    if #available(iOS 16.2, *) {
      await current.end(nil, dismissalPolicy: .immediate)
    } else {
      await current.end(using: nil, dismissalPolicy: .immediate)
    }

    activity = nil
  }
}

@available(iOS 16.1, *)
private struct TradingSessionActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var sessionLabel: String
    var tradesRemaining: Int
    var eatTime: String
  }

  var name: String
}
