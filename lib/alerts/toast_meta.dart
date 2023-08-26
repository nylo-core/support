import 'dart:core';
import 'package:flutter/material.dart';
import 'package:nylo_support/alerts/toast_enums.dart';

/// Toast Meta makes it easy to use pre-defined styles in the toast alert.
class ToastMeta {
  Widget? icon;
  String title;
  String style;
  String description;
  Color? color;
  Function? action;
  Function? dismiss;
  Duration duration;
  ToastMeta(
      {this.icon,
      required this.title,
      required this.style,
      required this.description,
      this.color,
      this.action,
      this.dismiss,
      this.duration = const Duration(seconds: 2)});

  ToastMeta.success({
    Color? backgroundColor,
    String? description,
    String? title,
    Duration? duration,
    Function? action,
  })  : icon = const Icon(Icons.check, color: Colors.white, size: 30),
        title = title ?? "Success",
        description = description ?? "",
        color = backgroundColor ?? Colors.green,
        duration = duration ?? const Duration(seconds: 5),
        action = action ?? null,
        style = 'success',
        super();

  ToastMeta.warning({
    Color? backgroundColor,
    String? description,
    String? title,
    Duration? duration,
    Function? action,
  })  : icon = const Icon(Icons.error_outline, color: Colors.white, size: 30),
        title = "Oops!",
        description = "",
        color = Colors.orange,
        duration = const Duration(seconds: 6),
        action = action ?? null,
        style = 'warning',
        super();

  ToastMeta.info({
    Color? backgroundColor,
    String? description,
    String? title,
    Duration? duration,
    Function? action,
  })  : icon = const Icon(Icons.info, color: Colors.white, size: 30),
        title = "Info",
        description = "",
        color = Colors.teal,
        duration = const Duration(seconds: 5),
        action = action ?? null,
        style = 'info',
        super();

  ToastMeta.danger({
    Color? backgroundColor,
    String? description,
    String? title,
    Duration? duration,
    Function? action,
  })  : icon = const Icon(Icons.warning, color: Colors.white, size: 30),
        title = "Oops!",
        description = "",
        color = Colors.redAccent,
        duration = const Duration(seconds: 7),
        action = action ?? null,
        style = 'danger',
        super();

  ToastMeta.custom({
    Color? backgroundColor,
    String? description,
    String? title,
    Duration? duration,
    Function? action,
  })  : icon = const Icon(Icons.warning, color: Colors.white, size: 30),
        title = "",
        description = "",
        color = Colors.redAccent,
        duration = const Duration(seconds: 7),
        action = action ?? null,
        style = 'custom',
        super();

  ToastMeta copyWith(
      {Widget? icon,
      String? title,
      String? style,
      String? description,
      Color? color,
      Function? action,
      Function? dismiss,
      Duration? duration}) {
    return this;
  }
}

/// ToastNotificationStyleMetaHelper is used to return
/// the correct value for the [ToastNotificationStyleType] toast style.
class ToastNotificationStyleMetaHelper {
  ToastNotificationStyleMetaHelper(ToastNotificationStyleType? style)
      : _style = style;

  ToastNotificationStyleType? _style;

  ToastMeta onSuccess() {
    return ToastMeta.success();
  }

  ToastMeta onWarning() {
    return ToastMeta.warning();
  }

  ToastMeta onInfo() {
    return ToastMeta.info();
  }

  ToastMeta onDanger() {
    return ToastMeta.danger();
  }

  ToastMeta onCustom() {
    return ToastMeta(title: "", description: "", style: "custom");
  }

  ToastMeta getValue() {
    switch (_style) {
      case ToastNotificationStyleType.SUCCESS:
        return onSuccess();
      case ToastNotificationStyleType.WARNING:
        return onWarning();
      case ToastNotificationStyleType.INFO:
        return onInfo();
      case ToastNotificationStyleType.DANGER:
        return onDanger();
      default:
        return onSuccess();
    }
  }
}
