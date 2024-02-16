import 'dart:core';
import 'package:flutter/material.dart';
import '/alerts/toast_enums.dart';

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
  Map<String, dynamic>? metaData;
  ToastMeta(
      {this.icon,
      required this.title,
      required this.style,
      required this.description,
      this.color,
      this.action,
      this.dismiss,
      this.duration = const Duration(seconds: 2),
      this.metaData});

  /// Pre-defined style for the [ToastNotificationStyleType.SUCCESS] toast alert.
  ToastMeta.success(
      {Color? backgroundColor,
      String? description,
      String? title,
      Duration? duration,
      Function? action,
      Map<String, dynamic>? metaData,
      icon = const Icon(Icons.check, color: Colors.green, size: 20)})
      : icon = icon,
        title = title ?? "Success",
        description = description ?? "",
        color = backgroundColor ?? Colors.green.shade50,
        duration = duration ?? const Duration(seconds: 5),
        action = action,
        style = 'success',
        metaData = metaData,
        super();

  /// Pre-defined style for the [ToastNotificationStyleType.WARNING] toast alert.
  ToastMeta.warning({
    Color? backgroundColor,
    String? description,
    String? title,
    Duration? duration,
    Function? action,
    Map<String, dynamic>? metaData,
    icon = const Icon(Icons.error_outline, color: Colors.orange, size: 20),
  })  : icon = icon,
        title = "Oops!",
        description = "",
        color = Colors.orange.shade50,
        duration = const Duration(seconds: 6),
        action = action,
        style = 'warning',
        metaData = metaData,
        super();

  /// Pre-defined style for the [ToastNotificationStyleType.INFO] toast alert.
  ToastMeta.info({
    Color? backgroundColor,
    String? description,
    String? title,
    Duration? duration,
    Function? action,
    Map<String, dynamic>? metaData,
    icon = const Icon(Icons.info, color: Colors.teal, size: 20),
  })  : icon = icon,
        title = "Info",
        description = "",
        color = Colors.teal.shade50,
        duration = const Duration(seconds: 5),
        action = action,
        style = 'info',
        metaData = metaData,
        super();

  /// Pre-defined style for the [ToastNotificationStyleType.DANGER] toast alert.
  ToastMeta.danger({
    Color? backgroundColor,
    String? description,
    String? title,
    Duration? duration,
    Function? action,
    Map<String, dynamic>? metaData,
    icon = const Icon(Icons.warning, color: Colors.redAccent, size: 20),
  })  : icon = icon,
        title = "Oops!",
        description = "",
        color = Colors.red.shade50,
        duration = const Duration(seconds: 7),
        action = action,
        style = 'danger',
        metaData = metaData,
        super();

  /// Pre-defined style for the [ToastNotificationStyleType.CUSTOM] toast alert.
  ToastMeta.custom({
    Color? backgroundColor,
    String? description,
    String? title,
    Duration? duration,
    Function? action,
    Map<String, dynamic>? metaData,
    icon = const Icon(Icons.warning, color: Colors.redAccent, size: 20),
  })  : icon = icon,
        title = "",
        description = "",
        color = Colors.red.shade50,
        duration = const Duration(seconds: 7),
        action = action,
        style = 'custom',
        metaData = metaData,
        super();

  /// ToastMeta.copyWith() is used to copy the current toast alert and
  /// override the values.
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
