import '/controllers/ny_controllers.dart';
import '/helpers/ny_helpers.dart';
import '../ny_navigator.dart';
import '../ny_router.dart';
import '/widgets/ny_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'ny_argument.dart';
import 'ny_query_parameters.dart';
import 'ny_page_transition_settings.dart';
import 'nyrouter_route_guard.dart';

/// The typedef for the route builder.
typedef NyRouterRouteBuilder =
    Widget Function(
      BuildContext context,
      NyArgument? args,
      NyQueryParameters? queryParameters,
    );

/// The [NyRouterRoute] class is used to define a route in the Nylo Router.
class NyRouterRoute {
  String name;
  late NyRouterRouteBuilder builder;
  final NyArgument? defaultArgs;
  final NyQueryParameters? queryParameters;
  final NyRouteView view;
  TransitionType? _transitionType;
  TransitionType? get getTransitionType => _transitionType;
  PageTransitionType? pageTransitionType;
  PageTransitionSettings? pageTransitionSettings;
  bool _initialRoute, _authPage, _unknownRoute, _previewRoute;
  NyArgument? _previewArgs;
  NyQueryParameters? _previewQueryParameters;
  List<String> _previewStack = const [];

  /// The data passed to [previewRoute], given to the page when it opens
  /// without data of its own.
  NyArgument? get previewArgs => _previewArgs;

  /// The query parameters passed to [previewRoute], given to the page when
  /// it opens without query parameters of its own.
  NyQueryParameters? get previewQueryParameters => _previewQueryParameters;

  /// The routes opened underneath this route when it is the preview route.
  List<String> get previewStack => _previewStack;

  /// Whether [previewRoute] takes effect. False in release builds, so a
  /// preview left in the router never reaches production.
  @visibleForTesting
  static bool previewsEnabled = !kReleaseMode;
  final List<RouteGuard> _routeGuards = [];
  Function()? _when;

  NyRouterRoute({
    required this.name,
    required this.view,
    this.defaultArgs,
    this.queryParameters,
    List<RouteGuard>? routeGuards,
    this._transitionType,
    this.pageTransitionType,
    this.pageTransitionSettings,
    initialRoute = false,
    unknownRoute = false,
    authPage = false,
  }) : _initialRoute = initialRoute,
       _unknownRoute = unknownRoute,
       _authPage = authPage,
       _previewRoute = false {
    _routeGuards.addAll(routeGuards ?? []);
    builder = (context, arg, queryParameters) {
      Widget widget = view(context);
      if (widget is NyStatefulWidget) {
        widget.controller.request = NyRequest(
          currentRoute: name,
          args: arg,
          queryParameters: queryParameters,
        );

        final List<RouteGuard> merged = List<RouteGuard>.of(
          widget.controller.routeGuards,
        );
        for (final RouteGuard guard in _routeGuards) {
          if (!merged.any((g) => identical(g, guard))) merged.add(guard);
        }
        widget.controller.routeGuards = merged;

        widget.controller.construct(context);
        if (widget.state != null) {
          widget.controller.state = widget.state!;
        }
      }
      return widget;
    };
  }

  /// Add a transition type to the route.
  NyRouterRoute transitionType(TransitionType transitionType) {
    _transitionType = transitionType;
    NyNavigator.instance.router.updateRoute(this);
    return this;
  }

  /// Add a transition to the route.
  NyRouterRoute transition(PageTransitionType transition) {
    pageTransitionType = transition;
    NyNavigator.instance.router.updateRoute(this);
    return this;
  }

  /// Add a transition settings to the route.
  NyRouterRoute transitionSettings(PageTransitionSettings settings) {
    pageTransitionSettings = settings;
    NyNavigator.instance.router.updateRoute(this);
    return this;
  }

  /// Add a route guard to the route.
  NyRouterRoute addRouteGuard(RouteGuard guard) {
    _routeGuards.add(guard);
    NyNavigator.instance.router.updateRoute(this);
    return this;
  }

  /// Add route guards to the route
  NyRouterRoute addRouteGuards(List<RouteGuard> guards) {
    for (var guard in guards) {
      _routeGuards.add(guard);
    }
    NyNavigator.instance.router.updateRoute(this);
    return this;
  }

  /// Set the initial route.
  NyRouterRoute initialRoute({bool Function()? when}) {
    _when = when;
    if (when != null && when()) {
      _initialRoute = true;
    }
    if (when == null) {
      _initialRoute = true;
    }
    if (_initialRoute) {
      NyNavigator.instance.router.updateRoute(this);
    }
    return this;
  }

  /// Add a prefix to the route name.
  NyRouterRoute addPrefixToName(String prefix) {
    name = prefix + name;
    return this;
  }

  /// Get the initial route.
  bool getInitialRoute() {
    return _initialRoute;
  }

  /// Get the preview route flag.
  bool getPreviewRoute() {
    return _previewRoute;
  }

  /// Get the unknown route.
  bool getUnknownRoute() {
    return _unknownRoute;
  }

  /// Set the authenticated route.
  NyRouterRoute authenticatedRoute({bool Function()? when}) {
    _when = when;
    if (when != null && when()) {
      _authPage = true;
    }
    if (when == null) {
      _authPage = true;
    }
    if (_authPage) {
      NyNavigator.instance.router.updateRoute(this);
    }
    return this;
  }

  /// Set the unknown route.
  NyRouterRoute unknownRoute() {
    _unknownRoute = true;
    NyNavigator.instance.router.updateRoute(this);
    return this;
  }

  /// Set this route as a preview route.
  /// This will override any existing [initialRoute] and [authenticatedRoute]
  /// settings on all other routes, making this route the initial route.
  /// Useful for quickly previewing a specific route during development.
  ///
  /// [data] and [queryParameters] are passed to the page as if it was
  /// navigated to with `routeTo(path, data: data, queryParameters: ...)`.
  /// Data passed by a real navigation still takes priority.
  ///
  /// [stack] lists routes to open underneath this one, so the back button
  /// works as it does after a normal launch. It needs the app to use
  /// `NyApp.materialApp`, or to pass `NyRouter.previewInitialRoutes` to
  /// `onGenerateInitialRoutes`.
  ///
  /// Release builds ignore this method, so a forgotten preview can't change
  /// the app's first page in production.
  ///
  /// Usage:
  /// ```dart
  /// router.add(ProductPage.path).previewRoute(
  ///   data: {'id': 1},
  ///   stack: [HomePage.path],
  /// );
  /// ```
  NyRouterRoute previewRoute({
    dynamic data,
    Map<String, String>? queryParameters,
    List<String> stack = const [],
  }) {
    if (!previewsEnabled) return this;

    // Clear preview and initial flags on all other routes
    Map<String, NyRouterRoute> routes = NyNavigator.instance.router
        .getRegisteredRoutes();
    for (NyRouterRoute route in routes.values) {
      route._previewRoute = false;
      route._initialRoute = false;
      route._previewArgs = null;
      route._previewQueryParameters = null;
      route._previewStack = const [];
    }

    // Set this route as the preview route
    _previewRoute = true;
    _initialRoute = true; // Keep for backwards compatibility
    _previewArgs = data == null ? null : NyArgument(data);
    _previewQueryParameters = queryParameters == null
        ? null
        : NyQueryParameters(queryParameters);
    _previewStack = List.unmodifiable(stack);
    NyNavigator.instance.router.updateRoute(this);
    NyLogger.info(
      'Opening the preview route. '
      'Remove previewRoute() when you\'re done; release builds ignore it.',
      context: {'route': name},
    );
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

  /// Get the when function.
  bool getWhen() {
    return _when != null ? _when!() : true;
  }
}
