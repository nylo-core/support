import 'package:flutter/material.dart';
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'package:nylo_support/router/errors/route_not_found.dart';
import 'package:nylo_support/router/models/arguments_wrapper.dart';
import 'package:nylo_support/router/models/ny_page_transition_settings.dart';
import 'package:nylo_support/router/models/ny_query_parameters.dart';
import 'package:nylo_support/router/models/nyrouter_route_guard.dart';
import 'package:nylo_support/router/models/route_args_pair.dart';
import 'package:nylo_support/router/models/nyrouter_options.dart';
import 'package:nylo_support/router/models/nyrouter_route.dart';
import 'package:nylo_support/router/ui/page_not_found.dart';
import 'package:page_transition/page_transition.dart';
import 'models/ny_argument.dart';

class NyNavigator {
  NyRouter router = NyRouter();
  NyNavigator._privateConstructor();

  static final NyNavigator instance = NyNavigator._privateConstructor();
}

typedef NyRouteView = Widget Function(
  BuildContext context,
);

/// Builds the routes in the router.dart file
NyRouter nyRoutes(Function(NyRouter router) build) {
  NyRouter nyRouter = NyRouter();
  build(nyRouter);

  return nyRouter;
}

enum NavigationType {
  push,
  pushReplace,
  pushAndRemoveUntil,
  popAndPushNamed,
  pushAndForgetAll
}

/// NyRouterRoute manages routing, registering routes with transitions, navigating to
/// routes, closing routes. It is a thin layer on top of [Navigator] to help
/// you encapsulate and manage routing at one place.
class NyRouter {
  NyRouter({
    this.options = const NyRouterOptions(),
  }) {
    if (options.navigatorKey != null) {
      this._navigatorKey = options.navigatorKey;
    } else {
      this._navigatorKey = GlobalKey<NavigatorState>();
    }
  }

  /// Configuration options for [NyRouterRoute].
  ///
  /// Check out [NyRouterRouteOptions] for available options.
  final NyRouterOptions options;

  /// Store all the mappings of route names and corresponding [NyRouterRouteRoute]
  /// Used to generate routes
  Map<String, NyRouterRoute> _routeNameMappings = {};

  /// A navigator key lets NyRouterRoute grab the [NavigatorState] from a [MaterialApp]
  /// or a [CupertinoApp]. All navigation operations (push, pop, etc) are carried
  /// out using this [NavigatorState].
  ///
  /// This is the same [NavigatorState] that is returned by [Navigator.of(context)]
  /// (when there is only a single [Navigator] in Widget tree, i.e. from [MaterialApp]
  /// or [CupertinoApp]).
  GlobalKey<NavigatorState>? _navigatorKey;

  /// Stores the history of routes visited.
  List<Route<dynamic>> _routeHistory = [];

  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  /// Get the registered routes names as a list.
  List<String> getRegisteredRouteNames() => _routeNameMappings.keys.toList();

  /// Get the registered routes as a list.
  Map<String, NyRouterRoute> getRegisteredRoutes() => _routeNameMappings;

  /// Set the registered routes.
  void setRegisteredRoutes(Map<String, NyRouterRoute> routes) {
    _routeNameMappings.addAll(routes);
  }

  /// Set the registered routes.
  void setNyRoutes(NyRouter router) {
    _routeNameMappings.addAll(router.getRegisteredRoutes());
  }

  /// Retrieves the arguments passed in when calling the [navigate] function.
  ///
  /// Returned arguments are casted with the type provided, the type will always
  /// be a subtype of [NyArgument].
  ///
  /// Make sure to provide the appropriate type, that is, provide the same type
  /// as the one passed while calling [navigate], else a cast error will be
  /// thrown.
  static T? args<T extends NyArgument?>(BuildContext context) {
    return (ModalRoute.of(context)!.settings.arguments as ArgumentsWrapper)
        .baseArguments as T?;
  }

  /// Updates a named route.
  updateRoute(NyRouterRoute route) {
    _routeNameMappings[route.name] = route;
  }

  /// Add a new route with a widget.
  NyRouterRoute route(String name, NyRouteView view,
      {PageTransitionType? transition,
      PageTransitionSettings? pageTransitionSettings,
      List<NyRouteGuard> routeGuards = const [],
      bool initialRoute = false,
      bool authPage = false}) {
    NyRouterRoute nyRouterRoute = NyRouterRoute(
        name: name,
        view: view,
        pageTransitionType: transition ?? PageTransitionType.rightToLeft,
        pageTransitionSettings: pageTransitionSettings,
        routeGuards: routeGuards,
        initialRoute: initialRoute,
        authPage: authPage);
    this._addRoute(nyRouterRoute);

    assert(
        _routeNameMappings.entries
                .where((element) => element.value.getInitialRoute() == true)
                .length <=
            1,
        'Your project has more than one initial route defined, please check your router file.');

    return nyRouterRoute;
  }

  /// Add a new route to [NyRouterRoute].
  ///
  /// Route is stored in [_routeNameMappings].
  ///
  /// If a route is provided with a name that was previously added, it will
  /// override the old one.
  void _addRoute(NyRouterRoute route) {
    if (_routeNameMappings.containsKey(route.name)) {
      NyLogger.info(
          "'${route.name}' has already been registered before. Overriding it!");
    }
    _routeNameMappings[route.name] = route;
    NyNavigator.instance.router = this;
  }

  /// Retrieves the auth route name from your router.
  String? getAuthRouteName() {
    List<MapEntry<String, NyRouterRoute>> authRoutes = NyNavigator
        .instance.router._routeNameMappings.entries
        .where((element) => element.value.getAuthRoute() == true)
        .toList();

    if (authRoutes.isNotEmpty && Backpack.instance.auth() != null) {
      return authRoutes.first.value.name;
    }
    return null;
  }

  /// Retrieves the initial route name from your router.
  String getInitialRouteName() {
    List<MapEntry<String, NyRouterRoute>> initialRoutes = NyNavigator
        .instance.router._routeNameMappings.entries
        .where((element) => element.value.getInitialRoute() == true)
        .toList();

    if (initialRoutes.isNotEmpty) {
      return initialRoutes.first.value.name;
    }
    return "/";
  }

  /// Find the initial route.
  static String getInitialRoute() {
    List<MapEntry<String, NyRouterRoute>> authRoutes = NyNavigator
        .instance.router._routeNameMappings.entries
        .where((element) => element.value.getAuthRoute() == true)
        .toList();

    if (authRoutes.isNotEmpty && Backpack.instance.auth() != null) {
      return authRoutes.first.value.name;
    }

    List<MapEntry<String, NyRouterRoute>> initialRoutes = NyNavigator
        .instance.router._routeNameMappings.entries
        .where((element) => element.value.getInitialRoute() == true)
        .toList();

    if (initialRoutes.isNotEmpty) {
      return initialRoutes.first.value.name;
    }
    return "/";
  }

  /// Add a list of routes at once.
  void addRoutes(List<NyRouterRoute> routes) {
    if (routes.isNotEmpty) {
      routes.forEach((route) => this._addRoute(route));
    }
    NyNavigator.instance.router = this;
  }

  /// Makes this a callable class. Delegates to [navigate].
  Future<T> call<T>(String name,
      {NyArgument? args,
      NavigationType navigationType = NavigationType.push,
      dynamic result,
      bool Function(Route<dynamic> route)? removeUntilPredicate,
      Map<String, dynamic>? params,
      PageTransitionType? pageTransitionType,
      PageTransitionSettings? pageTransitionSettings}) async {
    assert(navigationType != NavigationType.pushAndRemoveUntil ||
        removeUntilPredicate != null);

    _checkAndThrowRouteNotFound(name, args, navigationType);

    return await navigate<T>(name,
        navigationType: navigationType,
        result: result,
        removeUntilPredicate: removeUntilPredicate,
        args: args,
        pageTransitionType: pageTransitionType,
        pageTransitionSettings: pageTransitionSettings);
  }

  /// Function used to navigate pages.
  ///
  /// [name] is the route name that was registered using [addRoute].
  ///
  /// [args] are optional arguments that can be passed to the next page.
  /// To retrieve these arguments use [args] method on [NyRouterRoute].
  ///
  /// [navigationType] can be specified to choose from various navigation
  /// strategies such as [NavigationType.push], [NavigationType.pushReplace],
  /// [NavigationType.pushAndRemoveUntil].
  ///
  /// [removeUntilPredicate] should be provided if using
  /// [NavigationType.pushAndRemoveUntil] strategy.
  Future<T> navigate<T>(String name,
      {NyArgument? args,
      NavigationType navigationType = NavigationType.push,
      dynamic result,
      bool Function(Route<dynamic> route)? removeUntilPredicate,
      PageTransitionType? pageTransitionType,
      PageTransitionSettings? pageTransitionSettings}) async {
    assert(navigationType != NavigationType.pushAndRemoveUntil ||
        removeUntilPredicate != null);

    _checkAndThrowRouteNotFound(name, args, navigationType);

    return await _navigate(name, args, navigationType, result,
            removeUntilPredicate, pageTransitionType, pageTransitionSettings)
        .then((value) => value as T);
  }

  /// Push multiple routes at the same time.
  ///
  /// [routeArgsPairs] is a list of [RouteArgsPair]. Each [RouteArgsPair]
  /// contains the name of a route and its corresponding argument (if any).
  Future<List> navigateMultiple(
    List<RouteArgsPair> routeArgsPairs,
  ) {
    assert(routeArgsPairs.isNotEmpty);

    final pageResponses = <Future>[];

    // For each route check if it exists.
    // Push the route.
    routeArgsPairs.forEach((routeArgs) {
      _checkAndThrowRouteNotFound(
        routeArgs.name,
        routeArgs.args,
        NavigationType.push,
      );

      final response = _navigate(
          routeArgs.name,
          routeArgs.args,
          NavigationType.push,
          null,
          null,
          routeArgs.pageTransition,
          routeArgs.pageTransitionSettings);

      pageResponses.add(response);
    });

    return Future.wait(pageResponses);
  }

  /// Actual navigation is delegated by [navigate] method to this method.
  ///
  /// [name] is the route name that was registered using [addRoute].
  ///
  /// [args] are optional arguments that can be passed to the next page.
  /// To retrieve these arguments use [arguments] method on [NyRouterRoute].
  ///
  /// [navigationType] can be specified to choose from various navigation
  /// strategies such as [NavigationType.push], [NavigationType.pushReplace],
  /// [NavigationType.pushAndRemoveUntil].
  ///
  /// [removeUntilPredicate] should be provided is using
  /// [NavigationType.pushAndRemoveUntil] strategy.
  Future<dynamic> _navigate(
      String name,
      NyArgument? args,
      NavigationType navigationType,
      dynamic result,
      bool Function(Route<dynamic> route)? removeUntilPredicate,
      PageTransitionType? pageTransitionType,
      PageTransitionSettings? pageTransitionSettings) async {
    final argsWrapper = ArgumentsWrapper(
      baseArguments: args,
      pageTransitionType: pageTransitionType,
      pageTransitionSettings: pageTransitionSettings,
    );

    // Evaluate if the route can be opened using route guard.
    final route = _routeNameMappings[name];

    if (route != null && (route.getRouteGuards()).isNotEmpty) {
      for (RouteGuard routeGuard in route.getRouteGuards()) {
        final result = await routeGuard.canOpen(
          navigatorKey!.currentContext,
          argsWrapper.baseArguments,
        );

        if (result == false) {
          return await routeGuard.redirectTo(
              navigatorKey!.currentContext, argsWrapper.baseArguments);
        }
      }
    }

    switch (navigationType) {
      case NavigationType.push:
        return await this
            .navigatorKey!
            .currentState!
            .pushNamed(name, arguments: argsWrapper);
      case NavigationType.pushReplace:
        return await this
            .navigatorKey!
            .currentState!
            .pushReplacementNamed(name, result: result, arguments: argsWrapper);
      case NavigationType.pushAndRemoveUntil:
        return await this.navigatorKey!.currentState!.pushNamedAndRemoveUntil(
            name, removeUntilPredicate!,
            arguments: argsWrapper);
      case NavigationType.popAndPushNamed:
        return await this
            .navigatorKey!
            .currentState!
            .popAndPushNamed(name, result: result, arguments: argsWrapper);
      case NavigationType.pushAndForgetAll:
        return await this.navigatorKey!.currentState!.pushNamedAndRemoveUntil(
              name,
              (_) => false,
              arguments: argsWrapper,
            );
    }
  }

  /// Get the previous route.
  Route<dynamic>? getPreviousRoute() {
    if (_routeHistory.length < 2) return null;
    return _routeHistory[_routeHistory.length - 2];
  }

  /// Get the current route.
  Route<dynamic>? getCurrentRoute() {
    if (_routeHistory.length < 1) return null;
    return _routeHistory[_routeHistory.length - 1];
  }

  /// Add the route to the history.
  addRouteHistory(Route<dynamic> route) {
    _routeHistory.add(route);
  }

  /// Remove the route from the history.
  removeRouteHistory(Route<dynamic> route) {
    _routeHistory.remove(route);
  }

  /// Remove the last route from the history.
  removeLastRouteHistory() {
    _routeHistory.removeLast();
  }

  /// Get the route history.
  List<Route<dynamic>> getRouteHistory() {
    return _routeHistory;
  }

  /// If the route is not registered throw an error
  /// Make sure to use the correct name while calling navigate.
  void _checkAndThrowRouteNotFound(
    String name,
    NyArgument? args,
    NavigationType navigationType,
  ) {
    if (!_routeNameMappings.containsKey(name)) {
      if (this.options.handleNameNotFoundUI) {
        NyLogger.error("Page not found\n"
            "[Route Name] $name\n"
            "[ARGS] ${args.toString()}");
        this.navigatorKey!.currentState!.push(
          MaterialPageRoute(builder: (BuildContext context) {
            return PageNotFound();
          }),
        );
      }
      throw RouteNotFoundError(name: name);
    }
  }

  /// Delegation for [Navigator.pop].
  void pop([dynamic result]) {
    this.navigatorKey!.currentState!.pop(result);
  }

  /// Delegation for [Navigator.popUntil].
  void popUntil(void Function(Route<dynamic>) predicate) {
    this
        .navigatorKey!
        .currentState!
        .popUntil(predicate as bool Function(Route<dynamic>));
  }

  /// Generates the [RouteFactory] which builds a [Route] on request.
  ///
  /// These routes are built using the [NyRouterRoute]s [addRoute] method.
  RouteFactory generator(
      {Widget Function(BuildContext context, Widget widget)? builder}) {
    return (RouteSettings settings) {
      if (settings.name == null) return null;

      Uri? uriSettingName;
      try {
        uriSettingName = Uri.parse(settings.name!);
      } on FormatException catch (e) {
        NyLogger.error(e.toString());
      }

      String routeName = settings.name!;
      if (uriSettingName != null) {
        routeName = uriSettingName.path;
      }

      final NyRouterRoute? route = _routeNameMappings[routeName];

      if (route == null) return null;

      ArgumentsWrapper? argumentsWrapper;
      if (settings.arguments is ArgumentsWrapper) {
        argumentsWrapper = settings.arguments as ArgumentsWrapper?;
      } else {
        argumentsWrapper = ArgumentsWrapper();
        argumentsWrapper.baseArguments = NyArgument(settings.arguments);
      }

      if (argumentsWrapper == null) {
        argumentsWrapper = ArgumentsWrapper();
      }

      if (uriSettingName != null && uriSettingName.queryParameters.isNotEmpty) {
        argumentsWrapper.queryParameters =
            NyQueryParameters(uriSettingName.queryParameters);
      }

      final NyArgument? baseArgs = argumentsWrapper.baseArguments;
      final NyQueryParameters? queryParameters =
          argumentsWrapper.queryParameters;

      if (argumentsWrapper.pageTransitionSettings == null) {
        argumentsWrapper.pageTransitionSettings = PageTransitionSettings();
      }

      if (route.pageTransitionSettings == null) {
        route.pageTransitionSettings = PageTransitionSettings();
      }

      return PageTransition(
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          if (builder != null) {
            Widget widget = route.builder(
              context,
              baseArgs ?? route.defaultArgs,
              queryParameters ?? route.queryParameters,
            );
            return builder(context, widget);
          }
          return route.builder(context, baseArgs ?? route.defaultArgs,
              queryParameters ?? route.queryParameters);
        }),
        type: argumentsWrapper.pageTransitionType ?? route.pageTransitionType,
        settings: settings,
        duration: _getPageTransitionDuration(route, argumentsWrapper),
        alignment: _getPageTransitionAlignment(route, argumentsWrapper),
        reverseDuration:
            _getPageTransitionReversedDuration(route, argumentsWrapper),
        matchingBuilder:
            _getPageTransitionMatchingBuilder(route, argumentsWrapper),
        childCurrent: _getPageTransitionChildCurrent(route, argumentsWrapper),
        curve: _getPageTransitionCurve(route, argumentsWrapper),
        ctx: _getPageTransitionContext(route, argumentsWrapper),
        inheritTheme: _getPageTransitionInheritTheme(route, argumentsWrapper),
        fullscreenDialog:
            _getPageTransitionFullscreenDialog(route, argumentsWrapper),
        opaque: _getPageTransitionOpaque(route, argumentsWrapper),
        isIos: _getPageTransitionIsIos(route, argumentsWrapper),
      );
    };
  }

  /// Used to retrieve the correct Duration value for the [PageTransition] constructor.
  Duration _getPageTransitionDuration(
      NyRouterRoute route, ArgumentsWrapper argumentsWrapper) {
    Duration duration = this.options.pageTransitionSettings.duration!;

    if (route.pageTransitionSettings != null &&
        route.pageTransitionSettings!.duration != null) {
      duration = route.pageTransitionSettings!.duration!;
    }
    if (argumentsWrapper.pageTransitionSettings != null &&
        argumentsWrapper.pageTransitionSettings!.duration != null) {
      duration = argumentsWrapper.pageTransitionSettings!.duration!;
    }
    return duration;
  }

  /// Used to retrieve the correct ReversedDuration value for the [PageTransition] constructor.
  Duration _getPageTransitionReversedDuration(
      NyRouterRoute route, ArgumentsWrapper argumentsWrapper) {
    Duration duration = this.options.pageTransitionSettings.reverseDuration!;

    if (route.pageTransitionSettings != null &&
        route.pageTransitionSettings!.reverseDuration != null) {
      duration = route.pageTransitionSettings!.reverseDuration!;
    }
    if (argumentsWrapper.pageTransitionSettings != null &&
        argumentsWrapper.pageTransitionSettings!.reverseDuration != null) {
      duration = argumentsWrapper.pageTransitionSettings!.reverseDuration!;
    }
    return duration;
  }

  /// Used to retrieve the correct ChildCurrent value for the [PageTransition] constructor.
  Widget? _getPageTransitionChildCurrent(
      NyRouterRoute route, ArgumentsWrapper argumentsWrapper) {
    Widget? widget = this.options.pageTransitionSettings.childCurrent;

    if (route.pageTransitionSettings != null &&
        route.pageTransitionSettings!.childCurrent != null) {
      widget = route.pageTransitionSettings!.childCurrent;
    }
    if (argumentsWrapper.pageTransitionSettings != null &&
        argumentsWrapper.pageTransitionSettings!.childCurrent != null) {
      widget = argumentsWrapper.pageTransitionSettings!.childCurrent;
    }
    return widget;
  }

  /// Used to retrieve the correct Context value for the [PageTransition] constructor.
  BuildContext? _getPageTransitionContext(
      NyRouterRoute route, ArgumentsWrapper argumentsWrapper) {
    BuildContext? buildContext = this.options.pageTransitionSettings.context;

    if (route.pageTransitionSettings != null &&
        route.pageTransitionSettings!.context != null) {
      buildContext = route.pageTransitionSettings!.context;
    }
    if (argumentsWrapper.pageTransitionSettings != null &&
        argumentsWrapper.pageTransitionSettings!.context != null) {
      buildContext = argumentsWrapper.pageTransitionSettings!.context;
    }
    return buildContext;
  }

  /// Used to retrieve the correct InheritTheme value for the [PageTransition] constructor.
  bool _getPageTransitionInheritTheme(
      NyRouterRoute route, ArgumentsWrapper argumentsWrapper) {
    bool boolVal = this.options.pageTransitionSettings.inheritTheme!;

    if (route.pageTransitionSettings != null &&
        route.pageTransitionSettings!.inheritTheme != null) {
      boolVal = route.pageTransitionSettings!.inheritTheme!;
    }
    if (argumentsWrapper.pageTransitionSettings != null &&
        argumentsWrapper.pageTransitionSettings!.inheritTheme != null) {
      boolVal = argumentsWrapper.pageTransitionSettings!.inheritTheme!;
    }
    return boolVal;
  }

  /// Used to retrieve the correct Curve value for the [PageTransition] constructor.
  Curve _getPageTransitionCurve(
      NyRouterRoute route, ArgumentsWrapper argumentsWrapper) {
    Curve curve = this.options.pageTransitionSettings.curve!;

    if (route.pageTransitionSettings != null &&
        route.pageTransitionSettings!.curve != null) {
      curve = route.pageTransitionSettings!.curve!;
    }
    if (argumentsWrapper.pageTransitionSettings != null &&
        argumentsWrapper.pageTransitionSettings!.curve != null) {
      curve = argumentsWrapper.pageTransitionSettings!.curve!;
    }
    return curve;
  }

  /// Used to retrieve the correct Alignment value for the [PageTransition] constructor.
  Alignment? _getPageTransitionAlignment(
      NyRouterRoute route, ArgumentsWrapper argumentsWrapper) {
    Alignment? alignment = this.options.pageTransitionSettings.alignment;

    if (route.pageTransitionSettings != null &&
        route.pageTransitionSettings!.alignment != null) {
      alignment = route.pageTransitionSettings!.alignment;
    }
    if (argumentsWrapper.pageTransitionSettings != null &&
        argumentsWrapper.pageTransitionSettings!.alignment != null) {
      alignment = argumentsWrapper.pageTransitionSettings!.alignment;
    }
    return alignment;
  }

  /// Used to retrieve the correct FullscreenDialog value for the [PageTransition] constructor.
  bool _getPageTransitionFullscreenDialog(
      NyRouterRoute route, ArgumentsWrapper argumentsWrapper) {
    bool fullscreenDialog =
        this.options.pageTransitionSettings.fullscreenDialog!;

    if (route.pageTransitionSettings != null &&
        route.pageTransitionSettings!.fullscreenDialog != null) {
      fullscreenDialog = route.pageTransitionSettings!.fullscreenDialog!;
    }
    if (argumentsWrapper.pageTransitionSettings != null &&
        argumentsWrapper.pageTransitionSettings!.fullscreenDialog != null) {
      fullscreenDialog =
          argumentsWrapper.pageTransitionSettings!.fullscreenDialog!;
    }
    return fullscreenDialog;
  }

  /// Used to retrieve the correct Opaque value for the [PageTransition] constructor.
  bool _getPageTransitionOpaque(
      NyRouterRoute route, ArgumentsWrapper argumentsWrapper) {
    bool opaque = this.options.pageTransitionSettings.opaque!;

    if (route.pageTransitionSettings != null &&
        route.pageTransitionSettings!.opaque != null) {
      opaque = route.pageTransitionSettings!.opaque!;
    }
    if (argumentsWrapper.pageTransitionSettings != null &&
        argumentsWrapper.pageTransitionSettings!.opaque != null) {
      opaque = argumentsWrapper.pageTransitionSettings!.opaque!;
    }
    return opaque;
  }

  /// Used to retrieve the correct IsIos value for the [PageTransition] constructor.
  bool _getPageTransitionIsIos(
      NyRouterRoute route, ArgumentsWrapper argumentsWrapper) {
    bool isIos = this.options.pageTransitionSettings.isIos!;

    if (route.pageTransitionSettings != null &&
        route.pageTransitionSettings!.isIos != null) {
      isIos = route.pageTransitionSettings!.isIos!;
    }
    if (argumentsWrapper.pageTransitionSettings != null &&
        argumentsWrapper.pageTransitionSettings!.isIos != null) {
      isIos = argumentsWrapper.pageTransitionSettings!.isIos!;
    }
    return isIos;
  }

  /// Used to retrieve the correct MatchingBuilder value for the [PageTransition] constructor.
  PageTransitionsBuilder _getPageTransitionMatchingBuilder(
      NyRouterRoute route, ArgumentsWrapper argumentsWrapper) {
    PageTransitionsBuilder matchingBuilder =
        this.options.pageTransitionSettings.matchingBuilder!;

    if (route.pageTransitionSettings != null &&
        route.pageTransitionSettings!.matchingBuilder != null) {
      matchingBuilder = route.pageTransitionSettings!.matchingBuilder!;
    }
    if (argumentsWrapper.pageTransitionSettings != null &&
        argumentsWrapper.pageTransitionSettings!.matchingBuilder != null) {
      matchingBuilder =
          argumentsWrapper.pageTransitionSettings!.matchingBuilder!;
    }
    return matchingBuilder;
  }

  static RouteFactory unknownRouteGenerator() {
    return (settings) {
      return MaterialPageRoute(
        settings: settings,
        builder: (BuildContext context) {
          return PageNotFound();
        },
      );
    };
  }
}

/// Navigate to a new route.
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
    PageTransitionSettings? pageTransitionSettings,
    PageTransitionType? pageTransition,
    Function(dynamic value)? onPop}) async {
  NyArgument nyArgument = NyArgument(data);
  await NyNavigator.instance.router
      .navigate(routeName,
          args: nyArgument,
          navigationType: navigationType,
          result: result,
          removeUntilPredicate: removeUntilPredicate,
          pageTransitionType: pageTransition,
          pageTransitionSettings: pageTransitionSettings)
      .then((v) => onPop != null ? onPop(v) : (v) {});
}

/// Navigate to the auth route.
routeToAuth(
    {dynamic data,
    NavigationType navigationType = NavigationType.pushAndForgetAll,
    dynamic result,
    bool Function(Route<dynamic> route)? removeUntilPredicate,
    PageTransitionSettings? pageTransitionSettings,
    PageTransitionType? pageTransition,
    Function(dynamic value)? onPop}) async {
  NyArgument nyArgument = NyArgument(data);
  String? route = NyNavigator.instance.router.getAuthRouteName();
  if (route == null) {
    NyLogger.debug("No auth route set");
    return;
  }
  await NyNavigator.instance.router
      .navigate(route,
          args: nyArgument,
          navigationType: navigationType,
          result: result,
          removeUntilPredicate: removeUntilPredicate,
          pageTransitionType: pageTransition,
          pageTransitionSettings: pageTransitionSettings)
      .then((v) => onPop != null ? onPop(v) : (v) {});
}

/// Navigate to the initial route.
routeToInitial(
    {dynamic data,
    NavigationType navigationType = NavigationType.pushAndForgetAll,
    dynamic result,
    bool Function(Route<dynamic> route)? removeUntilPredicate,
    PageTransitionSettings? pageTransitionSettings,
    PageTransitionType? pageTransition,
    Function(dynamic value)? onPop}) async {
  NyArgument nyArgument = NyArgument(data);
  String route = NyNavigator.instance.router.getInitialRouteName();

  await NyNavigator.instance.router
      .navigate(route,
          args: nyArgument,
          navigationType: navigationType,
          result: result,
          removeUntilPredicate: removeUntilPredicate,
          pageTransitionType: pageTransition,
          pageTransitionSettings: pageTransitionSettings)
      .then((v) => onPop != null ? onPop(v) : (v) {});
}
