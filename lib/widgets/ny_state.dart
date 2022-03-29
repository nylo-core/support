import 'package:flutter/material.dart';
import 'package:nylo_support/alerts/toast_enums.dart';
import 'package:nylo_support/alerts/toast_notification.dart';
import 'package:nylo_support/exceptions/validation_exception.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'package:nylo_support/localization/app_localization.dart';
import 'package:nylo_support/router/models/ny_argument.dart';
import 'package:nylo_support/router/router.dart';
import 'package:nylo_support/validation/rules.dart';
import 'package:page_transition/page_transition.dart';

abstract class NyState<T extends StatefulWidget> extends State<T> {
  /// Helper to get the [TextTheme].
  TextTheme get textTheme => Theme.of(context).textTheme;

  /// Helper to get the [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(context);

  @override
  void initState() {
    super.initState();
    this.widgetDidLoad();
  }

  void dispose() {
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  /// Initialize your widget in [widgetDidLoad].
  ///
  /// * [widgetDidLoad] is called after the [initState] method.
  widgetDidLoad() async {}

  /// Pop the current widget from the stack.
  pop({dynamic result}) {
    Navigator.of(context).pop(result);

    this.validator(
        rules: {"title": "required|email", "body": "required|string"},
        data: {});
  }

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
  /// See more https://nylo.dev/docs/2.x/validation
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

  /// Navigate to a new route in your /routes/router.dart.
  ///
  /// It requires a String [routeName] e.g. "/my-route"
  ///
  /// Optional variables in [data] that you can pass in [dynamic] objects to
  /// the next widget you navigate to.
  ///
  /// [navigationType] can be assigned with the following:
  /// NavigationType.push, NavigationType.pushReplace,
  /// NavigationType.pushAndRemoveUntil or NavigationType.popAndPushNamed
  ///
  /// [pageTransitionType] allows you to assign a transition type for when
  /// navigating to the new route. E.g. [PageTransitionType.fade] or
  /// [PageTransitionType.bottomToTop].
  /// See https://pub.dev/packages/page_transition to learn more.
  routeTo(String routeName,
      {dynamic data,
      NavigationType navigationType = NavigationType.push,
      dynamic result,
      bool Function(Route<dynamic> route)? removeUntilPredicate,
      Duration? transitionDuration,
      PageTransitionType? pageTransition,
      Function(dynamic value)? onPop}) {
    NyArgument nyArgument = NyArgument(data);
    NyNavigator.instance.router
        .navigate(
          routeName,
          args: nyArgument,
          navigationType: navigationType,
          result: result,
          removeUntilPredicate: removeUntilPredicate,
          pageTransitionType: pageTransition,
        )
        .then((v) => onPop != null ? onPop(v) : (v) {});
  }

  /// Perform an action when the application's [env] is in a certain state
  ///
  /// E.g. Inside in your .env file your APP_ENV='production'
  /// Call the method like the below example.
  ///
  /// whenEnv('production', perform: () {
  /// .. perform any action you need to in production
  /// });
  whenEnv(String env, {required Function() perform, bool shouldSetState = true}) async {
    if (getEnv('APP_ENV') != env) {
      return;
    }
    
    if (perform is Future) {
      await perform();  
    } else {
      perform();
    }

    if (shouldSetState) {
      setState(() {});
    }
  }
}
