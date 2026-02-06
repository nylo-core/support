import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '/helpers/ny_helpers.dart';
import '/localization/ny_localization.dart';
import '/nylo.dart';
import '/widgets/ny_widgets.dart';
import 'mocks/ny_mock_api.dart';

/// Test helper utilities for Nylo testing.
///
/// Provides assertion methods for common testing scenarios:
/// - Route assertions
/// - Backpack state assertions
/// - Environment variable assertions
/// - Authentication assertions
/// - API call assertions
/// - Locale assertions
///
/// Example:
/// ```dart
/// expectRoute('/home');
/// expectBackpackContains('user');
/// expectAuthenticated<User>();
/// expectApiCalled<UserApiService>(endpoint: '/users', times: 1);
/// ```

/// Assert that the current route matches the expected route.
void expectRoute(String route) {
  final currentRoute = Nylo.getCurrentRouteName();
  expect(
    currentRoute,
    route,
    reason: 'Expected route "$route" but was "$currentRoute"',
  );
}

/// Assert that the current route is not the specified route.
void expectNotRoute(String route) {
  final currentRoute = Nylo.getCurrentRouteName();
  expect(
    currentRoute,
    isNot(route),
    reason: 'Expected route to not be "$route"',
  );
}

/// Assert that the route history contains a specific route.
void expectRouteInHistory(String route) {
  final history = Nylo.getRouteHistory();
  final routeNames = history.map((r) => r['name']).toList();
  expect(
    routeNames,
    contains(route),
    reason: 'Expected route "$route" in history but found: $routeNames',
  );
}

/// Assert that Backpack contains a specific key.
void expectBackpackContains(String key, {dynamic value}) {
  expect(
    Backpack.instance.contains(key),
    isTrue,
    reason: 'Expected Backpack to contain key "$key"',
  );

  if (value != null) {
    expect(
      Backpack.instance.read(key),
      value,
      reason: 'Expected Backpack key "$key" to have value "$value"',
    );
  }
}

/// Assert that Backpack does not contain a specific key.
void expectBackpackNotContains(String key) {
  expect(
    Backpack.instance.contains(key),
    isFalse,
    reason: 'Expected Backpack to not contain key "$key"',
  );
}

/// Assert that an environment variable has a specific value.
void expectEnv(String key, dynamic expectedValue) {
  final actualValue = getEnv(key);
  expect(
    actualValue,
    expectedValue,
    reason: 'Expected env "$key" to be "$expectedValue" but was "$actualValue"',
  );
}

/// Assert that an environment variable is set (not null).
void expectEnvSet(String key) {
  final value = getEnv(key);
  expect(value, isNotNull, reason: 'Expected env "$key" to be set');
}

/// Assert that Nylo is initialized.
void expectNyloInitialized() {
  expect(
    Nylo.isInitialized(),
    isTrue,
    reason: 'Expected Nylo to be initialized',
  );
}

/// Assert that a user is authenticated.
void expectAuthenticated<T>() {
  final user = Nylo.user<T>();
  expect(
    user,
    isNotNull,
    reason: 'Expected user of type $T to be authenticated',
  );
}

/// Assert that no user is authenticated (guest).
void expectGuest() {
  try {
    final user = Nylo.user();
    expect(user, isNull, reason: 'Expected no authenticated user (guest)');
  } catch (_) {
    // Auth key not set, which also means guest
  }
}

/// Assert that an API endpoint was called.
void expectApiCalled(String endpoint, {String? method, int? times}) {
  final wasCalled = NyMockApi.wasCalled(endpoint, method: method, times: times);
  if (times != null) {
    expect(
      wasCalled,
      isTrue,
      reason: 'Expected "$endpoint" to be called $times time(s)',
    );
  } else {
    expect(
      wasCalled,
      isTrue,
      reason: 'Expected "$endpoint" to have been called',
    );
  }
}

/// Assert that an API endpoint was not called.
void expectApiNotCalled(String endpoint, {String? method}) {
  final wasCalled = NyMockApi.wasCalled(endpoint, method: method);
  expect(
    wasCalled,
    isFalse,
    reason: 'Expected "$endpoint" to not have been called',
  );
}

/// Assert that the current locale matches.
void expectLocale(String locale) {
  final currentLocale = NyLocalization.instance.languageCode;
  expect(
    currentLocale,
    locale,
    reason: 'Expected locale "$locale" but was "$currentLocale"',
  );
}

/// Assert that a route exists in the router.
void expectRouteExists(String route) {
  expect(
    Nylo.containsRoute(route),
    isTrue,
    reason: 'Expected route "$route" to exist',
  );
}

/// Assert that routes exist in the router.
void expectRoutesExist(List<String> routes) {
  expect(
    Nylo.containsRoutes(routes),
    isTrue,
    reason: 'Expected routes $routes to exist',
  );
}

/// Assert that Nylo is in test mode.
void expectTestMode() {
  expect(Nylo.isTestMode, isTrue, reason: 'Expected Nylo to be in test mode');
}

/// Assert that Nylo is in debug mode.
void expectDebugMode() {
  expect(
    Nylo.isDebuggingEnabled(),
    isTrue,
    reason: 'Expected Nylo to be in debug mode',
  );
}

/// Assert that Nylo is in production mode.
void expectProductionMode() {
  expect(
    Nylo.isEnvProduction(),
    isTrue,
    reason: 'Expected Nylo to be in production mode',
  );
}

/// Assert that Nylo is in developing mode.
void expectDevelopingMode() {
  expect(
    Nylo.isEnvDeveloping(),
    isTrue,
    reason: 'Expected Nylo to be in developing mode',
  );
}

/// Matcher for checking if an object is of a specific type.
TypeMatcher<T> isType<T>() => isA<T>();

/// Custom matcher for route name.
Matcher hasRouteName(String name) => _HasRouteName(name);

class _HasRouteName extends Matcher {
  final String expectedName;

  _HasRouteName(this.expectedName);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is Route) {
      return item.settings.name == expectedName;
    }
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('route with name "$expectedName"');
}

/// Custom matcher for Backpack containing key.
Matcher backpackHas(String key, {dynamic value}) => _BackpackHas(key, value);

class _BackpackHas extends Matcher {
  final String key;
  final dynamic expectedValue;

  _BackpackHas(this.key, this.expectedValue);

  @override
  bool matches(dynamic item, Map matchState) {
    if (!Backpack.instance.contains(key)) return false;
    if (expectedValue != null) {
      return Backpack.instance.read(key) == expectedValue;
    }
    return true;
  }

  @override
  Description describe(Description description) {
    if (expectedValue != null) {
      return description.add(
        'Backpack contains "$key" with value "$expectedValue"',
      );
    }
    return description.add('Backpack contains "$key"');
  }
}

/// Custom matcher for API calls.
Matcher apiWasCalled(String endpoint, {String? method, int? times}) =>
    _ApiWasCalled(endpoint, method, times);

class _ApiWasCalled extends Matcher {
  final String endpoint;
  final String? method;
  final int? times;

  _ApiWasCalled(this.endpoint, this.method, this.times);

  @override
  bool matches(dynamic item, Map matchState) {
    return NyMockApi.wasCalled(endpoint, method: method, times: times);
  }

  @override
  Description describe(Description description) {
    var desc = 'API endpoint "$endpoint"';
    if (method != null) desc += ' with method $method';
    if (times != null) desc += ' called $times time(s)';
    return description.add(desc);
  }
}

// =============================================================================
// Toast Notification Assertions
// =============================================================================

/// A simple recorder that tracks toast notifications shown during tests.
///
/// Call [NyToastRecorder.setup] in your test setUp to start recording,
/// and use [expectToastShown] to assert on the results.
///
/// Example:
/// ```dart
/// setUp(() {
///   NyToastRecorder.setup();
/// });
///
/// nyWidgetTest('shows success toast', (tester) async {
///   await tester.pumpNyWidget(MyPage());
///   // trigger action that shows a toast...
///   expectToastShown(id: 'success');
/// });
/// ```
class NyToastRecorder {
  static final List<ToastRecord> _records = [];

  NyToastRecorder._();

  /// Start recording toast notifications. Call this in setUp.
  static void setup() {
    _records.clear();
  }

  /// Record a toast notification.
  static void record({String? id, String? title, String? description}) {
    _records.add(ToastRecord(id: id, title: title, description: description));
  }

  /// Get all recorded toasts.
  static List<ToastRecord> get records => List.unmodifiable(_records);

  /// Check if a toast was recorded with the given criteria.
  static bool wasShown({String? id, String? description}) {
    return _records.any((r) {
      if (id != null && r.id != id) return false;
      if (description != null && r.description != description) return false;
      return true;
    });
  }

  /// Clear all recorded toasts.
  static void clear() => _records.clear();
}

/// A recorded toast notification entry.
class ToastRecord {
  final String? id;
  final String? title;
  final String? description;
  final DateTime timestamp;

  ToastRecord({this.id, this.title, this.description})
    : timestamp = DateTime.now();

  @override
  String toString() =>
      'ToastRecord(id: $id, title: $title, description: $description)';
}

/// Assert that a toast notification was shown.
///
/// Requires [NyToastRecorder.setup] to be called before the test.
/// Toast notifications must be recorded via [NyToastRecorder.record]
/// (integrate into your test's toast notification handler).
///
/// Example:
/// ```dart
/// expectToastShown(id: 'success');
/// expectToastShown(id: 'danger', description: 'Something went wrong');
/// ```
void expectToastShown({String? id, String? description}) {
  final wasShown = NyToastRecorder.wasShown(id: id, description: description);
  expect(
    wasShown,
    isTrue,
    reason:
        'Expected toast to be shown'
        '${id != null ? ' with id "$id"' : ''}'
        '${description != null ? ' with description "$description"' : ''}'
        '. Recorded toasts: ${NyToastRecorder.records}',
  );
}

/// Assert that no toast notification was shown matching the criteria.
void expectNoToastShown({String? id, String? description}) {
  final wasShown = NyToastRecorder.wasShown(id: id, description: description);
  expect(
    wasShown,
    isFalse,
    reason:
        'Expected no toast to be shown'
        '${id != null ? ' with id "$id"' : ''}'
        '${description != null ? ' with description "$description"' : ''}',
  );
}

// =============================================================================
// Lock / Loading State Assertions
// =============================================================================

/// Assert that a named lock is currently held in a NyPage/NyState widget.
///
/// Uses [finder] to locate the widget and checks the lock named [name].
///
/// Example:
/// ```dart
/// expectLocked(tester, find.byType(MyPage), 'submit');
/// ```
void expectLocked(WidgetTester tester, Finder finder, String name) {
  final state = _findNyBaseState(finder);
  expect(
    state.isLocked(name),
    isTrue,
    reason: 'Expected lock "$name" to be held',
  );
}

/// Assert that a named lock is not held in a NyPage/NyState widget.
///
/// Example:
/// ```dart
/// expectNotLocked(tester, find.byType(MyPage), 'submit');
/// ```
void expectNotLocked(WidgetTester tester, Finder finder, String name) {
  final state = _findNyBaseState(finder);
  expect(
    state.isLocked(name),
    isFalse,
    reason: 'Expected lock "$name" to not be held',
  );
}

/// Assert that a named loading key is active in a NyPage/NyState widget.
///
/// Example:
/// ```dart
/// expectLoadingNamed(tester, find.byType(MyPage), 'fetchUsers');
/// ```
void expectLoadingNamed(WidgetTester tester, Finder finder, String name) {
  final state = _findNyBaseState(finder);
  expect(
    state.isLoading(name: name),
    isTrue,
    reason: 'Expected loading key "$name" to be active',
  );
}

/// Assert that a named loading key is not active in a NyPage/NyState widget.
///
/// Example:
/// ```dart
/// expectNotLoadingNamed(tester, find.byType(MyPage), 'fetchUsers');
/// ```
void expectNotLoadingNamed(WidgetTester tester, Finder finder, String name) {
  final state = _findNyBaseState(finder);
  expect(
    state.isLoading(name: name),
    isFalse,
    reason: 'Expected loading key "$name" to not be active',
  );
}

/// Find a [NyBaseState] from a widget [Finder], or fail with a descriptive message.
NyBaseState _findNyBaseState(Finder finder) {
  final elements = finder.evaluate();
  if (elements.isEmpty) {
    fail('No widget found for finder: $finder');
  }
  final element = elements.first;
  if (element is StatefulElement && element.state is NyBaseState) {
    return element.state as NyBaseState;
  }
  fail('Widget state is not a NyBaseState. Element: ${element.runtimeType}');
}
