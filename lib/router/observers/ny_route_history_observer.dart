import 'package:flutter/cupertino.dart';
import '/nylo.dart';

/// A [NavigatorObserver] that keeps track of the current route.
class NyRouteHistoryObserver extends NavigatorObserver {
  /// The [Navigator] pushed `route`.
  ///
  /// The route immediately below that one, and thus the previously active
  /// route, is `previousRoute`.
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    Nylo.addRouteHistory(route);
  }

  /// The [Navigator] popped `route`.
  ///
  /// The route immediately below that one, and thus the newly active
  /// route, is `previousRoute`.
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    Nylo.removeLastRouteHistory();
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
    Nylo.removeLastRouteHistory();
  }

  /// The [Navigator] replaced `oldRoute` with `newRoute`.
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    Nylo.removeLastRouteHistory();
    if (newRoute == null) return;
    Nylo.addRouteHistory(newRoute);
  }
}
