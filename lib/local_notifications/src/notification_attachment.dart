/// Represents an attachment for a notification.
///
/// Attachments are primarily used on iOS to include images,
/// audio, or video with notifications.
class NotificationAttachment {
  /// The URL to download the attachment from.
  final String url;

  /// The file name to save the attachment as.
  final String fileName;

  /// Whether to show a thumbnail preview of the attachment.
  final bool? showThumbnail;

  /// Creates a [NotificationAttachment] with the given parameters.
  const NotificationAttachment(
    this.url,
    this.fileName, {
    this.showThumbnail = true,
  });
}

/// Backwards compatibility alias for [NotificationAttachment].
@Deprecated('Use NotificationAttachment instead')
typedef PushNotificationAttachments = NotificationAttachment;
