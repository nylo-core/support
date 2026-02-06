import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Configuration options specific to Android notifications.
///
/// This class encapsulates all Android-specific notification settings,
/// making it easier to configure and pass Android notification options.
class AndroidNotificationConfig {
  /// The channel ID for the notification.
  final String? channelId;

  /// The channel name for the notification.
  final String? channelName;

  /// The channel description for the notification.
  final String? channelDescription;

  /// The importance level of the notification.
  final Importance? importance;

  /// The priority of the notification.
  final Priority? priority;

  /// The ticker text for accessibility.
  final String? ticker;

  /// The small icon resource name.
  final String? icon;

  /// Whether to play a sound.
  final bool? playSound;

  /// Whether to enable vibration.
  final bool? enableVibration;

  /// Custom vibration pattern in milliseconds.
  final List<int>? vibrationPattern;

  /// The group key for grouping notifications.
  final String? groupKey;

  /// Whether this notification is the group summary.
  final bool? setAsGroupSummary;

  /// The alert behavior for grouped notifications.
  final GroupAlertBehavior? groupAlertBehavior;

  /// Whether to auto-cancel when tapped.
  final bool? autoCancel;

  /// Whether the notification is ongoing (cannot be dismissed).
  final bool? ongoing;

  /// Whether the notification is silent.
  final bool? silent;

  /// The accent color for the notification.
  final Color? color;

  /// The large icon resource path.
  final String? largeIcon;

  /// Whether to only alert once.
  final bool? onlyAlertOnce;

  /// Whether to show the timestamp.
  final bool? showWhen;

  /// Custom timestamp in milliseconds since epoch.
  final int? when;

  /// Whether to use chronometer display.
  final bool? usesChronometer;

  /// Whether the chronometer counts down.
  final bool? chronometerCountDown;

  /// Whether to show badge on the channel.
  final bool? channelShowBadge;

  /// Whether to show progress indicator.
  final bool? showProgress;

  /// Maximum progress value.
  final int? maxProgress;

  /// Current progress value.
  final int? progress;

  /// Whether progress is indeterminate.
  final bool? indeterminate;

  /// The action to take on the notification channel.
  final AndroidNotificationChannelAction? channelAction;

  /// Whether to enable notification lights.
  final bool? enableLights;

  /// The LED light color.
  final Color? ledColor;

  /// LED on duration in milliseconds.
  final int? ledOnMs;

  /// LED off duration in milliseconds.
  final int? ledOffMs;

  /// The visibility of the notification on lock screen.
  final NotificationVisibility? visibility;

  /// Auto-dismiss timeout in milliseconds.
  final int? timeoutAfter;

  /// Whether to launch as full screen intent.
  final bool? fullScreenIntent;

  /// The shortcut ID for the notification.
  final String? shortcutId;

  /// Additional flags for the notification.
  final List<int>? additionalFlags;

  /// The tag for the notification.
  final String? tag;

  /// Action buttons for the notification.
  final List<AndroidNotificationAction>? actions;

  /// Whether the notification is colorized.
  final bool? colorized;

  /// The audio attributes usage type.
  final AudioAttributesUsage? audioAttributesUsage;

  /// Creates an [AndroidNotificationConfig] with the specified options.
  const AndroidNotificationConfig({
    this.channelId,
    this.channelName,
    this.channelDescription,
    this.importance,
    this.priority,
    this.ticker,
    this.icon,
    this.playSound,
    this.enableVibration,
    this.vibrationPattern,
    this.groupKey,
    this.setAsGroupSummary,
    this.groupAlertBehavior,
    this.autoCancel,
    this.ongoing,
    this.silent,
    this.color,
    this.largeIcon,
    this.onlyAlertOnce,
    this.showWhen,
    this.when,
    this.usesChronometer,
    this.chronometerCountDown,
    this.channelShowBadge,
    this.showProgress,
    this.maxProgress,
    this.progress,
    this.indeterminate,
    this.channelAction,
    this.enableLights,
    this.ledColor,
    this.ledOnMs,
    this.ledOffMs,
    this.visibility,
    this.timeoutAfter,
    this.fullScreenIntent,
    this.shortcutId,
    this.additionalFlags,
    this.tag,
    this.actions,
    this.colorized,
    this.audioAttributesUsage,
  });

  /// Creates a copy of this config with the specified fields replaced.
  AndroidNotificationConfig copyWith({
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
  }) {
    return AndroidNotificationConfig(
      channelId: channelId ?? this.channelId,
      channelName: channelName ?? this.channelName,
      channelDescription: channelDescription ?? this.channelDescription,
      importance: importance ?? this.importance,
      priority: priority ?? this.priority,
      ticker: ticker ?? this.ticker,
      icon: icon ?? this.icon,
      playSound: playSound ?? this.playSound,
      enableVibration: enableVibration ?? this.enableVibration,
      vibrationPattern: vibrationPattern ?? this.vibrationPattern,
      groupKey: groupKey ?? this.groupKey,
      setAsGroupSummary: setAsGroupSummary ?? this.setAsGroupSummary,
      groupAlertBehavior: groupAlertBehavior ?? this.groupAlertBehavior,
      autoCancel: autoCancel ?? this.autoCancel,
      ongoing: ongoing ?? this.ongoing,
      silent: silent ?? this.silent,
      color: color ?? this.color,
      largeIcon: largeIcon ?? this.largeIcon,
      onlyAlertOnce: onlyAlertOnce ?? this.onlyAlertOnce,
      showWhen: showWhen ?? this.showWhen,
      when: when ?? this.when,
      usesChronometer: usesChronometer ?? this.usesChronometer,
      chronometerCountDown: chronometerCountDown ?? this.chronometerCountDown,
      channelShowBadge: channelShowBadge ?? this.channelShowBadge,
      showProgress: showProgress ?? this.showProgress,
      maxProgress: maxProgress ?? this.maxProgress,
      progress: progress ?? this.progress,
      indeterminate: indeterminate ?? this.indeterminate,
      channelAction: channelAction ?? this.channelAction,
      enableLights: enableLights ?? this.enableLights,
      ledColor: ledColor ?? this.ledColor,
      ledOnMs: ledOnMs ?? this.ledOnMs,
      ledOffMs: ledOffMs ?? this.ledOffMs,
      visibility: visibility ?? this.visibility,
      timeoutAfter: timeoutAfter ?? this.timeoutAfter,
      fullScreenIntent: fullScreenIntent ?? this.fullScreenIntent,
      shortcutId: shortcutId ?? this.shortcutId,
      additionalFlags: additionalFlags ?? this.additionalFlags,
      tag: tag ?? this.tag,
      actions: actions ?? this.actions,
      colorized: colorized ?? this.colorized,
      audioAttributesUsage: audioAttributesUsage ?? this.audioAttributesUsage,
    );
  }

  /// Returns the default Android notification configuration.
  static AndroidNotificationConfig get defaults =>
      const AndroidNotificationConfig(
        channelId: 'default_channel',
        channelName: 'Default Channel',
        channelDescription: 'Default Channel',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        playSound: true,
        enableVibration: true,
        groupAlertBehavior: GroupAlertBehavior.all,
        autoCancel: true,
        showWhen: true,
        channelShowBadge: true,
      );
}
