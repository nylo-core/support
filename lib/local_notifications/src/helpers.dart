import 'package:nylo_support/local_notifications/src/local_notification.dart'
    show LocalNotification;

/// Creates a new [LocalNotification] with the given [title] and [body].
///
/// This is a convenience function for quickly creating notifications.
///
/// Example:
/// ```dart
/// await localNotification('Hello', 'World').send();
/// ```
LocalNotification localNotification(String title, String body) =>
    LocalNotification(title: title, body: body);

/// Creates a new [LocalNotification] with the given [title] and [body].
///
/// This is a backwards-compatible alias for [localNotification].
@Deprecated('Use localNotification instead')
LocalNotification pushNotification(String title, String body) =>
    LocalNotification(title: title, body: body);
