import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/local_notifications/src/local_notification.dart';
import 'package:nylo_support/local_notifications/src/notification_attachment.dart';
import 'package:nylo_support/local_notifications/src/notification_exception.dart';
import 'package:nylo_support/local_notifications/src/helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  // ===========================================================================
  // NotificationException tests
  // ===========================================================================

  nyGroup('NotificationException', () {
    nyTest('should store message', () async {
      const exception = NotificationException('test error');
      expect(exception.message, 'test error');
    });

    nyTest('should implement Exception', () async {
      const exception = NotificationException('msg');
      expect(exception, isA<Exception>());
    });

    nyTest('toString should include message', () async {
      const exception = NotificationException('something went wrong');
      expect(exception.toString(), contains('something went wrong'));
      expect(exception.toString(), contains('NotificationException'));
    });

    nyTest('should support const constructor', () async {
      const a = NotificationException('a');
      const b = NotificationException('a');
      expect(identical(a, b), isTrue);
    });
  });

  // ===========================================================================
  // NotificationAttachment tests
  // ===========================================================================

  nyGroup('NotificationAttachment', () {
    nyTest('should store url and fileName', () async {
      const attachment = NotificationAttachment(
        'https://example.com/image.png',
        'image.png',
      );
      expect(attachment.url, 'https://example.com/image.png');
      expect(attachment.fileName, 'image.png');
    });

    nyTest('should default showThumbnail to true', () async {
      const attachment = NotificationAttachment('url', 'file');
      expect(attachment.showThumbnail, isTrue);
    });

    nyTest('should accept showThumbnail parameter', () async {
      const attachment = NotificationAttachment(
        'url',
        'file',
        showThumbnail: false,
      );
      expect(attachment.showThumbnail, isFalse);
    });

    nyTest('should support const constructor', () async {
      const attachment = NotificationAttachment('url', 'file');
      expect(attachment, isA<NotificationAttachment>());
    });
  });

  // ===========================================================================
  // LocalNotification builder tests
  // ===========================================================================

  nyGroup('LocalNotification builder', () {
    nyTest('should create with title and body', () async {
      final notification = LocalNotification(title: 'Hello', body: 'World');
      expect(notification, isA<LocalNotification>());
    });

    nyTest('should create with default empty values', () async {
      final notification = LocalNotification();
      expect(notification, isA<LocalNotification>());
    });

    nyTest('addPayload should return self for chaining', () async {
      final notification = LocalNotification(title: 'Test', body: 'Test');
      final result = notification.addPayload('data');
      expect(result, same(notification));
    });

    nyTest('addId should return self for chaining', () async {
      final notification = LocalNotification(title: 'Test', body: 'Test');
      final result = notification.addId(42);
      expect(result, same(notification));
    });

    nyTest('addSubtitle should return self for chaining', () async {
      final notification = LocalNotification(title: 'Test', body: 'Test');
      final result = notification.addSubtitle('subtitle');
      expect(result, same(notification));
    });

    nyTest('addBadgeNumber should return self for chaining', () async {
      final notification = LocalNotification(title: 'Test', body: 'Test');
      final result = notification.addBadgeNumber(5);
      expect(result, same(notification));
    });

    nyTest('addSound should return self for chaining', () async {
      final notification = LocalNotification(title: 'Test', body: 'Test');
      final result = notification.addSound('alert.wav');
      expect(result, same(notification));
    });

    nyTest('addAttachment should return self for chaining', () async {
      final notification = LocalNotification(title: 'Test', body: 'Test');
      final result = notification.addAttachment('url', 'file.png');
      expect(result, same(notification));
    });

    nyTest('fluent API should support chaining', () async {
      final notification = LocalNotification(title: 'Hello', body: 'World')
          .addPayload('custom-data')
          .addId(123)
          .addSubtitle('sub')
          .addBadgeNumber(3)
          .addSound('ding.wav')
          .addAttachment('https://example.com/img.png', 'img.png');
      expect(notification, isA<LocalNotification>());
    });
  });

  // ===========================================================================
  // localNotification helper tests
  // ===========================================================================

  nyGroup('localNotification helper', () {
    nyTest('should create LocalNotification', () async {
      final notification = localNotification('Hello', 'World');
      expect(notification, isA<LocalNotification>());
    });

    nyTest('should support chaining after creation', () async {
      final notification = localNotification(
        'Title',
        'Body',
      ).addPayload('data').addId(1);
      expect(notification, isA<LocalNotification>());
    });
  });
}
