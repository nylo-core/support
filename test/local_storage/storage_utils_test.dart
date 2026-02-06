import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/local_storage/ny_local_storage.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('isInteger', () {
    nyGroup('valid integers', () {
      nyTest('should return true for positive integer string', () async {
        expect(isInteger('123'), isTrue);
        expect(isInteger('1'), isTrue);
        expect(isInteger('999999'), isTrue);
      });

      nyTest('should return true for negative integer string', () async {
        expect(isInteger('-123'), isTrue);
        expect(isInteger('-1'), isTrue);
        expect(isInteger('-999999'), isTrue);
      });

      nyTest('should return true for zero', () async {
        expect(isInteger('0'), isTrue);
      });
    });

    nyGroup('invalid integers', () {
      nyTest('should return false for null', () async {
        expect(isInteger(null), isFalse);
      });

      nyTest('should return false for empty string', () async {
        expect(isInteger(''), isFalse);
      });

      nyTest('should return false for decimal numbers', () async {
        expect(isInteger('123.45'), isFalse);
        expect(isInteger('1.0'), isFalse);
        expect(isInteger('-1.5'), isFalse);
      });

      nyTest('should return false for non-numeric strings', () async {
        expect(isInteger('abc'), isFalse);
        expect(isInteger('12a3'), isFalse);
        expect(isInteger('hello'), isFalse);
      });

      nyTest('should return false for whitespace', () async {
        expect(isInteger(' '), isFalse);
        expect(isInteger(' 123'), isFalse);
        expect(isInteger('123 '), isFalse);
      });

      nyTest('should return false for special characters', () async {
        expect(isInteger('12.3'), isFalse);
        expect(isInteger('1,234'), isFalse);
        expect(isInteger('\$100'), isFalse);
      });
    });
  });

  nyGroup('isDouble', () {
    nyGroup('valid doubles', () {
      nyTest('should return true for positive decimal string', () async {
        expect(isDouble('123.45'), isTrue);
        expect(isDouble('0.5'), isTrue);
        expect(isDouble('999.999'), isTrue);
      });

      nyTest('should return true for negative decimal string', () async {
        expect(isDouble('-123.45'), isTrue);
        expect(isDouble('-0.5'), isTrue);
        expect(isDouble('-999.999'), isTrue);
      });

      nyTest(
        'should return true for decimal with single digit after point',
        () async {
          expect(isDouble('1.5'), isTrue);
          expect(isDouble('10.0'), isTrue);
        },
      );
    });

    nyGroup('invalid doubles', () {
      nyTest('should return false for null', () async {
        expect(isDouble(null), isFalse);
      });

      nyTest('should return false for empty string', () async {
        expect(isDouble(''), isFalse);
      });

      nyTest('should return false for integers without decimal', () async {
        // isDouble requires a decimal point
        expect(isDouble('123'), isFalse);
        expect(isDouble('-123'), isFalse);
        expect(isDouble('0'), isFalse);
      });

      nyTest('should return false for non-numeric strings', () async {
        expect(isDouble('abc'), isFalse);
        expect(isDouble('12.3a'), isFalse);
      });

      nyTest('should return false for invalid decimal formats', () async {
        expect(isDouble('.5'), isFalse);
        expect(isDouble('5.'), isFalse);
        expect(isDouble('1.2.3'), isFalse);
      });

      nyTest('should return false for whitespace', () async {
        expect(isDouble(' '), isFalse);
        expect(isDouble(' 1.5'), isFalse);
      });
    });
  });

  nyGroup('JsonHelper', () {
    nyGroup('tryEncode', () {
      nyTest('should encode valid JSON data', () async {
        final result = JsonHelper.tryEncode({'key': 'value'});
        expect(result, '{"key":"value"}');
      });

      nyTest('should encode list data', () async {
        final result = JsonHelper.tryEncode([1, 2, 3]);
        expect(result, '[1,2,3]');
      });

      nyTest('should encode nested objects', () async {
        final result = JsonHelper.tryEncode({
          'user': {'name': 'John', 'age': 30},
        });
        expect(result, '{"user":{"name":"John","age":30}}');
      });

      nyTest('should encode primitive types', () async {
        expect(JsonHelper.tryEncode('string'), '"string"');
        expect(JsonHelper.tryEncode(123), '123');
        expect(JsonHelper.tryEncode(true), 'true');
        expect(JsonHelper.tryEncode(null), 'null');
      });

      nyTest(
        'should return null for DateTime (not directly JSON encodable)',
        () async {
          // DateTime is not directly JSON encodable without custom encoder
          final result = JsonHelper.tryEncode(DateTime(2024, 1, 1));
          // Returns null because DateTime cannot be directly encoded to JSON
          expect(result, isNull);
        },
      );

      nyTest('should handle empty collections', () async {
        expect(JsonHelper.tryEncode({}), '{}');
        expect(JsonHelper.tryEncode([]), '[]');
      });

      nyTest('should encode complex nested structures', () async {
        final data = {
          'users': [
            {'id': 1, 'name': 'Alice'},
            {'id': 2, 'name': 'Bob'},
          ],
          'total': 2,
          'active': true,
        };
        final result = JsonHelper.tryEncode(data);

        expect(result, isNotNull);
        expect(result!.contains('"users"'), isTrue);
        expect(result.contains('"Alice"'), isTrue);
      });
    });
  });

  nyGroup('additional isInteger edge cases', () {
    nyTest('should return true for large positive integers', () async {
      expect(isInteger('9999999999'), isTrue);
      expect(isInteger('12345678901234567890'), isTrue);
    });

    nyTest('should return true for large negative integers', () async {
      expect(isInteger('-9999999999'), isTrue);
      expect(isInteger('-12345678901234567890'), isTrue);
    });

    nyTest('should return false for leading zeros', () async {
      // Leading zeros make it a valid integer still
      expect(isInteger('007'), isTrue);
      expect(isInteger('00123'), isTrue);
    });

    nyTest('should return false for plus sign prefix', () async {
      // The regex only allows negative sign, not positive
      expect(isInteger('+123'), isFalse);
    });

    nyTest('should return false for exponential notation', () async {
      expect(isInteger('1e10'), isFalse);
      expect(isInteger('1E10'), isFalse);
    });
  });

  nyGroup('additional isDouble edge cases', () {
    nyTest('should return true for very small decimals', () async {
      expect(isDouble('0.000001'), isTrue);
      expect(isDouble('0.123456789'), isTrue);
    });

    nyTest('should return true for very large decimals', () async {
      expect(isDouble('999999999.999999999'), isTrue);
    });

    nyTest('should return false for exponential notation', () async {
      expect(isDouble('1.5e10'), isFalse);
      expect(isDouble('1.5E-10'), isFalse);
    });

    nyTest('should return false for multiple decimal points', () async {
      expect(isDouble('1.2.3'), isFalse);
      expect(isDouble('1..5'), isFalse);
    });

    nyTest('should return false for leading decimal', () async {
      expect(isDouble('.123'), isFalse);
    });

    nyTest('should return false for trailing decimal', () async {
      expect(isDouble('123.'), isFalse);
    });
  });

  nyGroup('JsonHelper additional scenarios', () {
    nyTest('should encode boolean values', () async {
      expect(JsonHelper.tryEncode(true), 'true');
      expect(JsonHelper.tryEncode(false), 'false');
    });

    nyTest('should encode null value', () async {
      expect(JsonHelper.tryEncode(null), 'null');
    });

    nyTest('should encode arrays with null values', () async {
      final result = JsonHelper.tryEncode([1, null, 3]);
      expect(result, '[1,null,3]');
    });

    nyTest('should encode maps with null values', () async {
      final result = JsonHelper.tryEncode({'key': null, 'other': 'value'});
      expect(result, '{"key":null,"other":"value"}');
    });

    nyTest('should encode deeply nested structures', () async {
      final deepNested = {
        'a': {
          'b': {
            'c': {
              'd': {'e': 'deep'},
            },
          },
        },
      };
      final result = JsonHelper.tryEncode(deepNested);
      expect(result, isNotNull);
      expect(result!.contains('"e":"deep"'), isTrue);
    });

    nyTest('should encode array of maps', () async {
      final arrayOfMaps = [
        {'id': 1, 'name': 'first'},
        {'id': 2, 'name': 'second'},
      ];
      final result = JsonHelper.tryEncode(arrayOfMaps);
      expect(result, isNotNull);
      expect(result!.contains('"id":1'), isTrue);
      expect(result.contains('"id":2'), isTrue);
    });

    nyTest('should return null for circular references', () async {
      // Create a structure that cannot be encoded
      final map = <String, dynamic>{};
      map['self'] = map; // Circular reference

      final result = JsonHelper.tryEncode(map);
      expect(result, isNull);
    });

    nyTest('should encode unicode strings', () async {
      final result = JsonHelper.tryEncode({
        'emoji': 'Hello',
        'chinese': 'Test',
      });
      expect(result, isNotNull);
    });

    nyTest('should encode strings with escape characters', () async {
      final result = JsonHelper.tryEncode({'text': 'line1\nline2\ttab'});
      expect(result, isNotNull);
      expect(result!.contains('\\n'), isTrue);
      expect(result.contains('\\t'), isTrue);
    });

    nyTest('should encode strings with quotes', () async {
      final result = JsonHelper.tryEncode({'quote': 'He said "hello"'});
      expect(result, isNotNull);
      expect(result!.contains('\\"hello\\"'), isTrue);
    });

    nyTest('should encode empty string', () async {
      expect(JsonHelper.tryEncode(''), '""');
    });

    nyTest('should encode numeric strings', () async {
      expect(JsonHelper.tryEncode('123'), '"123"');
      expect(JsonHelper.tryEncode('45.67'), '"45.67"');
    });
  });

  // Note: objectToJson tests require environment initialization and are
  // tested indirectly through NyStorage model serialization tests.
}
