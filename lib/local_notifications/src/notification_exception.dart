/// Exception thrown when a notification operation fails.
class NotificationException implements Exception {
  /// The error message describing what went wrong.
  final String message;

  /// Creates a [NotificationException] with the given [message].
  const NotificationException(this.message);

  @override
  String toString() => 'NotificationException: $message';
}
