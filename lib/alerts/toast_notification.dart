import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import '/alerts/default_toast_notification.dart';
import '/alerts/toast_meta.dart';
import '/helpers/backpack.dart';
import '/nylo.dart';

/// Display a new Toast notification to the user.
/// Provide a valid [ToastNotificationStyleType]
/// i.e. [ToastNotificationStyleType.SUCCESS]
/// Set a title, description to personalise the message.
void showToastNotification(BuildContext context,
    {ToastNotificationStyleType? style,
    String? title,
    IconData? icon,
    String? description,
    Duration? duration}) {
  ToastNotificationStyleMetaHelper toastNotificationStyleMetaHelper =
      ToastNotificationStyleMetaHelper(style);
  ToastMeta toastMeta = toastNotificationStyleMetaHelper.getValue();

  Nylo nylo = Backpack.instance.nylo();

  Widget? toastNotificationWidget;

  if (nylo.toastNotification != null) {
    toastNotificationWidget = nylo.toastNotification!(
        style: style ?? ToastNotificationStyleType.custom,
        toastNotificationStyleMeta: (meta) {
          toastNotificationStyleMetaHelper = meta;
          ToastMeta toastNotificationMeta =
              toastNotificationStyleMetaHelper.getValue();
          if (title != null) {
            toastNotificationMeta.title = title;
          }
          if (description != null) {
            toastNotificationMeta.description = description;
          }
          return toastNotificationMeta;
        },
        onDismiss: () {
          ToastManager().dismissAll(showAnim: true);
        });
  }

  if (title != null) {
    toastMeta.title = title;
  }

  if (description != null) {
    toastMeta.description = description;
  }

  // show the toast notification
  showToastWidget(
    toastNotificationWidget ??
        DefaultToastNotification(
          toastMeta,
          onDismiss: () {
            ToastManager().dismissAll(showAnim: true);
          },
        ),
    context: context,
    isIgnoring: false,
    position: StyledToastPosition.top,
    animation: StyledToastAnimation.slideFromTopFade,
    duration: duration ?? toastMeta.duration,
  );
}
