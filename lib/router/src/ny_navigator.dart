import 'package:flutter/material.dart';

import 'ny_router.dart';
import 'models/ny_argument.dart';

/// The NyNavigator class is a singleton class that manages the routing of the
/// application. It is a thin layer on top of [Navigator] to help you encapsulate
/// and manage routing at one place.
class NyNavigator {
  NyRouter router = NyRouter();
  NyNavigator._privateConstructor();

  static final NyNavigator instance = NyNavigator._privateConstructor();

  /// Update the stack on the router.
  /// [routes] is a list of routes to navigate to. E.g. [HomePage.path, SettingPage.path]
  /// [replace] is a boolean that determines if the current route should be replaced.
  /// [dataForRoute] is a map of data to pass to the route. E.g. {HomePage.path: {"name": "John Doe"}}
  /// Example:
  /// ```dart
  /// Nylo.updateStack([
  ///  HomePage.path,
  ///  SettingPage.path
  ///  ], replace: true, dataForRoute: {
  ///  HomePage.path: {"name": "John Doe"}
  ///  });
  ///  ```
  ///  This will navigate to the HomePage and SettingPage with the data passed to the HomePage.
  static void updateStack(
    List<String> routes, {
    bool replace = true,
    Map<String, dynamic>? dataForRoute,
  }) {
    for (var route in routes) {
      dynamic data;
      if (dataForRoute != null && dataForRoute.containsKey(route)) {
        data = dataForRoute[route];
      }

      if (routes.first == route && replace == true) {
        instance.router.navigate(
          route,
          navigationType: NavigationType.pushAndForgetAll,
          args: NyArgument(data),
        );
        continue;
      }
      instance.router.navigate(
        route,
        navigationType: NavigationType.push,
        args: NyArgument(data),
      );
    }
  }

  /// Prefix routes
  Map<String, String> prefixRoutes = {};
}
