import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '/helpers/helper.dart';
import '/helpers/extensions.dart';
import '/helpers/ny_scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/timezone.dart' as tz;

import '/helpers/ny_logger.dart';
import '/nylo.dart';
import '/networking/ny_api_service.dart';

/// Download and save a file
Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  NyApiService api = NyApiService(null, decoders: {
    List<int>: (data) => List<int>.from(data),
  });
  final List<int>? responseData =
      await api.get(url, options: Options(responseType: ResponseType.bytes));
  if (responseData == null) {
    throw Exception("Failed to download file");
  }
  final File file = File(filePath);
  await file.writeAsBytes(responseData);
  return filePath;
}

/// Push Notification Attachments
class _PushNotificationAttachments {
  final String url;
  final String fileName;
  final bool? showThumbnail;

  _PushNotificationAttachments(this.url, this.fileName,
      {this.showThumbnail = true});
}

/// Push Notification
class PushNotification {
  int? _id;
  final String _title;
  final String _body;
  String? _payload;
  String? _subtitle;
  final List<_PushNotificationAttachments> _attachments = [];
  DateTime? _sendAt;

  // IOS
  bool? _presentList;
  bool? _presentAlert;
  bool? _presentBadge;
  bool? _presentSound;
  bool? _presentBanner;
  String? _sound;
  int? _badgeNumber;
  String? _threadIdentifier;
  String? _categoryIdentifier;
  InterruptionLevel? _interruptionLevel;

  // Android
  String? _channelId;
  String? _channelName;
  String? _channelDescription;
  Importance? _importance;
  Priority? _priority;
  String? _ticker;
  String? _icon;
  bool? _playSound;
  bool? _enableVibration;
  List<int>? _vibrationPattern;
  String? _groupKey;
  bool? _setAsGroupSummary;
  GroupAlertBehavior? _groupAlertBehavior;
  bool? _autoCancel;
  bool? _ongoing;
  bool? _silent;
  Color? _color;
  String? _largeIcon;
  bool? _onlyAlertOnce;
  bool? _showWhen;
  int? _when;
  bool? _usesChronometer;
  bool? _chronometerCountDown;
  bool? _channelShowBadge;
  bool? _showProgress;
  int? _maxProgress;
  int? _progress;
  bool? _indeterminate;
  AndroidNotificationChannelAction? _channelAction;
  bool? _enableLights;
  Color? _ledColor;
  int? _ledOnMs;
  int? _ledOffMs;
  NotificationVisibility? _visibility;
  int? _timeoutAfter;
  bool? _fullScreenIntent;
  String? _shortcutId;
  List<int>? _additionalFlags;
  String? _tag;
  List<AndroidNotificationAction>? _actions;
  bool? _colorized;
  AudioAttributesUsage? _audioAttributesUsage;
  bool _initialized = false;

  PushNotification({String title = "", String body = ""})
      : _title = title,
        _body = body;

  /// Send a notification
  /// Example:
  /// ```dart
  /// PushNotification.sendNotification(
  ///  title: "Hello",
  ///  body: "World",
  ///  );
  ///  ```
  ///  This will send a notification with the title "Hello" and the body "World"
  static sendNotification({
    required String title,
    required String body,
    String? payload,
    DateTime? at,
    int? id,
    String? subtitle,
    int? badgeNumber,
    String? sound,
    String? channelId,
    String? channelName,
    String? channelDescription,
    Importance? importance,
    Priority? priority,
    String? ticker,
    String? icon,
    bool? playSound,
    bool? enableVibration,
    List<int>? vibrationPattern,
    String? groupKey,
    bool? setAsGroupSummary,
    GroupAlertBehavior? groupAlertBehavior,
    bool? autoCancel,
    bool? ongoing,
    bool? silent,
    Color? color,
    String? largeIcon,
    bool? onlyAlertOnce,
    bool? showWhen,
    int? when,
    bool? usesChronometer,
    bool? chronometerCountDown,
    bool? channelShowBadge,
    bool? showProgress,
    int? maxProgress,
    int? progress,
    bool? indeterminate,
    AndroidNotificationChannelAction? channelAction,
    bool? enableLights,
    Color? ledColor,
    int? ledOnMs,
    int? ledOffMs,
    NotificationVisibility? visibility,
    int? timeoutAfter,
    bool? fullScreenIntent,
    String? shortcutId,
    List<int>? additionalFlags,
    String? tag,
    List<AndroidNotificationAction>? actions,
    bool? colorized,
    AudioAttributesUsage? audioAttributesUsage,
    bool? presentList,
    bool? presentAlert,
    bool? presentBadge,
    bool? presentSound,
    bool? presentBanner,
    String? threadIdentifier,
    String? categoryIdentifier,
    InterruptionLevel? interruptionLevel,
    AndroidScheduleMode? androidScheduleMode,
  }) async {
    PushNotification pushNotification = PushNotification(
      title: title,
      body: body,
    );
    if (Platform.isAndroid) {
      if (channelId == null) {
        pushNotification.addChannelId("default_channel");
      }
      if (channelName == null) {
        pushNotification.addChannelName("Default Channel");
      }
      if (channelDescription == null) {
        pushNotification.addChannelDescription("Default Channel");
      }
      if (importance == null) {
        pushNotification.addImportance(Importance.max);
      }
      if (priority == null) {
        pushNotification.addPriority(Priority.high);
      }
      if (ticker == null) {
        pushNotification.addTicker("ticker");
      }
      if (icon == null) {
        pushNotification.addIcon("app_icon");
      }
      if (playSound == null) {
        pushNotification.addPlaySound(true);
      }
      if (enableVibration == null) {
        pushNotification.addEnableVibration(true);
      }
      if (groupAlertBehavior == null) {
        pushNotification.addGroupAlertBehavior(GroupAlertBehavior.all);
      }
      if (autoCancel == null) {
        pushNotification.addAutoCancel(true);
      }
      if (showWhen == null) {
        pushNotification.addShowWhen(true);
      }
      if (channelShowBadge == null) {
        pushNotification.addChannelShowBadge(true);
      }
    }
    if (payload != null) {
      pushNotification.addPayload(payload);
    }
    if (at != null) {
      pushNotification.send(at: at, androidScheduleMode: androidScheduleMode);
    }
    if (id != null) {
      pushNotification.addId(id);
    }
    if (subtitle != null) {
      pushNotification.addSubtitle(subtitle);
    }
    if (badgeNumber != null) {
      pushNotification.addBadgeNumber(badgeNumber);
    }
    if (sound != null) {
      pushNotification.addSound(sound);
    }
    if (channelId != null) {
      pushNotification.addChannelId(channelId);
    }
    if (channelName != null) {
      pushNotification.addChannelName(channelName);
    }
    if (channelDescription != null) {
      pushNotification.addChannelDescription(channelDescription);
    }
    if (importance != null) {
      pushNotification.addImportance(importance);
    }
    if (priority != null) {
      pushNotification.addPriority(priority);
    }
    if (ticker != null) {
      pushNotification.addTicker(ticker);
    }
    if (icon != null) {
      pushNotification.addIcon(icon);
    }
    if (playSound != null) {
      pushNotification.addPlaySound(playSound);
    }
    if (enableVibration != null) {
      pushNotification.addEnableVibration(enableVibration);
    }
    if (vibrationPattern != null) {
      pushNotification.addVibrationPattern(vibrationPattern);
    }
    if (groupKey != null) {
      pushNotification.addGroupKey(groupKey);
    }
    if (setAsGroupSummary != null) {
      pushNotification.addSetAsGroupSummary(setAsGroupSummary);
    }
    if (groupAlertBehavior != null) {
      pushNotification.addGroupAlertBehavior(groupAlertBehavior);
    }
    if (autoCancel != null) {
      pushNotification.addAutoCancel(autoCancel);
    }
    if (ongoing != null) {
      pushNotification.addOngoing(ongoing);
    }
    if (silent != null) {
      pushNotification.addSilent(silent);
    }
    if (color != null) {
      pushNotification.addColor(color);
    }
    if (largeIcon != null) {
      pushNotification.addLargeIcon(largeIcon);
    }
    if (onlyAlertOnce != null) {
      pushNotification.addOnlyAlertOnce(onlyAlertOnce);
    }
    if (showWhen != null) {
      pushNotification.addShowWhen(showWhen);
    }
    if (when != null) {
      pushNotification.addWhen(when);
    }
    if (usesChronometer != null) {
      pushNotification.addUsesChronometer(usesChronometer);
    }
    if (chronometerCountDown != null) {
      pushNotification.addChronometerCountDown(chronometerCountDown);
    }
    if (channelShowBadge != null) {
      pushNotification.addChannelShowBadge(channelShowBadge);
    }
    if (showProgress != null) {
      pushNotification.addShowProgress(showProgress);
    }
    if (maxProgress != null) {
      pushNotification.addMaxProgress(maxProgress);
    }
    if (progress != null) {
      pushNotification.addProgress(progress);
    }
    if (indeterminate != null) {
      pushNotification.addIndeterminate(indeterminate);
    }
    if (channelAction != null) {
      pushNotification.addChannelAction(channelAction);
    }
    if (enableLights != null) {
      pushNotification.addEnableLights(enableLights);
    }
    if (ledColor != null) {
      pushNotification.addLedColor(ledColor);
    }
    if (ledOnMs != null) {
      pushNotification.addLedOnMs(ledOnMs);
    }
    if (ledOffMs != null) {
      pushNotification.addLedOffMs(ledOffMs);
    }
    if (visibility != null) {
      pushNotification.addVisibility(visibility);
    }
    if (timeoutAfter != null) {
      pushNotification.addTimeoutAfter(timeoutAfter);
    }
    if (fullScreenIntent != null) {
      pushNotification.addFullScreenIntent(fullScreenIntent);
    }
    if (shortcutId != null) {
      pushNotification.addShortcutId(shortcutId);
    }
    if (additionalFlags != null) {
      pushNotification.addAdditionalFlags(additionalFlags);
    }
    if (tag != null) {
      pushNotification.addTag(tag);
    }
    if (actions != null) {
      pushNotification.addActions(actions);
    }
    if (colorized != null) {
      pushNotification.addColorized(colorized);
    }
    if (audioAttributesUsage != null) {
      pushNotification.addAudioAttributesUsage(audioAttributesUsage);
    }
    if (presentList != null) {
      pushNotification.addPresentList(presentList);
    }
    if (presentAlert != null) {
      pushNotification.addPresentAlert(presentAlert);
    }
    if (presentBadge != null) {
      pushNotification.addPresentBadge(presentBadge);
    }
    if (presentSound != null) {
      pushNotification.addPresentSound(presentSound);
    }
    if (presentBanner != null) {
      pushNotification.addPresentBanner(presentBanner);
    }
    if (threadIdentifier != null) {
      pushNotification.addThreadIdentifier(threadIdentifier);
    }
    if (categoryIdentifier != null) {
      pushNotification.addCategoryIdentifier(categoryIdentifier);
    }
    if (interruptionLevel != null) {
      pushNotification.addInterruptionLevel(interruptionLevel);
    }
    await pushNotification.send(at: at);
  }

  /// Send the push notification
  Future<void> send(
      {DateTime? at, AndroidScheduleMode? androidScheduleMode}) async {
    await NyScheduler.taskOnce('push_notification_permissions', () async {
      // request permissions
      await requestPermissions();
    });

    _sendAt = at;

    NotificationDetails notificationDetails = await _getNotificationDetails();

    if (_initialized == false) {
      _initialized = await Nylo.instance.initializeLocalNotifications();
    }

    if (_sendAt != null) {
      String? sendAtDateTime = at.toDateTimeString();

      if (sendAtDateTime == null) {
        throw Exception("Invalid date provided");
      }

      await Nylo.localNotifications((FlutterLocalNotificationsPlugin
          flutterLocalNotificationsPlugin) async {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          _id ?? 1,
          _title,
          _body,
          tz.TZDateTime.parse(tz.local, sendAtDateTime),
          notificationDetails,
          androidScheduleMode: androidScheduleMode ?? AndroidScheduleMode.exact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: _payload,
        );
      });
      return;
    }

    await Nylo.localNotifications((FlutterLocalNotificationsPlugin
        flutterLocalNotificationsPlugin) async {
      await flutterLocalNotificationsPlugin.show(
        _id ?? 1,
        _title,
        _body,
        notificationDetails,
        payload: _payload,
      );
    });
  }

  /// Add an attachment to the push notification
  PushNotification addAttachment(String url, String fileName,
      {bool? showThumbnail}) {
    _attachments.add(_PushNotificationAttachments(url, fileName,
        showThumbnail: showThumbnail));
    return this;
  }

  /// Add a payload to the push notification
  PushNotification addPayload(String payload) {
    _payload = payload;
    return this;
  }

  /// Add an id to the push notification
  PushNotification addId(int id) {
    _id = id;
    return this;
  }

  /// Add a subtitle to the push notification
  PushNotification addSubtitle(String subtitle) {
    _subtitle = subtitle;
    return this;
  }

  /// Add the badge number to the push notification
  PushNotification addBadgeNumber(int badgeNumber) {
    _badgeNumber = badgeNumber;
    return this;
  }

  /// Add a sound to the push notification
  PushNotification addSound(String sound) {
    _sound = sound;
    return this;
  }

  /// Add channel Id to the push notification
  PushNotification addChannelId(String channelId) {
    _channelId = channelId;
    return this;
  }

  /// Add channel name to the push notification
  PushNotification addChannelName(String channelName) {
    _channelName = channelName;
    return this;
  }

  /// Add channel description to the push notification
  PushNotification addChannelDescription(String channelDescription) {
    _channelDescription = channelDescription;
    return this;
  }

  /// Add importance to the push notification
  PushNotification addImportance(Importance importance) {
    _importance = importance;
    return this;
  }

  /// Add priority to the push notification
  PushNotification addPriority(Priority priority) {
    _priority = priority;
    return this;
  }

  /// Add ticker to the push notification
  PushNotification addTicker(String ticker) {
    _ticker = ticker;
    return this;
  }

  /// Add icon to the push notification
  PushNotification addIcon(String icon) {
    _icon = icon;
    return this;
  }

  /// Add play sound to the push notification
  PushNotification addPlaySound(bool playSound) {
    _playSound = playSound;
    return this;
  }

  /// Add enable vibration to the push notification
  PushNotification addEnableVibration(bool enableVibration) {
    _enableVibration = enableVibration;
    return this;
  }

  /// Add vibration pattern to the push notification
  PushNotification addVibrationPattern(List<int> vibrationPattern) {
    _vibrationPattern = vibrationPattern;
    return this;
  }

  /// Add group key to the push notification
  PushNotification addGroupKey(String groupKey) {
    _groupKey = groupKey;
    return this;
  }

  /// Add set as group summary to the push notification
  PushNotification addSetAsGroupSummary(bool setAsGroupSummary) {
    _setAsGroupSummary = setAsGroupSummary;
    return this;
  }

  /// Add group alert behavior to the push notification
  PushNotification addGroupAlertBehavior(
      GroupAlertBehavior groupAlertBehavior) {
    _groupAlertBehavior = groupAlertBehavior;
    return this;
  }

  /// Add auto cancel to the push notification
  PushNotification addAutoCancel(bool autoCancel) {
    _autoCancel = autoCancel;
    return this;
  }

  /// Add ongoing to the push notification
  PushNotification addOngoing(bool ongoing) {
    _ongoing = ongoing;
    return this;
  }

  /// Add silent to the push notification
  PushNotification addSilent(bool silent) {
    _silent = silent;
    return this;
  }

  /// Add color to the push notification
  PushNotification addColor(Color color) {
    _color = color;
    return this;
  }

  /// Add large icon to the push notification
  PushNotification addLargeIcon(String largeIcon) {
    _largeIcon = largeIcon;
    return this;
  }

  /// Add only alert once to the push notification
  PushNotification addOnlyAlertOnce(bool onlyAlertOnce) {
    _onlyAlertOnce = onlyAlertOnce;
    return this;
  }

  /// Add show when to the push notification
  PushNotification addShowWhen(bool showWhen) {
    _showWhen = showWhen;
    return this;
  }

  /// Add when to the push notification
  PushNotification addWhen(int when) {
    _when = when;
    return this;
  }

  /// Add uses chronometer to the push notification
  PushNotification addUsesChronometer(bool usesChronometer) {
    _usesChronometer = usesChronometer;
    return this;
  }

  /// Add chronometer count down to the push notification
  PushNotification addChronometerCountDown(bool chronometerCountDown) {
    _chronometerCountDown = chronometerCountDown;
    return this;
  }

  /// Add channel show badge to the push notification
  PushNotification addChannelShowBadge(bool channelShowBadge) {
    _channelShowBadge = channelShowBadge;
    return this;
  }

  /// Add show progress to the push notification
  PushNotification addShowProgress(bool showProgress) {
    _showProgress = showProgress;
    return this;
  }

  /// Add max progress to the push notification
  PushNotification addMaxProgress(int maxProgress) {
    _maxProgress = maxProgress;
    return this;
  }

  /// Add progress to the push notification
  PushNotification addProgress(int progress) {
    _progress = progress;
    return this;
  }

  /// Add indeterminate to the push notification
  PushNotification addIndeterminate(bool indeterminate) {
    _indeterminate = indeterminate;
    return this;
  }

  /// Add channel action to the push notification
  PushNotification addChannelAction(
      AndroidNotificationChannelAction channelAction) {
    _channelAction = channelAction;
    return this;
  }

  /// Add enable lights to the push notification
  PushNotification addEnableLights(bool enableLights) {
    _enableLights = enableLights;
    return this;
  }

  /// Add led color to the push notification
  PushNotification addLedColor(Color ledColor) {
    _ledColor = ledColor;
    return this;
  }

  /// Add led on ms to the push notification
  PushNotification addLedOnMs(int ledOnMs) {
    _ledOnMs = ledOnMs;
    return this;
  }

  /// Add led off ms to the push notification
  PushNotification addLedOffMs(int ledOffMs) {
    _ledOffMs = ledOffMs;
    return this;
  }

  /// Add visibility to the push notification
  PushNotification addVisibility(NotificationVisibility visibility) {
    _visibility = visibility;
    return this;
  }

  /// Add timeout after to the push notification
  PushNotification addTimeoutAfter(int timeoutAfter) {
    _timeoutAfter = timeoutAfter;
    return this;
  }

  /// Add full screen intent to the push notification
  PushNotification addFullScreenIntent(bool fullScreenIntent) {
    _fullScreenIntent = fullScreenIntent;
    return this;
  }

  /// Add shortcut id to the push notification
  PushNotification addShortcutId(String shortcutId) {
    _shortcutId = shortcutId;
    return this;
  }

  /// Add additional flags to the push notification
  PushNotification addAdditionalFlags(List<int> additionalFlags) {
    _additionalFlags = additionalFlags;
    return this;
  }

  /// Add tag to the push notification
  PushNotification addTag(String tag) {
    _tag = tag;
    return this;
  }

  /// Add actions to the push notification
  PushNotification addActions(List<AndroidNotificationAction> actions) {
    _actions = actions;
    return this;
  }

  /// Add colorized to the push notification
  PushNotification addColorized(bool colorized) {
    _colorized = colorized;
    return this;
  }

  /// Add audio attributes usage to the push notification
  PushNotification addAudioAttributesUsage(
      AudioAttributesUsage audioAttributesUsage) {
    _audioAttributesUsage = audioAttributesUsage;
    return this;
  }

  /// Add present list to the push notification
  PushNotification addPresentList(bool presentList) {
    _presentList = presentList;
    return this;
  }

  /// Add present alert to the push notification
  PushNotification addPresentAlert(bool presentAlert) {
    _presentAlert = presentAlert;
    return this;
  }

  /// Add present badge to the push notification
  PushNotification addPresentBadge(bool presentBadge) {
    _presentBadge = presentBadge;
    return this;
  }

  /// Add present sound to the push notification
  PushNotification addPresentSound(bool presentSound) {
    _presentSound = presentSound;
    return this;
  }

  /// Add present banner to the push notification
  PushNotification addPresentBanner(bool presentBanner) {
    _presentBanner = presentBanner;
    return this;
  }

  /// Add thread identifier to the push notification
  PushNotification addThreadIdentifier(String threadIdentifier) {
    _threadIdentifier = threadIdentifier;
    return this;
  }

  /// Add category identifier to the push notification
  PushNotification addCategoryIdentifier(String categoryIdentifier) {
    _categoryIdentifier = categoryIdentifier;
    return this;
  }

  /// Add interruption level to the push notification
  PushNotification addInterruptionLevel(InterruptionLevel interruptionLevel) {
    _interruptionLevel = interruptionLevel;
    return this;
  }

  /// Get the notification details
  Future<NotificationDetails> _getNotificationDetails() async {
    if (Platform.isIOS) {
      // fetch the attachments
      List<DarwinNotificationAttachment> attachments = [];
      for (_PushNotificationAttachments attachment in _attachments) {
        try {
          final String fileAttachment =
              await _downloadAndSaveFile(attachment.url, attachment.fileName);

          attachments.add(DarwinNotificationAttachment(
            fileAttachment,
            identifier: attachment.fileName,
            hideThumbnail: attachment.showThumbnail ?? false,
          ));
        } on Exception catch (e) {
          NyLogger.error(e.toString());
          continue;
        }
      }

      DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentList: _presentList ?? true,
        presentAlert: _presentAlert ?? true,
        presentBadge: _presentBadge ?? true,
        presentSound: _presentSound ?? true,
        presentBanner: _presentBanner ?? true,
        sound: _sound,
        attachments: attachments,
        badgeNumber: _badgeNumber,
        subtitle: _subtitle,
        threadIdentifier: _threadIdentifier,
        categoryIdentifier: _categoryIdentifier,
        interruptionLevel: _interruptionLevel,
      );

      return NotificationDetails(
        iOS: iOSPlatformChannelSpecifics,
      );
    }

    if (Platform.isAndroid) {
      bool isSoundAUrl = _sound != null && _sound!.startsWith("http");
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        _channelId ?? "",
        _channelName ?? "",
        channelDescription: _channelDescription ?? "",
        importance: _importance ?? Importance.max,
        priority: _priority ?? Priority.high,
        ticker: _ticker ?? "",
        icon: _icon,
        playSound: _playSound ?? true,
        sound: isSoundAUrl
            ? UriAndroidNotificationSound(_sound ?? "")
            : RawResourceAndroidNotificationSound(_sound ?? ""),
        enableVibration: _enableVibration ?? true,
        vibrationPattern: _vibrationPattern == null
            ? null
            : Int64List.fromList(_vibrationPattern ?? []),
        groupKey: _groupKey,
        setAsGroupSummary: _setAsGroupSummary ?? false,
        groupAlertBehavior: _groupAlertBehavior ?? GroupAlertBehavior.all,
        autoCancel: _autoCancel ?? true,
        ongoing: _ongoing ?? false,
        silent: _silent ?? false,
        color: _color,
        largeIcon:
            _largeIcon == null ? null : FilePathAndroidBitmap(_largeIcon ?? ""),
        onlyAlertOnce: _onlyAlertOnce ?? false,
        showWhen: _showWhen ?? true,
        when: _when,
        usesChronometer: _usesChronometer ?? false,
        chronometerCountDown: _chronometerCountDown ?? false,
        channelShowBadge: _channelShowBadge ?? true,
        showProgress: _showProgress ?? false,
        maxProgress: _maxProgress ?? 0,
        progress: _progress ?? 0,
        indeterminate: _indeterminate ?? false,
        channelAction: _channelAction ??
            AndroidNotificationChannelAction.createIfNotExists,
        enableLights: _enableLights ?? false,
        ledColor: _ledColor,
        ledOnMs: _ledOnMs,
        ledOffMs: _ledOffMs,
        visibility: _visibility,
        timeoutAfter: _timeoutAfter,
        category: AndroidNotificationCategory.message,
        fullScreenIntent: _fullScreenIntent ?? false,
        shortcutId: _shortcutId,
        additionalFlags: _additionalFlags == null
            ? null
            : Int32List.fromList(_additionalFlags ?? []),
        subText: _subtitle,
        tag: _tag,
        actions: _actions,
        colorized: _colorized ?? false,
        number: _badgeNumber,
        audioAttributesUsage:
            _audioAttributesUsage ?? AudioAttributesUsage.notification,
      );

      return NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
    }

    throw Exception("Platform not supported");
  }

  /// Cancel a notification
  static Future<void> cancelNotification(int id, {String? tag}) async {
    await Nylo.localNotifications((FlutterLocalNotificationsPlugin
        flutterLocalNotificationsPlugin) async {
      await flutterLocalNotificationsPlugin.cancel(id, tag: tag);
    });
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await Nylo.localNotifications(
        (FlutterLocalNotificationsPlugin localNotifications) async {
      await localNotifications.cancelAll();
    });
  }

  /// Request permissions
  static Future<void> requestPermissions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
    bool provisional = false,
    bool critical = false,
    bool vibrate = true,
    bool enableLights = true,
    String channelId = "default_notification_channel_id",
    String channelName = "Default Notification Channel",
    String? description,
    String? groupId,
    Importance? importance,
    List<int>? vibratePattern,
    Color? ledColor,
    AudioAttributesUsage? audioAttributesUsage,
  }) async {
    await Nylo.localNotifications(
        (FlutterLocalNotificationsPlugin localNotifications) async {
      if (Platform.isIOS) {
        await localNotifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions();
        return;
      }
      if (Platform.isAndroid) {
        await localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        return;
      }

      throw Exception("Platform not supported");
    });
  }

  /// Clear badge count
  static clearBadgeCount() async {
    await clearBadgeNumber();
  }
}

/// Push notification helper
PushNotification pushNotification(String title, String body) =>
    PushNotification(title: title, body: body);
