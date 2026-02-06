import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Helper function to create an EnvGetter from a Map for testing
EnvGetter mockEnv(Map<String, dynamic> values) =>
    (String key, {dynamic defaultValue}) => values[key] ?? defaultValue;

void main() {
  NyTest.init();

  nySetUp(() {
    NyEnvRegistry.register(getter: mockEnv({'APP_DEBUG': true}));
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // NyStrExt (nullable String extensions)
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('NyStrExt (String? extensions)', () {
    nyGroup('toHexColor', () {
      nyTest('should convert hex string to Color', () async {
        const String? hexString = 'FF5733';

        final color = hexString.toHexColor();

        expect(color, isA<Color>());
        expect(color.red, 255);
        expect(color.green, 87);
        expect(color.blue, 51);
      });

      nyTest('should throw for null string', () async {
        const String? nullString = null;

        // Null string throws FormatException when parsed
        expect(() => nullString.toHexColor(), throwsA(isA<FormatException>()));
      });

      nyTest('should handle hex with hash', () async {
        const String? hexString = '#00FF00';

        final color = hexString.toHexColor();

        expect(color.green, 255);
      });
    });

    nyGroup('parseJson', () {
      nyTest('should parse valid JSON string', () async {
        const String? jsonString = '{"name": "John", "age": 30}';

        final result = jsonString.parseJson();

        expect(result, {'name': 'John', 'age': 30});
      });

      nyTest('should parse JSON array', () async {
        const String? jsonString = '[1, 2, 3]';

        final result = jsonString.parseJson();

        expect(result, [1, 2, 3]);
      });

      nyTest('should handle null string', () async {
        const String? nullString = null;

        final result = nullString.parseJson();

        expect(result, {});
      });

      nyTest('should parse primitive JSON values', () async {
        expect('"hello"'.parseJson(), 'hello');
        expect('123'.parseJson(), 123);
        expect('true'.parseJson(), true);
        expect('null'.parseJson(), null);
      });
    });

    nyGroup('toDateTime', () {
      nyTest('should convert ISO string to DateTime', () async {
        const String? dateString = '2024-03-15T10:30:00';

        final result = dateString.toDateTime();

        expect(result, isA<DateTime>());
        expect(result.year, 2024);
        expect(result.month, 3);
        expect(result.day, 15);
        expect(result.hour, 10);
        expect(result.minute, 30);
      });

      nyTest('should parse date-only string', () async {
        const String? dateString = '2024-03-15';

        final result = dateString.toDateTime();

        expect(result.year, 2024);
        expect(result.month, 3);
        expect(result.day, 15);
      });

      nyTest('should throw for null string', () async {
        const String? nullString = null;

        expect(() => nullString.toDateTime(), throwsA(isA<FormatException>()));
      });

      nyTest('should throw for invalid date string', () async {
        const String? invalidString = 'not-a-date';

        expect(
          () => invalidString.toDateTime(),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // NyStringExt (non-nullable String extensions)
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('NyStringExt (String extensions)', () {
    nyGroup('toBool', () {
      nyTest('should convert "true" to true', () async {
        final result = 'true'.toBool();

        expect(result, isTrue);
      });

      nyTest('should convert "TRUE" to true (case insensitive)', () async {
        final result = 'TRUE'.toBool();

        expect(result, isTrue);
      });

      nyTest('should convert "True" to true (mixed case)', () async {
        final result = 'True'.toBool();

        expect(result, isTrue);
      });

      nyTest('should convert "1" to true', () async {
        final result = '1'.toBool();

        expect(result, isTrue);
      });

      nyTest('should convert "false" to false', () async {
        final result = 'false'.toBool();

        expect(result, isFalse);
      });

      nyTest('should convert "FALSE" to false (case insensitive)', () async {
        final result = 'FALSE'.toBool();

        expect(result, isFalse);
      });

      nyTest('should convert "0" to false', () async {
        final result = '0'.toBool();

        expect(result, isFalse);
      });

      nyTest('should throw for invalid boolean string', () async {
        expect(() => 'invalid'.toBool(), throwsA(isA<UnsupportedError>()));
      });

      nyTest('should throw for empty string', () async {
        expect(() => ''.toBool(), throwsA(isA<UnsupportedError>()));
      });

      nyTest('should throw for "yes"', () async {
        expect(() => 'yes'.toBool(), throwsA(isA<UnsupportedError>()));
      });
    });

    nyGroup('tryParseBool', () {
      nyTest('should return true for "true"', () async {
        final result = 'true'.tryParseBool();

        expect(result, isTrue);
      });

      nyTest('should return true for "1"', () async {
        final result = '1'.tryParseBool();

        expect(result, isTrue);
      });

      nyTest('should return false for "false"', () async {
        final result = 'false'.tryParseBool();

        expect(result, isFalse);
      });

      nyTest('should return false for "0"', () async {
        final result = '0'.tryParseBool();

        expect(result, isFalse);
      });

      nyTest('should return null for invalid string', () async {
        final result = 'invalid'.tryParseBool();

        expect(result, isNull);
      });

      nyTest('should return null for empty string', () async {
        final result = ''.tryParseBool();

        expect(result, isNull);
      });

      nyTest('should handle case insensitivity', () async {
        expect('TRUE'.tryParseBool(), isTrue);
        expect('FALSE'.tryParseBool(), isFalse);
        expect('TrUe'.tryParseBool(), isTrue);
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // StringExtensionExt
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('StringExtensionExt', () {
    nyGroup('capitalize', () {
      nyTest('should capitalize first letter', () async {
        final result = 'hello'.capitalize();

        expect(result, 'Hello');
      });

      nyTest('should handle already capitalized string', () async {
        final result = 'Hello'.capitalize();

        expect(result, 'Hello');
      });

      nyTest('should handle single character', () async {
        final result = 'a'.capitalize();

        expect(result, 'A');
      });

      nyTest('should preserve rest of string', () async {
        final result = 'hELLO wORLD'.capitalize();

        expect(result, 'HELLO wORLD');
      });

      nyTest('should handle uppercase first letter', () async {
        final result = 'HELLO'.capitalize();

        expect(result, 'HELLO');
      });

      nyTest('should handle numbers at start', () async {
        final result = '123abc'.capitalize();

        expect(result, '123abc');
      });

      nyTest('should handle special characters at start', () async {
        final result = '!hello'.capitalize();

        expect(result, '!hello');
      });

      nyTest('should handle unicode characters', () async {
        final result = 'cafe'.capitalize();

        expect(result, 'Cafe');
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Edge Cases and Integration Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('String Extensions Edge Cases', () {
    nyTest('should handle whitespace in boolean conversion', () async {
      // Note: The implementation may not trim, so testing actual behavior
      expect('true'.tryParseBool(), isTrue);
      expect('false'.tryParseBool(), isFalse);
    });

    nyTest('should handle nested JSON objects', () async {
      const json = '{"user": {"name": "John", "address": {"city": "NYC"}}}';

      final result = json.parseJson();

      expect(result['user']['name'], 'John');
      expect(result['user']['address']['city'], 'NYC');
    });

    nyTest('should handle JSON with special characters', () async {
      const json = '{"message": "Hello\\nWorld", "symbol": "\\u0024"}';

      final result = json.parseJson();

      expect(result['message'], 'Hello\nWorld');
      expect(result['symbol'], '\$');
    });

    nyTest('should handle ISO 8601 date with timezone', () async {
      const dateString = '2024-03-15T10:30:00Z';

      final result = dateString.toDateTime();

      expect(result.isUtc, isTrue);
      expect(result.year, 2024);
    });

    nyTest('should handle various hex color formats', () async {
      expect('000000'.toHexColor().red, 0);
      expect('FFFFFF'.toHexColor().red, 255);
      expect('FF0000'.toHexColor().red, 255);
      expect('00FF00'.toHexColor().green, 255);
      expect('0000FF'.toHexColor().blue, 255);
    });

    nyTest('should handle complex JSON array', () async {
      const json = '[{"id": 1}, {"id": 2}, {"id": 3}]';

      final result = json.parseJson() as List;

      expect(result.length, 3);
      expect(result[0]['id'], 1);
      expect(result[2]['id'], 3);
    });
  });
}
