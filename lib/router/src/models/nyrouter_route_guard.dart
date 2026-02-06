import 'package:flutter/material.dart';
import '../ny_router.dart';
import '../page_transition/page_transition.dart';
import '../router_functions.dart';
import 'ny_argument.dart';
import 'ny_page_transition_settings.dart';

/// The result of a route guard check.
///
/// Guards return this to indicate whether navigation should continue,
/// be redirected, or be aborted.
enum GuardResult {
  /// Continue to the next guard or to the route.
  next,

  /// The guard handled the navigation (redirect or abort).
  /// The chain stops here.
  handled,
}

/// Immutable context passed to route guards.
///
/// Contains all information about the navigation request.
/// Use [copyWith] or [withData] to create modified copies.
///
/// Example:
/// ```dart
/// @override
/// Future<GuardResult> onBefore(RouteContext context) async {
///   print('Navigating to: ${context.routeName}');
///   print('Query params: ${context.queryParameters}');
///   return next();
/// }
/// ```
class RouteContext<T> {
  /// The current build context, if available.
  final BuildContext? context;

  /// The data passed to this route.
  final T? data;

  /// Query parameters from the URL.
  final Map<String, String> queryParameters;

  /// The name/path of the route being navigated to.
  final String routeName;

  /// The original route name before any transformations.
  final String? originalRouteName;

  const RouteContext({
    this.context,
    this.data,
    this.queryParameters = const {},
    required this.routeName,
    this.originalRouteName,
  });

  /// Create a copy with different data.
  ///
  /// Useful for transforming data as it passes through guards.
  /// ```dart
  /// final enrichedContext = context.withData(
  ///   UserData(user: user, permissions: permissions),
  /// );
  /// ```
  RouteContext<R> withData<R>(R newData) {
    return RouteContext<R>(
      context: context,
      data: newData,
      queryParameters: queryParameters,
      routeName: routeName,
      originalRouteName: originalRouteName,
    );
  }

  /// Create a copy with some fields changed.
  RouteContext<T> copyWith({
    BuildContext? context,
    T? data,
    Map<String, String>? queryParameters,
    String? routeName,
    String? originalRouteName,
  }) {
    return RouteContext<T>(
      context: context ?? this.context,
      data: data ?? this.data,
      queryParameters: queryParameters ?? this.queryParameters,
      routeName: routeName ?? this.routeName,
      originalRouteName: originalRouteName ?? this.originalRouteName,
    );
  }
}

/// Configuration for a redirect action.
class RedirectConfig {
  final String path;
  final dynamic data;
  final Map<String, dynamic>? queryParameters;
  final NavigationType navigationType;
  final dynamic result;
  final bool Function(Route<dynamic> route)? removeUntilPredicate;
  final TransitionType? transitionType;
  final Function(dynamic value)? onPop;

  const RedirectConfig({
    required this.path,
    this.data,
    this.queryParameters,
    this.navigationType = NavigationType.pushReplace,
    this.result,
    this.removeUntilPredicate,
    this.transitionType,
    this.onPop,
  });
}

/// Base class for Nylo route guards.
///
/// Route guards intercept navigation and can:
/// - Allow navigation to continue ([next])
/// - Redirect to a different route ([redirect])
/// - Abort navigation entirely ([abort])
///
/// ## Lifecycle Hooks
///
/// - [onBefore]: Called before navigation. Return [next] to continue.
/// - [onAfter]: Called after successful navigation to the route.
///
/// ## Basic Example
/// ```dart
/// class AuthGuard extends NyRouteGuard {
///   @override
///   Future<GuardResult> onBefore(RouteContext context) async {
///     if (!await Auth.isLoggedIn()) {
///       return redirect(LoginPage.path);
///     }
///     return next();
///   }
/// }
/// ```
///
/// ## With Data Transformation
/// ```dart
/// class UserDataGuard extends NyRouteGuard {
///   @override
///   Future<GuardResult> onBefore(RouteContext context) async {
///     final user = await UserService.getCurrentUser();
///     // Enrich context with user data for the route
///     setData(user);
///     return next();
///   }
/// }
/// ```
///
/// ## Usage in Router
/// ```dart
/// router.route(
///   ProfilePage.path,
///   (_) => ProfilePage(),
///   routeGuards: [AuthGuard(), UserDataGuard()],
/// );
/// ```
abstract class NyRouteGuard extends RouteGuard {
  NyRouteGuard() : super();

  /// Internal storage for redirect configuration.
  RedirectConfig? _redirectConfig;

  /// Internal storage for modified data.
  dynamic _modifiedData;
  bool _hasModifiedData = false;

  /// The current route context. Set by the router before calling hooks.
  RouteContext? _context;

  /// Get the redirect configuration if a redirect was requested.
  RedirectConfig? get redirectConfig => _redirectConfig;

  /// Get modified data if [setData] was called.
  dynamic get modifiedData => _modifiedData;

  /// Whether [setData] was called during this guard's execution.
  bool get hasModifiedData => _hasModifiedData;

  /// The current route context.
  RouteContext? get routeContext => _context;

  /// Convenience getter for the route data.
  dynamic get data => _context?.data;

  /// Convenience getter for the build context.
  BuildContext? get context => _context?.context;

  /// Convenience getter for query parameters.
  Map<String, String> get queryParameters => _context?.queryParameters ?? {};

  /// Convenience getter for the route name.
  String? get routeName => _context?.routeName;

  /// Set the route context. Called by the router.
  void setRouteContext(RouteContext context) {
    _context = context;
    _redirectConfig = null;
    _modifiedData = null;
    _hasModifiedData = false;
  }

  /// Called before navigation to the route.
  ///
  /// Return [next] to continue navigation, or [redirect]/[abort] to stop.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<GuardResult> onBefore(RouteContext context) async {
  ///   if (!await hasPermission()) {
  ///     return redirect('/unauthorized');
  ///   }
  ///   return next();
  /// }
  /// ```
  Future<GuardResult> onBefore(RouteContext context) async => GuardResult.next;

  /// Called after successful navigation to the route.
  ///
  /// Use this for analytics, logging, or post-navigation setup.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> onAfter(RouteContext context) async {
  ///   Analytics.trackPageView(context.routeName);
  /// }
  /// ```
  Future<void> onAfter(RouteContext context) async {}

  /// Continue to the next guard or to the route.
  GuardResult next() => GuardResult.next;

  /// Redirect to a different route.
  ///
  /// Accepts either a [String] path or a [RouteView] (e.g., `HomePage.path`).
  ///
  /// Example:
  /// ```dart
  /// return redirect('/login', data: {'returnTo': context.routeName});
  /// // or
  /// return redirect(HomePage.path);
  /// ```
  GuardResult redirect(
    Object path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    NavigationType navigationType = NavigationType.pushReplace,
    dynamic result,
    bool Function(Route<dynamic> route)? removeUntilPredicate,
    TransitionType? transitionType,
    Function(dynamic value)? onPop,
  }) {
    final String resolvedPath = path is RouteView ? path.$1 : path as String;
    _redirectConfig = RedirectConfig(
      path: resolvedPath,
      data: data,
      queryParameters: queryParameters,
      navigationType: navigationType,
      result: result,
      removeUntilPredicate: removeUntilPredicate,
      transitionType: transitionType,
      onPop: onPop,
    );
    return GuardResult.handled;
  }

  /// Abort navigation without redirecting.
  ///
  /// The user stays on the current route.
  GuardResult abort() => GuardResult.handled;

  /// Modify the data passed to subsequent guards and the route.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<GuardResult> onBefore(RouteContext context) async {
  ///   final user = await fetchUser();
  ///   setData({'user': user, ...?context.data});
  ///   return next();
  /// }
  /// ```
  void setData(dynamic data) {
    _modifiedData = data;
    _hasModifiedData = true;
  }

  /// Legacy method override for backward compatibility.
  /// Delegates to the new [onBefore] lifecycle method.
  @override
  Future<PageRequest?> onRequest(PageRequest pageRequest) async {
    final routeContext = pageRequest.toRouteContext(routeName ?? '');
    setRouteContext(routeContext);
    final result = await onBefore(routeContext);

    if (result == GuardResult.handled) {
      if (_redirectConfig != null) {
        return PageRequest.redirect(
          _redirectConfig!.path,
          data: _redirectConfig!.data,
          queryParameters: _redirectConfig!.queryParameters,
          navigationType: _redirectConfig!.navigationType,
          result: _redirectConfig!.result,
          removeUntilPredicate: _redirectConfig!.removeUntilPredicate,
          onPop: _redirectConfig!.onPop,
        );
      }
      // Aborted without redirect
      return PageRequest()..isRedirect = true;
    }

    // Continue to next guard, possibly with modified data
    if (_hasModifiedData) {
      pageRequest.addData((_) => _modifiedData);
    }
    return null;
  }
}

/// A route guard that accepts configuration parameters.
///
/// Use this when you need to configure guard behavior per-route.
///
/// Example:
/// ```dart
/// class RoleGuard extends ParameterizedGuard<List<String>> {
///   RoleGuard(super.params);
///
///   @override
///   Future<GuardResult> onBefore(RouteContext context) async {
///     final user = await Auth.user();
///     if (!params.any((role) => user.hasRole(role))) {
///       return redirect('/unauthorized');
///     }
///     return next();
///   }
/// }
///
/// // Usage:
/// router.route(
///   AdminPage.path,
///   (_) => AdminPage(),
///   routeGuards: [RoleGuard(['admin', 'moderator'])],
/// );
/// ```
abstract class ParameterizedGuard<P> extends NyRouteGuard {
  /// The parameters passed to this guard.
  final P params;

  ParameterizedGuard(this.params);
}

/// Compose multiple guards into a single guard.
///
/// Executes guards in order until one returns [GuardResult.handled]
/// or all return [GuardResult.next].
///
/// Example:
/// ```dart
/// // Create reusable guard combinations
/// final adminGuards = GuardStack([
///   AuthGuard(),
///   RoleGuard(['admin']),
///   AuditLogGuard(),
/// ]);
///
/// router.route(
///   AdminPage.path,
///   (_) => AdminPage(),
///   routeGuards: [adminGuards],
/// );
/// ```
class GuardStack extends NyRouteGuard {
  /// The guards to execute in order.
  final List<NyRouteGuard> guards;

  GuardStack(this.guards);

  @override
  Future<GuardResult> onBefore(RouteContext context) async {
    RouteContext currentContext = context;

    for (final guard in guards) {
      guard.setRouteContext(currentContext);
      final result = await guard.onBefore(currentContext);

      if (result == GuardResult.handled) {
        // Propagate redirect config if set
        if (guard.redirectConfig != null) {
          _redirectConfig = guard.redirectConfig;
        }
        return GuardResult.handled;
      }

      // Pass modified data to next guard
      if (guard.hasModifiedData) {
        currentContext = currentContext.withData(guard.modifiedData);
      }
    }

    // Propagate final modified data
    if (currentContext.data != context.data) {
      setData(currentContext.data);
    }

    return GuardResult.next;
  }

  @override
  Future<void> onAfter(RouteContext context) async {
    for (final guard in guards) {
      await guard.onAfter(context);
    }
  }
}

/// Conditionally apply a guard based on a predicate.
///
/// Example:
/// ```dart
/// ConditionalGuard(
///   condition: (context) => context.routeName.startsWith('/admin'),
///   guard: AdminGuard(),
/// )
/// ```
class ConditionalGuard extends NyRouteGuard {
  /// The condition to check.
  final bool Function(RouteContext context) condition;

  /// The guard to apply if condition is true.
  final NyRouteGuard guard;

  ConditionalGuard({required this.condition, required this.guard});

  @override
  Future<GuardResult> onBefore(RouteContext context) async {
    if (!condition(context)) {
      return next();
    }
    guard.setRouteContext(context);
    final result = await guard.onBefore(context);
    if (guard.redirectConfig != null) {
      _redirectConfig = guard.redirectConfig;
    }
    if (guard.hasModifiedData) {
      setData(guard.modifiedData);
    }
    return result;
  }

  @override
  Future<void> onAfter(RouteContext context) async {
    if (condition(context)) {
      await guard.onAfter(context);
    }
  }
}

// =============================================================================
// BACKWARD COMPATIBILITY LAYER
// The classes below maintain compatibility with the existing router.
// =============================================================================

/// @deprecated Use [NyRouteGuard] instead.
/// Legacy class interface for backward compatibility.
abstract class RouteGuard {
  RouteGuard({this.pageRequest});

  PageRequest? pageRequest;

  Future<PageRequest?> onRequest(PageRequest pageRequest) async => null;
}

/// Legacy page request class for backward compatibility.
class PageRequest {
  BuildContext? context;
  NyArgument? nyArgument;
  Map<String, String>? queryParameters;
  bool isRedirect = false;
  RouteData? routeData;

  dynamic get data => nyArgument?.data;

  PageRequest({this.context, this.nyArgument, this.queryParameters});

  PageRequest.redirect(
    dynamic path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    NavigationType navigationType = NavigationType.pushReplace,
    dynamic result,
    bool Function(Route<dynamic> route)? removeUntilPredicate,
    PageTransitionSettings? pageTransitionSettings,
    PageTransitionType? pageTransitionType,
    Function(dynamic value)? onPop,
  }) {
    isRedirect = true;
    routeData = RouteData(
      path,
      data: data,
      queryParameters: queryParameters,
      navigationType: navigationType,
      result: result,
      removeUntilPredicate: removeUntilPredicate,
      pageTransitionSettings: pageTransitionSettings,
      pageTransitionType: pageTransitionType,
      onPop: onPop,
    );
  }

  void addData(dynamic Function(dynamic data) currentData) {
    nyArgument?.setData(currentData(data));
  }

  /// Convert to RouteContext for new guard system.
  RouteContext toRouteContext(String routeName) {
    return RouteContext(
      context: context,
      data: data,
      queryParameters: queryParameters ?? {},
      routeName: routeName,
    );
  }

  /// Create from RouteContext.
  static PageRequest fromRouteContext(RouteContext context) {
    return PageRequest(
      context: context.context,
      nyArgument: context.data != null ? NyArgument(context.data) : null,
      queryParameters: context.queryParameters,
    );
  }
}

/// Route data class for navigation configuration.
class RouteData {
  dynamic path;
  dynamic data;
  Map<String, dynamic>? queryParameters;
  NavigationType navigationType;
  dynamic result;
  bool Function(Route<dynamic> route)? removeUntilPredicate;
  TransitionType? transitionType;
  PageTransitionSettings? pageTransitionSettings;
  PageTransitionType? pageTransitionType;
  Function(dynamic value)? onPop;

  RouteData(
    this.path, {
    this.data,
    this.queryParameters,
    this.navigationType = NavigationType.pushReplace,
    this.result,
    this.removeUntilPredicate,
    this.pageTransitionSettings,
    this.pageTransitionType,
    this.transitionType,
    this.onPop,
  });

  Future<void> routeToPage() async {
    await routeTo(
      path,
      data: data,
      queryParameters: queryParameters,
      navigationType: navigationType,
      result: result,
      removeUntilPredicate: removeUntilPredicate,
      transitionType: transitionType,
      onPop: onPop,
    );
  }

  /// Create from RedirectConfig.
  static RouteData fromRedirectConfig(RedirectConfig config) {
    return RouteData(
      config.path,
      data: config.data,
      queryParameters: config.queryParameters,
      navigationType: config.navigationType,
      result: config.result,
      removeUntilPredicate: config.removeUntilPredicate,
      transitionType: config.transitionType,
      onPop: config.onPop,
    );
  }
}
