import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/local_notifications/ny_local_notifications.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NotificationException', () {
    nyGroup('constructor', () {
      nyTest('creates with message', () async {
        const exception = NotificationException('Test error message');

        expect(exception.message, 'Test error message');
      });

      nyTest('accepts empty message', () async {
        const exception = NotificationException('');

        expect(exception.message, '');
      });
    });

    nyGroup('toString', () {
      nyTest('formats message correctly', () async {
        const exception = NotificationException('Something went wrong');

        expect(
          exception.toString(),
          'NotificationException: Something went wrong',
        );
      });

      nyTest('handles empty message', () async {
        const exception = NotificationException('');

        expect(exception.toString(), 'NotificationException: ');
      });

      nyTest('handles special characters', () async {
        const exception = NotificationException('Error: "test" & <value>');

        expect(
          exception.toString(),
          'NotificationException: Error: "test" & <value>',
        );
      });
    });

    nyGroup('implements Exception', () {
      nyTest('is an Exception', () async {
        const exception = NotificationException('Test');

        expect(exception, isA<Exception>());
      });

      nyTest('can be caught as Exception', () async {
        try {
          throw const NotificationException('Test error');
        } on Exception catch (e) {
          expect(e, isA<NotificationException>());
          expect((e as NotificationException).message, 'Test error');
        }
      });
    });

    nyGroup('const constructor', () {
      nyTest('allows const instantiation', () async {
        const exception1 = NotificationException('Same message');
        const exception2 = NotificationException('Same message');

        // Both are const instances with same message
        expect(exception1.message, exception2.message);
      });
    });
  });
}
