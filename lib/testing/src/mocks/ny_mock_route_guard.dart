import '/router/ny_router.dart';

/// A mock route guard for testing NyPage route guard behavior.
///
/// Use [NyMockRouteGuard.pass] to create a guard that allows navigation,
/// or [NyMockRouteGuard.redirect] to create one that redirects.
///
/// ## Example
///
/// ```dart
/// // A guard that always passes
/// final guard = NyMockRouteGuard.pass();
///
/// // A guard that redirects to login
/// final guard = NyMockRouteGuard.redirect('/login');
///
/// // A guard with custom logic
/// final guard = NyMockRouteGuard.custom((context) async {
///   if (someCondition) return GuardResult.next;
///   return GuardResult.handled;
/// });
///
/// // Check if the guard was called
/// expect(guard.wasCalled, isTrue);
/// expect(guard.callCount, 1);
/// ```
class NyMockRouteGuard extends NyRouteGuard {
  final Future<GuardResult> Function(RouteContext context)? _onBeforeHandler;
  final String? _redirectPath;
  final dynamic _redirectData;

  int _callCount = 0;
  RouteContext? _lastContext;

  NyMockRouteGuard._({
    Future<GuardResult> Function(RouteContext context)? onBeforeHandler,
    String? redirectPath,
    dynamic redirectData,
  }) : _onBeforeHandler = onBeforeHandler,
       _redirectPath = redirectPath,
       _redirectData = redirectData;

  /// Create a guard that always allows navigation to continue.
  ///
  /// ```dart
  /// final guard = NyMockRouteGuard.pass();
  /// ```
  factory NyMockRouteGuard.pass() {
    return NyMockRouteGuard._();
  }

  /// Create a guard that always redirects to [path].
  ///
  /// ```dart
  /// final guard = NyMockRouteGuard.redirect('/login');
  /// final guard = NyMockRouteGuard.redirect('/error', data: {'code': 403});
  /// ```
  factory NyMockRouteGuard.redirect(String path, {dynamic data}) {
    return NyMockRouteGuard._(redirectPath: path, redirectData: data);
  }

  /// Create a guard with custom logic.
  ///
  /// The [handler] receives the [RouteContext] and should return a
  /// [GuardResult]. Use `next()` and `redirect()` from the guard instance
  /// inside the handler.
  ///
  /// ```dart
  /// final guard = NyMockRouteGuard.custom((context) async {
  ///   if (context.data == null) {
  ///     return GuardResult.handled; // abort
  ///   }
  ///   return GuardResult.next;
  /// });
  /// ```
  factory NyMockRouteGuard.custom(
    Future<GuardResult> Function(RouteContext context) handler,
  ) {
    return NyMockRouteGuard._(onBeforeHandler: handler);
  }

  @override
  Future<GuardResult> onBefore(RouteContext context) async {
    _callCount++;
    _lastContext = context;

    if (_onBeforeHandler != null) {
      return _onBeforeHandler(context);
    }

    if (_redirectPath != null) {
      return redirect(_redirectPath, data: _redirectData);
    }

    return next();
  }

  /// Whether this guard has been called at least once.
  bool get wasCalled => _callCount > 0;

  /// The number of times this guard has been called.
  int get callCount => _callCount;

  /// The [RouteContext] from the most recent call, or null if never called.
  RouteContext? get lastContext => _lastContext;

  /// Reset the call tracking state.
  void reset() {
    _callCount = 0;
    _lastContext = null;
  }
}
