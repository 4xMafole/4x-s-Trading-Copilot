const int kCurrentSchemaVersion = 2;

Map<String, dynamic> migrateAppStatePayload(Map<String, dynamic> raw) {
  var payload = Map<String, dynamic>.from(raw);

  if (payload.containsKey('trades') && !payload.containsKey('allTrades')) {
    payload['allTrades'] = payload['trades'];
  }

  var version = _coerceInt(payload['schemaVersion']) ?? 1;
  if (version < 1) version = 1;

  while (version < kCurrentSchemaVersion) {
    switch (version) {
      case 1:
        payload = _migrateV1ToV2(payload);
        version = 2;
        break;
      default:
        version = kCurrentSchemaVersion;
        break;
    }
  }

  payload.putIfAbsent('checks', () => <String, dynamic>{});
  payload.putIfAbsent('lock', () => false);
  payload.putIfAbsent('preloaded', () => true);
  payload['schemaVersion'] = kCurrentSchemaVersion;

  return payload;
}

Map<String, dynamic> _migrateV1ToV2(Map<String, dynamic> payload) {
  final migrated = Map<String, dynamic>.from(payload);
  migrated['allTrades'] = _normalizeTrades(migrated['allTrades']);
  migrated['schemaVersion'] = 2;
  return migrated;
}

List<Map<String, dynamic>> _normalizeTrades(dynamic rawTrades) {
  if (rawTrades is! List) return <Map<String, dynamic>>[];

  final trades = <Map<String, dynamic>>[];
  final seenIds = <String>{};

  for (var i = 0; i < rawTrades.length; i++) {
    final item = rawTrades[i];
    if (item is! Map) continue;

    final trade = Map<String, dynamic>.from(item);

    var id = (trade['id'] ?? '').toString().trim();
    if (id.isEmpty) {
      id = 'migrated_${DateTime.now().microsecondsSinceEpoch}_$i';
    }
    while (seenIds.contains(id)) {
      id = '${id}_$i';
    }
    seenIds.add(id);

    trade['id'] = id;

    final date = (trade['date'] ?? '').toString().trim();
    if (date.isNotEmpty && _isIsoDate(date)) {
      trade['date'] = date;
    }

    final time = (trade['time'] ?? '').toString().trim();
    if (time.isNotEmpty) {
      final normalizedTime = _normalizeTime(time);
      if (normalizedTime != null) {
        trade['time'] = normalizedTime;
      }
    }

    final dir = (trade['dir'] ?? '').toString().trim().toLowerCase();
    if (dir == 'buy' || dir == 'sell') {
      trade['dir'] = dir;
    }

    final violations = trade['violations'];
    if (violations is String) {
      trade['violations'] = violations
          .split('|')
          .map((v) => v.trim())
          .where((v) => v.isNotEmpty)
          .toList();
    } else if (violations is List) {
      trade['violations'] = violations.map((v) => v.toString()).toList();
    } else {
      trade['violations'] = <String>[];
    }

    trades.add(trade);
  }

  return trades;
}

String? _normalizeTime(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return null;

  final first = value.split(' ').first;
  final parts = first.split(':');
  if (parts.length < 2) return null;

  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
    return null;
  }

  final hh = h.toString().padLeft(2, '0');
  final mm = m.toString().padLeft(2, '0');
  return '$hh:$mm EAT';
}

bool _isIsoDate(String value) {
  if (!_isoDatePattern.hasMatch(value)) return false;
  final parsed = DateTime.tryParse('${value}T00:00:00Z');
  if (parsed == null) return false;

  final y = parsed.toUtc().year.toString().padLeft(4, '0');
  final m = parsed.toUtc().month.toString().padLeft(2, '0');
  final d = parsed.toUtc().day.toString().padLeft(2, '0');
  return '$y-$m-$d' == value;
}

int? _coerceInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

final RegExp _isoDatePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
