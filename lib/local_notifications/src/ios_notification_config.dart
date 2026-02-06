import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Configuration options specific to iOS notifications.
///
/// This class encapsulates all iOS-specific notification settings,
/// making it easier to configure and pass iOS notification options.
class IOSNotificationConfig {
  /// Whether to present the notification in the notification list.
  final bool? presentList;

  /// Whether to present an alert for the notification.
  final bool? presentAlert;

  /// Whether to update the app badge.
  final bool? presentBadge;

  /// Whether to play a sound.
  final bool? presentSound;

  /// Whether to present a banner.
  final bool? presentBanner;

  /// The sound file name to play.
  final String? sound;

  /// The badge number to display.
  final int? badgeNumber;

  /// The thread identifier for grouping notifications.
  final String? threadIdentifier;

  /// The category identifier for notification actions.
  final String? categoryIdentifier;

  /// The interruption level of the notification.
  final InterruptionLevel? interruptionLevel;

  /// Creates an [IOSNotificationConfig] with the specified options.
  const IOSNotificationConfig({
    this.presentList,
    this.presentAlert,
    this.presentBadge,
    this.presentSound,
    this.presentBanner,
    this.sound,
    this.badgeNumber,
    this.threadIdentifier,
    this.categoryIdentifier,
    this.interruptionLevel,
  });

  /// Creates a copy of this config with the specified fields replaced.
  IOSNotificationConfig copyWith({
    bool? presentList,
    bool? presentAlert,
    bool? presentBadge,
    bool? presentSound,
    bool? presentBanner,
    String? sound,
    int? badgeNumber,
    String? threadIdentifier,
    String? categoryIdentifier,
    InterruptionLevel? interruptionLevel,
  }) {
    return IOSNotificationConfig(
      presentList: presentList ?? this.presentList,
      presentAlert: presentAlert ?? this.presentAlert,
      presentBadge: presentBadge ?? this.presentBadge,
      presentSound: presentSound ?? this.presentSound,
      presentBanner: presentBanner ?? this.presentBanner,
      sound: sound ?? this.sound,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      threadIdentifier: threadIdentifier ?? this.threadIdentifier,
      categoryIdentifier: categoryIdentifier ?? this.categoryIdentifier,
      interruptionLevel: interruptionLevel ?? this.interruptionLevel,
    );
  }

  /// Returns the default iOS notification configuration.
  static IOSNotificationConfig get defaults => const IOSNotificationConfig(
    presentList: true,
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    presentBanner: true,
  );
}
