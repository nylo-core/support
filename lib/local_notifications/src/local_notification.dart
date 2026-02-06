import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/local_notifications/src/android_notification_config.dart';
import 'package:nylo_support/local_notifications/src/ios_notification_config.dart';
import 'package:nylo_support/local_notifications/src/notification_exception.dart';
import 'package:nylo_support/local_notifications/src/notification_attachment.dart';
import 'package:nylo_support/networking/ny_networking.dart';
import 'package:nylo_support/nylo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/timezone.dart' as tz;

/// Default notification ID when none is specified.
const int _defaultNotificationId = 1;

/// A class for creating and sending local notifications on iOS and Android.
///
/// This class provides a fluent builder API for configuring notifications,
/// as well as static methods for common operations.
///
/// Example usage with builder pattern:
/// ```dart
/// await LocalNotification(title: 'Hello', body: 'World')
///     .addPayload('custom-data')
///     .addId(123)
///     .send();
/// ```
///
/// Example usage with static method:
/// ```dart
/// await LocalNotification.sendNotification(
///   title: 'Hello',
///   body: 'World',
///   payload: 'custom-data',
/// );
/// ```
class LocalNotification {
  final String _title;
  final String _body;

  int? _id;
  String? _payload;
  String? _subtitle;
  DateTime? _sendAt;
  String? _sound;
  int? _badgeNumber;

  final List<NotificationAttachment> _attachments = [];

  AndroidNotificationConfig _androidConfig = const AndroidNotificationConfig();
  IOSNotificationConfig _iosConfig = const IOSNotificationConfig();

  bool _initialized = false;

  /// Creates a [LocalNotification] with the given [title] and [body].
  LocalNotification({String title = '', String body = ''})
    : _title = title,
      _body = body;

  /// Sends a notification with the specified parameters.
  ///
  /// This is a convenience method that creates a [LocalNotification],
  /// configures it with the provided parameters, and sends it.
  ///
  /// Example:
  /// ```dart
  /// await LocalNotification.sendNotification(
  ///   title: 'Hello',
  ///   body: 'World',
  ///   payload: 'custom-data',
  /// );
  /// ```
  static Future<void> sendNotification({
    required String title,
    required String body,
    String? payload,
    DateTime? at,
    int? id,
    String? subtitle,
    int? badgeNumber,
    String? sound,
    AndroidNotificationConfig? androidConfig,
    IOSNotificationConfig? iosConfig,
    AndroidScheduleMode? androidScheduleMode,
  }) async {
    _assertNotWeb();

    final notification = LocalNotification(title: title, body: body);

    _applyIfNotNull(payload, notification.addPayload);
    _applyIfNotNull(id, notification.addId);
    _applyIfNotNull(subtitle, notification.addSubtitle);
    _applyIfNotNull(badgeNumber, notification.addBadgeNumber);
    _applyIfNotNull(sound, notification.addSound);

    if (androidConfig != null) {
      notification.setAndroidConfig(androidConfig);
    }
    if (iosConfig != null) {
      notification.setIOSConfig(iosConfig);
    }

    await notification.send(at: at, androidScheduleMode: androidScheduleMode);
  }

  /// Sends the notification.
  ///
  /// If [at] is specified, the notification will be scheduled for that time.
  /// Otherwise, it will be shown immediately.
  Future<void> send({
    DateTime? at,
    AndroidScheduleMode? androidScheduleMode,
  }) async {
    _assertNotWeb();

    await NyScheduler.taskOnce('local_notification_permissions', () async {
      await requestPermissions();
    });

    _sendAt = at;

    final notificationDetails = await _getNotificationDetails();

    if (!_initialized) {
      _initialized =
          await Nylo.instance.initializeLocalNotifications() ?? false;
    }

    if (_sendAt != null) {
      await _sendScheduledNotification(
        notificationDetails,
        androidScheduleMode ?? AndroidScheduleMode.exactAllowWhileIdle,
      );
      return;
    }

    await _sendImmediateNotification(notificationDetails);
  }

  Future<void> _sendScheduledNotification(
    NotificationDetails notificationDetails,
    AndroidScheduleMode androidScheduleMode,
  ) async {
    final sendAtDateTime = _sendAt.toDateTimeString();

    if (sendAtDateTime == null) {
      throw const NotificationException('Invalid date provided');
    }

    await Nylo.localNotifications((flutterLocalNotificationsPlugin) async {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: _id ?? _defaultNotificationId,
        title: _title,
        body: _body,
        scheduledDate: tz.TZDateTime.parse(tz.local, sendAtDateTime),
        notificationDetails: notificationDetails,
        androidScheduleMode: androidScheduleMode,
        payload: _payload,
      );
    });
  }

  Future<void> _sendImmediateNotification(
    NotificationDetails notificationDetails,
  ) async {
    await Nylo.localNotifications((flutterLocalNotificationsPlugin) async {
      await flutterLocalNotificationsPlugin.show(
        id: _id ?? _defaultNotificationId,
        title: _title,
        body: _body,
        notificationDetails: notificationDetails,
        payload: _payload,
      );
    });
  }

  /// Adds an attachment to the notification.
  ///
  /// Attachments are only supported on iOS.
  LocalNotification addAttachment(
    String url,
    String fileName, {
    bool? showThumbnail,
  }) {
    _attachments.add(
      NotificationAttachment(url, fileName, showThumbnail: showThumbnail),
    );
    return this;
  }

  /// Sets the payload data for the notification.
  LocalNotification addPayload(String payload) {
    _payload = payload;
    return this;
  }

  /// Sets the notification ID.
  LocalNotification addId(int id) {
    _id = id;
    return this;
  }

  /// Sets the subtitle for the notification.
  LocalNotification addSubtitle(String subtitle) {
    _subtitle = subtitle;
    return this;
  }

  /// Sets the badge number for the notification.
  LocalNotification addBadgeNumber(int badgeNumber) {
    _badgeNumber = badgeNumber;
    return this;
  }

  /// Sets the sound for the notification.
  LocalNotification addSound(String sound) {
    _sound = sound;
    return this;
  }

  /// Sets the Android-specific configuration.
  LocalNotification setAndroidConfig(AndroidNotificationConfig config) {
    _androidConfig = config;
    return this;
  }

  /// Sets the iOS-specific configuration.
  LocalNotification setIOSConfig(IOSNotificationConfig config) {
    _iosConfig = config;
    return this;
  }

  Future<NotificationDetails> _getNotificationDetails() async {
    if (Platform.isIOS) {
      return _getIOSNotificationDetails();
    }

    if (Platform.isAndroid) {
      return _getAndroidNotificationDetails();
    }

    throw const NotificationException('Platform not supported');
  }

  Future<NotificationDetails> _getIOSNotificationDetails() async {
    final attachments = await _downloadAttachments();
    final config = _iosConfig;

    final iosDetails = DarwinNotificationDetails(
      presentList: config.presentList ?? true,
      presentAlert: config.presentAlert ?? true,
      presentBadge: config.presentBadge ?? true,
      presentSound: config.presentSound ?? true,
      presentBanner: config.presentBanner ?? true,
      sound: _sound ?? config.sound,
      attachments: attachments,
      badgeNumber: _badgeNumber ?? config.badgeNumber,
      subtitle: _subtitle,
      threadIdentifier: config.threadIdentifier,
      categoryIdentifier: config.categoryIdentifier,
      interruptionLevel: config.interruptionLevel,
    );

    return NotificationDetails(iOS: iosDetails);
  }

  Future<List<DarwinNotificationAttachment>> _downloadAttachments() async {
    final attachments = <DarwinNotificationAttachment>[];

    for (final attachment in _attachments) {
      try {
        final filePath = await _downloadAndSaveFile(
          attachment.url,
          attachment.fileName,
        );

        attachments.add(
          DarwinNotificationAttachment(
            filePath,
            identifier: attachment.fileName,
            hideThumbnail: !(attachment.showThumbnail ?? true),
          ),
        );
      } on Exception catch (e) {
        NyLogger.error(e.toString());
        continue;
      }
    }

    return attachments;
  }

  NotificationDetails _getAndroidNotificationDetails() {
    final config = _mergeAndroidConfigWithDefaults();
    final sound = _sound;

    final androidDetails = AndroidNotificationDetails(
      config.channelId ?? 'default_channel',
      config.channelName ?? 'Default Channel',
      channelDescription: config.channelDescription ?? 'Default Channel',
      importance: config.importance ?? Importance.max,
      priority: config.priority ?? Priority.high,
      ticker: config.ticker ?? 'ticker',
      icon: config.icon ?? _getDefaultAndroidIcon(),
      playSound: config.playSound ?? true,
      sound: _buildAndroidSound(sound),
      enableVibration: config.enableVibration ?? true,
      vibrationPattern: _buildVibrationPattern(config.vibrationPattern),
      groupKey: config.groupKey,
      setAsGroupSummary: config.setAsGroupSummary ?? false,
      groupAlertBehavior: config.groupAlertBehavior ?? GroupAlertBehavior.all,
      autoCancel: config.autoCancel ?? true,
      ongoing: config.ongoing ?? false,
      silent: config.silent ?? false,
      color: config.color,
      largeIcon: _buildLargeIcon(config.largeIcon),
      onlyAlertOnce: config.onlyAlertOnce ?? false,
      showWhen: config.showWhen ?? true,
      when: config.when,
      usesChronometer: config.usesChronometer ?? false,
      chronometerCountDown: config.chronometerCountDown ?? false,
      channelShowBadge: config.channelShowBadge ?? true,
      showProgress: config.showProgress ?? false,
      maxProgress: config.maxProgress ?? 0,
      progress: config.progress ?? 0,
      indeterminate: config.indeterminate ?? false,
      channelAction:
          config.channelAction ??
          AndroidNotificationChannelAction.createIfNotExists,
      enableLights: config.enableLights ?? false,
      ledColor: config.ledColor,
      ledOnMs: config.ledOnMs,
      ledOffMs: config.ledOffMs,
      visibility: config.visibility,
      timeoutAfter: config.timeoutAfter,
      category: AndroidNotificationCategory.message,
      fullScreenIntent: config.fullScreenIntent ?? false,
      shortcutId: config.shortcutId,
      additionalFlags: _buildAdditionalFlags(config.additionalFlags),
      subText: _subtitle,
      tag: config.tag,
      actions: config.actions,
      colorized: config.colorized ?? false,
      number: _badgeNumber,
      audioAttributesUsage:
          config.audioAttributesUsage ?? AudioAttributesUsage.notification,
    );

    return NotificationDetails(android: androidDetails);
  }

  AndroidNotificationConfig _mergeAndroidConfigWithDefaults() {
    return _androidConfig;
  }

  String? _getDefaultAndroidIcon() {
    final initSettings = Nylo.instance.getInitializationSettings();
    return initSettings?.android?.defaultIcon ?? 'app_icon';
  }

  AndroidNotificationSound? _buildAndroidSound(String? sound) {
    if (sound == null) return null;

    final isUrl = sound.startsWith('http');
    return isUrl
        ? UriAndroidNotificationSound(sound)
        : RawResourceAndroidNotificationSound(sound);
  }

  Int64List? _buildVibrationPattern(List<int>? pattern) {
    if (pattern == null) return null;
    return Int64List.fromList(pattern);
  }

  FilePathAndroidBitmap? _buildLargeIcon(String? largeIcon) {
    if (largeIcon == null) return null;
    return FilePathAndroidBitmap(largeIcon);
  }

  Int32List? _buildAdditionalFlags(List<int>? flags) {
    if (flags == null) return null;
    return Int32List.fromList(flags);
  }

  /// Cancels a notification with the given [id].
  static Future<void> cancelNotification(int id, {String? tag}) async {
    await Nylo.localNotifications((flutterLocalNotificationsPlugin) async {
      await flutterLocalNotificationsPlugin.cancel(id: id, tag: tag);
    });
  }

  /// Cancels all notifications.
  static Future<void> cancelAllNotifications() async {
    await Nylo.localNotifications((localNotifications) async {
      await localNotifications.cancelAll();
    });
  }

  /// Requests notification permissions from the user.
  static Future<void> requestPermissions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
    bool provisional = false,
    bool critical = false,
    bool vibrate = true,
    bool enableLights = true,
    String channelId = 'default_notification_channel_id',
    String channelName = 'Default Notification Channel',
    String? description,
    String? groupId,
    Importance? importance,
    List<int>? vibratePattern,
    Color? ledColor,
    AudioAttributesUsage? audioAttributesUsage,
  }) async {
    _assertNotWeb();

    await Nylo.localNotifications((localNotifications) async {
      if (Platform.isIOS) {
        await localNotifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions();
        return;
      }

      if (Platform.isAndroid) {
        await localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
        return;
      }

      throw const NotificationException('Platform not supported');
    });
  }

  /// Clears the badge count on iOS.
  static Future<void> clearBadgeCount() async {
    await clearBadgeNumber();
  }

  static void _assertNotWeb() {
    if (kIsWeb) {
      throw const NotificationException(
        'Local notifications are not supported on the web',
      );
    }
  }
}

/// Helper function to apply a value if it's not null.
void _applyIfNotNull<T>(T? value, LocalNotification Function(T) apply) {
  if (value != null) apply(value);
}

/// Downloads and saves a file from a URL.
Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';

  final api = NyApiService(
    decoders: {List<int>: (data) => List<int>.from(data)},
  );

  final responseData = await api.get<List<int>>(
    url,
    options: Options(responseType: ResponseType.bytes),
  );

  if (responseData == null) {
    throw const NotificationException('Failed to download file');
  }

  final file = File(filePath);
  await file.writeAsBytes(responseData);
  return filePath;
}

/// Backwards compatibility alias for [LocalNotification].
@Deprecated('Use LocalNotification instead')
typedef PushNotification = LocalNotification;
