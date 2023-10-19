import 'package:flutter/material.dart';
import 'package:nylo_support/controllers/controller.dart';
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/widgets/ny_state.dart';
import 'package:nylo_support/widgets/ny_stateful_widget.dart';
import '/helpers/helper.dart';

class _State extends NyState<NyPage> {
  _State(
      {required Widget Function(BuildContext context) child,
      void Function()? init,
      void Function()? boot,
      Widget Function(BuildContext context)? loading,
      String? stateName}) {
    _child = child;
    _init = init;
    _boot = boot;
    _loading = loading;
    if (stateName != null) {
      this.stateName = stateName;
    }
  }

  Widget Function(BuildContext context)? _loading;
  late Widget Function(BuildContext context) _child;

  Function()? _init, _boot;

  stateUpdated(dynamic data) async {
    if (data['action'] == null) return;

    dynamic stateData = {};
    if (data['data'] != null) {
      stateData = data['data'];
    }
    switch (data['action']) {
      case 'refresh-page':
        {
          Function()? _setState = stateData['setState'];
          if (_setState != null) {
            this.setState(() {
              _setState();
            });
            return;
          }
          reboot();
          break;
        }
      case 'validate':
        {
          validate(
              rules: stateData['rules'],
              data: stateData['data'],
              onSuccess: stateData['onSuccess'],
              messages: stateData['messages'],
              showAlert: stateData['showAlert'],
              alertDuration: stateData['alertDuration'],
              alertStyle: stateData['alertStyle'],
              onFailure: stateData['onFailure'],
              lockRelease: stateData['lockRelease']);
          break;
        }
      case 'toast-success':
        {
          showToastSuccess(
              title: stateData['title'],
              description: stateData['description'],
              style: stateData['style']);
          break;
        }
      case 'toast-warning':
        {
          showToastWarning(
              title: stateData['title'],
              description: stateData['description'],
              style: stateData['style']);
          break;
        }
      case 'toast-info':
        {
          showToastInfo(
              title: stateData['title'],
              description: stateData['description'],
              style: stateData['style']);
          break;
        }
      case 'toast-danger':
        {
          showToastDanger(
              title: stateData['title'],
              description: stateData['description'],
              style: stateData['style']);
          break;
        }
      case 'toast-custom':
        {
          showToastCustom(
              title: stateData['title'],
              description: stateData['description'],
              style: stateData['style']);
          break;
        }
      case 'toast-custom':
        {
          showToastCustom(
              title: stateData['title'],
              description: stateData['description'],
              style: stateData['style']);
          break;
        }
      case 'change-language':
        {
          changeLanguage(stateData['language'],
              restartState: stateData['restartState']);
          break;
        }
      default:
        {}
    }
  }

  @override
  init() async {
    super.init();
    if (_init != null) {
      await _init!();
    }
  }

  @override
  boot() async {
    if (_boot != null) {
      await _boot!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_boot != null) {
      if (_loading != null) {
        return afterLoad(
            child: () => _child(context), loading: _loading!(context));
      }
      return Scaffold(
        body: afterLoad(
          child: () => _child(context),
        ),
      );
    }
    return _child(context);
  }
}

class NyPage<T extends BaseController> extends NyStatefulWidget<T> {
  /// Path name for the Page
  static String path = "/";

  /// Contains the loading widget from your config/design.dart file
  Widget get loadingWidget => backpack.nylo().appLoader;

  /// Instance of the [Backpack] class
  Backpack get backpack => Backpack.instance;

  /// Context of the state
  BuildContext get context => controller!.context!;

  /// Helper to get the [TextTheme].
  TextTheme get textTheme => Theme.of(context).textTheme;

  /// Helper to get the [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(context);

  @override
  createState() {
    return _State(
        child: build,
        init: init,
        boot: boot,
        loading: loading,
        stateName: path);
  }

  /// Build your UI
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }

  /// This widget is used whenever your widget uses the [boot]
  /// method to load data. When data is loading via a Future in
  /// the boot method, this widget will be displayed to the user.
  ///
  /// You can override it in your [NyPage] class to custom the look.
  Widget loading(BuildContext context) {
    return Scaffold(
      body: loadingWidget,
    );
  }

  /// Initialize your widget in [init].
  ///
  /// * [init] is called in the [initState] method.
  /// This method is async so you can call methods that are Futures.
  init() async {}

  /// The [boot] method called within [init].
  /// You may override this method for making asynchronous awaits.
  /// In your [build] method, you can use the [afterLoad] method
  /// like in the below example.
  /// @override
  ///   Widget build(BuildContext context) {
  ///     return Scaffold(
  ///       body: SafeAreaWidget(
  ///        child: afterLoad(child: () => Container()
  ///        )
  ///     );
  ///  }
  /// This will then only display the widget after the boot method has completed.
  boot() async {}

  /// Refresh the page
  void refreshPage({Function()? setState}) {
    updateState(path, data: {
      "action": "refresh-page",
      "data": {"setState": setState}
    });
  }

  /// Displays a Toast message containing "Sorry" for the title, you
  /// only need to provide a [description].
  void showToastSorry(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    updateState(path, data: {
      "action": "toast-sorry",
      "data": {
        "title": (title ?? "Sorry"),
        "description": description,
        "style": style ?? ToastNotificationStyleType.DANGER
      }
    });
  }

  /// Displays a Toast message containing "Warning" for the title, you
  /// only need to provide a [description].
  void showToastWarning(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    updateState(path, data: {
      "action": "toast-warning",
      "data": {
        "title": title ?? "Warning",
        "description": description,
        "style": style ?? ToastNotificationStyleType.WARNING
      }
    });
  }

  /// Displays a Toast message containing "Info" for the title, you
  /// only need to provide a [description].
  void showToastInfo(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    updateState(path, data: {
      "action": "toast-info",
      "data": {
        "title": title ?? "Info",
        "description": description,
        "style": style ?? ToastNotificationStyleType.INFO
      }
    });
  }

  /// Displays a Toast message containing "Error" for the title, you
  /// only need to provide a [description].
  void showToastDanger(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    updateState(path, data: {
      "action": "toast-danger",
      "data": {
        "title": title ?? "Error",
        "description": description,
        "style": style ?? ToastNotificationStyleType.DANGER
      }
    });
  }

  /// Displays a Toast message containing "Oops" for the title, you
  /// only need to provide a [description].
  void showToastOops(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    updateState(path, data: {
      "action": "toast-oops",
      "data": {
        "title": title ?? "Oops",
        "description": description,
        "style": style ?? ToastNotificationStyleType.DANGER
      }
    });
  }

  /// Displays a Toast message containing "Success" for the title, you
  /// only need to provide a [description].
  void showToastSuccess(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    updateState(path, data: {
      "action": "toast-success",
      "data": {
        "title": title ?? "Success",
        "description": description,
        "style": style ?? ToastNotificationStyleType.SUCCESS
      }
    });
  }

  /// Display a custom Toast message.
  void showToastCustom(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    updateState(path, data: {
      "action": "toast-custom",
      "data": {
        "title": title ?? "",
        "description": description,
        "style": style ?? ToastNotificationStyleType.CUSTOM
      }
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
    updateState(path, data: {
      "action": "validate",
      "data": {
        "rules": rules,
        "data": data,
        "messages": messages,
        "showAlert": showAlert,
        "alertDuration": alertDuration,
        "alertStyle": alertStyle,
        "onSuccess": onSuccess,
        "onFailure": onFailure,
        "lockRelease": lockRelease,
      }
    });
  }

  /// Update the language in the application
  void changeLanguage(String language, {bool restartState = true}) {
    updateState(path, data: {
      "action": "change-language",
      "data": {"language": language, "restartState": restartState}
    });
  }
}
