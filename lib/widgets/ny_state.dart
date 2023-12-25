import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:nylo_support/event_bus/event_bus_plus.dart';
import 'package:flutter/material.dart';
import 'package:nylo_support/alerts/toast_notification.dart';
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'package:nylo_support/localization/app_localization.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/validation/ny_validator.dart';
import 'package:nylo_support/widgets/event_bus/update_state.dart';
import 'package:nylo_support/widgets/ny_stateful_widget.dart';

abstract class NyState<T extends StatefulWidget> extends State<T> {
  /// Base NyState
  NyState({String? path}) : stateName = path;

  /// Helper to get the [TextTheme].
  TextTheme get textTheme => Theme.of(context).textTheme;

  /// Helper to get the [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(context);

  /// Helper to get the [EventBus].
  EventBus? get eventBus => Backpack.instance.read("event_bus");

  /// Get data from the [NyStatefulWidget] controller.
  dynamic data({String? key}) {
    if (widget is NyStatefulWidget) {
      return (widget as NyStatefulWidget).controller.data(key: key);
    }
    return null;
  }

  /// The [stateName] is used as the ID for the [UpdateState] class.
  String? stateName;

  /// The [stateData] contains the last value set from a `updateState()` call.
  dynamic stateData;

  /// If set, the [boot] method will not be called.
  bool requiresBoot = true;

  /// Check if the [initState] has already been loaded.
  bool initialLoad = true;

  /// Check if the state should listen for events via the [EventBus].
  bool get allowStateUpdates => stateName != null && eventBus != null;

  /// Contains a map for all the loading keys.
  Map<String, bool> _loadingMap = {};

  /// Contains a map for all the locked states.
  Map<String, bool> _lockMap = {};

  @override
  void initState() {
    super.initState();

    /// Set the state name if the widget is a NyStatefulWidget
    if (widget is NyStatefulWidget) {
      stateName = (widget as NyStatefulWidget).controller.state;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initialLoad = false;
      if (allowStateUpdates) {
        List<EventBusHistoryEntry> eventHistory = eventBus!.history
            .where((element) =>
                element.event.runtimeType.toString() == 'UpdateState')
            .toList();
        if (eventHistory.isNotEmpty) {
          stateData = eventHistory.last.event.props[1];
        }
        eventBus!.on<UpdateState>().listen((event) async {
          if (event.stateName != stateName) return;

          await stateUpdated(event.data);
          setState(() {});
        });
      }
      await this.init();
    });
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
      default:
        {}
    }
  }

  void dispose() {
    super.dispose();
    _lockMap = {};
    _loadingMap = {};
  }

  /// Notify the framework that the internal state of this object has changed.
  ///
  /// Whenever you change the internal state of a [State] object, make the
  /// change in a function that you pass to [setState]:
  ///
  /// ```dart
  /// setState(() { _myState = newValue; });
  /// ```
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  /// Initialize your widget in [init].
  ///
  /// * [init] is called in the [initState] method.
  /// This method is async so you can call methods that are Futures.
  init() async {
    if (!requiresBoot) {
      return;
    }
    awaitData(
      perform: () async {
        await boot();
      },
      shouldSetStateBefore: false,
    );
  }

  /// Reboot your widget.
  ///
  /// This method will re-call the boot command to 'reboot' your widget.
  reboot() async {
    awaitData(
      perform: () async {
        await boot();
      },
      shouldSetStateBefore: false,
    );
  }

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

  /// Pop the current widget from the stack.
  pop({dynamic result}) {
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  /// Show a toast notification
  showToast(
      {ToastNotificationStyleType style = ToastNotificationStyleType.SUCCESS,
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
  showToastSorry(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    showToast(
        title: title ?? "Sorry",
        description: description,
        style: style ?? ToastNotificationStyleType.DANGER);
  }

  /// Displays a Toast message containing "Warning" for the title, you
  /// only need to provide a [description].
  showToastWarning(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    showToast(
        title: title ?? "Warning",
        description: description,
        style: style ?? ToastNotificationStyleType.WARNING);
  }

  /// Displays a Toast message containing "Info" for the title, you
  /// only need to provide a [description].
  showToastInfo(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    showToast(
        title: title ?? "Info",
        description: description,
        style: style ?? ToastNotificationStyleType.INFO);
  }

  /// Displays a Toast message containing "Error" for the title, you
  /// only need to provide a [description].
  showToastDanger(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    showToast(
        title: title ?? "Error",
        description: description,
        style: style ?? ToastNotificationStyleType.DANGER);
  }

  /// Displays a Toast message containing "Oops" for the title, you
  /// only need to provide a [description].
  showToastOops(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    showToast(
        title: title ?? "Oops",
        description: description,
        style: style ?? ToastNotificationStyleType.DANGER);
  }

  /// Displays a Toast message containing "Success" for the title, you
  /// only need to provide a [description].
  showToastSuccess(
      {String? title,
      required String description,
      ToastNotificationStyleType? style}) {
    showToast(
        title: title ?? "Success",
        description: description,
        style: style ?? ToastNotificationStyleType.SUCCESS);
  }

  /// Display a custom Toast message.
  showToastCustom(
      {String? title, String? description, ToastNotificationStyleType? style}) {
    showToast(
        title: title ?? "",
        description: description ?? "",
        style: style ?? ToastNotificationStyleType.CUSTOM);
  }

  /// Validate data from your widget.
  validate(
      {required Map<String, dynamic> rules,
      Map<String, dynamic>? data,
      Map<String, dynamic>? messages,
      bool showAlert = true,
      Duration? alertDuration,
      ToastNotificationStyleType alertStyle =
          ToastNotificationStyleType.WARNING,
      required Function()? onSuccess,
      Function(Exception exception)? onFailure,
      String? lockRelease}) {
    if (!mounted) return;

    Map<String, String> finalRules = {};
    Map<String, dynamic> finalData = {};
    Map<String, dynamic> finalMessages = messages ?? {};

    rules.forEach((key, value) {
      if (value is List) {
        assert(value.length < 4,
            'Validation rules can contain a maximum of 3 items. E.g. "email": [emailData, "add|validation|rules", "my message"]');
        finalRules[key] = value[1];
        finalData[key] = value[0];
        if (value.length == 3) {
          finalMessages[key] = value[2];
        }
      } else {
        finalRules[key] = value;
      }
    });

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
          NyLogger.error(exception.toString());
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
  changeLanguage(String language, {bool restartState = true}) async {
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
  whenEnv(String env,
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
  awaitData(
      {String name = 'default',
      required Function perform,
      bool shouldSetStateBefore = true,
      bool shouldSetStateAfter = true}) async {
    _updateLoadingState(
        shouldSetState: shouldSetStateBefore, name: name, value: true);

    try {
      await perform();
    } on Exception catch (e) {
      NyLogger.error(e.toString());
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
  _updateLoadingState(
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
  _setLoader(String name, {required bool value}) {
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
  _setLock(String name, {required bool value}) {
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
  lockRelease(String name,
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
  _updateLockState(
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
    if (initialLoad == true || isLoading(name: loadingKey ?? "default")) {
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
  setLoading(bool value, {String name = 'default', bool resetState = true}) {
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
  ///  }, title: "Confirm Action", dismissText: "Cancel");
  confirmAction(Function() action,
      {required String title, String dismissText = "Cancel"}) {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
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
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              action();
            },
            child: Text(
              title,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              dismissText.tr(),
            ),
          ),
        ],
      ),
    );
  }
}
