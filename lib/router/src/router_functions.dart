import 'package:flutter/material.dart';

import '/helpers/ny_helpers.dart';
import 'ny_router.dart';
import 'ny_navigator.dart';
import 'models/ny_argument.dart';
import 'models/ny_page_transition_settings.dart';
import 'page_transition/page_transition.dart';

/// Navigate to a new route.
///
/// It requires a String [routeName] e.g. ProfilePage.path or "/my-route"
///
/// Optional variables in [data] that you can pass in [dynamic] objects to
/// the next widget you navigate to.
///
/// [navigationType] can be assigned with the following:
/// NavigationType.push, NavigationType.pushReplace,
/// NavigationType.pushAndRemoveUntil, NavigationType.popAndPushNamed or
/// NavigationType.pushAndForgetAll.
///
/// [transitionType] allows you to assign a transition type for when
/// navigating to the new route. E.g. [TransitionType.fade()] or
/// [TransitionType.bottomToTop()].
/// See https://pub.dev/packages/page_transition to learn more.
Future<void> routeTo(
  dynamic routeName, {
  dynamic data,
  Map<String, dynamic>? queryParameters,
  NavigationType navigationType = NavigationType.push,
  dynamic result,
  bool Function(Route<dynamic> route)? removeUntilPredicate,
  TransitionType? transitionType,
  @Deprecated(
    'Use transitionType instead to specify the page transition type.\nE.g. TransitionType.fadeIn()',
  )
  PageTransitionType? pageTransitionType,
  @Deprecated(
    'Use transitionType instead to specify the page transition settings.\nE.g. TransitionType.fadeIn(curve: Curves.easeIn)',
  )
  PageTransitionSettings? pageTransitionSettings,
  int? tabIndex,
  Function(dynamic value)? onPop,
}) async {
  if (routeName is RouteView) {
    routeName = routeName.$1;
  }

  if (transitionType != null) {
    pageTransitionType = transitionType.pageTransitionType;
    pageTransitionSettings = transitionType.pageTransitionSettings;
  }

  if (tabIndex != null) {
    if (data != null) {
      assert(data is Map, "Data must be of type Map");
      (data as Map<String, dynamic>).addAll({"tab-index": tabIndex});
    } else {
      data = {"tab-index": tabIndex};
    }
  }

  NyArgument nyArgument = NyArgument(data);
  if (queryParameters != null) {
    routeName = Uri(
      path: routeName,
      queryParameters: queryParameters,
    ).toString();
  }

  await NyNavigator.instance.router
      .navigate(
        routeName,
        args: nyArgument,
        navigationType: navigationType,
        result: result,
        removeUntilPredicate: removeUntilPredicate,
        pageTransitionType: pageTransitionType,
        pageTransitionSettings: pageTransitionSettings,
      )
      .then((v) => onPop != null ? onPop(v) : (v) {});
}

/// Navigate to a new route if a condition is met.
/// If the condition is false, the route will not be navigated to.
Future<void> routeIf(
  bool condition,
  dynamic routeName, {
  dynamic data,
  Map<String, dynamic>? queryParameters,
  NavigationType navigationType = NavigationType.push,
  dynamic result,
  bool Function(Route<dynamic> route)? removeUntilPredicate,
  TransitionType? transitionType,
  @Deprecated(
    'Use transitionType instead to specify the page transition type.\nE.g. TransitionType.fadeIn()',
  )
  PageTransitionType? pageTransitionType,
  @Deprecated(
    'Use transitionType instead to specify the page transition type.\nE.g. TransitionType.fadeIn()',
  )
  PageTransitionSettings? pageTransitionSettings,
  Function(dynamic value)? onPop,
}) async {
  if (!condition) return;
  await routeTo(
    routeName,
    data: data,
    queryParameters: queryParameters,
    navigationType: navigationType,
    result: result,
    removeUntilPredicate: removeUntilPredicate,
    transitionType: transitionType,
    // ignore: deprecated_member_use_from_same_package
    pageTransitionSettings: pageTransitionSettings,
    // ignore: deprecated_member_use_from_same_package
    pageTransitionType: pageTransitionType,
    onPop: onPop,
  );
}

/// Navigate to the auth route.
Future<void> routeToAuthenticatedRoute({
  dynamic data,
  NavigationType navigationType = NavigationType.pushAndForgetAll,
  dynamic result,
  bool Function(Route<dynamic> route)? removeUntilPredicate,
  TransitionType? transitionType,
  @Deprecated(
    'Use transitionType instead to specify the page transition type.\nE.g. TransitionType.fadeIn()',
  )
  PageTransitionType? pageTransitionType,
  @Deprecated(
    'Use transitionType instead to specify the page transition type.\nE.g. TransitionType.fadeIn()',
  )
  PageTransitionSettings? pageTransitionSettings,
  Function(dynamic value)? onPop,
}) async {
  NyArgument nyArgument = NyArgument(data);
  String? route = NyNavigator.instance.router.getAuthRouteName();
  if (route == null) {
    NyLogger.debug("No authenticated route set");
    return;
  }
  await NyNavigator.instance.router
      .navigate(
        route,
        args: nyArgument,
        navigationType: navigationType,
        result: result,
        removeUntilPredicate: removeUntilPredicate,
        transitionType: transitionType,
        pageTransitionType: pageTransitionType,
        pageTransitionSettings: pageTransitionSettings,
      )
      .then((v) => onPop != null ? onPop(v) : (v) {});
}

/// Navigate to the initial route.
Future<void> routeToInitial({
  dynamic data,
  NavigationType navigationType = NavigationType.pushAndForgetAll,
  dynamic result,
  bool Function(Route<dynamic> route)? removeUntilPredicate,
  TransitionType? transitionType,
  @Deprecated(
    'Use transitionType instead to specify the page transition type.\nE.g. TransitionType.fadeIn()',
  )
  PageTransitionType? pageTransitionType,
  @Deprecated(
    'Use transitionType instead to specify the page transition type.\nE.g. TransitionType.fadeIn()',
  )
  PageTransitionSettings? pageTransitionSettings,
  Function(dynamic value)? onPop,
}) async {
  NyArgument nyArgument = NyArgument(data);
  String route = NyNavigator.instance.router.getInitialRouteName();

  await NyNavigator.instance.router
      .navigate(
        route,
        args: nyArgument,
        navigationType: navigationType,
        result: result,
        removeUntilPredicate: removeUntilPredicate,
        transitionType: transitionType,
        pageTransitionType: pageTransitionType,
        pageTransitionSettings: pageTransitionSettings,
      )
      .then((v) => onPop != null ? onPop(v) : (v) {});
}
