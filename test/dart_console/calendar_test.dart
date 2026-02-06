import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/dart_console/ny_dart_console.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('Calendar', () {
    nyTest('should create for a specific date', () async {
      final calendar = Calendar(DateTime(2025, 6, 15));
      expect(calendar, isA<Table>());
    });

    nyTest('should have 7 columns for days of week', () async {
      final calendar = Calendar(DateTime(2025, 1, 1));
      expect(calendar.columns, 7);
    });

    nyTest('should set title to month and year', () async {
      final calendar = Calendar(DateTime(2025, 6, 15));
      expect(calendar.title, contains('June'));
      expect(calendar.title, contains('2025'));
    });

    nyTest('should set title for January', () async {
      final calendar = Calendar(DateTime(2025, 1, 1));
      expect(calendar.title, contains('January'));
      expect(calendar.title, contains('2025'));
    });

    nyTest('should set title for December', () async {
      final calendar = Calendar(DateTime(2025, 12, 25));
      expect(calendar.title, contains('December'));
    });

    nyTest('should have day labels', () async {
      final calendar = Calendar(DateTime(2025, 1, 1));
      expect(calendar.dayLabels, hasLength(7));
      expect(calendar.dayLabels[0], 'Sun');
      expect(calendar.dayLabels[6], 'Sat');
    });

    nyTest('should have rows for weeks', () async {
      final calendar = Calendar(DateTime(2025, 1, 1));
      // January 2025 starts on Wednesday, needs 5 rows
      expect(calendar.rows, greaterThanOrEqualTo(4));
      expect(calendar.rows, lessThanOrEqualTo(6));
    });

    nyTest('should highlight today by default', () async {
      final calendar = Calendar(DateTime.now());
      expect(calendar.highlightTodaysDate, isTrue);
    });

    nyTest('Calendar.now should create for current date', () async {
      final calendar = Calendar.now();
      expect(calendar, isA<Calendar>());
      expect(calendar, isA<Table>());
    });

    nyTest('should render without errors', () async {
      final calendar = Calendar(DateTime(2025, 3, 1));
      final output = calendar.render();
      expect(output, isNotEmpty);
    });

    nyTest('should render plain text without errors', () async {
      final calendar = Calendar(DateTime(2025, 3, 1));
      final output = calendar.render(plainText: true);
      expect(output, isNotEmpty);
      expect(output, contains('March'));
    });
  });
}
