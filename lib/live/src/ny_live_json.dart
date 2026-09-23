import 'dart:convert';

import '/helpers/src/model.dart';

/// JSON helpers shared by the live commands.
class NyLiveJson {
  NyLiveJson._();

  /// Converts [value] into something `jsonEncode` accepts.
  ///
  /// Models and objects with `toJson()` are serialized, dates become ISO-8601
  /// strings, and anything else falls back to `toString()`.
  static Object? encodable(Object? value, [int depth = 0]) {
    if (value == null || value is bool || value is String) return value;
    if (value is num) return value.isFinite ? value : value.toString();
    if (depth > 12) return value.toString();
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic item) =>
            MapEntry(key.toString(), encodable(item, depth + 1)),
      );
    }
    if (value is Iterable) {
      return value.map((dynamic item) => encodable(item, depth + 1)).toList();
    }
    if (value is DateTime) return value.toIso8601String();
    if (value is Duration) return value.inMilliseconds;
    if (value is Enum) return value.name;
    if (value is Model) return encodable(value.toJson(), depth + 1);
    try {
      return encodable((value as dynamic).toJson(), depth + 1);
    } catch (_) {
      return value.toString();
    }
  }

  /// Describes a raw NyStorage value, decoding its `{_v, _t, _d, _e}` envelope.
  static Map<String, Object?> describeStorageValue(String key, String? raw) {
    if (raw == null) {
      return {'key': key, 'exists': false, 'type': null, 'value': null};
    }
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map &&
          decoded.containsKey('_v') &&
          decoded.containsKey('_t') &&
          decoded.containsKey('_d')) {
        final String type = decoded['_t'].toString().toLowerCase();
        final dynamic data = decoded['_d'];
        final dynamic expiresAt = decoded['_e'];
        return {
          'key': key,
          'exists': true,
          'type': type,
          'value': _decodeEnvelopeValue(type, data),
          if (expiresAt is int)
            'expiresAt': DateTime.fromMillisecondsSinceEpoch(
              expiresAt,
            ).toIso8601String(),
        };
      }
    } catch (_) {
      // Not an envelope; fall through to the raw value.
    }
    return {'key': key, 'exists': true, 'type': 'raw', 'value': raw};
  }

  static Object? _decodeEnvelopeValue(String type, dynamic data) {
    switch (type) {
      case 'int':
        return int.tryParse('$data') ?? data;
      case 'double':
        return double.tryParse('$data') ?? data;
      case 'bool':
        return '$data' == 'true';
      case 'null':
        return null;
      case 'json':
      case 'model':
        if (data is! String) return data;
        try {
          return jsonDecode(data);
        } catch (_) {
          return data;
        }
      default:
        return data;
    }
  }
}
