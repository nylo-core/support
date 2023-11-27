import 'package:flutter/material.dart';
import 'package:nylo_support/alerts/toast_enums.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'controller.dart';

/// Base NyController
class NyController extends BaseController {
  BuildContext? context;
  NyRequest? request;
  String? state;
  NyController({this.context, this.request}) : super(context: context);

  /// Updates the page [state]
  /// Provide an [action] and [data] to call a method in the [NyState].
  void updatePageState(String action, dynamic data) {
    assert(state != null, "State cannot be null");
    if (state == null) return;
    updateState(state!, data: {"action": action, "data": data});
  }

  /// Refreshes the page
  refreshPage() {
    updatePageState("refresh-page", {"setState": () {}});
  }

  /// Displays a Toast message containing "Sorry" for the title, you
  /// only need to provide a [description].
  void showToastSorry(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    updatePageState("toast-sorry", {
      "title": title ?? "Sorry",
      "description": description,
      "style": style ?? ToastNotificationStyleType.DANGER
    });
  }

  /// Displays a Toast message containing "Warning" for the title, you
  /// only need to provide a [description].
  void showToastWarning(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    updatePageState("toast-warning", {
      "title": title ?? "Warning",
      "description": description,
      "style": style ?? ToastNotificationStyleType.WARNING
    });
  }

  /// Displays a Toast message containing "Info" for the title, you
  /// only need to provide a [description].
  void showToastInfo(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    updatePageState("toast-info", {
      "title": title ?? "Info",
      "description": description,
      "style": style ?? ToastNotificationStyleType.INFO
    });
  }

  /// Displays a Toast message containing "Error" for the title, you
  /// only need to provide a [description].
  void showToastDanger(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    updatePageState("toast-danger", {
      "title": title ?? "Error",
      "description": description,
      "style": style ?? ToastNotificationStyleType.DANGER
    });
  }

  /// Displays a Toast message containing "Oops" for the title, you
  /// only need to provide a [description].
  void showToastOops(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    updatePageState("toast-oops", {
      "title": title ?? "Oops",
      "description": description,
      "style": style ?? ToastNotificationStyleType.DANGER
    });
  }

  /// Displays a Toast message containing "Success" for the title, you
  /// only need to provide a [description].
  void showToastSuccess(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    updatePageState("toast-success", {
      "title": title ?? "Success",
      "description": description,
      "style": style ?? ToastNotificationStyleType.SUCCESS
    });
  }

  /// Display a custom Toast message.
  void showToastCustom(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    updatePageState("toast-custom", {
      "title": title ?? "",
      "description": description,
      "style": style ?? ToastNotificationStyleType.CUSTOM
    });
  }

  /// Validate data from your widget.
  void validate(
      {required Map<String, String> rules,
      required Map<String, dynamic> data,
      Map<String, dynamic> messages = const {},
      bool showAlert = true,
      Duration? alertDuration,
      ToastNotificationStyleType alertStyle =
          ToastNotificationStyleType.WARNING,
      required Function()? onSuccess,
      Function(Exception exception)? onFailure,
      String? lockRelease}) {
    updatePageState("validate", {
      "rules": rules,
      "data": data,
      "messages": messages,
      "showAlert": showAlert,
      "alertDuration": alertDuration,
      "alertStyle": alertStyle,
      "onSuccess": onSuccess,
      "onFailure": onFailure,
      "lockRelease": lockRelease,
    });
  }

  /// Update the language in the application
  void changeLanguage(String language, {bool restartState = true}) {
    updatePageState("change-language", {
      "language": language,
      "restartState": restartState,
    });
  }

  /// Perform a lock release
  void lockRelease(String name,
      {required Function perform, bool shouldSetState = true}) async {
    updatePageState("lock-release",
        {"name": name, "perform": perform, "shouldSetState": shouldSetState});
  }
}