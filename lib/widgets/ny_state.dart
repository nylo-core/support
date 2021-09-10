import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nylo_support/router/models/ny_argument.dart';
import 'package:nylo_support/router/router.dart';
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

  /// Initialize your widget in [widgetDidLoad].
  ///
  /// * [widgetDidLoad] is called after the [initState] method.
  widgetDidLoad() async {}

  /// Pop the current widget from the stack.
  pop({dynamic result}) {
    Navigator.of(context).pop(result);
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
}
