import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/models.dart';

/// Sprint 5.2 — Encrypted local-file backup.
///
/// Strategy: $0/month, no server, no OAuth. We export the entire
/// AppState as a PIN-encrypted JSON blob (AES-GCM, PBKDF2-HMAC-SHA256
/// 200k iterations) and hand it to the OS share sheet. The user picks
/// where to put it — Drive, iCloud, Dropbox, email-to-self — all of
/// which mount as share targets on Android & iOS for free.
///
/// Restore: file_picker → user types the same PIN → decrypt → return
/// AppState. The cubit handles the actual replace.
class CloudBackupService {
  CloudBackupService();

  /// Magic header so we can sanity-check files before attempting decrypt.
  static const String _magic = 'LTBKPv1';
  static const int _pbkdf2Iterations = 200000;
  static const int _saltLength = 16;
  static const int _nonceLength = 12;

  /// Builds an encrypted backup file in the app's cache dir, then
  /// invokes the OS share sheet so the user can drop it in Drive/iCloud.
  /// Returns the file path written.
  Future<String> exportEncryptedBackup({
    required AppState state,
    required String pin,
  }) async {
    if (pin.length < 4) {
      throw const FormatException('PIN must be at least 4 characters.');
    }

    final plaintext = utf8.encode(jsonEncode(state.toJson()));
    final salt = _randomBytes(_saltLength);
    final key = await _deriveKey(pin, salt);

    final algo = AesGcm.with256bits();
    final nonce = _randomBytes(_nonceLength);
    final secretBox = await algo.encrypt(
      plaintext,
      secretKey: key,
      nonce: nonce,
    );

    // File layout: magic | iter (4 BE) | salt (16) | nonce (12) | mac (16) | ct
    final mac = secretBox.mac.bytes;
    final ct = secretBox.cipherText;
    final out = BytesBuilder()
      ..add(utf8.encode(_magic))
      ..add(_uint32BE(_pbkdf2Iterations))
      ..add(salt)
      ..add(nonce)
      ..add(Uint8List.fromList(mac))
      ..add(Uint8List.fromList(ct));

    final dir = await getTemporaryDirectory();
    final ts = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final path = '${dir.path}/locotrader-backup-$ts.ltbkp';
    final file = File(path);
    await file.writeAsBytes(out.toBytes(), flush: true);

    await Share.shareXFiles(
      [XFile(path)],
      subject: 'LocoTrader encrypted backup',
      text: 'Save this file in Drive/iCloud. Restore with the same PIN.',
    );
    return path;
  }

  /// Decrypts a backup file produced by [exportEncryptedBackup]. Throws
  /// `FormatException` on bad magic and `BackupAuthException` on wrong PIN.
  Future<AppState> importEncryptedBackup({
    required File file,
    required String pin,
  }) async {
    final bytes = await file.readAsBytes();
    final magicLen = _magic.length;
    if (bytes.length < magicLen + 4 + _saltLength + _nonceLength + 16) {
      throw const FormatException('File too small to be a LocoTrader backup.');
    }
    final magic = utf8.decode(bytes.sublist(0, magicLen));
    if (magic != _magic) {
      throw const FormatException('Not a LocoTrader backup file.');
    }
    var offset = magicLen;
    final iter = _readUint32BE(bytes, offset);
    offset += 4;
    final salt = bytes.sublist(offset, offset + _saltLength);
    offset += _saltLength;
    final nonce = bytes.sublist(offset, offset + _nonceLength);
    offset += _nonceLength;
    final mac = bytes.sublist(offset, offset + 16);
    offset += 16;
    final ct = bytes.sublist(offset);

    final key = await _deriveKey(pin, salt, iterations: iter);
    final algo = AesGcm.with256bits();
    try {
      final clear = await algo.decrypt(
        SecretBox(ct, nonce: nonce, mac: Mac(mac)),
        secretKey: key,
      );
      final json = jsonDecode(utf8.decode(clear)) as Map<String, dynamic>;
      return AppState.fromJson(json);
    } on SecretBoxAuthenticationError {
      throw BackupAuthException('Wrong PIN or corrupted backup.');
    } catch (e) {
      debugPrint('Backup decrypt failed: $e');
      throw const FormatException('Backup file is corrupted or malformed.');
    }
  }

  Future<SecretKey> _deriveKey(
    String pin,
    List<int> salt, {
    int iterations = _pbkdf2Iterations,
  }) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
  }

  Uint8List _randomBytes(int length) {
    final secureRandom = SecretKeyData.random(length: length);
    return Uint8List.fromList(secureRandom.bytes);
  }

  List<int> _uint32BE(int v) => [
    (v >> 24) & 0xff,
    (v >> 16) & 0xff,
    (v >> 8) & 0xff,
    v & 0xff,
  ];

  int _readUint32BE(List<int> b, int off) =>
      (b[off] << 24) | (b[off + 1] << 16) | (b[off + 2] << 8) | b[off + 3];
}

class BackupAuthException implements Exception {
  BackupAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
