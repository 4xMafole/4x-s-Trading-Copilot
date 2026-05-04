# Mobile Surfaces Implementation Notes

## Implemented now

1. Android home-screen widget
- Shows EAT clock, current session status, and trades remaining today.
- Refreshes when Flutter state is saved through method channel bridge.

2. Configurable push notifications
- Session events are configurable in Settings and scheduled in EAT.
- Events currently include Mid London, Late London, Blackout, and NY Open.

3. Biometric lock
- Face ID / fingerprint lock can be enabled in Settings.
- App prompts on open/resume when lock is enabled.

## iOS Live Activity handoff (implemented bridge + template)

- iOS platform scaffold is generated under [ios](../ios).
- App-side ActivityKit bridge is implemented in [ios/Runner/AppDelegate.swift](../ios/Runner/AppDelegate.swift).
- Widget Extension template is provided in [ios/LiveActivityExtensionTemplate](../ios/LiveActivityExtensionTemplate).

To finalize Live Activity, a Mac/Xcode user must add and wire a Widget Extension target.
