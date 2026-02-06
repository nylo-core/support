import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'default_toast_notification.dart';
import 'toast_meta.dart';

/// Convert ToastNotificationPosition to StyledToastPosition
StyledToastPosition _toStyledPosition(ToastNotificationPosition position) {
  switch (position) {
    case ToastNotificationPosition.top:
      return StyledToastPosition.top;
    case ToastNotificationPosition.bottom:
      return StyledToastPosition.bottom;
    case ToastNotificationPosition.center:
      return StyledToastPosition.center;
  }
}

/// Convert ToastNotificationPosition to StyledToastAnimation (position-based default)
StyledToastAnimation _toStyledAnimationFromPosition(
  ToastNotificationPosition position,
) {
  switch (position) {
    case ToastNotificationPosition.top:
      return StyledToastAnimation.slideFromTopFade;
    case ToastNotificationPosition.bottom:
      return StyledToastAnimation.slideFromBottomFade;
    case ToastNotificationPosition.center:
      return StyledToastAnimation.fade;
  }
}

/// Convert ToastAnimationType to StyledToastAnimation
StyledToastAnimation _toStyledAnimationFromType(ToastAnimationType type) {
  switch (type) {
    case ToastAnimationType.fade:
      return StyledToastAnimation.fade;
    case ToastAnimationType.scale:
      return StyledToastAnimation.scale;
    case ToastAnimationType.slideFromTop:
      return StyledToastAnimation.slideFromTop;
    case ToastAnimationType.slideFromTopFade:
      return StyledToastAnimation.slideFromTopFade;
    case ToastAnimationType.slideFromBottom:
      return StyledToastAnimation.slideFromBottom;
    case ToastAnimationType.slideFromBottomFade:
      return StyledToastAnimation.slideFromBottomFade;
    case ToastAnimationType.slideFromLeft:
      return StyledToastAnimation.slideFromLeft;
    case ToastAnimationType.slideFromLeftFade:
      return StyledToastAnimation.slideFromLeftFade;
    case ToastAnimationType.slideFromRight:
      return StyledToastAnimation.slideFromRight;
    case ToastAnimationType.slideFromRightFade:
      return StyledToastAnimation.slideFromRightFade;
    case ToastAnimationType.fadeScale:
      return StyledToastAnimation.fadeScale;
    case ToastAnimationType.rotate:
      return StyledToastAnimation.rotate;
    case ToastAnimationType.fadeRotate:
      return StyledToastAnimation.fadeRotate;
    case ToastAnimationType.none:
      return StyledToastAnimation.none;
  }
}

/// Display a new Toast notification to the user.
/// Provide a valid toast [id] (e.g., "success", "warning", "info", "danger")
/// or a custom ID registered via [Nylo.addToastNotifications].
/// Set a [title] and [description] to personalize the message.
///
/// Optional callbacks:
/// - [action] - Called when the toast is tapped
/// - [onDismiss] - Called when the toast is dismissed (auto or manual)
/// - [onShow] - Called when the toast becomes visible
///
/// Example:
/// ```dart
/// showToastNotification(context, id: "success", description: "Item saved!");
/// showToastNotification(context, id: "customToast", title: "Hello");
/// showToastNotification(context, id: "info", position: ToastNotificationPosition.bottom);
/// showToastNotification(context, id: "warning", onDismiss: () => print("Dismissed!"));
/// ```
void showToastNotification(
  BuildContext context, {
  String id = 'success',
  String? title,
  String? description,
  Duration? duration,
  ToastNotificationPosition? position,
  ToastAnimation? animation,
  VoidCallback? action,
  VoidCallback? onDismiss,
  VoidCallback? onShow,
}) {
  final registry = ToastNotificationRegistry.instance;

  // Create base ToastMeta with user-provided overrides
  ToastMeta toastMeta = ToastMeta(
    title: title ?? '',
    description: description ?? '',
    duration: duration ?? const Duration(seconds: 5),
    position: position ?? ToastNotificationPosition.top,
    animation: animation,
    action: action,
    onDismiss: onDismiss,
    onShow: onShow,
    dismiss: () {
      ToastManager().dismissAll(showAnim: true);
    },
  );

  // Look up the widget factory from the registry
  final factory = registry.get(id);

  Widget toastWidget;
  if (factory != null) {
    // Call factory with callback that lets the widget update meta
    toastWidget = factory(toastMeta, (updated) => toastMeta = updated);
  } else {
    // Fallback to default toast notification if no styles registered
    toastWidget = DefaultToastNotification(toastMeta);
  }

  // Invoke onShow callback when toast is displayed
  toastMeta.onShow?.call();

  // Determine final animation (meta.animation > position-based default)
  final styledAnimation = toastMeta.animation != null
      ? _toStyledAnimationFromType(toastMeta.animation!.type)
      : _toStyledAnimationFromPosition(toastMeta.position);

  // Determine reverse animation if provided
  final reverseStyledAnimation = toastMeta.reverseAnimation != null
      ? _toStyledAnimationFromType(toastMeta.reverseAnimation!.type)
      : null;

  // Show the toast notification (uses potentially updated meta)
  showToastWidget(
    toastWidget,
    context: context,
    isIgnoring: toastMeta.isIgnoring ?? false,
    position: _toStyledPosition(toastMeta.position),
    animation: styledAnimation,
    reverseAnimation: reverseStyledAnimation,
    animDuration: toastMeta.animation?.duration,
    curve: toastMeta.animation?.curve,
    reverseCurve: toastMeta.reverseAnimation?.curve,
    duration: toastMeta.duration,
    onDismiss: toastMeta.onDismiss,
    dismissOtherToast: toastMeta.dismissOtherToast,
    textDirection: toastMeta.textDirection,
    alignment: toastMeta.alignment,
    axis: toastMeta.axis,
    startOffset: toastMeta.startOffset,
    endOffset: toastMeta.endOffset,
    reverseStartOffset: toastMeta.reverseStartOffset,
    reverseEndOffset: toastMeta.reverseEndOffset,
    isHideKeyboard: toastMeta.isHideKeyboard,
    animationBuilder: toastMeta.animationBuilder,
    reverseAnimBuilder: toastMeta.reverseAnimBuilder,
    onInitState: toastMeta.onInitState,
  );
}
