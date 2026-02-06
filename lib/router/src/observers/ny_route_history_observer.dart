import 'package:flutter/cupertino.dart';
import '/nylo.dart';

/// A [NavigatorObserver] that keeps track of the current route.
class NyRouteHistoryObserver extends NavigatorObserver {
  /// Optional external route change callback.
  /// When set, route changes will be forwarded to this callback.
  /// This enables integration with external systems like DevPanelStore.
  ///
  /// The [action] parameter indicates the type of navigation:
  /// - `push`: A new route was pushed onto the navigator
  /// - `pop`: A route was popped from the navigator
  /// - `remove`: A route was removed from the navigator
  /// - `replace`: A route was replaced with another
  ///
  /// Example:
  /// ```dart
  /// NyRouteHistoryObserver.onRouteChange = (action, routeName, {arguments, previousRoute}) {
  ///   DevPanelStore.instance.trackRoute(RouteEntry(
  ///     name: routeName,
  ///     action: RouteAction.values.byName(action),
  ///     arguments: arguments,
  ///     previousRoute: previousRoute,
  ///   ));
  /// };
  /// ```
  static void Function(
    String action,
    String routeName, {
    Object? arguments,
    String? previousRoute,
  })?
  onRouteChange;

  /// Returns true if an external route change callback is registered.
  static bool get hasExternalListener => onRouteChange != null;

  /// Helper to extract route name from a Route object.
  static String? _getRouteName(Route<dynamic>? route) {
    return route?.settings.name;
  }

  /// The [Navigator] pushed `route`.
  ///
  /// The route immediately below that one, and thus the previously active
  /// route, is `previousRoute`.
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    Nylo.addRouteHistory(route);

    // Notify external listener if registered
    final routeName = _getRouteName(route);
    if (hasExternalListener && routeName != null) {
      onRouteChange!(
        'push',
        routeName,
        arguments: route.settings.arguments,
        previousRoute: _getRouteName(previousRoute),
      );
    }
  }

  /// The [Navigator] popped `route`.
  ///
  /// The route immediately below that one, and thus the newly active
  /// route, is `previousRoute`.
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    Nylo.removeLastRouteHistory();

    // Notify external listener if registered
    final routeName = _getRouteName(route);
    if (hasExternalListener && routeName != null) {
      onRouteChange!(
        'pop',
        routeName,
        previousRoute: _getRouteName(previousRoute),
      );
    }
  }

  /// The [Navigator] removed `route`.
  ///
  /// If only one route is being removed, then the route immediately below
  /// that one, if any, is `previousRoute`.
  ///
  /// If multiple routes are being removed, then the route below the
  /// bottommost route being removed, if any, is `previousRoute`, and this
  /// method will be called once for each removed route, from the topmost route
  /// to the bottommost route.
  @override
  void didRemove(Route route, Route? previousRoute) {
    Nylo.removeRouteHistory(route);

    // Notify external listener if registered
    final routeName = _getRouteName(route);
    if (hasExternalListener && routeName != null) {
      onRouteChange!(
        'remove',
        routeName,
        previousRoute: _getRouteName(previousRoute),
      );
    }
  }

  /// The [Navigator] replaced `oldRoute` with `newRoute`.
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (oldRoute != null) {
      Nylo.removeRouteHistory(oldRoute);
    }
    if (newRoute != null) {
      Nylo.addRouteHistory(newRoute);
    }

    // Notify external listener if registered
    final routeName = _getRouteName(newRoute);
    if (hasExternalListener && routeName != null) {
      onRouteChange!(
        'replace',
        routeName,
        arguments: newRoute?.settings.arguments,
        previousRoute: _getRouteName(oldRoute),
      );
    }
  }
}
