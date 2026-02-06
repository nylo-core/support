import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/local_notifications/ny_local_notifications.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('IOSNotificationConfig', () {
    nyGroup('constructor', () {
      nyTest('creates with default null values', () async {
        const config = IOSNotificationConfig();

        expect(config.presentList, isNull);
        expect(config.presentAlert, isNull);
        expect(config.presentBadge, isNull);
        expect(config.presentSound, isNull);
        expect(config.presentBanner, isNull);
        expect(config.sound, isNull);
        expect(config.badgeNumber, isNull);
        expect(config.threadIdentifier, isNull);
        expect(config.categoryIdentifier, isNull);
        expect(config.interruptionLevel, isNull);
      });

      nyTest('creates with custom values', () async {
        const config = IOSNotificationConfig(
          presentList: true,
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          presentBanner: true,
          sound: 'custom_sound.aiff',
          badgeNumber: 5,
          threadIdentifier: 'thread_123',
          categoryIdentifier: 'category_abc',
          interruptionLevel: InterruptionLevel.timeSensitive,
        );

        expect(config.presentList, true);
        expect(config.presentAlert, true);
        expect(config.presentBadge, true);
        expect(config.presentSound, true);
        expect(config.presentBanner, true);
        expect(config.sound, 'custom_sound.aiff');
        expect(config.badgeNumber, 5);
        expect(config.threadIdentifier, 'thread_123');
        expect(config.categoryIdentifier, 'category_abc');
        expect(config.interruptionLevel, InterruptionLevel.timeSensitive);
      });

      nyTest('accepts false boolean values', () async {
        const config = IOSNotificationConfig(
          presentList: false,
          presentAlert: false,
          presentBadge: false,
          presentSound: false,
          presentBanner: false,
        );

        expect(config.presentList, false);
        expect(config.presentAlert, false);
        expect(config.presentBadge, false);
        expect(config.presentSound, false);
        expect(config.presentBanner, false);
      });
    });

    nyGroup('defaults', () {
      nyTest('returns correct default configuration', () async {
        final defaults = IOSNotificationConfig.defaults;

        expect(defaults.presentList, true);
        expect(defaults.presentAlert, true);
        expect(defaults.presentBadge, true);
        expect(defaults.presentSound, true);
        expect(defaults.presentBanner, true);
      });

      nyTest('has null optional values in defaults', () async {
        final defaults = IOSNotificationConfig.defaults;

        expect(defaults.sound, isNull);
        expect(defaults.badgeNumber, isNull);
        expect(defaults.threadIdentifier, isNull);
        expect(defaults.categoryIdentifier, isNull);
        expect(defaults.interruptionLevel, isNull);
      });
    });

    nyGroup('copyWith', () {
      nyTest('preserves unchanged fields', () async {
        const original = IOSNotificationConfig(
          presentList: true,
          presentAlert: true,
          sound: 'original.aiff',
          badgeNumber: 10,
        );

        final copied = original.copyWith();

        expect(copied.presentList, original.presentList);
        expect(copied.presentAlert, original.presentAlert);
        expect(copied.sound, original.sound);
        expect(copied.badgeNumber, original.badgeNumber);
      });

      nyTest('updates specified fields only', () async {
        const original = IOSNotificationConfig(
          presentList: true,
          presentAlert: true,
          presentBadge: true,
          sound: 'original.aiff',
        );

        final copied = original.copyWith(presentList: false, sound: 'new.aiff');

        // Changed fields
        expect(copied.presentList, false);
        expect(copied.sound, 'new.aiff');

        // Unchanged fields
        expect(copied.presentAlert, true);
        expect(copied.presentBadge, true);
      });

      nyTest('can update all fields', () async {
        const original = IOSNotificationConfig();

        final copied = original.copyWith(
          presentList: false,
          presentAlert: false,
          presentBadge: false,
          presentSound: false,
          presentBanner: false,
          sound: 'updated_sound.aiff',
          badgeNumber: 99,
          threadIdentifier: 'new_thread',
          categoryIdentifier: 'new_category',
          interruptionLevel: InterruptionLevel.critical,
        );

        expect(copied.presentList, false);
        expect(copied.presentAlert, false);
        expect(copied.presentBadge, false);
        expect(copied.presentSound, false);
        expect(copied.presentBanner, false);
        expect(copied.sound, 'updated_sound.aiff');
        expect(copied.badgeNumber, 99);
        expect(copied.threadIdentifier, 'new_thread');
        expect(copied.categoryIdentifier, 'new_category');
        expect(copied.interruptionLevel, InterruptionLevel.critical);
      });

      nyTest('does not mutate original', () async {
        const original = IOSNotificationConfig(
          presentList: true,
          sound: 'original.aiff',
        );

        original.copyWith(presentList: false, sound: 'modified.aiff');

        // Original should remain unchanged
        expect(original.presentList, true);
        expect(original.sound, 'original.aiff');
      });
    });

    nyGroup('interruption levels', () {
      nyTest('supports passive interruption level', () async {
        const config = IOSNotificationConfig(
          interruptionLevel: InterruptionLevel.passive,
        );

        expect(config.interruptionLevel, InterruptionLevel.passive);
      });

      nyTest('supports active interruption level', () async {
        const config = IOSNotificationConfig(
          interruptionLevel: InterruptionLevel.active,
        );

        expect(config.interruptionLevel, InterruptionLevel.active);
      });

      nyTest('supports timeSensitive interruption level', () async {
        const config = IOSNotificationConfig(
          interruptionLevel: InterruptionLevel.timeSensitive,
        );

        expect(config.interruptionLevel, InterruptionLevel.timeSensitive);
      });

      nyTest('supports critical interruption level', () async {
        const config = IOSNotificationConfig(
          interruptionLevel: InterruptionLevel.critical,
        );

        expect(config.interruptionLevel, InterruptionLevel.critical);
      });
    });

    nyGroup('const constructor', () {
      nyTest('allows const instantiation', () async {
        const config1 = IOSNotificationConfig(presentList: true);
        const config2 = IOSNotificationConfig(presentList: true);

        expect(config1.presentList, config2.presentList);
      });
    });

    nyGroup('badge number', () {
      nyTest('accepts zero badge number', () async {
        const config = IOSNotificationConfig(badgeNumber: 0);

        expect(config.badgeNumber, 0);
      });

      nyTest('accepts large badge number', () async {
        const config = IOSNotificationConfig(badgeNumber: 999);

        expect(config.badgeNumber, 999);
      });
    });
  });
}
