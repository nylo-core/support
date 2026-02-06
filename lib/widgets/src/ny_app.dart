import 'package:flutter/material.dart';
import '/localization/ny_localization.dart';
import '/themes/ny_themes.dart';

/// A unified widget that combines theme management and localization.
///
/// This simplifies the app entry point by wrapping your [MaterialApp] with
/// all necessary providers for themes and localization.
///
/// Example:
/// ```dart
/// class Main extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return NyApp(
///       child: (themeData, locale) => MaterialApp(
///         theme: themeData,
///         locale: locale,
///         localizationsDelegates: NyLocalization.instance.delegates,
///         supportedLocales: [Locale('en', 'US')],
///         home: HomePage(),
///       ),
///     );
///   }
/// }
/// ```
///
/// Or use the [materialApp] factory for a more complete setup:
/// ```dart
/// NyApp.materialApp(
///   navigatorKey: navigatorKey,
///   initialRoute: '/home',
///   onGenerateRoute: router.generator(),
///   onUnknownRoute: router.unknownRoute(),
///   navigatorObservers: [MyObserver()],
///   supportedLocales: [Locale('en', 'US'), Locale('es', 'ES')],
/// )
/// ```
class NyApp extends StatefulWidget {
  /// Builder function that receives theme data and locale.
  final Widget Function(ThemeData? themeData, Locale locale)? child;

  /// Duration of the theme transition animation.
  final Duration themeDuration;

  /// Curve of the theme transition animation.
  final Curve themeCurve;

  /// Background color shown during loading.
  final Color? backgroundColor;

  /// Create a new [NyApp] with a custom builder.
  const NyApp({
    super.key,
    required this.child,
    this.themeDuration = const Duration(milliseconds: 200),
    this.themeCurve = Curves.easeInOut,
    this.backgroundColor,
  });

  /// Factory constructor for a complete [MaterialApp] setup.
  ///
  /// This provides a fully configured [MaterialApp] with theme and
  /// localization support out of the box.
  static Widget materialApp({
    Key? key,
    GlobalKey<NavigatorState>? navigatorKey,
    String? initialRoute,
    Route<dynamic>? Function(RouteSettings settings)? onGenerateRoute,
    Route<dynamic>? Function(RouteSettings settings)? onUnknownRoute,
    List<NavigatorObserver> navigatorObservers = const [],
    List<Locale> supportedLocales = const [Locale('en', 'US')],
    ThemeMode themeMode = ThemeMode.system,
    bool debugShowCheckedModeBanner = false,
    bool debugShowMaterialGrid = false,
    bool showPerformanceOverlay = false,
    bool checkerboardRasterCacheImages = false,
    bool checkerboardOffscreenLayers = false,
    bool showSemanticsDebugger = false,
    Duration themeDuration = const Duration(milliseconds: 200),
    Curve themeCurve = Curves.easeInOut,
    Color? backgroundColor,
    Widget? home,
    String? title,
    Widget Function(BuildContext, Widget?)? builder,
    Locale? Function(Locale?, Iterable<Locale>)? localeResolutionCallback,
  }) {
    return NyApp(
      key: key,
      themeDuration: themeDuration,
      themeCurve: themeCurve,
      backgroundColor: backgroundColor,
      child: (themeData, locale) => MaterialApp(
        navigatorKey: navigatorKey,
        themeMode: themeMode,
        navigatorObservers: navigatorObservers,
        debugShowMaterialGrid: debugShowMaterialGrid,
        showPerformanceOverlay: showPerformanceOverlay,
        checkerboardRasterCacheImages: checkerboardRasterCacheImages,
        checkerboardOffscreenLayers: checkerboardOffscreenLayers,
        showSemanticsDebugger: showSemanticsDebugger,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        darkTheme: NyThemeManager.instance.darkTheme?.themeData,
        initialRoute: initialRoute,
        onGenerateRoute: onGenerateRoute,
        onUnknownRoute: onUnknownRoute,
        theme: themeData,
        home: home,
        title: title ?? '',
        builder: builder,
        localeResolutionCallback:
            localeResolutionCallback ??
            (Locale? locale, Iterable<Locale> supportedLocales) => locale,
        localizationsDelegates: NyLocalization.instance.delegates,
        locale: locale,
        supportedLocales: supportedLocales,
      ),
    );
  }

  /// Restart the app (useful after language changes).
  static void restart(BuildContext context) {
    context.findAncestorStateOfType<_NyAppState>()?.restart();
  }

  @override
  State<NyApp> createState() => _NyAppState();
}

class _NyAppState extends State<NyApp> {
  /// Key used to force rebuild the app.
  Key _key = UniqueKey();

  /// Locale notifier for reactive locale updates.
  late ValueNotifier<Locale> _localeNotifier;

  @override
  void initState() {
    super.initState();
    _localeNotifier = ValueNotifier(NyLocalization.instance.locale);
  }

  @override
  void dispose() {
    _localeNotifier.dispose();
    super.dispose();
  }

  /// Restart the app by regenerating the key.
  void restart() {
    setState(() {
      _key = UniqueKey();
      _localeNotifier.value = NyLocalization.instance.locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      color: widget.backgroundColor ?? Colors.white,
      child: ValueListenableBuilder<String>(
        valueListenable: NyThemeManager.instance.themeNotifier,
        builder: (context, themeId, _) {
          final themeData = NyThemeManager.instance.themeData;

          return ValueListenableBuilder<Locale>(
            valueListenable: _localeNotifier,
            builder: (context, locale, _) {
              if (widget.child != null) {
                // Wrap in AnimatedTheme for smooth transitions
                if (themeData != null) {
                  return AnimatedTheme(
                    data: themeData,
                    duration: widget.themeDuration,
                    curve: widget.themeCurve,
                    child: widget.child!(themeData, locale),
                  );
                }
                return widget.child!(themeData, locale);
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

/// Extension on [BuildContext] for easier theme and app access.
extension NyAppContext on BuildContext {
  /// Get the current theme data.
  ThemeData? get nyThemeData => NyThemeManager.instance.themeData;

  /// Get typed color styles.
  T nyColors<T>() => NyThemeManager.instance.colorStyles<T>();

  /// Check if current theme is dark.
  bool get nyIsDark => NyThemeManager.instance.isDark;

  /// Change the current theme.
  ///
  /// [themeId] - The ID of the theme to set.
  /// [remember] - If true, sets this theme as the preferred theme for its type
  ///              (light or dark). This is used when following system theme to
  ///              remember which theme variant the user prefers.
  Future<void> nySetTheme(String themeId, {bool remember = false}) async {
    await NyThemeManager.instance.setTheme(themeId, remember: remember);
  }

  /// Restart the app (e.g., after language change).
  void nyRestart() => NyApp.restart(this);
}
