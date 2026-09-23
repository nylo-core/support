import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/local_notifications/ny_local_notifications.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Helper function to create an EnvGetter from a Map for testing
EnvGetter mockEnv(Map<String, dynamic> values) =>
    (String key, {dynamic defaultValue}) => values[key] ?? defaultValue;

void main() {
  NyTest.init();

  nyGroup('LocalNotification', () {
    nyGroup('constructor', () {
      nyTest('creates with default empty values', () async {
        final notification = LocalNotification();

        // The constructor accepts empty strings as defaults
        expect(notification, isA<LocalNotification>());
      });

      nyTest('creates with title and body', () async {
        final notification = LocalNotification(
          title: 'Test Title',
          body: 'Test Body',
        );

        expect(notification, isA<LocalNotification>());
      });

      nyTest('creates with only title', () async {
        final notification = LocalNotification(title: 'Only Title');

        expect(notification, isA<LocalNotification>());
      });

      nyTest('creates with only body', () async {
        final notification = LocalNotification(body: 'Only Body');

        expect(notification, isA<LocalNotification>());
      });
    });

    nyGroup('builder pattern', () {
      nyTest('addPayload returns LocalNotification for chaining', () async {
        final notification = LocalNotification(title: 'Test', body: 'Body');

        final result = notification.addPayload('test-payload');

        expect(result, isA<LocalNotification>());
        expect(result, same(notification));
      });

      nyTest('addId returns LocalNotification for chaining', () async {
        final notification = LocalNotification(title: 'Test', body: 'Body');

        final result = notification.addId(123);

        expect(result, isA<LocalNotification>());
        expect(result, same(notification));
      });

      nyTest('addSubtitle returns LocalNotification for chaining', () async {
        final notification = LocalNotification(title: 'Test', body: 'Body');

        final result = notification.addSubtitle('Subtitle');

        expect(result, isA<LocalNotification>());
        expect(result, same(notification));
      });

      nyTest('addBadgeNumber returns LocalNotification for chaining', () async {
        final notification = LocalNotification(title: 'Test', body: 'Body');

        final result = notification.addBadgeNumber(5);

        expect(result, isA<LocalNotification>());
        expect(result, same(notification));
      });

      nyTest('addSound returns LocalNotification for chaining', () async {
        final notification = LocalNotification(title: 'Test', body: 'Body');

        final result = notification.addSound('custom_sound');

        expect(result, isA<LocalNotification>());
        expect(result, same(notification));
      });

      nyTest('addAttachment returns LocalNotification for chaining', () async {
        final notification = LocalNotification(title: 'Test', body: 'Body');

        final result = notification.addAttachment(
          'https://example.com/image.png',
          'image.png',
        );

        expect(result, isA<LocalNotification>());
        expect(result, same(notification));
      });

      nyTest(
        'setAndroidConfig returns LocalNotification for chaining',
        () async {
          final notification = LocalNotification(title: 'Test', body: 'Body');

          final result = notification.setAndroidConfig(
            const AndroidNotificationConfig(channelId: 'test'),
          );

          expect(result, isA<LocalNotification>());
          expect(result, same(notification));
        },
      );

      nyTest('setIOSConfig returns LocalNotification for chaining', () async {
        final notification = LocalNotification(title: 'Test', body: 'Body');

        final result = notification.setIOSConfig(
          const IOSNotificationConfig(presentAlert: true),
        );

        expect(result, isA<LocalNotification>());
        expect(result, same(notification));
      });

      nyTest('supports method chaining', () async {
        final notification = LocalNotification(title: 'Chained', body: 'Body')
            .addPayload('payload')
            .addId(456)
            .addSubtitle('Subtitle')
            .addBadgeNumber(10)
            .addSound('sound')
            .addAttachment('https://example.com/img.png', 'img.png')
            .setAndroidConfig(const AndroidNotificationConfig())
            .setIOSConfig(const IOSNotificationConfig());

        expect(notification, isA<LocalNotification>());
      });
    });

    nyGroup('addAttachment', () {
      nyTest('accepts showThumbnail parameter', () async {
        final notification = LocalNotification(title: 'Test', body: 'Body');

        final result = notification.addAttachment(
          'https://example.com/image.png',
          'image.png',
          showThumbnail: false,
        );

        expect(result, isA<LocalNotification>());
      });

      nyTest('can add multiple attachments', () async {
        final notification = LocalNotification(title: 'Test', body: 'Body')
            .addAttachment('https://example.com/image1.png', 'image1.png')
            .addAttachment('https://example.com/image2.png', 'image2.png')
            .addAttachment('https://example.com/image3.png', 'image3.png');

        expect(notification, isA<LocalNotification>());
      });
    });

    nyGroup('deprecated alias', () {
      nyTest('PushNotification is alias for LocalNotification', () async {
        // ignore: deprecated_member_use_from_same_package
        final notification = PushNotification(title: 'Test', body: 'Body');

        expect(notification, isA<LocalNotification>());
      });
    });

    nyGroup('resolveAndroidScheduleMode', () {
      final plugin = FlutterLocalNotificationsPlugin();

      setUp(() async {
        // The fallback logs a warning, which needs Nylo initialized
        await Nylo.init(env: mockEnv({'APP_DEBUG': true}));
      });

      void mockCanScheduleExactNotifications(bool canScheduleExact) {
        AndroidFlutterLocalNotificationsPlugin.registerWith();
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('dexterous.com/flutter/local_notifications'),
              (MethodCall methodCall) async =>
                  methodCall.method == 'canScheduleExactNotifications'
                  ? canScheduleExact
                  : null,
            );
        addTearDown(() {
          debugDefaultTargetPlatformOverride = null;
          NyMockChannels.tearDown();
          NyMockChannels.setup();
        });
      }

      nyTest('keeps exact modes when exact alarms are permitted', () async {
        mockCanScheduleExactNotifications(true);

        for (final mode in [
          AndroidScheduleMode.exact,
          AndroidScheduleMode.exactAllowWhileIdle,
          AndroidScheduleMode.alarmClock,
        ]) {
          expect(
            await LocalNotification.resolveAndroidScheduleMode(plugin, mode),
            mode,
          );
        }
      });

      nyTest(
        'falls back to inexact modes when exact alarms are not permitted',
        () async {
          mockCanScheduleExactNotifications(false);

          expect(
            await LocalNotification.resolveAndroidScheduleMode(
              plugin,
              AndroidScheduleMode.exact,
            ),
            AndroidScheduleMode.inexact,
          );
          expect(
            await LocalNotification.resolveAndroidScheduleMode(
              plugin,
              AndroidScheduleMode.exactAllowWhileIdle,
            ),
            AndroidScheduleMode.inexactAllowWhileIdle,
          );
          expect(
            await LocalNotification.resolveAndroidScheduleMode(
              plugin,
              AndroidScheduleMode.alarmClock,
            ),
            AndroidScheduleMode.inexactAllowWhileIdle,
          );
        },
      );

      nyTest('leaves inexact modes unchanged', () async {
        mockCanScheduleExactNotifications(false);

        for (final mode in [
          AndroidScheduleMode.inexact,
          AndroidScheduleMode.inexactAllowWhileIdle,
        ]) {
          expect(
            await LocalNotification.resolveAndroidScheduleMode(plugin, mode),
            mode,
          );
        }
      });
    });
  });

  nyGroup('localNotification helper function', () {
    nyTest('creates LocalNotification with title and body', () async {
      final notification = localNotification('Hello', 'World');

      expect(notification, isA<LocalNotification>());
    });

    nyTest('supports method chaining', () async {
      final notification = localNotification(
        'Hello',
        'World',
      ).addPayload('custom-data').addId(789);

      expect(notification, isA<LocalNotification>());
    });
  });

  nyGroup('pushNotification helper function (deprecated)', () {
    nyTest('creates LocalNotification with title and body', () async {
      // ignore: deprecated_member_use_from_same_package
      final notification = pushNotification('Hello', 'World');

      expect(notification, isA<LocalNotification>());
    });
  });
}
