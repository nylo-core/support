import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/live/src/ny_live_json.dart';
import 'package:nylo_support/testing/ny_testing.dart';

class _User extends Model {
  final String name;

  _User(this.name);

  @override
  Map<String, dynamic> toJson() => {'name': name};
}

class _WithToJson {
  Map<String, dynamic> toJson() => {'ok': true};
}

class _Opaque {
  @override
  String toString() => 'opaque';
}

enum _Tier { gold }

String _envelope(String type, String data, {int? expiresAt}) => jsonEncode({
  '_v': 'v1',
  '_t': type,
  '_d': data,
  if (expiresAt != null) '_e': expiresAt,
});

void main() {
  NyTest.init();

  nyGroup('NyLiveJson.encodable', () {
    nyTest('passes JSON primitives through', () async {
      expect(NyLiveJson.encodable(null), isNull);
      expect(NyLiveJson.encodable('a'), 'a');
      expect(NyLiveJson.encodable(1), 1);
      expect(NyLiveJson.encodable(true), isTrue);
    });

    nyTest('converts values jsonEncode rejects', () async {
      final Object? value = NyLiveJson.encodable({
        1: DateTime.utc(2026, 9, 12),
        'user': _User('Jane'),
        'custom': _WithToJson(),
        'opaque': _Opaque(),
        'tier': _Tier.gold,
        'items': {'a', 'b'},
        'nan': double.nan,
        'wait': const Duration(seconds: 2),
      });

      expect(value, {
        '1': '2026-09-12T00:00:00.000Z',
        'user': {'name': 'Jane'},
        'custom': {'ok': true},
        'opaque': 'opaque',
        'tier': 'gold',
        'items': ['a', 'b'],
        'nan': 'NaN',
        'wait': 2000,
      });
      expect(() => jsonEncode(value), returnsNormally);
    });
  });

  nyGroup('NyLiveJson.describeStorageValue', () {
    nyTest('reports a missing key', () async {
      expect(NyLiveJson.describeStorageValue('k', null), {
        'key': 'k',
        'exists': false,
        'type': null,
        'value': null,
      });
    });

    nyTest('decodes typed envelopes', () async {
      expect(
        NyLiveJson.describeStorageValue(
          's',
          _envelope('String', 'hi'),
        )['value'],
        'hi',
      );
      expect(NyLiveJson.describeStorageValue('i', _envelope('int', '10')), {
        'key': 'i',
        'exists': true,
        'type': 'int',
        'value': 10,
      });
      expect(
        NyLiveJson.describeStorageValue(
          'd',
          _envelope('double', '1.5'),
        )['value'],
        1.5,
      );
      expect(
        NyLiveJson.describeStorageValue(
          'b',
          _envelope('bool', 'true'),
        )['value'],
        isTrue,
      );
      expect(
        NyLiveJson.describeStorageValue(
          'n',
          _envelope('Null', 'null'),
        )['value'],
        isNull,
      );
      expect(
        NyLiveJson.describeStorageValue(
          'j',
          _envelope('json', jsonEncode({'id': 42})),
        )['value'],
        {'id': 42},
      );
      expect(
        NyLiveJson.describeStorageValue(
          'm',
          _envelope('model', jsonEncode({'name': 'Jane'})),
        )['type'],
        'model',
      );
    });

    nyTest('adds an ISO-8601 expiry when the envelope has one', () async {
      final int expiresAt = DateTime(2030, 1, 1).millisecondsSinceEpoch;

      final Map<String, Object?> described = NyLiveJson.describeStorageValue(
        'token',
        _envelope('String', 'abc', expiresAt: expiresAt),
      );

      expect(
        described['expiresAt'],
        DateTime.fromMillisecondsSinceEpoch(expiresAt).toIso8601String(),
      );
    });

    nyTest('returns raw values that are not envelopes', () async {
      expect(NyLiveJson.describeStorageValue('legacy', 'plain'), {
        'key': 'legacy',
        'exists': true,
        'type': 'raw',
        'value': 'plain',
      });
      expect(NyLiveJson.describeStorageValue('json', '{"a":1}')['type'], 'raw');
    });
  });
}
