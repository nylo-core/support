import 'package:flutter/material.dart';
import 'package:nylo_support/alerts/toast_notification.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'package:nylo_support/localization/app_localization.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/themes/base_color_styles.dart';
import 'package:nylo_support/themes/base_theme_config.dart';
import 'package:nylo_support/validation/rules.dart';

abstract class NyState<T extends StatefulWidget> extends State<T> {
  /// Helper to get the [TextTheme].
  TextTheme get textTheme => Theme.of(context).textTheme;

  /// Helper to get the [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(context);

  /// Helper to get the [MediaQueryData].
  BaseColorStyles color({String? themeId}) {
    Nylo nylo = Backpack.instance.read('nylo');
    BaseThemeConfig baseThemeConfig = nylo.appThemes.firstWhere(
        (theme) => theme.id == (themeId ?? getEnv('LIGHT_THEME_ID')),
        orElse: () => nylo.appThemes.first);
    return baseThemeConfig.colors;
  }

  @override
  void initState() {
    super.initState();
    this.init();
  }

  void dispose() {
    super.dispose();
    _lockMap = {};
    _loadingMap = {};
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  /// Initialize your widget in [init].
  ///
  /// * [init] is called in the [initState] method.
  /// This method is async so you can call methods that are Futures.
  init() async {}

  /// Pop the current widget from the stack.
  pop({dynamic result}) {
    Navigator.of(context).pop(result);
  }

  /// Show a toast notification
  showToast(
      {ToastNotificationStyleType style = ToastNotificationStyleType.SUCCESS,
      required String title,
      required String description,
      IconData? icon,
      Duration? duration}) {
    showToastNotification(context,
        style: style,
        title: title,
        description: description,
        icon: icon,
        duration: duration);
  }

  /// This validator method provides an easy way to validate data.
  /// You can use this method like the example below:
  /// try {
  ///   this.validator(rules: {
  ///     "email": "email|max:20",
  ///     "name": "min:10"
  ///   }, data: {
  ///     "email": _textEditingEmailController.text,
  ///     "name": _textEditingNameController.text
  ///   });
  ///
  /// } on ValidationException catch (e) {
  ///   print(e.validationRule.description);
  ///   print(e.toString());
  /// }
  /// See more https://nylo.dev/docs/3.x/validation
  validator(
      {required Map<String, String> rules,
      required Map<String, dynamic> data,
      Map<String, dynamic> messages = const {},
      bool showAlert = true,
      Duration? alertDuration,
      ToastNotificationStyleType alertStyle =
          ToastNotificationStyleType.WARNING}) {
    Map<String, Map<String, dynamic>> map = data.map((key, value) {
      if (!rules.containsKey(key)) {
        throw new Exception('Missing rule: ' + key);
      }
      Map<String, dynamic> tmp = {"data": value, "rule": rules[key]};
      if (messages.containsKey(key)) {
        tmp.addAll({"message": messages[key]});
      }
      return MapEntry(key, tmp);
    });

    for (int i = 0; i < map.length; i++) {
      String attribute = map.keys.toList()[i];
      Map<String, dynamic> info = map[attribute]!;

      dynamic data = info['data'];

      String rule = info['rule'];
      List<String> rules = rule.split("|").toList();

      if (rule.contains("nullable") && (data == null || data == "")) {
        continue;
      }

      List<ValidationRule?> validationRules = [
        EmailRule(attribute),
        BooleanRule(attribute),
        ContainsRule(attribute),
        URLRule(attribute),
        StringRule(attribute),
        MaxRule(attribute),
        MinRule(attribute),
      ];

      for (rule in rules) {
        ValidationRule? validationRule =
            validationRules.firstWhere((validationRule) {
          if (validationRule!.signature == rule) {
            return true;
          }
          if (rule.contains(":")) {
            String firstSection = rule.split(":").first;
            return validationRule.signature == firstSection;
          }
          return false;
        }, orElse: () => null);
        if (validationRule == null) {
          continue;
        }
        bool hasFailed = validationRule.handle(info);
        if (hasFailed == false) {
          if (showAlert == true) {
            validationRule.alert(context,
                style: alertStyle, duration: alertDuration);
          }
          throw new ValidationException(attribute, validationRule);
        }
      }
    }
  }

  /// Update the language in the application
  changeLanguage(String language, {bool restartState = true}) async {
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

  Map<String, bool> _loadingMap = {};

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
      bool shouldSetState = true}) async {
    _updateLoadingState(
        shouldSetState: shouldSetState, name: name, value: true);

    try {
      await perform();
    } on Exception catch (e) {
      if (getEnv('APP_DEBUG', defaultValue: true) == true) {
        print(e.toString());
      }
    }

    _updateLoadingState(
        shouldSetState: shouldSetState, name: name, value: false);
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

  Map<String, bool> _lockMap = {};

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
      if (getEnv('APP_DEBUG', defaultValue: true) == true) {
        print(e.toString());
      }
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
}
