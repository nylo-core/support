import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';

import '/helpers/ny_helpers.dart';
import '/nylo.dart';
import 'ny_navigator.dart';
import 'router_functions.dart';

/// Signature for the function that actually routes an incoming deep link.
/// Defaults to [routeTo]. Overridable in tests.
typedef DeepLinkDispatcher =
    void Function(String route, Map<String, dynamic> queryParameters);

/// Handles platform deep links (Android App Links / iOS Universal Links /
/// custom URL schemes / web URLs) and dispatches them through Nylo's router.
///
/// Enable via [Nylo.useDeepLinks]. The handler captures the cold-start URI on
/// [init] and subscribes to the warm-start URI stream on [listen]. Each URI
/// is offered to the developer's [Nylo.onIncomingLink] callback (if set),
/// then routed automatically when the callback returns `true` or is absent.
class NyDeepLinkHandler {
  NyDeepLinkHandler({
    this.fallbackRoute,
    @visibleForTesting AppLinks? appLinks,
    @visibleForTesting DeepLinkDispatcher? dispatcher,
  }) : _appLinks = appLinks ?? AppLinks(),
       _dispatch = dispatcher ?? _defaultDispatch;

  /// Route to navigate to when an incoming URI's path is not registered.
  /// If null, falls through to the router's unknown-route handler.
  final String? fallbackRoute;

  final AppLinks _appLinks;
  final DeepLinkDispatcher _dispatch;
  StreamSubscription<Uri>? _subscription;

  /// Replay the cold-start URI (if any) through the router.
  Future<void> init() async {
    final Uri? initial = await _appLinks.getInitialLink();
    if (initial != null) {
      await handle(initial);
    }
  }

  /// Subscribe to warm-start URIs.
  void listen() {
    _subscription?.cancel();
    _subscription = _appLinks.uriLinkStream.listen(
      handle,
      onError: (Object error) {
        NyLogger.error('Deep link stream error: $error');
      },
    );
  }

  /// Stop listening for warm-start URIs.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Offer the URI to the developer's callback, then dispatch automatically
  /// when allowed. Visible for testing; production code goes through
  /// [init] / [listen].
  @visibleForTesting
  Future<void> handle(Uri uri) async {
    try {
      final callback = Nylo.instance.onIncomingLinkAction;
      if (callback != null) {
        final shouldRoute = await callback(uri);
        if (!shouldRoute) return;
      }
      _navigate(uri);
    } catch (e) {
      NyLogger.error('Deep link handling failed for "$uri": $e');
    }
  }

  void _navigate(Uri uri) {
    final Map<String, dynamic> queryParameters = Map<String, dynamic>.from(
      uri.queryParameters,
    );
    final String path = _routePath(uri);
    final router = NyNavigator.instance.router;

    final String target = router.routeNameMappingsContains(path)
        ? path
        : (fallbackRoute ?? path);

    _dispatch(target, queryParameters);
  }

  /// Resolves the route path from an incoming [uri].
  ///
  /// http(s) URLs (App Links / Universal Links / web) route on [Uri.path].
  /// Custom schemes (`myapp://settings`) place the first path segment in
  /// [Uri.host], so it is folded back into the path here (`/settings`).
  static String _routePath(Uri uri) {
    final bool isWebUrl = uri.scheme == 'http' || uri.scheme == 'https';
    final String path = (isWebUrl || uri.host.isEmpty)
        ? uri.path
        : '/${uri.host}${uri.path}';
    return path.isEmpty ? '/' : path;
  }

  /// Default dispatcher: defers to [routeTo] after the next frame so the
  /// navigator is guaranteed to be mounted (handles cold-start where
  /// [init] resolves before `runApp` has built the tree).
  static void _defaultDispatch(
    String route,
    Map<String, dynamic> queryParameters,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      routeTo(route, queryParameters: queryParameters);
    });
  }
}
