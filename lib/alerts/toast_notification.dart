import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:nylo_support/alerts/toast_enums.dart';

/// ToastNotificationStyleMetaHelper is used to return
/// the correct value for the [ToastNotificationStyleType] toast style.
class ToastNotificationStyleMetaHelper {
  static ToastMeta getValue(ToastNotificationStyleType style) {
    switch (style) {
      case ToastNotificationStyleType.SUCCESS:
        return ToastMeta.success(action: () {
          ToastManager().dismissAll(showAnim: true);
        });
      case ToastNotificationStyleType.WARNING:
        return ToastMeta.warning(action: () {
          ToastManager().dismissAll(showAnim: true);
        });
      case ToastNotificationStyleType.INFO:
        return ToastMeta.info(action: () {
          ToastManager().dismissAll(showAnim: true);
        });
      case ToastNotificationStyleType.DANGER:
        return ToastMeta.danger(action: () {
          ToastManager().dismissAll(showAnim: true);
        });
      default:
        return ToastMeta.success(action: () {
          ToastManager().dismissAll(showAnim: true);
        });
    }
  }
}

/// Toast Meta makes it easy to use pre-defined styles in the toast alert.
class ToastMeta {
  Widget icon;
  String title;
  String description;
  Color color;
  Function? action;
  Duration duration;
  ToastMeta(
      {required this.icon,
      required this.title,
      required this.description,
      required this.color,
      this.action,
      this.duration = const Duration(seconds: 2)});

  /// DEFAULT SUCCESS TOAST META
  ToastMeta.success(
      {this.icon = const Icon(Icons.check, color: Colors.white, size: 30),
      this.title = "Success",
      this.description = "",
      this.color = Colors.green,
      this.action,
      this.duration = const Duration(seconds: 5)});

  /// DEFAULT INFO TOAST META
  ToastMeta.info(
      {this.icon = const Icon(Icons.info, color: Colors.white, size: 30),
      this.title = "",
      this.description = "",
      this.color = Colors.teal,
      this.action,
      this.duration = const Duration(seconds: 5)});

  /// DEFAULT WARNING TOAST META
  ToastMeta.warning(
      {this.icon =
          const Icon(Icons.error_outline, color: Colors.white, size: 30),
      this.title = "Oops!",
      this.description = "",
      this.color = Colors.orange,
      this.action,
      this.duration = const Duration(seconds: 6)});

  /// DEFAULT DANGER TOAST META
  ToastMeta.danger(
      {this.icon = const Icon(Icons.warning, color: Colors.white, size: 30),
      this.title = "Oops!",
      this.description = "",
      this.color = Colors.redAccent,
      this.action,
      this.duration = const Duration(seconds: 7)});
}

/// Display a new Toast notification to the user.
/// Provide a valid [ToastNotificationStyleType]
/// i.e [ToastNotificationStyleType.SUCCESS]
/// Set a title, description to personalise the message.
showToastNotification(BuildContext context,
    {required ToastNotificationStyleType style,
    String? title,
    IconData? icon,
    String description = "",
    Duration? duration}) {
  ToastMeta toastMeta = ToastNotificationStyleMetaHelper.getValue(style);
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
    InkWell(
      onTap: () => ToastManager().dismissAll(showAnim: true),
      child: Container(
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
                    toastMeta.title,
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(color: Colors.white),
                  ),
                  Text(
                    toastMeta.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    context: context,
    isIgnoring: false,
    position: StyledToastPosition.top,
    animation: StyledToastAnimation.slideFromTopFade,
    duration: duration ?? toastMeta.duration,
  );
}
