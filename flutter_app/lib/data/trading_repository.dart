import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'schema_migration.dart';

class TradingRepository {
  // Encrypted box (current).
  static const String _boxName = 'trading_box_enc_v1';
  // Legacy plaintext box — read-once on first encrypted launch.
  static const String _legacyBoxName = 'trading_box';

  static const String _appStateKey = 'em_fp2_v4';
  static const String _themeKey = 'theme_mode_v1';
  static const String _sessionAlertsEnabledKey = 'session_alerts_enabled_v1';
  static const String _biometricLockKey = 'biometric_lock_enabled_v1';
  static const String _sessionAlertTimesKey = 'session_alert_times_v1';
  static const String _walkthroughKey = 'walkthrough_v2';

  // Secure-storage entries.
  static const String _ssAesKey = 'hive_aes_key_v1';
  static const String _ssMigratedFlag = 'legacy_box_migrated_v1';

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  late Box _box;

  /// Whether the box is currently encrypted at rest. Surfaced in Settings.
  bool encryptionEnabled = false;

  Future<void> init() async {
    await Hive.initFlutter();

    // Acquire (or generate) the AES key.
    final key = await _ensureAesKey();

    // Open the encrypted box.
    _box = await Hive.openBox(_boxName, encryptionCipher: HiveAesCipher(key));
    encryptionEnabled = true;

    // One-shot migrate plaintext box -> encrypted box.
    await _migratePlaintextToEncrypted();

    // SharedPreferences fallback migration (legacy path).
    await _migrateFromSharedPreferences();
  }

  // ── Encryption key management ───────────────────────────────────────

  Future<List<int>> _ensureAesKey() async {
    final existing = await _secureStorage.read(key: _ssAesKey);
    if (existing != null) {
      try {
        return base64Decode(existing);
      } catch (_) {
        // Corrupt stored key — regenerate. Old box becomes unreadable but
        // we have a plaintext-box safety net for one launch.
      }
    }
    final key = Hive.generateSecureKey();
    await _secureStorage.write(key: _ssAesKey, value: base64Encode(key));
    return key;
  }

  /// On first encrypted run, copy any entries from the legacy plaintext box
  /// into the encrypted box so users don't lose data. Idempotent — guarded
  /// by a flag in secure storage.
  Future<void> _migratePlaintextToEncrypted() async {
    final flag = await _secureStorage.read(key: _ssMigratedFlag);
    if (flag == 'true') return;

    if (!await Hive.boxExists(_legacyBoxName)) {
      await _secureStorage.write(key: _ssMigratedFlag, value: 'true');
      return;
    }
    try {
      final legacy = await Hive.openBox(_legacyBoxName);
      for (final k in legacy.keys) {
        if (!_box.containsKey(k)) {
          await _box.put(k, legacy.get(k));
        }
      }
      await legacy.close();
      // Best-effort: delete the plaintext box from disk.
      await Hive.deleteBoxFromDisk(_legacyBoxName);
    } catch (e) {
      debugPrint('Plaintext -> encrypted migration failed: $e');
    }
    await _secureStorage.write(key: _ssMigratedFlag, value: 'true');
  }

  /// Re-key the encrypted box. Reads everything, generates a fresh AES key,
  /// writes everything back encrypted with the new key. Used by the
  /// "Reset encryption key" action in Settings.
  Future<void> rotateEncryptionKey() async {
    // Snapshot current data.
    final snapshot = <dynamic, dynamic>{};
    for (final k in _box.keys) {
      snapshot[k] = _box.get(k);
    }
    await _box.close();
    // Wipe and regenerate the key.
    await Hive.deleteBoxFromDisk(_boxName);
    await _secureStorage.delete(key: _ssAesKey);
    final key = await _ensureAesKey();
    _box = await Hive.openBox(_boxName, encryptionCipher: HiveAesCipher(key));
    for (final entry in snapshot.entries) {
      await _box.put(entry.key, entry.value);
    }
  }

  Future<void> _migrateFromSharedPreferences() async {
    // If the box already has data, we already migrated or it's a new install
    if (_box.containsKey(_appStateKey)) return;

    final prefs = await SharedPreferences.getInstance();

    // Migrate AppState
    final stateStr = prefs.getString(_appStateKey);
    if (stateStr != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(stateStr);
        // Save the decoded JSON map directly to Hive
        await _box.put(_appStateKey, json);
      } catch (e) {
        debugPrint('Failed to migrate AppState to Hive: $e');
      }
    }

    // Migrate settings
    if (prefs.containsKey(_themeKey)) {
      await _box.put(_themeKey, prefs.getInt(_themeKey));
    }
    if (prefs.containsKey(_biometricLockKey)) {
      await _box.put(_biometricLockKey, prefs.getBool(_biometricLockKey));
    }
    if (prefs.containsKey(_sessionAlertsEnabledKey)) {
      await _box.put(
        _sessionAlertsEnabledKey,
        prefs.getBool(_sessionAlertsEnabledKey),
      );
    }
    if (prefs.containsKey(_sessionAlertTimesKey)) {
      await _box.put(
        _sessionAlertTimesKey,
        prefs.getString(_sessionAlertTimesKey),
      );
    }
    if (prefs.containsKey(_walkthroughKey)) {
      await _box.put(_walkthroughKey, prefs.getBool(_walkthroughKey));
    }

    // After migration, you can optionally clear prefs or leave them. Let's leave them for safety for now.
  }

  // --- App State ---

  Future<AppState> getAppState() async {
    final dynamic data = _box.get(_appStateKey);
    if (data == null) {
      return AppState.defaults();
    }
    try {
      final String jsonStr = jsonEncode(data);
      final Map<String, dynamic> map = jsonDecode(jsonStr);
      return AppState.fromJson(migrateAppStatePayload(map));
    } catch (e) {
      debugPrint('Error parsing AppState from Hive: $e');
      return AppState.defaults();
    }
  }

  Future<void> saveAppState(AppState state) async {
    await _box.put(_appStateKey, state.toJson());
  }

  // --- Settings ---

  Future<ThemeMode> getThemeMode() async {
    final int? themeIdx = _box.get(_themeKey);
    if (themeIdx != null &&
        themeIdx >= 0 &&
        themeIdx < ThemeMode.values.length) {
      return ThemeMode.values[themeIdx];
    }
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _box.put(_themeKey, mode.index);
  }

  Future<bool> getBiometricLockEnabled() async {
    return _box.get(_biometricLockKey, defaultValue: false);
  }

  Future<void> setBiometricLockEnabled(bool enabled) async {
    await _box.put(_biometricLockKey, enabled);
  }

  Future<bool> getSessionAlertsEnabled() async {
    return _box.get(_sessionAlertsEnabledKey, defaultValue: false);
  }

  Future<void> setSessionAlertsEnabled(bool enabled) async {
    await _box.put(_sessionAlertsEnabledKey, enabled);
  }

  Future<String?> getSessionAlertTimes() async {
    return _box.get(_sessionAlertTimesKey);
  }

  Future<void> setSessionAlertTimes(String jsonTimes) async {
    await _box.put(_sessionAlertTimesKey, jsonTimes);
  }

  Future<bool> hasSeenWalkthrough() async {
    return _box.get(_walkthroughKey, defaultValue: false);
  }

  Future<void> setHasSeenWalkthrough(bool seen) async {
    await _box.put(_walkthroughKey, seen);
  }
}
