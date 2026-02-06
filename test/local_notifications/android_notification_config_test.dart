import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/local_notifications/ny_local_notifications.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('AndroidNotificationConfig', () {
    nyGroup('constructor', () {
      nyTest('creates with default null values', () async {
        const config = AndroidNotificationConfig();

        expect(config.channelId, isNull);
        expect(config.channelName, isNull);
        expect(config.channelDescription, isNull);
        expect(config.importance, isNull);
        expect(config.priority, isNull);
        expect(config.ticker, isNull);
        expect(config.icon, isNull);
        expect(config.playSound, isNull);
        expect(config.enableVibration, isNull);
        expect(config.vibrationPattern, isNull);
        expect(config.groupKey, isNull);
        expect(config.setAsGroupSummary, isNull);
        expect(config.groupAlertBehavior, isNull);
        expect(config.autoCancel, isNull);
        expect(config.ongoing, isNull);
        expect(config.silent, isNull);
        expect(config.color, isNull);
        expect(config.largeIcon, isNull);
        expect(config.onlyAlertOnce, isNull);
        expect(config.showWhen, isNull);
        expect(config.when, isNull);
        expect(config.usesChronometer, isNull);
        expect(config.chronometerCountDown, isNull);
        expect(config.channelShowBadge, isNull);
        expect(config.showProgress, isNull);
        expect(config.maxProgress, isNull);
        expect(config.progress, isNull);
        expect(config.indeterminate, isNull);
        expect(config.channelAction, isNull);
        expect(config.enableLights, isNull);
        expect(config.ledColor, isNull);
        expect(config.ledOnMs, isNull);
        expect(config.ledOffMs, isNull);
        expect(config.visibility, isNull);
        expect(config.timeoutAfter, isNull);
        expect(config.fullScreenIntent, isNull);
        expect(config.shortcutId, isNull);
        expect(config.additionalFlags, isNull);
        expect(config.tag, isNull);
        expect(config.actions, isNull);
        expect(config.colorized, isNull);
        expect(config.audioAttributesUsage, isNull);
      });

      nyTest('creates with custom values', () async {
        const config = AndroidNotificationConfig(
          channelId: 'test_channel',
          channelName: 'Test Channel',
          channelDescription: 'Test Description',
          importance: Importance.high,
          priority: Priority.max,
          ticker: 'Test ticker',
          icon: 'ic_notification',
          playSound: true,
          enableVibration: true,
          vibrationPattern: [0, 250, 250, 250],
          groupKey: 'test_group',
          setAsGroupSummary: true,
          groupAlertBehavior: GroupAlertBehavior.summary,
          autoCancel: false,
          ongoing: true,
          silent: false,
          color: Color(0xFF0000FF),
          largeIcon: 'large_icon.png',
          onlyAlertOnce: true,
          showWhen: true,
          when: 1234567890,
          usesChronometer: true,
          chronometerCountDown: true,
          channelShowBadge: true,
          showProgress: true,
          maxProgress: 100,
          progress: 50,
          indeterminate: false,
          enableLights: true,
          ledColor: Color(0xFF00FF00),
          ledOnMs: 1000,
          ledOffMs: 500,
          visibility: NotificationVisibility.public,
          timeoutAfter: 60000,
          fullScreenIntent: true,
          shortcutId: 'shortcut_1',
          additionalFlags: [1, 2, 4],
          tag: 'test_tag',
          colorized: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );

        expect(config.channelId, 'test_channel');
        expect(config.channelName, 'Test Channel');
        expect(config.channelDescription, 'Test Description');
        expect(config.importance, Importance.high);
        expect(config.priority, Priority.max);
        expect(config.ticker, 'Test ticker');
        expect(config.icon, 'ic_notification');
        expect(config.playSound, true);
        expect(config.enableVibration, true);
        expect(config.vibrationPattern, [0, 250, 250, 250]);
        expect(config.groupKey, 'test_group');
        expect(config.setAsGroupSummary, true);
        expect(config.groupAlertBehavior, GroupAlertBehavior.summary);
        expect(config.autoCancel, false);
        expect(config.ongoing, true);
        expect(config.silent, false);
        expect(config.color, const Color(0xFF0000FF));
        expect(config.largeIcon, 'large_icon.png');
        expect(config.onlyAlertOnce, true);
        expect(config.showWhen, true);
        expect(config.when, 1234567890);
        expect(config.usesChronometer, true);
        expect(config.chronometerCountDown, true);
        expect(config.channelShowBadge, true);
        expect(config.showProgress, true);
        expect(config.maxProgress, 100);
        expect(config.progress, 50);
        expect(config.indeterminate, false);
        expect(config.enableLights, true);
        expect(config.ledColor, const Color(0xFF00FF00));
        expect(config.ledOnMs, 1000);
        expect(config.ledOffMs, 500);
        expect(config.visibility, NotificationVisibility.public);
        expect(config.timeoutAfter, 60000);
        expect(config.fullScreenIntent, true);
        expect(config.shortcutId, 'shortcut_1');
        expect(config.additionalFlags, [1, 2, 4]);
        expect(config.tag, 'test_tag');
        expect(config.colorized, true);
        expect(config.audioAttributesUsage, AudioAttributesUsage.alarm);
      });
    });

    nyGroup('defaults', () {
      nyTest('returns correct default configuration', () async {
        final defaults = AndroidNotificationConfig.defaults;

        expect(defaults.channelId, 'default_channel');
        expect(defaults.channelName, 'Default Channel');
        expect(defaults.channelDescription, 'Default Channel');
        expect(defaults.importance, Importance.max);
        expect(defaults.priority, Priority.high);
        expect(defaults.ticker, 'ticker');
        expect(defaults.playSound, true);
        expect(defaults.enableVibration, true);
        expect(defaults.groupAlertBehavior, GroupAlertBehavior.all);
        expect(defaults.autoCancel, true);
        expect(defaults.showWhen, true);
        expect(defaults.channelShowBadge, true);
      });
    });

    nyGroup('copyWith', () {
      nyTest('preserves unchanged fields', () async {
        const original = AndroidNotificationConfig(
          channelId: 'original_channel',
          channelName: 'Original Channel',
          importance: Importance.high,
          priority: Priority.max,
        );

        final copied = original.copyWith();

        expect(copied.channelId, original.channelId);
        expect(copied.channelName, original.channelName);
        expect(copied.importance, original.importance);
        expect(copied.priority, original.priority);
      });

      nyTest('updates specified fields only', () async {
        const original = AndroidNotificationConfig(
          channelId: 'original_channel',
          channelName: 'Original Channel',
          importance: Importance.high,
        );

        final copied = original.copyWith(
          channelId: 'new_channel',
          importance: Importance.low,
        );

        // Changed fields
        expect(copied.channelId, 'new_channel');
        expect(copied.importance, Importance.low);

        // Unchanged fields
        expect(copied.channelName, 'Original Channel');
      });

      nyTest('can update all fields', () async {
        const original = AndroidNotificationConfig();

        final copied = original.copyWith(
          channelId: 'new_channel',
          channelName: 'New Channel',
          channelDescription: 'New Description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'new ticker',
          icon: 'new_icon',
          playSound: false,
          enableVibration: false,
          vibrationPattern: [100, 200],
          groupKey: 'new_group',
          setAsGroupSummary: true,
          groupAlertBehavior: GroupAlertBehavior.children,
          autoCancel: false,
          ongoing: true,
          silent: true,
          color: const Color(0xFFFF0000),
          largeIcon: 'new_large_icon',
          onlyAlertOnce: true,
          showWhen: false,
          when: 9999999999,
          usesChronometer: true,
          chronometerCountDown: true,
          channelShowBadge: false,
          showProgress: true,
          maxProgress: 200,
          progress: 100,
          indeterminate: true,
          channelAction: AndroidNotificationChannelAction.update,
          enableLights: true,
          ledColor: const Color(0xFF0000FF),
          ledOnMs: 2000,
          ledOffMs: 1000,
          visibility: NotificationVisibility.private,
          timeoutAfter: 120000,
          fullScreenIntent: true,
          shortcutId: 'new_shortcut',
          additionalFlags: [8, 16],
          tag: 'new_tag',
          colorized: true,
          audioAttributesUsage: AudioAttributesUsage.media,
        );

        expect(copied.channelId, 'new_channel');
        expect(copied.channelName, 'New Channel');
        expect(copied.channelDescription, 'New Description');
        expect(copied.importance, Importance.max);
        expect(copied.priority, Priority.high);
        expect(copied.ticker, 'new ticker');
        expect(copied.icon, 'new_icon');
        expect(copied.playSound, false);
        expect(copied.enableVibration, false);
        expect(copied.vibrationPattern, [100, 200]);
        expect(copied.groupKey, 'new_group');
        expect(copied.setAsGroupSummary, true);
        expect(copied.groupAlertBehavior, GroupAlertBehavior.children);
        expect(copied.autoCancel, false);
        expect(copied.ongoing, true);
        expect(copied.silent, true);
        expect(copied.color, const Color(0xFFFF0000));
        expect(copied.largeIcon, 'new_large_icon');
        expect(copied.onlyAlertOnce, true);
        expect(copied.showWhen, false);
        expect(copied.when, 9999999999);
        expect(copied.usesChronometer, true);
        expect(copied.chronometerCountDown, true);
        expect(copied.channelShowBadge, false);
        expect(copied.showProgress, true);
        expect(copied.maxProgress, 200);
        expect(copied.progress, 100);
        expect(copied.indeterminate, true);
        expect(copied.channelAction, AndroidNotificationChannelAction.update);
        expect(copied.enableLights, true);
        expect(copied.ledColor, const Color(0xFF0000FF));
        expect(copied.ledOnMs, 2000);
        expect(copied.ledOffMs, 1000);
        expect(copied.visibility, NotificationVisibility.private);
        expect(copied.timeoutAfter, 120000);
        expect(copied.fullScreenIntent, true);
        expect(copied.shortcutId, 'new_shortcut');
        expect(copied.additionalFlags, [8, 16]);
        expect(copied.tag, 'new_tag');
        expect(copied.colorized, true);
        expect(copied.audioAttributesUsage, AudioAttributesUsage.media);
      });

      nyTest('does not mutate original', () async {
        const original = AndroidNotificationConfig(
          channelId: 'original',
          channelName: 'Original Name',
        );

        original.copyWith(channelId: 'modified', channelName: 'Modified Name');

        // Original should remain unchanged
        expect(original.channelId, 'original');
        expect(original.channelName, 'Original Name');
      });
    });

    nyGroup('const constructor', () {
      nyTest('allows const instantiation', () async {
        const config1 = AndroidNotificationConfig(channelId: 'test');
        const config2 = AndroidNotificationConfig(channelId: 'test');

        expect(config1.channelId, config2.channelId);
      });
    });
  });
}
