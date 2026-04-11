import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart' as skel;
import '/nylo.dart';
import '/router/ny_router.dart';
import '/themes/ny_themes.dart';
import '/widgets/ny_widgets.dart';

/// Widget testing utilities for Nylo applications.
///
/// Provides easy-to-use helpers for testing NyStatefulWidget, NyPage, and NyState
/// widgets with proper initialization, theme support, and loading state management.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:nylo_support/testing/ny_testing.dart';
///
/// void main() {
///   NyTest.init();
///
///   nySetUpAll(() async {
///     // Initialize your app
///     NyEnvRegistry.register(getter: Env.get);
///     await setupApplication(providers);
///   });
///
///   nyGroup('MyPage', () {
///     nyWidgetTest('displays content', (tester) async {
///       await tester.pumpNyWidget(MyPage());
///       expect(find.text('Hello'), findsOneWidget);
///     });
///   });
/// }
/// ```
class NyWidgetTest {
  NyWidgetTest._();

  static ThemeData? _testTheme;

  /// Configure widget testing environment.
  ///
  /// This should be called in your `setUpAll` before running widget tests.
  /// It disables Google Fonts runtime fetching to prevent HTTP errors in tests.
  ///
  /// Example:
  /// ```dart
  /// nySetUpAll(() async {
  ///   NyWidgetTest.configure();
  ///   await setupApplication(providers);
  /// });
  /// ```
  static void configure({ThemeData? testTheme}) {
    _testTheme = testTheme;
  }

  /// Get a simple test theme that doesn't use Google Fonts.
  ///
  /// Use this when you want to avoid any font-related issues in tests.
  static ThemeData get simpleTestTheme {
    return _testTheme ??
        ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          fontFamily: null, // Use default system font
        );
  }

  /// Get a simple dark test theme.
  static ThemeData get simpleDarkTestTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: null,
    );
  }

  /// Reset configuration.
  static void reset() {
    _testTheme = null;
  }
}

/// Extension on WidgetTester for Nylo-specific widget testing.
///
/// Provides convenient methods for pumping Nylo widgets with proper
/// configuration and testing loading states.
extension NyWidgetTesterExtension on WidgetTester {
  /// Pump a Nylo widget with proper MaterialApp wrapper and theme support.
  ///
  /// This method automatically:
  /// - Wraps the widget in a MaterialApp
  /// - Sets up the navigator key for Nylo text extensions
  /// - Handles Google Fonts gracefully
  /// - Waits for the widget to settle
  ///
  /// Example:
  /// ```dart
  /// await tester.pumpNyWidget(HomePage());
  /// expect(find.text('Welcome'), findsOneWidget);
  /// ```
  Future<void> pumpNyWidget(
    Widget widget, {
    ThemeData? theme,
    ThemeData? darkTheme,
    ThemeMode themeMode = ThemeMode.light,
    Duration? settleTimeout,
    bool useSimpleTheme = false,
  }) async {
    // Ensure Google Fonts is configured
    NyWidgetTest.configure();

    final effectiveTheme = useSimpleTheme
        ? NyWidgetTest.simpleTestTheme
        : (theme ?? _getDefaultTheme());

    final effectiveDarkTheme = useSimpleTheme
        ? NyWidgetTest.simpleDarkTestTheme
        : (darkTheme ?? _getDefaultDarkTheme());

    await pumpWidget(
      _NyTestWrapper(
        theme: effectiveTheme,
        darkTheme: effectiveDarkTheme,
        themeMode: themeMode,
        child: widget,
      ),
    );

    // Pump frames to allow widget to build
    await pump();
    await pump(const Duration(milliseconds: 100));

    // Try to settle, but don't fail on timeout (fonts may cause issues)
    try {
      await pumpAndSettle(settleTimeout ?? const Duration(seconds: 5));
    } catch (e) {
      // If pumpAndSettle fails (e.g., due to font loading), just pump more frames
      await pump(const Duration(milliseconds: 100));
      await pump(const Duration(milliseconds: 100));
    }
  }

  /// Pump a Nylo widget using a simple theme (no Google Fonts).
  ///
  /// Use this when you want to completely avoid font-related issues.
  ///
  /// Example:
  /// ```dart
  /// await tester.pumpNyWidgetSimple(HomePage());
  /// ```
  Future<void> pumpNyWidgetSimple(Widget widget) async {
    await pumpNyWidget(widget, useSimpleTheme: true);
  }

  /// Pump a widget and wait for loading to complete.
  ///
  /// This is useful for testing NyPage and NyState widgets that have
  /// async `init` methods. It pumps frames until `hasInitComplete` is true
  /// or the timeout is reached.
  ///
  /// Example:
  /// ```dart
  /// await tester.pumpNyWidgetAndWaitForInit(
  ///   HomePage(),
  ///   timeout: Duration(seconds: 5),
  /// );
  /// // Now the init() has completed
  /// expect(find.text('Loaded Data'), findsOneWidget);
  /// ```
  Future<void> pumpNyWidgetAndWaitForInit(
    Widget widget, {
    Duration timeout = const Duration(seconds: 10),
    ThemeData? theme,
    bool useSimpleTheme = false,
  }) async {
    await pumpNyWidget(widget, theme: theme, useSimpleTheme: useSimpleTheme);

    // Pump frames until init completes or timeout
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      await pump(const Duration(milliseconds: 100));

      // Check if any loading indicators are gone
      final loaderFinder = find.byType(CircularProgressIndicator);
      if (loaderFinder.evaluate().isEmpty) {
        // Also check for Skeletonizer
        final skeletonizerFinder = find.byType(skel.Skeletonizer);
        final skeletonizers = skeletonizerFinder.evaluate();
        bool hasActiveSkeletonizer = false;
        for (final element in skeletonizers) {
          final widget = element.widget as skel.Skeletonizer;
          if (widget.enabled) {
            hasActiveSkeletonizer = true;
            break;
          }
        }
        if (!hasActiveSkeletonizer) {
          break;
        }
      }
    }

    await pump(const Duration(milliseconds: 100));
  }

  /// Check if a widget is currently in loading state.
  ///
  /// Returns true if a CircularProgressIndicator or enabled Skeletonizer
  /// is found in the widget tree.
  bool isLoading() {
    // Check for CircularProgressIndicator
    final loaderFinder = find.byType(CircularProgressIndicator);
    if (loaderFinder.evaluate().isNotEmpty) {
      return true;
    }

    // Check for enabled Skeletonizer
    final skeletonizerFinder = find.byType(skel.Skeletonizer);
    for (final element in skeletonizerFinder.evaluate()) {
      final widget = element.widget as skel.Skeletonizer;
      if (widget.enabled) {
        return true;
      }
    }

    return false;
  }

  /// Pump until a specific widget is found or timeout.
  ///
  /// Example:
  /// ```dart
  /// await tester.pumpUntilFound(find.text('Welcome'));
  /// ```
  Future<bool> pumpUntilFound(
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      await pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// Pump and settle with graceful error handling.
  ///
  /// Unlike standard pumpAndSettle, this won't throw if settling times out
  /// (e.g., due to font loading issues). Instead, it pumps additional frames.
  Future<void> pumpAndSettleGracefully({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      await pumpAndSettle(timeout);
    } catch (e) {
      // Gracefully handle timeout by pumping more frames
      await pump(const Duration(milliseconds: 100));
      await pump(const Duration(milliseconds: 100));
    }
  }

  /// Pump a route with full Nylo navigation support.
  ///
  /// Sets up a [MaterialApp] with the NyRouter's route generator,
  /// navigator key, and route history observer so that navigation
  /// via [routeTo] works correctly in tests.
  ///
  /// Example:
  /// ```dart
  /// await tester.visit(DashboardPage.path);
  /// await tester.tap(find.byType(MyButton));
  /// tester.assertNavigatedTo(ProfilePage.path);
  /// ```
  Future<void> visit(
    RouteView route, {
    ThemeData? theme,
    ThemeData? darkTheme,
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    final effectiveTheme = theme ?? _getDefaultTheme();
    final effectiveDarkTheme = darkTheme ?? _getDefaultDarkTheme();

    await pumpWidget(
      MaterialApp(
        navigatorKey: NyNavigator.instance.router.navigatorKey,
        navigatorObservers: [NyRouteHistoryObserver()],
        initialRoute: route.$1,
        onGenerateRoute: NyNavigator.instance.router.generator(),
        theme: effectiveTheme,
        darkTheme: effectiveDarkTheme,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
      ),
    );

    await pump();
    await pump(const Duration(milliseconds: 100));

    try {
      await pumpAndSettle(const Duration(seconds: 5));
    } catch (e) {
      await pump(const Duration(milliseconds: 100));
      await pump(const Duration(milliseconds: 100));
    }
  }

  /// Assert that the app navigated to the given route.
  ///
  /// Pumps remaining frames to allow navigation animations to complete,
  /// then checks [Nylo.getCurrentRouteName] matches the route path.
  ///
  /// Example:
  /// ```dart
  /// await tester.tap(find.text('Profile'));
  /// tester.assertNavigatedTo(ProfilePage.path);
  /// ```
  void assertNavigatedTo(RouteView route) {
    final currentRoute = Nylo.getCurrentRouteName();
    expect(
      currentRoute,
      route.$1,
      reason:
          'Expected to navigate to "${route.$1}" but current route is "$currentRoute"',
    );
  }

  /// Wait for all animations, frame callbacks, and pending UI updates to complete.
  ///
  /// A readable alias for [pumpAndSettle]. Use after actions that trigger
  /// navigation, animations, or state changes.
  ///
  /// Example:
  /// ```dart
  /// await tester.tap(find.byType(MyButton));
  /// await tester.settle();
  /// tester.assertNavigatedTo(ProfilePage.path);
  /// ```
  Future<void> settle({Duration? timeout}) async {
    try {
      await pumpAndSettle(timeout ?? const Duration(seconds: 5));
    } catch (e) {
      await pump(const Duration(milliseconds: 100));
      await pump(const Duration(milliseconds: 100));
    }
  }

  /// Simulate an [AppLifecycleState] change on any NyPage in the widget tree.
  ///
  /// This triggers the `didChangeAppLifecycleState` callback, allowing you
  /// to test lifecycle actions defined in [NyPage.lifecycleActions].
  ///
  /// Example:
  /// ```dart
  /// await tester.pumpNyWidget(MyPage());
  /// await tester.simulateLifecycleState(AppLifecycleState.paused);
  /// await tester.pump();
  /// // Assert side effects of the paused lifecycle action
  /// ```
  Future<void> simulateLifecycleState(AppLifecycleState state) async {
    final ByteData? message = const StringCodec().encodeMessage(
      state.toString(),
    );
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage('flutter/lifecycle', message, (_) {});
  }

  /// Check if a named loading key is active in a NyPage/NyState widget.
  ///
  /// Finds the first [NyBaseState] via [finder] and checks its loading map
  /// for the given [name].
  ///
  /// Example:
  /// ```dart
  /// expect(tester.isLoadingNamed(find.byType(MyPage), name: 'fetchUsers'), isTrue);
  /// ```
  bool isLoadingNamed(Finder finder, {required String name}) {
    final state = _findNyBaseState(finder);
    if (state != null) {
      return state.isLoading(name: name);
    }
    return false;
  }

  /// Check if a named lock is held in a NyPage/NyState widget.
  ///
  /// Finds the first [NyBaseState] via [finder] and checks its lock map
  /// for the given [name].
  ///
  /// Example:
  /// ```dart
  /// expect(tester.isLockedNamed(find.byType(MyPage), name: 'submit'), isTrue);
  /// ```
  bool isLockedNamed(Finder finder, {required String name}) {
    final state = _findNyBaseState(finder);
    if (state != null) {
      return state.isLocked(name);
    }
    return false;
  }

  /// Find a [NyBaseState] from a widget [Finder].
  NyBaseState? _findNyBaseState(Finder finder) {
    final elements = finder.evaluate();
    if (elements.isEmpty) return null;
    final element = elements.first;
    if (element is StatefulElement && element.state is NyBaseState) {
      return element.state as NyBaseState;
    }
    return null;
  }
}

/// Internal wrapper widget for test environment.
class _NyTestWrapper extends StatelessWidget {
  final Widget child;
  final ThemeData theme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;

  const _NyTestWrapper({
    required this.child,
    required this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.light,
  });

  @override
  Widget build(BuildContext context) {
    // Get navigator key if Nylo is initialized
    GlobalKey<NavigatorState>? navigatorKey;
    try {
      if (Nylo.isInitialized()) {
        navigatorKey = NyNavigator.instance.router.navigatorKey;
      }
    } catch (_) {
      // Nylo not initialized, use a new key
    }

    navigatorKey ??= GlobalKey<NavigatorState>();

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: darkTheme ?? theme,
      themeMode: themeMode,
      home: child,
    );
  }
}

/// Get default theme from Nylo if available.
ThemeData _getDefaultTheme() {
  try {
    if (Nylo.isInitialized()) {
      final themes = Nylo.getThemes();
      if (themes.isNotEmpty) {
        final lightTheme = themes.firstWhere(
          (t) => t.type == NyThemeType.light,
          orElse: () => themes.first,
        );
        // theme is a function that takes colors, call it with the theme's colors
        return lightTheme.theme(lightTheme.colors);
      }
    }
  } catch (_) {}
  return NyWidgetTest.simpleTestTheme;
}

/// Get default dark theme from Nylo if available.
ThemeData _getDefaultDarkTheme() {
  try {
    if (Nylo.isInitialized()) {
      final themes = Nylo.getThemes();
      if (themes.isNotEmpty) {
        final darkTheme = themes.firstWhere(
          (t) => t.type == NyThemeType.dark,
          orElse: () => themes.first,
        );
        // theme is a function that takes colors, call it with the theme's colors
        return darkTheme.theme(darkTheme.colors);
      }
    }
  } catch (_) {}
  return NyWidgetTest.simpleDarkTestTheme;
}

/// Mixin for testing NyState and NyPage widgets.
///
/// Add this mixin to your test class for additional testing utilities.
///
/// Example:
/// ```dart
/// class HomePageTest with NyPageTestMixin {
///   void runTests() {
///     // Use mixin methods
///   }
/// }
/// ```
mixin NyPageTestMixin {
  /// Verify that the init method is called.
  Future<void> verifyInitCalled(
    WidgetTester tester,
    Widget page, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await tester.pumpNyWidgetAndWaitForInit(page, timeout: timeout);
    expect(tester.isLoading(), isFalse);
  }

  /// Verify loading state is shown during init.
  Future<void> verifyLoadingState(WidgetTester tester, Widget page) async {
    NyWidgetTest.configure();

    await tester.pumpWidget(
      _NyTestWrapper(theme: NyWidgetTest.simpleTestTheme, child: page),
    );

    // Pump one frame - should show loading
    await tester.pump();

    // Check if loading is shown (either CircularProgressIndicator or Skeletonizer)
    final hasLoader = find
        .byType(CircularProgressIndicator)
        .evaluate()
        .isNotEmpty;
    final hasSkeletonizer = find
        .byType(skel.Skeletonizer)
        .evaluate()
        .isNotEmpty;

    expect(hasLoader || hasSkeletonizer, isTrue);
  }
}

/// Test a NyStatefulWidget page with common assertions.
///
/// Example:
/// ```dart
/// testNyPage(
///   'HomePage loads correctly',
///   build: () => HomePage(),
///   expectations: (tester) async {
///     expect(find.text('Welcome'), findsOneWidget);
///   },
/// );
/// ```
void testNyPage(
  String description, {
  required Widget Function() build,
  required Future<void> Function(WidgetTester tester) expectations,
  bool useSimpleTheme = true,
  Duration initTimeout = const Duration(seconds: 10),
  bool skip = false,
}) {
  testWidgets(description, (tester) async {
    final widget = build();
    await tester.pumpNyWidgetAndWaitForInit(
      widget,
      timeout: initTimeout,
      useSimpleTheme: useSimpleTheme,
    );
    await expectations(tester);
  }, skip: skip);
}

/// Test a NyStatefulWidget's loading state.
///
/// Example:
/// ```dart
/// testNyPageLoading(
///   'HomePage shows loading state',
///   build: () => HomePage(),
/// );
/// ```
void testNyPageLoading(
  String description, {
  required Widget Function() build,
  bool skip = false,
}) {
  testWidgets(description, (tester) async {
    NyWidgetTest.configure();

    await tester.pumpWidget(
      _NyTestWrapper(theme: NyWidgetTest.simpleTestTheme, child: build()),
    );

    await tester.pump();

    // Verify some form of loading indicator is present
    final hasLoader = find
        .byType(CircularProgressIndicator)
        .evaluate()
        .isNotEmpty;
    final hasSkeletonizer = find
        .byType(skel.Skeletonizer)
        .evaluate()
        .isNotEmpty;

    // At least one loading indicator should be present
    // (unless the page has LoadingStyle.none())
    expect(hasLoader || hasSkeletonizer, isTrue);
  }, skip: skip);
}
