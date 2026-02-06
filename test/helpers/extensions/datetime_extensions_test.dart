import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Helper function to create an EnvGetter from a Map for testing
EnvGetter mockEnv(Map<String, dynamic> values) =>
    (String key, {dynamic defaultValue}) => values[key] ?? defaultValue;

void main() {
  NyTest.init();

  setUpAll(() async {
    // Initialize date formatting locale
    await initializeDateFormatting('en', null);
  });

  nySetUp(() {
    NyEnvRegistry.register(getter: mockEnv({'APP_DEBUG': true}));
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Time Period Checks
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('NyDateTimeExt Time Period Checks', () {
    nyGroup('isMorning', () {
      nyTest('should return true for morning hours (0-11)', () async {
        expect(DateTime(2024, 1, 1, 0, 0).isMorning(), isTrue);
        expect(DateTime(2024, 1, 1, 6, 0).isMorning(), isTrue);
        expect(DateTime(2024, 1, 1, 11, 59).isMorning(), isTrue);
      });

      nyTest('should return false for afternoon/evening hours', () async {
        expect(DateTime(2024, 1, 1, 12, 0).isMorning(), isFalse);
        expect(DateTime(2024, 1, 1, 18, 0).isMorning(), isFalse);
        expect(DateTime(2024, 1, 1, 23, 59).isMorning(), isFalse);
      });

      nyTest('should return false for null DateTime', () async {
        DateTime? nullDate;
        expect(nullDate.isMorning(), isFalse);
      });
    });

    nyGroup('isAfternoon', () {
      nyTest('should return true for afternoon hours (12-17)', () async {
        expect(DateTime(2024, 1, 1, 12, 0).isAfternoon(), isTrue);
        expect(DateTime(2024, 1, 1, 15, 0).isAfternoon(), isTrue);
        expect(DateTime(2024, 1, 1, 17, 59).isAfternoon(), isTrue);
      });

      nyTest('should return false for morning/evening hours', () async {
        expect(DateTime(2024, 1, 1, 11, 59).isAfternoon(), isFalse);
        expect(DateTime(2024, 1, 1, 18, 0).isAfternoon(), isFalse);
      });

      nyTest('should return false for null DateTime', () async {
        DateTime? nullDate;
        expect(nullDate.isAfternoon(), isFalse);
      });
    });

    nyGroup('isEvening', () {
      nyTest('should return true for evening hours (18-23)', () async {
        expect(DateTime(2024, 1, 1, 18, 0).isEvening(), isTrue);
        expect(DateTime(2024, 1, 1, 21, 0).isEvening(), isTrue);
        expect(DateTime(2024, 1, 1, 23, 59).isEvening(), isTrue);
      });

      nyTest('should return false for morning/afternoon hours', () async {
        expect(DateTime(2024, 1, 1, 6, 0).isEvening(), isFalse);
        expect(DateTime(2024, 1, 1, 17, 59).isEvening(), isFalse);
      });

      nyTest('should return false for null DateTime', () async {
        DateTime? nullDate;
        expect(nullDate.isEvening(), isFalse);
      });
    });

    nyGroup('isNight', () {
      nyTest('should return true for night hours (0-5)', () async {
        expect(DateTime(2024, 1, 1, 0, 0).isNight(), isTrue);
        expect(DateTime(2024, 1, 1, 3, 0).isNight(), isTrue);
        expect(DateTime(2024, 1, 1, 5, 59).isNight(), isTrue);
      });

      nyTest('should return false for day hours', () async {
        expect(DateTime(2024, 1, 1, 6, 0).isNight(), isFalse);
        expect(DateTime(2024, 1, 1, 12, 0).isNight(), isFalse);
        expect(DateTime(2024, 1, 1, 18, 0).isNight(), isFalse);
      });

      nyTest('should return false for null DateTime', () async {
        DateTime? nullDate;
        expect(nullDate.isNight(), isFalse);
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Date Arithmetic
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('NyDateTimeExt Date Arithmetic', () {
    nyGroup('addYears', () {
      nyTest('should add years to date', () async {
        final date = DateTime(2024, 3, 15);

        final result = date.addYears(2);

        expect(result.year, 2026);
        expect(result.month, 3);
        expect(result.day, 15);
      });

      nyTest('should handle leap year', () async {
        final date = DateTime(2024, 2, 29);

        final result = date.addYears(1);

        // Feb 29 2024 + 1 year = Feb 29 2025, but 2025 has no Feb 29
        // DateTime normalizes to Mar 1 2025
        expect(result.year, 2025);
        expect(result.month, 3);
        expect(result.day, 1);
      });

      nyTest('should throw for null DateTime', () async {
        DateTime? nullDate;
        expect(() => nullDate.addYears(1), throwsA(isA<Exception>()));
      });
    });

    nyGroup('subtractYears', () {
      nyTest('should subtract years from date', () async {
        final date = DateTime(2024, 3, 15);

        final result = date.subtractYears(2);

        expect(result.year, 2022);
        expect(result.month, 3);
        expect(result.day, 15);
      });
    });

    nyGroup('addMonths', () {
      nyTest('should add months to date', () async {
        final date = DateTime(2024, 3, 15);

        final result = date.addMonths(4);

        expect(result.year, 2024);
        expect(result.month, 7);
        expect(result.day, 15);
      });

      nyTest('should wrap to next year', () async {
        final date = DateTime(2024, 10, 15);

        final result = date.addMonths(4);

        expect(result.year, 2025);
        expect(result.month, 2);
      });
    });

    nyGroup('subtractMonths', () {
      nyTest('should subtract months from date', () async {
        final date = DateTime(2024, 6, 15);

        final result = date.subtractMonths(3);

        expect(result.year, 2024);
        expect(result.month, 3);
        expect(result.day, 15);
      });

      nyTest('should wrap to previous year', () async {
        final date = DateTime(2024, 3, 15);

        final result = date.subtractMonths(5);

        expect(result.year, 2023);
        expect(result.month, 10);
      });
    });

    nyGroup('addDays', () {
      nyTest('should add days to date', () async {
        final date = DateTime(2024, 3, 15);

        final result = date.addDays(10);

        expect(result.day, 25);
        expect(result.month, 3);
      });

      nyTest('should wrap to next month', () async {
        final date = DateTime(2024, 3, 28);

        final result = date.addDays(5);

        expect(result.month, 4);
        expect(result.day, 2);
      });
    });

    nyGroup('subtractDays', () {
      nyTest('should subtract days from date', () async {
        final date = DateTime(2024, 3, 15);

        final result = date.subtractDays(5);

        expect(result.day, 10);
        expect(result.month, 3);
      });
    });

    nyGroup('addHours', () {
      nyTest('should add hours to datetime', () async {
        final date = DateTime(2024, 3, 15, 10, 30);

        final result = date.addHours(5);

        expect(result.hour, 15);
        expect(result.minute, 30);
      });

      nyTest('should wrap to next day', () async {
        final date = DateTime(2024, 3, 15, 22, 0);

        final result = date.addHours(5);

        expect(result.day, 16);
        expect(result.hour, 3);
      });
    });

    nyGroup('subtractHours', () {
      nyTest('should subtract hours from datetime', () async {
        final date = DateTime(2024, 3, 15, 10, 30);

        final result = date.subtractHours(5);

        expect(result.hour, 5);
      });
    });

    nyGroup('addMinutes', () {
      nyTest('should add minutes to datetime', () async {
        final date = DateTime(2024, 3, 15, 10, 30);

        final result = date.addMinutes(45);

        expect(result.hour, 11);
        expect(result.minute, 15);
      });
    });

    nyGroup('subtractMinutes', () {
      nyTest('should subtract minutes from datetime', () async {
        final date = DateTime(2024, 3, 15, 10, 30);

        final result = date.subtractMinutes(15);

        expect(result.hour, 10);
        expect(result.minute, 15);
      });
    });

    nyGroup('addSeconds', () {
      nyTest('should add seconds to datetime', () async {
        final date = DateTime(2024, 3, 15, 10, 30, 30);

        final result = date.addSeconds(45);

        expect(result.minute, 31);
        expect(result.second, 15);
      });
    });

    nyGroup('subtractSeconds', () {
      nyTest('should subtract seconds from datetime', () async {
        final date = DateTime(2024, 3, 15, 10, 30, 30);

        final result = date.subtractSeconds(15);

        expect(result.second, 15);
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Date Formatting
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('NyDateTimeExt Date Formatting', () {
    nyGroup('toDateTimeString', () {
      nyTest('should format datetime to standard string', () async {
        final date = DateTime(2024, 3, 15, 10, 30, 45);

        final result = date.toDateTimeString();

        expect(result, '2024-03-15 10:30:45');
      });

      nyTest('should return null for null DateTime', () async {
        DateTime? nullDate;
        expect(nullDate.toDateTimeString(), isNull);
      });
    });

    nyGroup('toDateString', () {
      nyTest('should format date to standard string', () async {
        final date = DateTime(2024, 3, 15);

        final result = date.toDateString();

        expect(result, '2024-03-15');
      });

      nyTest('should support custom format', () async {
        final date = DateTime(2024, 3, 15);

        final result = date.toDateString(format: 'dd-MM-yyyy');

        expect(result, '15-03-2024');
      });

      nyTest('should return null for null DateTime', () async {
        DateTime? nullDate;
        expect(nullDate.toDateString(), isNull);
      });
    });

    nyGroup('toDateStringUK', () {
      nyTest('should format date in UK format', () async {
        final date = DateTime(2024, 3, 15);

        final result = date.toDateStringUK();

        expect(result, '15/03/2024');
      });
    });

    nyGroup('toDateStringUS', () {
      nyTest('should format date in US format', () async {
        final date = DateTime(2024, 3, 15);

        final result = date.toDateStringUS();

        expect(result, '03/15/2024');
      });
    });

    nyGroup('toTimestamp', () {
      nyTest('should convert to Unix timestamp string', () async {
        final date = DateTime(2024, 3, 15, 12, 0, 0);

        final result = date.toTimestamp();

        expect(result, isA<String>());
        expect(int.tryParse(result!), isNotNull);
      });

      nyTest('should return null for null DateTime', () async {
        DateTime? nullDate;
        expect(nullDate.toTimestamp(), isNull);
      });
    });

    nyGroup('toTimeString', () {
      nyTest('should format time without seconds', () async {
        final date = DateTime(2024, 3, 15, 14, 30, 45);

        final result = date.toTimeString();

        expect(result, '14:30');
      });

      nyTest('should format time with seconds', () async {
        final date = DateTime(2024, 3, 15, 14, 30, 45);

        final result = date.toTimeString(withSeconds: true);

        expect(result, '14:30:45');
      });

      nyTest('should return null for null DateTime', () async {
        DateTime? nullDate;
        expect(nullDate.toTimeString(), isNull);
      });
    });

    nyGroup('toFormat', () {
      nyTest('should format with custom pattern', () async {
        final date = DateTime(2024, 3, 15, 14, 30);

        final result = date.toFormat('EEEE, MMMM d, yyyy');

        expect(result, contains('March'));
        expect(result, contains('2024'));
      });

      nyTest('should return null for null DateTime', () async {
        DateTime? nullDate;
        expect(nullDate.toFormat('yyyy-MM-dd'), isNull);
      });
    });

    nyGroup('toShortDate', () {
      nyTest('should format to short date with ordinal', () async {
        final date = DateTime(2024, 3, 1);

        final result = date.toShortDate();

        expect(result, contains('1st'));
        expect(result, contains('Mar'));
      });

      nyTest('should handle different ordinals', () async {
        expect(DateTime(2024, 3, 1).toShortDate(), contains('1st'));
        expect(DateTime(2024, 3, 2).toShortDate(), contains('2nd'));
        expect(DateTime(2024, 3, 3).toShortDate(), contains('3rd'));
        expect(DateTime(2024, 3, 4).toShortDate(), contains('4th'));
        expect(DateTime(2024, 3, 11).toShortDate(), contains('11th'));
        expect(DateTime(2024, 3, 12).toShortDate(), contains('12th'));
        expect(DateTime(2024, 3, 13).toShortDate(), contains('13th'));
        expect(DateTime(2024, 3, 21).toShortDate(), contains('21st'));
        expect(DateTime(2024, 3, 22).toShortDate(), contains('22nd'));
        expect(DateTime(2024, 3, 23).toShortDate(), contains('23rd'));
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Age Calculations
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('NyDateTimeExt Age Calculations', () {
    nyGroup('toAge', () {
      nyTest('should calculate age from birthdate', () async {
        final birthDate = DateTime.now().subtract(Duration(days: 365 * 25 + 6));

        final result = birthDate.toAge();

        expect(result, 25);
      });

      nyTest('should return null for null DateTime', () async {
        DateTime? nullDate;
        expect(nullDate.toAge(), isNull);
      });
    });

    nyGroup('isAgeYounger', () {
      nyTest('should return true when age is younger', () async {
        final birthDate = DateTime.now().subtract(Duration(days: 365 * 20));

        final result = birthDate.isAgeYounger(25);

        expect(result, isTrue);
      });

      nyTest('should return false when age is older', () async {
        final birthDate = DateTime.now().subtract(Duration(days: 365 * 30));

        final result = birthDate.isAgeYounger(25);

        expect(result, isFalse);
      });
    });

    nyGroup('isAgeOlder', () {
      nyTest('should return true when age is older', () async {
        final birthDate = DateTime.now().subtract(Duration(days: 365 * 30));

        final result = birthDate.isAgeOlder(25);

        expect(result, isTrue);
      });

      nyTest('should return false when age is younger', () async {
        final birthDate = DateTime.now().subtract(Duration(days: 365 * 20));

        final result = birthDate.isAgeOlder(25);

        expect(result, isFalse);
      });
    });

    nyGroup('isAgeBetween', () {
      nyTest('should return true when age is between min and max', () async {
        final birthDate = DateTime.now().subtract(Duration(days: 365 * 25));

        final result = birthDate.isAgeBetween(20, 30);

        expect(result, isTrue);
      });

      nyTest('should return false when age is outside range', () async {
        final birthDate = DateTime.now().subtract(Duration(days: 365 * 35));

        final result = birthDate.isAgeBetween(20, 30);

        expect(result, isFalse);
      });

      nyTest('should include boundary values', () async {
        final birthDate20 = DateTime.now().subtract(Duration(days: 365 * 20));
        final birthDate30 = DateTime.now().subtract(Duration(days: 365 * 30));

        expect(birthDate20.isAgeBetween(20, 30), isTrue);
        expect(birthDate30.isAgeBetween(20, 30), isTrue);
      });
    });

    nyGroup('isAgeEqualTo', () {
      nyTest('should return true when age equals specified value', () async {
        final birthDate = DateTime.now().subtract(Duration(days: 365 * 25 + 6));

        final result = birthDate.isAgeEqualTo(25);

        expect(result, isTrue);
      });

      nyTest(
        'should return false when age does not equal specified value',
        () async {
          final birthDate = DateTime.now().subtract(Duration(days: 365 * 25));

          final result = birthDate.isAgeEqualTo(30);

          expect(result, isFalse);
        },
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Date Comparisons
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('NyDateTimeExt Date Comparisons', () {
    nyGroup('isInPast', () {
      nyTest('should return true for past date', () async {
        final pastDate = DateTime.now().subtract(Duration(days: 1));

        expect(pastDate.isInPast(), isTrue);
      });

      nyTest('should return false for future date', () async {
        final futureDate = DateTime.now().add(Duration(days: 1));

        expect(futureDate.isInPast(), isFalse);
      });

      nyTest('should return false for null DateTime', () async {
        DateTime? nullDate;
        expect(nullDate.isInPast(), isFalse);
      });
    });

    nyGroup('isInFuture', () {
      nyTest('should return true for future date', () async {
        final futureDate = DateTime.now().add(Duration(days: 1));

        expect(futureDate.isInFuture(), isTrue);
      });

      nyTest('should return false for past date', () async {
        final pastDate = DateTime.now().subtract(Duration(days: 1));

        expect(pastDate.isInFuture(), isFalse);
      });

      nyTest('should return false for null DateTime', () async {
        DateTime? nullDate;
        expect(nullDate.isInFuture(), isFalse);
      });
    });

    nyGroup('hasExpired', () {
      nyTest('should return true for past date', () async {
        final pastDate = DateTime.now().subtract(Duration(days: 1));

        expect(pastDate.hasExpired(), isTrue);
      });

      nyTest('should return false for future date', () async {
        final futureDate = DateTime.now().add(Duration(days: 1));

        expect(futureDate.hasExpired(), isFalse);
      });

      nyTest('should return true for null DateTime', () async {
        DateTime? nullDate;
        expect(nullDate.hasExpired(), isTrue);
      });
    });

    nyGroup('isToday', () {
      nyTest('should return true for today', () async {
        final today = DateTime.now();

        expect(today.isToday(), isTrue);
      });

      nyTest('should return false for yesterday', () async {
        final yesterday = DateTime.now().subtract(Duration(days: 1));

        expect(yesterday.isToday(), isFalse);
      });

      nyTest('should return false for tomorrow', () async {
        final tomorrow = DateTime.now().add(Duration(days: 1));

        expect(tomorrow.isToday(), isFalse);
      });

      nyTest('should return false for null DateTime', () async {
        DateTime? nullDate;
        expect(nullDate.isToday(), isFalse);
      });
    });

    nyGroup('isTomorrow', () {
      nyTest('should return true for tomorrow', () async {
        final tomorrow = DateTime.now().add(Duration(days: 1));

        expect(tomorrow.isTomorrow(), isTrue);
      });

      nyTest('should return false for today', () async {
        final today = DateTime.now();

        expect(today.isTomorrow(), isFalse);
      });

      nyTest('should return false for null DateTime', () async {
        DateTime? nullDate;
        expect(nullDate.isTomorrow(), isFalse);
      });
    });

    nyGroup('isYesterday', () {
      nyTest('should return true for yesterday', () async {
        final yesterday = DateTime.now().subtract(Duration(days: 1));

        expect(yesterday.isYesterday(), isTrue);
      });

      nyTest('should return false for today', () async {
        final today = DateTime.now();

        expect(today.isYesterday(), isFalse);
      });

      nyTest('should return false for null DateTime', () async {
        DateTime? nullDate;
        expect(nullDate.isYesterday(), isFalse);
      });
    });

    nyGroup('isSameDay', () {
      nyTest('should return true for same day', () async {
        final date1 = DateTime(2024, 3, 15, 10, 0);
        final date2 = DateTime(2024, 3, 15, 20, 0);

        expect(date1.isSameDay(date2), isTrue);
      });

      nyTest('should return false for different days', () async {
        final date1 = DateTime(2024, 3, 15);
        final date2 = DateTime(2024, 3, 16);

        expect(date1.isSameDay(date2), isFalse);
      });

      nyTest('should return false for null DateTime', () async {
        DateTime? nullDate;
        expect(nullDate.isSameDay(DateTime.now()), isFalse);
      });
    });
  });
}
