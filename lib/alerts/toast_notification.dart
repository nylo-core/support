import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:nylo_support/alerts/toast_enums.dart';
import 'package:nylo_support/localization/app_localization.dart';

/// ToastNotificationStyleMetaHelper is used to return
/// the correct value for the [ToastNotificationStyleType] toast style.
class _ToastNotificationStyleMetaHelper {
  static _ToastMeta getValue(ToastNotificationStyleType? style) {
    switch (style) {
      case null:
      case ToastNotificationStyleType.SUCCESS:
        return _ToastMeta(
            icon: const Icon(Icons.check, color: Colors.white, size: 30),
            title: "Success",
            description: "",
            color: Colors.green,
            action: () {
              ToastManager().dismissAll(showAnim: true);
            },
            duration: const Duration(seconds: 5));
      case ToastNotificationStyleType.WARNING:
        return _ToastMeta(
            icon:
                const Icon(Icons.error_outline, color: Colors.white, size: 30),
            title: "Oops!",
            description: "",
            color: Colors.orange,
            action: () {
              ToastManager().dismissAll(showAnim: true);
            },
            duration: const Duration(seconds: 6));
      case ToastNotificationStyleType.INFO:
        return _ToastMeta(
            icon: const Icon(Icons.info, color: Colors.white, size: 30),
            title: "Info",
            description: "",
            color: Colors.teal,
            action: () {
              ToastManager().dismissAll(showAnim: true);
            },
            duration: const Duration(seconds: 5));
      case ToastNotificationStyleType.DANGER:
        return _ToastMeta(
            icon: const Icon(Icons.warning, color: Colors.white, size: 30),
            title: "Oops!",
            description: "",
            color: Colors.redAccent,
            action: () {
              ToastManager().dismissAll(showAnim: true);
            },
            duration: const Duration(seconds: 7));
      default:
        return _ToastMeta(
            icon: const Icon(Icons.check, color: Colors.white, size: 30),
            title: "Success",
            description: "",
            color: Colors.green,
            action: () {
              ToastManager().dismissAll(showAnim: true);
            },
            duration: const Duration(seconds: 5));
    }
  }
}

/// Toast Meta makes it easy to use pre-defined styles in the toast alert.
class _ToastMeta {
  Widget icon;
  String title;
  String description;
  Color color;
  Function? action;
  Duration duration;
  _ToastMeta(
      {required this.icon,
      required this.title,
      required this.description,
      required this.color,
      this.action,
      this.duration = const Duration(seconds: 2)});
}

/// Display a new Toast notification to the user.
/// Provide a valid [ToastNotificationStyleType]
/// i.e. [ToastNotificationStyleType.SUCCESS]
/// Set a title, description to personalise the message.
showToastNotification(BuildContext context,
    {ToastNotificationStyleType? style,
    String? title,
    IconData? icon,
    String description = "",
    Duration? duration}) {
  _ToastMeta toastMeta = _ToastNotificationStyleMetaHelper.getValue(style);
  toastMeta.title = toastMeta.title;
  if (title != null) {
    toastMeta.title = title;
  }
  toastMeta.description = description;

  Widget _icon = toastMeta.icon;
  if (icon != null) {
    _icon = Icon(icon, color: Colors.white);
  }

  // show the toast notification
  showToastWidget(
    Stack(children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 18.0),
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        height: 100,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          color: toastMeta.color,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Pulse(
              child: Container(
                child: Center(
                  child: IconButton(
                    onPressed: () {},
                    icon: _icon,
                    padding: EdgeInsets.only(right: 16),
                  ),
                ),
              ),
              infinite: true,
              duration: Duration(milliseconds: 1500),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    toastMeta.title.tr(),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: Colors.white),
                  ),
                  Text(
                    toastMeta.description.tr(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: IconButton(
            onPressed: () {
              ToastManager().dismissAll(showAnim: true);
            },
            icon: Icon(
              Icons.close,
              color: Colors.white,
            )),
      )
    ]),
    context: context,
    isIgnoring: false,
    position: StyledToastPosition.top,
    animation: StyledToastAnimation.slideFromTopFade,
    duration: duration ?? toastMeta.duration,
  );
}
