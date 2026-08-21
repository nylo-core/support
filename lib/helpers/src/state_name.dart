import '/router/ny_router.dart';
import 'ny_logger.dart';

/// Type names that identify no page.
///
/// A route builder declared as `Widget Function(BuildContext)` - a tear-off of
/// a named function, or a variable typed as the [RouteView] signature - carries
/// its *declared* return type at runtime rather than the class it builds, so
/// one of these names is all a route can offer about the page behind it.
const Set<String> _typeNamesThatNameNoPage = {
  'Widget',
  'StatefulWidget',
  'StatelessWidget',
  'PreferredSizeWidget',
  'InheritedWidget',
  'Object',
  'dynamic',
  'Never',
};

/// Route paths already reported, so a route addressed on every navigation is
/// only reported the first time.
final Set<String> _reportedRoutes = {};

/// The state name a page listens on, built from the page's **widget** class.
///
/// e.g. `MyPage` -> `Closure: () => _MyPageState`
///
/// Every state name in the framework resolves through this function, so the
/// listening end ([NyPage], [NyState]) and the sending end
/// ([RouteViewExt.stateName], [updateState] with a [RouteView], [StateAction])
/// always build the same string from the same class.
///
/// The widget class is the anchor because it is the only class both ends can
/// see: a sender holds a [RouteView], which knows the widget it builds and
/// nothing about the state behind it. Reading one class on one end and a
/// different class on the other end only agrees while class names survive -
/// `flutter build --obfuscate` renames a widget and its state to two unrelated
/// symbols, which is why both ends now read the widget.
String nyStateNameForWidget(String widgetTypeName) =>
    "Closure: ${nyStateSignatureForWidget(widgetTypeName)}";

/// The closure signature part of a state name, without the `Closure: ` prefix.
///
/// e.g. `MyPage` -> `() => _MyPageState`
String nyStateSignatureForWidget(String widgetTypeName) =>
    "() => _${widgetTypeName}State";

/// The name of the widget class a [routeView] builds.
///
/// e.g. `("/my-page", (_) => MyPage())` -> `MyPage`
String nyWidgetTypeNameForRoute(RouteView routeView) {
  /// The builder's runtime type reads `(BuildContext) => MyPage`, so the
  /// widget class is whatever the signature returns.
  String signature = routeView.$2.runtimeType.toString();
  return signature.split(" => ").last.trim();
}

/// Whether the page a [routeView] builds can be read back from the route.
///
/// True for `("/my-page", (_) => MyPage())`, where the closure returns the page
/// and carries it in its runtime type. False for a builder declared to return
/// [Widget] - a tear-off of a named function, or a variable typed as the
/// [RouteView] signature - which carries that declared type instead, and so
/// names no page.
///
/// A route that answers false is addressed by a name of its own, given to the
/// page and used by every sender:
///
/// ```dart
/// class MyPage extends NyStatefulWidget {
///   static const String stateKey = "/my-page";
///
///   MyPage({super.key})
///       : super(child: () => _MyPageState(), stateName: stateKey);
/// }
/// ```
bool nyRouteIdentifiesItsPage(RouteView routeView) =>
    !_typeNamesThatNameNoPage.contains(nyWidgetTypeNameForRoute(routeView));

/// The state name a page listens on, built from the [routeView] that creates it.
///
/// e.g. `("/my-page", (_) => MyPage())` -> `Closure: () => _MyPageState`
///
/// Reports a route whose builder names no page - see
/// [nyRouteIdentifiesItsPage] - because the name built from it reaches nothing
/// and would otherwise be dropped by the event bus in silence.
String nyStateNameForRoute(RouteView routeView) {
  String widgetTypeName = nyWidgetTypeNameForRoute(routeView);

  if (_typeNamesThatNameNoPage.contains(widgetTypeName)) {
    _reportRouteThatNamesNoPage(routeView.$1, widgetTypeName);
  }

  return nyStateNameForWidget(widgetTypeName);
}

/// Report the route at [path], once, and name the two ways to address it.
void _reportRouteThatNamesNoPage(String path, String widgetTypeName) {
  if (_reportedRoutes.contains(path)) return;

  try {
    NyLogger.error(
      'The route "$path" is built by a function declared to return '
      '$widgetTypeName, so the page it builds cannot be read back from the '
      'route and "${nyStateNameForWidget(widgetTypeName)}" is a name no page '
      'listens on - state updates sent to it will not arrive. '
      'Build the route from a closure that returns the page, '
      '("$path", (_) => MyPage()), or give the page a name of its own and '
      'address it by that name, '
      'MyPage({super.key}) : super(child: () => _MyPageState(), '
      'stateName: "$path");',
      alwaysPrint: true,
    );
    _reportedRoutes.add(path);
  } catch (_) {
    /// Building a name has to hold whether or not the logger can print yet:
    /// `stateName()` runs from static initializers, e.g.
    /// `static NavigationHubStateActions stateActions =
    /// NavigationHubStateActions(path.stateName());`, which run before the app
    /// registers its env. The route stays unreported so the next call, once
    /// the app has booted, reports it.
  }
}
