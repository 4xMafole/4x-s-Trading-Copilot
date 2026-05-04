# iOS Live Activity Extension Template

This folder provides the Live Activity widget SwiftUI source for iOS handoff.

## Why this is a template

A Live Activity requires a dedicated Widget Extension target in Xcode, and target wiring cannot be fully validated from a Windows environment.

## Steps on a Mac with Xcode

1. Open [ios/Runner.xcworkspace](../Runner.xcworkspace) in Xcode.
2. Add a new target: `File` -> `New` -> `Target...` -> `Widget Extension`.
3. Name it for example `TradingSessionLiveActivityExtension`.
4. Enable ActivityKit / Live Activities capability for both Runner and the new extension target.
5. Replace the generated widget Swift file with [ios/LiveActivityExtensionTemplate/TradingSessionLiveActivityWidget.swift](TradingSessionLiveActivityWidget.swift).
6. Ensure the attributes type used by the extension matches the app-side method-channel payload fields:
   - `sessionLabel`
   - `tradesRemaining`
   - `eatTime`
7. Build and run on a physical iPhone (iOS 16.1+).

## App-side bridge already implemented

The Flutter app already sends updates through iOS method channel `trading_copilot/live_activity` with methods:
- `syncSessionActivity`
- `endSessionActivity`

Native handling is in [ios/Runner/AppDelegate.swift](../Runner/AppDelegate.swift).
