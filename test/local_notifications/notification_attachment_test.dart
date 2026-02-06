import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/local_notifications/ny_local_notifications.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NotificationAttachment', () {
    nyGroup('constructor', () {
      nyTest('creates with url and fileName', () async {
        const attachment = NotificationAttachment(
          'https://example.com/image.png',
          'image.png',
        );

        expect(attachment.url, 'https://example.com/image.png');
        expect(attachment.fileName, 'image.png');
      });

      nyTest('has default showThumbnail as true', () async {
        const attachment = NotificationAttachment(
          'https://example.com/image.png',
          'image.png',
        );

        expect(attachment.showThumbnail, true);
      });

      nyTest('accepts custom showThumbnail value', () async {
        const attachment = NotificationAttachment(
          'https://example.com/image.png',
          'image.png',
          showThumbnail: false,
        );

        expect(attachment.showThumbnail, false);
      });

      nyTest('handles various URL formats', () async {
        const httpAttachment = NotificationAttachment(
          'http://example.com/image.jpg',
          'image.jpg',
        );
        const httpsAttachment = NotificationAttachment(
          'https://example.com/image.png',
          'image.png',
        );
        const pathAttachment = NotificationAttachment(
          '/local/path/image.gif',
          'image.gif',
        );

        expect(httpAttachment.url, 'http://example.com/image.jpg');
        expect(httpsAttachment.url, 'https://example.com/image.png');
        expect(pathAttachment.url, '/local/path/image.gif');
      });

      nyTest('handles various fileName formats', () async {
        const simpleAttachment = NotificationAttachment(
          'https://example.com/image.png',
          'image.png',
        );
        const pathAttachment = NotificationAttachment(
          'https://example.com/files/image.png',
          'folder/image.png',
        );
        const specialAttachment = NotificationAttachment(
          'https://example.com/image.png',
          'my-file_v2.0.png',
        );

        expect(simpleAttachment.fileName, 'image.png');
        expect(pathAttachment.fileName, 'folder/image.png');
        expect(specialAttachment.fileName, 'my-file_v2.0.png');
      });
    });

    nyGroup('const constructor', () {
      nyTest('allows const instantiation', () async {
        const attachment1 = NotificationAttachment(
          'https://example.com/image.png',
          'image.png',
        );
        const attachment2 = NotificationAttachment(
          'https://example.com/image.png',
          'image.png',
        );

        expect(attachment1.url, attachment2.url);
        expect(attachment1.fileName, attachment2.fileName);
      });
    });

    nyGroup('showThumbnail nullable', () {
      nyTest('can be explicitly set to null', () async {
        const attachment = NotificationAttachment(
          'https://example.com/image.png',
          'image.png',
          showThumbnail: null,
        );

        expect(attachment.showThumbnail, isNull);
      });
    });

    nyGroup('deprecated alias', () {
      nyTest(
        'PushNotificationAttachments is alias for NotificationAttachment',
        () async {
          // ignore: deprecated_member_use_from_same_package
          const attachment = PushNotificationAttachments(
            'https://example.com/image.png',
            'image.png',
          );

          expect(attachment, isA<NotificationAttachment>());
          expect(attachment.url, 'https://example.com/image.png');
          expect(attachment.fileName, 'image.png');
        },
      );
    });
  });
}
