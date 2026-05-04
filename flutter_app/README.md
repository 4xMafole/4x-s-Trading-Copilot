# trading_copilot_flutter

Flutter mobile app for 4x Trades trading discipline workflows.

## Implemented mobile behavior loop

1. Journal missed-trade backfill with date/time and quick shortcuts.
2. Push session alerts with configurable EAT schedule in Settings.
3. Biometric lock on app open/resume.
4. Android home-screen widget with:
	- EAT clock
	- live session status
	- trades remaining today

## Run locally

1. Install dependencies:
	`flutter pub get`
2. Run tests:
	`flutter test`
3. Run app:
	`flutter run`

## Android widget notes

- Widget provider: `android/app/src/main/kotlin/com/example/trading_copilot_flutter/TradingStatusWidgetProvider.kt`
- Widget layout: `android/app/src/main/res/layout/trading_status_widget.xml`
- Widget metadata: `android/app/src/main/res/xml/trading_status_widget_info.xml`

## iOS Live Activity handoff (Mac/Xcode required)

iOS project scaffold and app-side method-channel bridge are already included, but Live Activity final wiring still requires Xcode target configuration on macOS.

Use:
- `ios/Runner/AppDelegate.swift` for native bridge handling.
- `ios/LiveActivityExtensionTemplate/` for extension template and setup guide.

Additional implementation notes:
- `docs/mobile_surfaces.md`
