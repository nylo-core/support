import 'package:nylo_support/controllers/controller.dart';
import 'package:nylo_support/router/models/ny_page_transition_settings.dart';
import 'package:nylo_support/router/models/ny_query_parameters.dart';
import 'package:nylo_support/router/models/nyrouter_route_guard.dart';
import 'package:nylo_support/router/router.dart';
import 'package:nylo_support/widgets/ny_page.dart';
import 'package:nylo_support/widgets/ny_stateful_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'ny_argument.dart';

typedef NyRouterRouteBuilder = Widget Function(
  BuildContext context,
  NyArgument? args,
  NyQueryParameters? queryParameters,
);

class NyRouterRoute {
  final String name;
  late NyRouterRouteBuilder builder;
  final NyArgument? defaultArgs;
  final NyQueryParameters? queryParameters;
  final NyRouteView view;
  PageTransitionType pageTransitionType;
  PageTransitionSettings? pageTransitionSettings;
  bool _initialRoute, _authPage;

  /// Ran before opening the route itself.
  /// If every route guard returns [true], the route is approved and opened.
  /// Anything else will result in the route being rejected and not open.
  final List<RouteGuard> _routeGuards;

  NyRouterRoute(
      {required this.name,
      required this.view,
      this.defaultArgs,
      this.queryParameters,
      routeGuards = const [],
      this.pageTransitionType = PageTransitionType.rightToLeft,
      this.pageTransitionSettings,
      initialRoute = false,
      authPage = false})
      : _initialRoute = initialRoute,
        _authPage = authPage,
        _routeGuards = routeGuards {
    this.builder = (context, arg, queryParameters) {
      Widget widget = view(context);
      if (widget is NyStatefulWidget) {
        widget.controller.request = NyRequest(
          currentRoute: name,
          args: arg,
          queryParameters: queryParameters,
        );
        widget.controller.construct(context);
        if (widget.state != null) {
          widget.controller.state = widget.state!;
        }
      }
      if (widget is NyPage) {
        widget.controller.request = NyRequest(
          currentRoute: name,
          args: arg,
          queryParameters: queryParameters,
        );
        widget.controller.construct(context);
        widget.controller.state = widget.state;
      }
      return widget;
    };
  }

  /// Add a transition to the route.
  NyRouterRoute transition(PageTransitionType transition) {
    this.pageTransitionType = transition;
    NyNavigator.instance.router.updateRoute(this);
    return this;
  }

  /// Add a transition settings to the route.
  NyRouterRoute transitionSettings(PageTransitionSettings settings) {
    this.pageTransitionSettings = settings;
    NyNavigator.instance.router.updateRoute(this);
    return this;
  }

  /// Add a route guard to the route.
  NyRouterRoute addRouteGuard(RouteGuard guard) {
    _routeGuards.add(guard);
    NyNavigator.instance.router.updateRoute(this);
    return this;
  }

  NyRouterRoute routeGuards(List<RouteGuard> guards) {
    _routeGuards.addAll(guards);
    NyNavigator.instance.router.updateRoute(this);
    return this;
  }

  /// Set the initial route.
  NyRouterRoute initialRoute() {
    _initialRoute = true;
    NyNavigator.instance.router.updateRoute(this);
    return this;
  }

  /// Get the initial route.
  bool getInitialRoute() {
    return _initialRoute;
  }

  /// Set the auth route.
  NyRouterRoute authRoute() {
    _authPage = true;
    NyNavigator.instance.router.updateRoute(this);
    return this;
  }

  /// Get the auth route.
  bool getAuthRoute() {
    return _authPage;
  }

  /// Get the route guards.
  List<RouteGuard> getRouteGuards() {
    return _routeGuards;
  }
}
