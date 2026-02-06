import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/testing/src/ny_time.dart';

void main() {
  setUp(() {
    NyTime.reset();
  });

  tearDown(() {
    NyTime.reset();
  });

  group('NyTime', () {
    group('now()', () {
      test('returns current time when not frozen', () {
        final before = DateTime.now();
        final result = NyTime.now();
        final after = DateTime.now();

        expect(
          result.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue,
        );
        expect(result.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });

      test('returns frozen time when set', () {
        final frozenTime = DateTime(2025, 6, 15, 10, 30, 0);
        NyTime.setTestNow(frozenTime);

        expect(NyTime.now(), equals(frozenTime));
      });
    });

    group('setTestNow()', () {
      test('sets a specific test time', () {
        final testTime = DateTime(2020, 1, 1, 12, 0, 0);
        NyTime.setTestNow(testTime);

        expect(NyTime.now(), equals(testTime));
      });

      test('overrides previous frozen time', () {
        NyTime.setTestNow(DateTime(2020, 1, 1));
        NyTime.setTestNow(DateTime(2025, 12, 25));

        expect(NyTime.now().year, equals(2025));
        expect(NyTime.now().month, equals(12));
        expect(NyTime.now().day, equals(25));
      });
    });

    group('reset()', () {
      test('clears frozen time', () {
        NyTime.setTestNow(DateTime(2020, 1, 1));
        expect(NyTime.isFrozen, isTrue);

        NyTime.reset();

        expect(NyTime.isFrozen, isFalse);
      });

      test('returns to system time after reset', () {
        NyTime.setTestNow(DateTime(2020, 1, 1));
        NyTime.reset();

        final now = NyTime.now();
        final systemNow = DateTime.now();

        expect(now.difference(systemNow).abs().inSeconds, lessThan(2));
      });
    });

    group('isFrozen', () {
      test('returns false when not frozen', () {
        expect(NyTime.isFrozen, isFalse);
      });

      test('returns true when frozen', () {
        NyTime.setTestNow(DateTime(2025, 1, 1));
        expect(NyTime.isFrozen, isTrue);
      });
    });

    group('advanceBy()', () {
      test('advances frozen time by duration', () {
        NyTime.setTestNow(DateTime(2025, 1, 1, 10, 0, 0));
        NyTime.advanceBy(const Duration(hours: 5));

        expect(NyTime.now().hour, equals(15));
      });

      test('advances by days', () {
        NyTime.setTestNow(DateTime(2025, 1, 1));
        NyTime.advanceBy(const Duration(days: 30));

        expect(NyTime.now().day, equals(31));
      });

      test('creates frozen time from system time when not already frozen', () {
        NyTime.advanceBy(const Duration(days: 1));

        expect(NyTime.isFrozen, isTrue);
        final frozenNow = NyTime.now();
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(frozenNow.difference(tomorrow).abs().inSeconds, lessThan(2));
      });
    });

    group('rewindBy()', () {
      test('rewinds frozen time by duration', () {
        NyTime.setTestNow(DateTime(2025, 1, 15, 10, 0, 0));
        NyTime.rewindBy(const Duration(days: 5));

        expect(NyTime.now().day, equals(10));
      });

      test('creates frozen time from system time when not already frozen', () {
        NyTime.rewindBy(const Duration(days: 1));

        expect(NyTime.isFrozen, isTrue);
      });
    });

    group('freeze()', () {
      test('freezes time at current moment', () {
        final before = DateTime.now();
        NyTime.freeze();
        final frozen = NyTime.now();

        expect(NyTime.isFrozen, isTrue);
        expect(frozen.difference(before).abs().inSeconds, lessThan(2));
      });
    });

    group('withFrozenTime()', () {
      test('executes callback with frozen time', () async {
        final testTime = DateTime(2025, 7, 4, 12, 0, 0);
        DateTime? capturedTime;

        await NyTime.withFrozenTime(testTime, () async {
          capturedTime = NyTime.now();
        });

        expect(capturedTime, equals(testTime));
      });

      test('restores previous time state after callback', () async {
        NyTime.setTestNow(DateTime(2020, 1, 1));

        await NyTime.withFrozenTime(DateTime(2025, 6, 15), () async {
          expect(NyTime.now().year, equals(2025));
        });

        expect(NyTime.now().year, equals(2020));
      });

      test('restores null state when not previously frozen', () async {
        expect(NyTime.isFrozen, isFalse);

        await NyTime.withFrozenTime(DateTime(2025, 1, 1), () async {
          expect(NyTime.isFrozen, isTrue);
        });

        expect(NyTime.isFrozen, isFalse);
      });

      test('returns callback result', () async {
        final result = await NyTime.withFrozenTime(
          DateTime(2025, 1, 1),
          () async {
            return 42;
          },
        );

        expect(result, equals(42));
      });
    });

    group('withFrozenTimeSync()', () {
      test('executes callback with frozen time synchronously', () {
        final testTime = DateTime(2025, 7, 4, 12, 0, 0);
        DateTime? capturedTime;

        NyTime.withFrozenTimeSync(testTime, () {
          capturedTime = NyTime.now();
        });

        expect(capturedTime, equals(testTime));
      });

      test('restores previous time state after callback', () {
        NyTime.setTestNow(DateTime(2020, 1, 1));

        NyTime.withFrozenTimeSync(DateTime(2025, 6, 15), () {
          expect(NyTime.now().year, equals(2025));
        });

        expect(NyTime.now().year, equals(2020));
      });

      test('returns callback result', () {
        final result = NyTime.withFrozenTimeSync(DateTime(2025, 1, 1), () {
          return 'test result';
        });

        expect(result, equals('test result'));
      });
    });

    group('testNow', () {
      test('returns null when not frozen', () {
        expect(NyTime.testNow, isNull);
      });

      test('returns frozen time when set', () {
        final testTime = DateTime(2025, 1, 1);
        NyTime.setTestNow(testTime);

        expect(NyTime.testNow, equals(testTime));
      });
    });

    group('travelToStartOfDay()', () {
      test('travels to start of current day', () {
        NyTime.setTestNow(DateTime(2025, 6, 15, 14, 30, 45));
        NyTime.travelToStartOfDay();

        expect(NyTime.now(), equals(DateTime(2025, 6, 15, 0, 0, 0)));
      });

      test('uses system time when not frozen', () {
        NyTime.travelToStartOfDay();
        final now = DateTime.now();

        expect(NyTime.now().year, equals(now.year));
        expect(NyTime.now().month, equals(now.month));
        expect(NyTime.now().day, equals(now.day));
        expect(NyTime.now().hour, equals(0));
        expect(NyTime.now().minute, equals(0));
        expect(NyTime.now().second, equals(0));
      });
    });

    group('travelToEndOfDay()', () {
      test('travels to end of current day', () {
        NyTime.setTestNow(DateTime(2025, 6, 15, 14, 30, 45));
        NyTime.travelToEndOfDay();

        expect(NyTime.now(), equals(DateTime(2025, 6, 15, 23, 59, 59, 999)));
      });
    });

    group('travelToStartOfMonth()', () {
      test('travels to start of current month', () {
        NyTime.setTestNow(DateTime(2025, 6, 15, 14, 30, 45));
        NyTime.travelToStartOfMonth();

        expect(NyTime.now(), equals(DateTime(2025, 6, 1)));
      });
    });

    group('travelToEndOfMonth()', () {
      test('travels to end of current month', () {
        NyTime.setTestNow(DateTime(2025, 6, 15, 14, 30, 45));
        NyTime.travelToEndOfMonth();

        // June has 30 days
        expect(NyTime.now().day, equals(30));
        expect(NyTime.now().hour, equals(23));
        expect(NyTime.now().minute, equals(59));
        expect(NyTime.now().second, equals(59));
      });

      test('handles months with 31 days', () {
        NyTime.setTestNow(DateTime(2025, 7, 15)); // July
        NyTime.travelToEndOfMonth();

        expect(NyTime.now().day, equals(31));
      });

      test('handles February', () {
        NyTime.setTestNow(DateTime(2025, 2, 15));
        NyTime.travelToEndOfMonth();

        expect(NyTime.now().day, equals(28));
      });

      test('handles leap year February', () {
        NyTime.setTestNow(DateTime(2024, 2, 15)); // 2024 is a leap year
        NyTime.travelToEndOfMonth();

        expect(NyTime.now().day, equals(29));
      });
    });

    group('travelToStartOfYear()', () {
      test('travels to start of current year', () {
        NyTime.setTestNow(DateTime(2025, 6, 15, 14, 30, 45));
        NyTime.travelToStartOfYear();

        expect(NyTime.now(), equals(DateTime(2025, 1, 1)));
      });
    });

    group('travelToEndOfYear()', () {
      test('travels to end of current year', () {
        NyTime.setTestNow(DateTime(2025, 6, 15, 14, 30, 45));
        NyTime.travelToEndOfYear();

        expect(NyTime.now(), equals(DateTime(2025, 12, 31, 23, 59, 59, 999)));
      });
    });
  });
}
