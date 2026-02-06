import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '/helpers/ny_helpers.dart';
import '/localization/ny_localization.dart';
import '/nylo.dart';
import 'mocks/ny_mock_api.dart';
import 'mocks/ny_mock_channels.dart';
import 'mocks/ny_test_cache.dart';
import 'ny_time.dart';
import 'ny_widget_test.dart';

/// Main testing orchestrator for Nylo testing framework.
///
/// Provides PHPUnit/Pest-like testing syntax with automatic setup,
/// teardown, mocking, and test isolation.
///
/// Example:
/// ```dart
/// void main() {
///   NyTest.init();
///
///   nyTest('user can login', () async {
///     NyTest.actingAs(User(id: 1, name: 'Test'));
///     expectAuthenticated<User>();
///   });
///
///   nyTest('can time travel', () async {
///     NyTest.travel(DateTime(2025, 1, 1));
///     expect(NyTime.now().year, 2025);
///     NyTest.travelBack();
///   });
/// }
/// ```
class NyTest {
  static bool _initialized = false;
  static dynamic _currentUser;
  static String? _originalLocale;
  static final Map<String, dynamic> _testState = {};

  /// Initialize the Nylo testing framework.
  ///
  /// This should be called once at the beginning of your test file.
  /// It sets up:
  /// - Test mode flag
  /// - Flutter test bindings
  /// - Auto-mocked platform channels
  /// - In-memory cache
  /// - Google Fonts configuration (disables HTTP requests)
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   NyTest.init();
  ///
  ///   nySetUpAll(() async {
  ///     NyEnvRegistry.register(getter: Env.get);
  ///     await setupApplication(providers);
  ///   });
  ///
  ///   nyWidgetTest('my test', (tester) async {
  ///     await tester.pumpNyWidget(MyPage());
  ///     expect(find.text('Hello'), findsOneWidget);
  ///   });
  /// }
  /// ```
  static void init({bool autoReset = true, bool disableGoogleFonts = true}) {
    TestWidgetsFlutterBinding.ensureInitialized();
    Nylo.isTestMode = true;
    NyMockChannels.setup();

    // Configure widget testing (disables Google Fonts HTTP requests)
    if (disableGoogleFonts) {
      NyWidgetTest.configure();
    }

    _initialized = true;

    if (autoReset) {
      setUp(() {
        // Fresh state for each test
      });

      tearDown(() {
        reset();
      });
    }
  }

  /// Reset all test state.
  ///
  /// This is automatically called in tearDown when autoReset is true.
  /// Clears:
  /// - Current authenticated user
  /// - Time mocks
  /// - API mocks
  /// - In-memory cache
  /// - Backpack state
  /// - Locale changes
  static void reset() {
    _currentUser = null;
    NyTime.reset();
    NyMockApi.clear();
    NyTestCache.resetInstance();
    NyMockChannels.reset();
    Backpack.instance.deleteAll();
    _testState.clear();

    // Reset locale if it was changed
    if (_originalLocale != null) {
      // Locale reset handled by framework
      _originalLocale = null;
    }
  }

  /// Set an authenticated user for the current test.
  ///
  /// Example:
  /// ```dart
  /// NyTest.actingAs<User>(User(id: 1, name: 'Test User'));
  /// // Now Nylo.user<User>() returns this user
  /// ```
  static void actingAs<T>(T user, {String? key}) {
    _currentUser = user;

    // Try to get auth key from Nylo if initialized, otherwise use default
    String authKey = key ?? 'auth_user';
    if (Nylo.isInitialized()) {
      authKey = key ?? Nylo.instance.getAuthKey() ?? 'auth_user';
    }

    Backpack.instance.save(authKey, user);

    // Also set auth key if Nylo is initialized and key not already set
    if (Nylo.isInitialized() && Nylo.instance.getAuthKey() == null) {
      Nylo.instance.addAuthKey(authKey);
    }
  }

  /// Get the currently acting user.
  static T? actingUser<T>() {
    if (_currentUser is T) {
      return _currentUser as T;
    }
    return null;
  }

  /// Clear the authenticated user.
  static void logout() {
    if (Nylo.isInitialized()) {
      final authKey = Nylo.instance.getAuthKey();
      if (authKey != null) {
        Backpack.instance.delete(authKey);
      }
    }
    _currentUser = null;
  }

  /// Mock an API service type.
  ///
  /// Example:
  /// ```dart
  /// NyTest.mockApi<UserApiService>((request) async {
  ///   if (request.endpoint == '/users/1') {
  ///     return {'id': 1, 'name': 'John'};
  ///   }
  ///   return null;
  /// });
  /// ```
  static void mockApi<T>(MockApiHandler handler) {
    NyMockApi.register<T>(handler);
  }

  /// Execute code with a temporary locale.
  ///
  /// Example:
  /// ```dart
  /// await NyTest.withLocale('es', () async {
  ///   expect('hello'.tr(), 'hola');
  /// });
  /// ```
  static Future<T> withLocale<T>(
    String locale,
    Future<T> Function() callback,
  ) async {
    _originalLocale = NyLocalization.instance.languageCode;
    await NyLocalization.instance.setLocale(locale: Locale(locale));
    try {
      return await callback();
    } finally {
      if (_originalLocale != null) {
        await NyLocalization.instance.setLocale(
          locale: Locale(_originalLocale!),
        );
      }
    }
  }

  /// Travel to a specific point in time.
  ///
  /// Example:
  /// ```dart
  /// NyTest.travel(DateTime(2025, 1, 1));
  /// expect(NyTime.now().year, 2025);
  /// ```
  static void travel(DateTime date) {
    NyTime.setTestNow(date);
  }

  /// Travel forward in time by a duration.
  ///
  /// Example:
  /// ```dart
  /// NyTest.travelForward(Duration(days: 30));
  /// ```
  static void travelForward(Duration duration) {
    NyTime.advanceBy(duration);
  }

  /// Travel backward in time by a duration.
  ///
  /// Example:
  /// ```dart
  /// NyTest.travelBack(Duration(days: 30));
  /// ```
  static void travelBackward(Duration duration) {
    NyTime.rewindBy(duration);
  }

  /// Reset time to use real system time.
  static void travelBack() {
    NyTime.reset();
  }

  /// Freeze time at the current moment.
  static void freezeTime() {
    NyTime.freeze();
  }

  /// Dump current test state to console.
  ///
  /// Prints:
  /// - Backpack contents
  /// - Current route
  /// - Mocked APIs
  /// - Time state
  /// - Cache contents
  static void dump() {
    print('╔════════════════════════════════════════════════════════════════╗');
    print('║                    NyTest State Dump                           ║');
    print('╠════════════════════════════════════════════════════════════════╣');

    // Test mode
    print('║ Test Mode: ${Nylo.isTestMode}');

    // Current user
    print('║ Acting As: ${_currentUser ?? 'Guest'}');

    // Time
    print('║ Time Frozen: ${NyTime.isFrozen}');
    if (NyTime.isFrozen) {
      print('║ Test Time: ${NyTime.now().toIso8601String()}');
    }

    // Backpack
    print('╠════════════════════════════════════════════════════════════════╣');
    print('║ Backpack Contents:');
    // Can't easily enumerate Backpack, but we can check common keys
    if (Nylo.isInitialized()) {
      print('║   - nylo: initialized');
    }
    if (_currentUser != null) {
      print('║   - auth_user: $_currentUser');
    }

    // Current route
    print('╠════════════════════════════════════════════════════════════════╣');
    print('║ Current Route: ${Nylo.getCurrentRouteName() ?? 'None'}');

    // Route history
    final history = Nylo.getRouteHistory();
    if (history.isNotEmpty) {
      print('║ Route History:');
      for (final route in history) {
        print('║   - ${route['name']}');
      }
    }

    // API mocks
    print('╠════════════════════════════════════════════════════════════════╣');
    print(
      '║ API Mocks: ${NyMockApi.handlerCount} handlers, ${NyMockApi.patternCount} patterns',
    );

    // API call history
    final calls = NyMockApi.getCalls();
    if (calls.isNotEmpty) {
      print('║ API Call History:');
      for (final call in calls) {
        print('║   - ${call.method} ${call.endpoint}');
      }
    }

    // Cache
    final cache = NyTestCache.getInstance();
    print('╠════════════════════════════════════════════════════════════════╣');
    print('║ Cache: ${cache.count} entries');
    if (cache.isNotEmpty) {
      print('║ Cache Keys:');
      for (final key in cache.entries.keys) {
        print('║   - $key');
      }
    }

    print('╚════════════════════════════════════════════════════════════════╝');
  }

  /// Dump state and throw an exception (like Laravel's dd()).
  ///
  /// Useful for debugging failed tests.
  static Never dd() {
    dump();
    throw StateError('Test execution stopped by dd()');
  }

  /// Store a value in test state.
  static void set(String key, dynamic value) {
    _testState[key] = value;
  }

  /// Get a value from test state.
  static T? get<T>(String key) {
    return _testState[key] as T?;
  }

  /// Check if test framework is initialized.
  static bool get isInitialized => _initialized;

  /// Get the in-memory cache instance.
  static NyTestCache get cache => NyTestCache.getInstance();

  /// Seed backpack with test data.
  static void seedBackpack(Map<String, dynamic> data) {
    for (final entry in data.entries) {
      Backpack.instance.save(entry.key, entry.value);
    }
  }

  /// Assert and return the result.
  static T assertReturns<T>(T value, dynamic matcher) {
    expect(value, matcher);
    return value;
  }
}

/// Pest-style test wrapper for Nylo tests.
///
/// Provides a clean syntax for writing tests:
/// ```dart
/// nyTest('user can register', () async {
///   // test code
/// });
/// ```
void nyTest(
  String description,
  Future<void> Function() callback, {
  bool skip = false,
  dynamic tags,
  Timeout? timeout,
}) {
  test(
    description,
    () async {
      await callback();
    },
    skip: skip,
    tags: tags,
    timeout: timeout,
  );
}

/// Pest-style group wrapper.
void nyGroup(String description, void Function() callback) {
  group(description, callback);
}

/// Pest-style widget test wrapper with Patrol integration.
///
/// This wraps the standard patrolWidgetTest for consistent syntax:
/// ```dart
/// nyWidgetTest('can tap login button', ($) async {
///   await $.pumpWidget(MyApp());
///   await $.tap(find.text('Login'));
/// });
/// ```
///
/// Note: Requires patrol package to be installed.
void nyWidgetTest(
  String description,
  Future<void> Function(WidgetTester tester) callback, {
  bool skip = false,
  dynamic tags,
  Timeout? timeout,
}) {
  testWidgets(
    description,
    (WidgetTester tester) async {
      await callback(tester);
    },
    skip: skip,
    tags: tags,
    timeout: timeout,
  );
}

/// Execute a callback before each test in the current group.
void nySetUp(void Function() callback) {
  setUp(callback);
}

/// Execute a callback after each test in the current group.
void nyTearDown(void Function() callback) {
  tearDown(callback);
}

/// Execute a callback once before all tests in the current group.
void nySetUpAll(void Function() callback) {
  setUpAll(callback);
}

/// Execute a callback once after all tests in the current group.
void nyTearDownAll(void Function() callback) {
  tearDownAll(callback);
}

/// Skip a test with a reason.
void nySkip(
  String description,
  Future<void> Function() callback,
  String reason,
) {
  test(description, () async {}, skip: reason);
}

/// Mark a test as expected to fail.
void nyFailing(String description, Future<void> Function() callback) {
  test(description, () async {
    try {
      await callback();
      fail('Expected test to fail but it passed');
    } catch (e) {
      // Expected to fail
    }
  });
}

/// Run a test only in CI environment.
void nyCi(String description, Future<void> Function() callback) {
  final isCI = const bool.fromEnvironment('CI', defaultValue: false);
  test(description, () async {
    await callback();
  }, skip: !isCI ? 'Only runs in CI' : null);
}
