/// Nylo Testing Framework
///
/// A comprehensive testing framework for Nylo with PHPUnit/Pest-like syntax,
/// automatic mocking, time travel, factories, and test isolation.
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
///     NyEnvRegistry.register(getter: Env.get);
///     await setupApplication(providers);
///   });
///
///   nyGroup('HomePage', () {
///     nyWidgetTest('displays content', (tester) async {
///       // Use the pumpNyWidget extension for easy widget testing
///       await tester.pumpNyWidget(HomePage());
///       expect(find.text('Welcome'), findsOneWidget);
///     });
///
///     // Or use pumpNyWidgetSimple to avoid font issues completely
///     nyWidgetTest('displays links', (tester) async {
///       await tester.pumpNyWidgetSimple(HomePage());
///       expect(find.text('Documentation'), findsOneWidget);
///     });
///   });
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
///
///   nyTest('mock API responses', () async {
///     NyMockApi.respond('/users/*', {'id': 1, 'name': 'John'});
///     NyMockApi.respond('/posts/**', {'posts': []});
///   });
///
///   nyTest('use factories', () async {
///     NyFactory.define<User>((faker) => User(
///       name: faker.name(),
///       email: faker.email(),
///     ));
///
///     final users = NyFactory.create<User>(count: 5);
///     expect(users.length, 5);
///   });
/// }
/// ```
///
/// ## Features
///
/// - **Widget Testing**: Easy testing of NyStatefulWidget, NyPage, and NyState
/// - **Google Fonts Handling**: Automatic configuration to prevent HTTP errors
/// - **Test Isolation**: Each test runs in isolation with automatic cleanup
/// - **Time Travel**: Freeze and manipulate time with [NyTime]
/// - **API Mocking**: Mock API responses with wildcards using [NyMockApi]
/// - **Factories**: Create test data with [NyFactory] and [NyFaker]
/// - **Authentication**: Test as authenticated user with [NyTest.actingAs]
/// - **Assertions**: Custom assertions for routes, backpack, locale, and more
/// - **Debugging**: Use [NyTest.dump] and [NyTest.dd] to inspect test state
library ny_testing;

// Core test framework
export 'src/ny_test.dart';

// Widget testing utilities
export 'src/ny_widget_test.dart';

// Time manipulation
export 'src/ny_time.dart';

// Factories and fake data
export 'src/ny_factory.dart';

// Test helpers and assertions
export 'src/ny_test_helper.dart';

// State testing helpers
export 'src/ny_state_test_helpers.dart';

// Mocks
export 'src/mocks/ny_mock_api.dart';
export 'src/mocks/ny_mock_channels.dart';
export 'src/mocks/ny_mock_route_guard.dart';
export 'src/mocks/ny_test_cache.dart';
