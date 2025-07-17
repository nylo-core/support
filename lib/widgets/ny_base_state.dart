import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '/events/events.dart';
import '/helpers/ny_color.dart';
import '/helpers/loading_style.dart';
import '/helpers/extensions.dart';
import 'package:theme_provider/theme_provider.dart';
import '/themes/base_theme_config.dart';
import '/validation/rules.dart';
import '/widgets/ny_form.dart';
import '/controllers/controller.dart';
import '/router/models/ny_argument.dart';
import '/event_bus/event_bus_plus.dart';
import 'package:flutter/material.dart';
import '/alerts/toast_notification.dart';
import '/helpers/backpack.dart';
import '/helpers/helper.dart';
import '/localization/app_localization.dart';
import '/nylo.dart';
import '/validation/ny_validator.dart';
import '/widgets/event_bus/update_state.dart';
import '/widgets/ny_stateful_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '/helpers/ny_logger.dart';

import 'form/validation.dart';

abstract class NyBaseState<T extends StatefulWidget> extends State<T> {
  /// Base NyState
  NyBaseState({String? path}) : stateName = path;

  /// Helper to get the [TextTheme].
  TextTheme get textTheme => Theme.of(context).textTheme;

  /// Helper to get the [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(context);

  /// Helper to get the [EventBus].
  EventBus? get eventBus => Backpack.instance.read("event_bus");

  /// Check if the [initState] has already been loaded.
  bool hasInitComplete = false;

  /// The [stateName] is used as the ID for the [UpdateState] class.
  String? stateName;

  /// The [stateData] contains the last value set from a `updateState()` call.
  dynamic stateData;

  /// Define the [LoadingStyle] for the widget.
  LoadingStyle get loadingStyle => LoadingStyle.normal();

  /// Check if the state should listen for events via the [EventBus].
  bool get allowStateUpdates => stateName != null && eventBus != null;

  /// Contains a map for all the loading keys.
  Map<String, bool> _loadingMap = {};

  /// Contains a map for all the locked states.
  Map<String, bool> _lockMap = {};

  /// The [eventSubscription] is used to listen for [UpdateState] events.
  StreamSubscription? eventSubscription;

  /// Check if the widget should be loaded.
  bool get shouldLoadView => (init is Future Function());

  /// Override the loading state.
  bool overrideLoading = false;

  /// Keep track of event subscriptions
  final List<NyEventSubscription> _eventSubscriptions = [];

  /// Listen to an event with a callback function
  /// Returns a subscription reference that can be used to cancel later
  NyEventSubscription listen<E extends NyEvent>(Function(Map? data) callback) {
    final listener = NyEventCallbackListener(callback);
    NyEventBus().on<E>(listener);
    final subscription = NyEventSubscription<E>(listener);
    _eventSubscriptions.add(subscription);
    return subscription;
  }

  /// Initialize your widget in [init].
  ///
  /// * [init] is called in the [initState] method.
  /// You can use this method to perform any operations before the widget is
  /// rendered.
  ///
  /// E.g.
  /// ```
  /// get init => () async {
  ///   await api<ApiService>((request) => request.fetchData());
  ///   setState(() {});
  /// };
  /// ```
  Function() get init => () {
        // Add your init code here
      };

  /// Get data from the [NyStatefulWidget] controller.
  // ignore: avoid_shadowing_type_parameters
  T? data<T>({dynamic defaultValue}) {
    if (widget is NyStatefulWidget) {
      return (widget as NyStatefulWidget)
          .controller
          .data(defaultValue: defaultValue);
    }
    return null;
  }

  /// Get queryParameters from the [NyStatefulWidget] controller.
  dynamic queryParameters({String? key}) {
    if (widget is NyStatefulWidget) {
      return (widget as NyStatefulWidget).controller.queryParameters(key: key);
    }
    return null;
  }

  /// Check if the [queryParameters] contains a specific key.
  bool hasQueryParameter(String key) {
    final queryParametersData = queryParameters();
    if (queryParametersData == null) return false;
    if (queryParametersData is Map) {
      return queryParametersData.containsKey(key);
    }
    return false;
  }

  /// When you call [updateState], this method will be called within your
  /// State. The [data] parameter will contain any data passed from the
  /// updateState method.
  ///
  /// E.g.
  /// updateState('my_state', data: "Hello World");
  ///
  /// stateUpdated(dynamic data) {
  ///   data = "Hello World"
  /// }
  Future<void> stateUpdated(dynamic data) async {
    if (data is! Map) return;
    if (!data.containsKey('action') || data['action'] == null) return;
    dynamic stateData = {};
    if (data['data'] != null) {
      stateData = data['data'];
    }
    switch (data['action']) {
      case 'refresh-page':
        {
          Function()? setStateData = stateData['setState'];
          if (setStateData != null) {
            setStateData();
            setState(() {});
            return;
          }
          reboot();
          break;
        }
      case 'pop':
        {
          dynamic result = stateData['result'];
          if (result != null) {
            pop(result: result);
            return;
          }
          pop();
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
      case 'toast-oops':
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
      case 'toast-sorry':
        {
          showToastSorry(
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
      case 'lock-release':
        {
          lockRelease(stateData['name'],
              perform: stateData['perform'],
              shouldSetState: stateData['shouldSetState']);
          break;
        }
      case 'confirm-action':
        {
          confirmAction(stateData['action'],
              title: stateData['title'], dismissText: stateData['dismissText']);
          break;
        }
      case 'set-state':
        {
          Function()? setStateData = stateData['setState'];
          if (setStateData != null) {
            setState(() {
              setStateData();
            });
            return;
          }
        }
      default:
        {}
    }
  }

  @override
  void dispose() {
    eventSubscription?.cancel();
    _lockMap = {};
    _loadingMap = {};

    for (var subscription in _eventSubscriptions) {
      subscription.cancel();
    }
    _eventSubscriptions.clear();

    super.dispose();
  }

  /// Reboot your widget.
  ///
  /// This method will re-call the boot command to 'reboot' your widget.
  Future<void> reboot() async {
    awaitData(
      perform: () async {
        await init();
      },
      shouldSetStateBefore: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!shouldLoadView && overrideLoading == false) {
      return view(context);
    }

    if (hasInitComplete == false || isLoading()) {
      switch (loadingStyle.type) {
        case LoadingStyleType.normal:
          {
            if (loadingStyle.child != null) {
              return loadingStyle.child!;
            }
            return Nylo.appLoader();
          }
        case LoadingStyleType.skeletonizer:
          {
            if (loadingStyle.child != null) {
              return Skeletonizer(
                enabled: true,
                child: loadingStyle.child!,
              );
            }
            return Skeletonizer(
              enabled: true,
              child: view(context),
            );
          }
        case LoadingStyleType.none:
          return view(context);
      }
    }
    return view(context);
  }

  /// Display your widget.
  Widget view(BuildContext context) {
    throw UnimplementedError();
  }

  /// Pop the current widget from the stack.
  void pop({dynamic result}) {
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  /// Show a toast notification
  void showToast(
      {ToastNotificationStyleType style = ToastNotificationStyleType.success,
      required String title,
      required String description,
      IconData? icon,
      Duration? duration}) {
    if (!mounted) return;
    showToastNotification(
      context,
      style: style,
      title: title,
      description: description,
      icon: icon,
      duration: duration,
    );
  }

  /// Displays a Toast message containing "Sorry" for the title, you
  /// only need to provide a [description].
  void showToastSorry(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    showToast(
        title: title ?? "Sorry",
        description: description,
        style: style ?? ToastNotificationStyleType.danger);
  }

  /// Displays a Toast message containing "Warning" for the title, you
  /// only need to provide a [description].
  void showToastWarning(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    showToast(
        title: title ?? "Warning",
        description: description,
        style: style ?? ToastNotificationStyleType.warning);
  }

  /// Displays a Toast message containing "Info" for the title, you
  /// only need to provide a [description].
  void showToastInfo(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    showToast(
        title: title ?? "Info",
        description: description,
        style: style ?? ToastNotificationStyleType.info);
  }

  /// Displays a Toast message containing "Error" for the title, you
  /// only need to provide a [description].
  void showToastDanger(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    showToast(
        title: title ?? "Error",
        description: description,
        style: style ?? ToastNotificationStyleType.danger);
  }

  /// Displays a Toast message containing "Oops" for the title, you
  /// only need to provide a [description].
  void showToastOops(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    showToast(
        title: title ?? "Oops",
        description: description,
        style: style ?? ToastNotificationStyleType.danger);
  }

  /// Displays a Toast message containing "Success" for the title, you
  /// only need to provide a [description].
  void showToastSuccess(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    showToast(
        title: title ?? "Success",
        description: description,
        style: style ?? ToastNotificationStyleType.success);
  }

  /// Display a custom Toast message.
  void showToastCustom(
      {String? title, String? description, ToastNotificationStyleType? style}) {
    showToast(
        title: title ?? "",
        description: description ?? "",
        style: style ?? ToastNotificationStyleType.custom);
  }

  /// Validate data from your widget.
  void validate(
      {required Map<String, dynamic> rules,
      Map<String, dynamic>? data,
      Map<String, dynamic>? messages,
      bool showAlert = true,
      Duration? alertDuration,
      ToastNotificationStyleType alertStyle =
          ToastNotificationStyleType.warning,
      required Function()? onSuccess,
      Function(Exception exception)? onFailure,
      String? lockRelease}) {
    if (!mounted) return;

    Map<String, String> finalRules = {};
    Map<String, dynamic> finalData = {};
    Map<String, dynamic> finalMessages = messages ?? {};

    bool completed = false;
    for (MapEntry rule in rules.entries) {
      String key = rule.key;
      dynamic value = rule.value;

      if (value is FormValidator) {
        FormValidator formValidator = value;

        if (formValidator.customRule != null) {
          bool passed = formValidator.customRule!(formValidator.data);
          if (!passed) {
            ValidationRule customRule = ValidationRule(
              signature: "FormValidator.custom",
              textFieldMessage: formValidator.message,
              title: formValidator.message ?? "Invalid data",
            );
            ValidationException exception =
                ValidationException(key, customRule);
            NyLogger.error(exception.toString());
            if (onFailure == null) return;
            onFailure(exception);
            completed = true;
            break;
          }
        }

        if (formValidator.rules == null) continue;
        finalRules[key] = formValidator.rules;
        finalData[key] = formValidator.data;
        if (formValidator.message != null) {
          finalMessages[key] = formValidator.message;
        }
        continue;
      }

      if (value is List) {
        assert(value.length < 4,
            'Validation rules can contain a maximum of 3 items. E.g. "email": [emailData, "add|validation|rules", "my message"]');
        finalRules[key] = value[1];
        finalData[key] = value[0];
        if (value.length == 3) {
          finalMessages[key] = value[2];
        }
      } else {
        if (value != null) {
          finalRules[key] = value;
        }
      }
    }

    if (completed) return;

    if (data != null) {
      data.forEach((key, value) {
        finalData.addAll({key: value});
      });
    }

    if (lockRelease != null) {
      this.lockRelease(lockRelease, perform: () async {
        try {
          NyValidator.check(
            rules: finalRules,
            data: finalData,
            messages: finalMessages,
            context: context,
            showAlert: showAlert,
            alertDuration: alertDuration,
            alertStyle: alertStyle,
          );

          if (onSuccess == null) return;
          await onSuccess();
        } on Exception catch (exception) {
          if (onFailure == null) return;
          onFailure(exception);
        }
      });
      return;
    }
    try {
      NyValidator.check(
        rules: finalRules,
        data: finalData,
        messages: finalMessages,
        context: context,
        showAlert: showAlert,
        alertDuration: alertDuration,
        alertStyle: alertStyle,
      );

      if (onSuccess == null) return;
      onSuccess();
    } on Exception catch (exception) {
      NyLogger.error(exception.toString());
      if (onFailure == null) return;
      onFailure(exception);
    }
  }

  /// Update the language in the application
  Future<void> changeLanguage(String language,
      {bool restartState = true}) async {
    if (!mounted) return;
    await NyLocalization.instance.setLanguage(
      context,
      language: language,
      restart: restartState,
    );
  }

  /// Perform an action when the application's [env] is in a certain state
  ///
  /// E.g. Inside in your .env file your APP_ENV='production'
  /// Call the method like the below example.
  ///
  /// whenEnv('production', perform: () {
  /// .. perform any action you need to in production
  /// });
  Future<void> whenEnv(String env,
      {required Function perform, bool shouldSetState = true}) async {
    if (getEnv('APP_ENV') != env) {
      return;
    }

    await perform();

    if (shouldSetState) {
      setState(() {});
    }
  }

  /// Use the [awaitData] method when initial fetching data for a widget.
  /// E.g. When your page first loads and you want to populate your widgets with
  /// data.
  ///
  /// init() async {
  ///  awaitData('home', perform: () async {
  ///   ... await fetchApiData();
  ///  });
  /// }
  ///
  /// ... in your widget
  /// Text( isLoading('home') ? 'YES Loading' : 'Loading Finished').
  Future<void> awaitData(
      {String name = 'default',
      required Function perform,
      bool shouldSetStateBefore = true,
      bool shouldSetStateAfter = true}) async {
    _updateLoadingState(
        shouldSetState: shouldSetStateBefore, name: name, value: true);
    overrideLoading = true;
    try {
      await perform();
    } on Exception catch (e) {
      NyLogger.error(e.toString());
    }
    if (widget is NyStatefulWidget &&
        (widget as NyStatefulWidget).controller.routeGuards.isEmpty) {
      hasInitComplete = true;
    }
    _updateLoadingState(
        shouldSetState: shouldSetStateAfter, name: name, value: false);
  }

  /// Checks the value from your loading map.
  /// Provide the [name] of the loader.
  bool isLoading({String name = 'default'}) {
    if (_loadingMap.containsKey(name) == false) {
      _loadingMap[name] = false;
    }
    return _loadingMap[name]!;
  }

  /// Update the loading state.
  void _updateLoadingState(
      {required bool shouldSetState,
      required String name,
      required bool value}) {
    if (shouldSetState == true) {
      setState(() {
        _setLoader(name, value: value);
      });
    } else {
      _setLoader(name, value: value);
    }
  }

  /// Set the state of the loader.
  /// E.g.setLoader('updating_user', value: true);
  ///
  /// Provide a [name] and boolean value.
  void _setLoader(String name, {required bool value}) {
    _loadingMap[name] = value;
  }

  /// Checks the value from your lock map.
  /// Provide the [name] of the lock.
  bool isLocked(String name) {
    if (_lockMap.containsKey(name) == false) {
      _lockMap[name] = false;
    }
    return _lockMap[name]!;
  }

  /// Set the state of the lock.
  /// E.g.setLock('updating_user', value: true);
  ///
  /// Provide a [name] and boolean value.
  void _setLock(String name, {required bool value}) {
    _lockMap[name] = value;
  }

  /// The [lockRelease] method will call the function provided in [perform]
  /// and then block the function from being called again until it has finished.
  ///
  /// E.g.
  /// lockRelease('update', perform: () async {
  ///   await handleSomething();
  /// });
  ///
  /// Use [isLocked] to check if the function is still locked.
  /// E.g.
  /// isLocked('update') // true/false
  Future<void> lockRelease(String name,
      {required Function perform, bool shouldSetState = true}) async {
    if (isLocked(name) == true) {
      return;
    }
    _updateLockState(shouldSetState: shouldSetState, name: name, value: true);

    try {
      await perform();
    } on Exception catch (e) {
      NyLogger.error(e.toString());
    }

    _updateLockState(shouldSetState: shouldSetState, name: name, value: false);
  }

  /// Update the lock state.
  void _updateLockState(
      {required bool shouldSetState,
      required String name,
      required bool value}) {
    if (shouldSetState == true) {
      setState(() {
        _setLock(name, value: value);
      });
    } else {
      _setLock(name, value: value);
    }
  }

  /// The [afterLoad] method will check if the state is loading
  /// If loading it will display the [loading] widget.
  /// You can also specify the name of the [loadingKey].
  Widget afterLoad(
      {required Function() child, Widget? loading, String? loadingKey}) {
    if (isLoading(name: loadingKey ?? "default")) {
      return loading ?? Nylo.appLoader();
    }
    return child();
  }

  /// The [afterNotNull] method will check if the [variable] passed in is null
  /// If the variable is not null, it will display the [loading] widget.
  Widget afterNotNull(dynamic variable,
      {required Function() child, Widget? loading}) {
    if (variable == null) {
      return loading ?? Nylo.appLoader();
    }
    return child();
  }

  /// The [afterNotLocked] method will check if the state is locked,
  /// if the state is locked it will display the [loading] widget.
  Widget afterNotLocked(String name,
      {required Function() child, Widget? loading}) {
    if (isLocked(name)) {
      return loading ?? Nylo.appLoader();
    }
    return child();
  }

  /// Set the value of a loading key by padding a true or false
  void setLoading(bool value,
      {String name = 'default', bool resetState = true}) {
    if (resetState) {
      setState(() {
        _loadingMap[name] = value;
      });
    } else {
      _loadingMap[name] = value;
    }
  }

  /// Allow the user to confirm an [action].
  /// Provide a [title] for the confirm button. You can also provide a
  /// [dismissText] for the cancel button.
  /// E.g.
  /// confirmAction(() {
  ///  ... perform action
  ///  }, title: "Delete account?", dismissText: "Cancel");
  void confirmAction(
    Function() action, {
    required String title,
    String dismissText = "Cancel",
    String confirmText = "Yes",
    CupertinoThemeData? cupertinoThemeData,
    ThemeData? themeData,
    Color barrierColor = kCupertinoModalBarrierColor,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
    bool semanticsDismissible = false,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
  }) {
    if (!kIsWeb && Platform.isIOS) {
      showCupertinoModalPopup(
          barrierColor: barrierColor,
          barrierDismissible: barrierDismissible,
          useRootNavigator: useRootNavigator,
          semanticsDismissible: semanticsDismissible,
          routeSettings: routeSettings,
          anchorPoint: anchorPoint,
          context: context,
          builder: (context) {
            CupertinoActionSheet cupertinoActionSheet = CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                    action();
                  },
                  child: Text(
                    title,
                  ),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                child: Text(
                  dismissText.tr(),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            );
            if (cupertinoThemeData != null) {
              return CupertinoTheme(
                  data: cupertinoThemeData, child: cupertinoActionSheet);
            }
            return cupertinoActionSheet;
          });
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        AlertDialog alertDialog = AlertDialog(
          title: Text(title),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                action();
              },
              child: Text(
                confirmText,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                dismissText.tr(),
              ),
            ),
          ],
        );
        if (themeData != null) {
          return Theme(data: themeData, child: alertDialog);
        }
        return alertDialog;
      },
    );
  }

  /// Push to a new page
  void pushTo(Widget page, {dynamic data, Function(dynamic value)? onPop}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          if (page is NyStatefulWidget) {
            page.controller.request = NyRequest(args: NyArgument(data));
          }
          return page;
        },
      ),
    ).then((value) {
      if (onPop != null) {
        onPop(value);
      }
    });
  }

  /// Get the color based on the device mode
  Color color({Color? light, Color? dark}) {
    return NyColor.resolveColor(context,
        light: light ?? Colors.grey.shade100, dark: dark ?? Colors.black38)!;
  }

  /// Get the state actions
  Map<String, Function> get stateActions => _stateActions;

  /// state actions variable
  Map<String, Function> _stateActions = {};

  /// Handle what happens when an action is called
  /// [actions] is a map of actions
  ///
  /// E.g.
  /// whenStateAction({
  ///  'logout': () async {
  ///     await Auth.logout();
  ///     routeToInitial();
  ///  }
  ///  });
  void whenStateAction(Map<String, Function> actions) {
    _stateActions = actions;
  }

  /// When the theme is in [light] mode, return [light] function, else return [dark] function
  // ignore: avoid_shadowing_type_parameters
  T whenTheme<T>({
    required T Function() light,
    T Function()? dark,
  }) {
    bool isDarkModeEnabled = false;
    ThemeController themeController = ThemeProvider.controllerOf(context);

    if (themeController.currentThemeId == getEnv('DARK_THEME_ID')) {
      isDarkModeEnabled = true;
    }

    if ((themeController.theme.options as NyThemeOptions).meta is Map &&
        (themeController.theme.options as NyThemeOptions).meta['type'] ==
            NyThemeType.dark) {
      isDarkModeEnabled = true;
    }

    if (context.isDeviceInDarkMode) {
      isDarkModeEnabled = true;
    }

    if (isDarkModeEnabled) {
      if (dark != null) {
        return dark();
      }
    }

    return light();
  }
}
