import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Helper function to create an EnvGetter from a Map for testing
EnvGetter mockEnv(Map<String, dynamic> values) =>
    (String key, {dynamic defaultValue}) => values[key] ?? defaultValue;

void main() {
  // Initialize the Nylo testing framework
  NyTest.init();

  nyGroup('NyTest Framework', () {
    nyTest('initializes in test mode', () async {
      expectTestMode();
      expect(Nylo.isTestMode, isTrue);
    });

    nyTest('resets state between tests', () async {
      // State from previous test should be cleared
      expect(NyMockApi.handlerCount, 0);
      expect(NyMockApi.patternCount, 0);
    });
  });

  nyGroup('Time Travel', () {
    nyTest('can travel to a specific date', () async {
      NyTest.travel(DateTime(2025, 1, 1));
      expect(NyTime.now().year, 2025);
      expect(NyTime.now().month, 1);
      expect(NyTime.now().day, 1);
    });

    nyTest('can travel back to real time', () async {
      NyTest.travel(DateTime(2020, 1, 1));
      expect(NyTime.now().year, 2020);

      NyTest.travelBack();
      expect(NyTime.isFrozen, isFalse);
      // Now using real time
      expect(NyTime.now().year >= 2024, isTrue);
    });

    nyTest('can advance time', () async {
      NyTest.travel(DateTime(2025, 1, 1));
      NyTime.advanceBy(Duration(days: 30));
      expect(NyTime.now().day, 31);
    });

    nyTest('can use withFrozenTime', () async {
      final result = await NyTime.withFrozenTime(
        DateTime(2025, 12, 25),
        () async {
          return NyTime.now().month;
        },
      );
      expect(result, 12);
      // Time is back to normal after callback
      expect(NyTime.isFrozen, isFalse);
    });
  });

  nyGroup('API Mocking', () {
    nyTest('can mock API with wildcard pattern', () async {
      NyMockApi.respond('/users/*', {'id': 1, 'name': 'Test User'});

      final match = NyMockApi.matchUrl('/users/123');
      expect(match, isNotNull);
      expect(match!.data['name'], 'Test User');
    });

    nyTest('can mock API with double wildcard', () async {
      NyMockApi.respond('/api/**', {'posts': []});

      final match = NyMockApi.matchUrl('/api/v1/users/123/posts');
      expect(match, isNotNull);
      expect(match!.data['posts'], isEmpty);
    });

    nyTest('tracks API calls', () async {
      NyMockApi.recordCall('/users/1', method: 'GET');
      NyMockApi.recordCall('/users/1', method: 'GET');
      NyMockApi.recordCall('/posts/1', method: 'POST');

      expectApiCalled('/users/1', method: 'GET', times: 2);
      expectApiCalled('/posts/1', method: 'POST', times: 1);
    });

    nyTest('respects HTTP method in patterns', () async {
      NyMockApi.respond('/users', {'users': []}, method: 'GET');
      NyMockApi.respond('/users', {'created': true}, method: 'POST');

      final getMatch = NyMockApi.matchUrl('/users', method: 'GET');
      expect(getMatch!.data['users'], isEmpty);

      final postMatch = NyMockApi.matchUrl('/users', method: 'POST');
      expect(postMatch!.data['created'], isTrue);
    });
  });

  nyGroup('Factories', () {
    nySetUp(() {
      // Define factories before each test
      NyFactory.define<Map<String, dynamic>>(
        (faker) => {
          'id': faker.randomInt(1, 1000),
          'name': faker.name(),
          'email': faker.email(),
        },
      );
    });

    nyTearDown(() {
      NyFactory.clear();
    });

    nyTest('can create instances with factory', () async {
      final user = NyFactory.make<Map<String, dynamic>>();

      expect(user['id'], isA<int>());
      expect(user['name'], isA<String>());
      expect(user['email'], contains('@'));
    });

    nyTest('can create multiple instances', () async {
      final users = NyFactory.create<Map<String, dynamic>>(count: 5);

      expect(users.length, 5);
      expect(users.map((u) => u['id']).toSet().length, 5); // Unique IDs
    });

    nyTest('NyFaker generates consistent data', () async {
      final faker = NyFaker();

      expect(faker.name(), isA<String>());
      expect(faker.email(), contains('@'));
      expect(faker.phone(), matches(RegExp(r'\(\d{3}\) \d{3}-\d{4}')));
      expect(
        faker.uuid(),
        matches(
          RegExp(r'[\da-f]{8}-[\da-f]{4}-[\da-f]{4}-[\da-f]{4}-[\da-f]{12}'),
        ),
      );
    });

    nyTest('can create sequence data', () async {
      final users = NyFactory.sequence<Map<String, dynamic>>(
        3,
        (i, faker) => {'id': i, 'email': 'user$i@example.com'},
      );

      expect(users[0]['id'], 0);
      expect(users[1]['id'], 1);
      expect(users[2]['id'], 2);
      expect(users[0]['email'], 'user0@example.com');
    });
  });

  nyGroup('Test Cache', () {
    nyTest('in-memory cache works', () async {
      final cache = NyTestCache.getInstance();

      await cache.put('key', 'value');
      final result = await cache.get<String>('key');

      expect(result, 'value');
    });

    nyTest('cache respects expiration with time travel', () async {
      final cache = NyTestCache.getInstance();

      NyTest.travel(DateTime(2025, 1, 1, 12, 0, 0));
      await cache.put('key', 'value', seconds: 60);

      // Still valid
      expect(await cache.get<String>('key'), 'value');

      // Travel past expiration
      NyTime.advanceBy(Duration(seconds: 61));
      expect(await cache.get<String>('key'), isNull);
    });

    nyTest('saveRemember caches results', () async {
      final cache = NyTestCache.getInstance();
      var callCount = 0;

      final result1 = await cache.saveRemember<String>('data', 60, () {
        callCount++;
        return 'computed value';
      });

      final result2 = await cache.saveRemember<String>('data', 60, () {
        callCount++;
        return 'computed value 2';
      });

      expect(result1, 'computed value');
      expect(result2, 'computed value'); // Cached
      expect(callCount, 1); // Only called once
    });
  });

  nyGroup('Backpack Assertions', () {
    nyTest('can check backpack contains key', () async {
      Backpack.instance.save('test_key', 'test_value');

      expectBackpackContains('test_key');
      expectBackpackContains('test_key', value: 'test_value');
    });

    nyTest('can seed backpack', () async {
      NyTest.seedBackpack({
        'user': {'id': 1, 'name': 'Test'},
        'token': 'abc123',
      });

      expectBackpackContains('user');
      expectBackpackContains('token', value: 'abc123');
    });
  });

  nyGroup('Authentication Helpers', () {
    nyTest('can act as authenticated user', () async {
      // Initialize Nylo first
      await Nylo.init(env: mockEnv({'APP_NAME': 'Test App'}));

      final testUser = {'id': 1, 'name': 'Test User', 'role': 'admin'};
      NyTest.actingAs<Map<String, dynamic>>(testUser);

      final user = NyTest.actingUser<Map<String, dynamic>>();
      expect(user?['name'], 'Test User');
    });

    nyTest('can logout', () async {
      // Initialize Nylo first
      await Nylo.init(env: mockEnv({'APP_NAME': 'Test App'}));

      NyTest.actingAs<Map<String, dynamic>>({'id': 1, 'name': 'Test'});
      expect(NyTest.actingUser<Map<String, dynamic>>(), isNotNull);

      NyTest.logout();
      expect(NyTest.actingUser<Map<String, dynamic>>(), isNull);
    });

    nyTest('can act as user without Nylo init', () async {
      // This should work even without Nylo.init
      final testUser = {'id': 2, 'name': 'No Init User'};
      NyTest.actingAs<Map<String, dynamic>>(testUser, key: 'test_user');

      final user = NyTest.actingUser<Map<String, dynamic>>();
      expect(user?['name'], 'No Init User');

      NyTest.logout();
      expect(NyTest.actingUser<Map<String, dynamic>>(), isNull);
    });
  });

  nyGroup('Debugging Helpers', () {
    nyTest('dump outputs state without throwing', () async {
      await Nylo.init(env: mockEnv({'APP_NAME': 'Test App'}));
      NyMockApi.respond('/users/*', {'id': 1});
      NyTest.travel(DateTime(2025, 6, 15));

      // This should print state to console without throwing
      NyTest.dump();
    });

    nyTest('dd throws after dumping', () async {
      expect(() => NyTest.dd(), throwsStateError);
    });
  });

  nyGroup('Mock Channels', () {
    nyTest('path provider is mocked', () async {
      expect(NyMockChannels.documentsPath, isNotEmpty);
      expect(NyMockChannels.temporaryPath, isNotEmpty);
    });

    nyTest('can override timezone', () async {
      NyMockChannels.overrideTimezone('Europe/London');
      expect(NyMockChannels.timezone, 'Europe/London');
    });

    nyTest('secure storage is mocked', () async {
      NyMockChannels.setSecureStorageValue('api_token', 'test123');

      final storage = NyMockChannels.getSecureStorage();
      expect(storage['api_token'], 'test123');
    });
  });

  nyGroup('Environment Assertions', () {
    nyTest('can check environment variables', () async {
      await Nylo.init(
        env: mockEnv({'APP_NAME': 'Nylo Test', 'APP_DEBUG': 'true'}),
      );

      expectEnv('APP_NAME', 'Nylo Test');
      expectEnv('APP_DEBUG', 'true');
    });
  });

  // Example of full integration test
  nyGroup('Integration Example', () {
    nyTest('complete user journey', () async {
      // Setup
      final nylo = await Nylo.init(
        env: mockEnv({'APP_NAME': 'Test App', 'APP_DEBUG': 'true'}),
      );

      // For testing purposes, manually add some model decoders to trigger Backpack save
      nylo.addModelDecoders({});

      NyFactory.define<Map<String, dynamic>>(
        (faker) => {
          'id': faker.randomInt(1, 1000),
          'name': faker.name(),
          'email': faker.email(),
        },
      );

      NyMockApi.respond('/api/users/*', {'id': 1, 'name': 'John Doe'});
      NyMockApi.respond('/api/posts', {'posts': []}, method: 'GET');

      // Travel to a specific time
      NyTest.travel(DateTime(2025, 3, 15, 10, 30, 0));

      // Act as authenticated user
      final user = NyFactory.make<Map<String, dynamic>>();
      NyTest.actingAs<Map<String, dynamic>>(user);

      // Assertions
      expectNyloInitialized();
      expect(NyTest.actingUser<Map<String, dynamic>>(), isNotNull);
      expect(NyTime.now().year, 2025);
      expect(NyMockApi.matchUrl('/api/users/123'), isNotNull);

      // Record and verify API calls
      NyMockApi.recordCall('/api/users/1', method: 'GET');
      expectApiCalled('/api/users/1');

      // Debug state (uncomment to see output)
      // NyTest.dump();
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Example: Patrol Snapshot Testing (requires patrol package)
  // ══════════════════════════════════════════════════════════════════════════
  //
  // To use snapshot testing with Patrol in your app, add to your integration
  // test file:
  //
  // ```dart
  // import 'package:patrol/patrol.dart';
  // import 'package:nylo_support/testing/ny_testing.dart';
  // import 'package:your_app/bootstrap/boot.dart';
  //
  // void main() {
  //   NyTest.init(autoReset: false);
  //
  //   patrolWidgetTest('screenshot all snapshot routes', ($) async {
  //     // Boot your Nylo app
  //     await Boot.nylo();
  //
  //     // Get all routes marked with .snapshot()
  //     final snapshotRoutes = NyTest.getSnapshotRoutes();
  //     expect(snapshotRoutes, isNotEmpty, reason: 'No snapshot routes configured');
  //
  //     // Iterate and screenshot each route
  //     for (final entry in snapshotRoutes.entries) {
  //       final route = entry.value;
  //       final config = route.snapshotConfig;
  //       final devices = config?.devices ?? NyTest.defaultDevices;
  //
  //       // Run setUp if configured
  //       if (config?.setUp != null) {
  //         await config!.setUp!();
  //       }
  //
  //       for (final device in devices) {
  //         // Set device size
  //         await NyTest.setDeviceSize($.tester, device);
  //
  //         // Pump your app with the route
  //         await $.pumpWidget(YourApp(initialRoute: route.name));
  //         await $.pumpAndSettle();
  //
  //         // Wait for async content
  //         await $.pump(config?.waitDuration ?? Duration(seconds: 2));
  //
  //         // Take screenshot
  //         final name = '${config?.name ?? route.name}_${device.name}';
  //         await $.takeScreenshot(name: name);
  //       }
  //
  //       // Reset device size
  //       await NyTest.resetDeviceSize($.tester);
  //     }
  //   });
  //
  //   // Or use NySnapshotTest for more control:
  //   patrolWidgetTest('screenshot with NySnapshotTest', ($) async {
  //     await Boot.nylo();
  //
  //     final results = await NySnapshotTest.runAll(
  //       tester: $.tester,
  //       appBuilder: (route) => YourApp(initialRoute: route.name),
  //       takeScreenshot: (name) async {
  //         await $.takeScreenshot(name: name);
  //       },
  //       config: NySnapshotTestConfig.standard,
  //     );
  //
  //     // Print summary and assert all passed
  //     NySnapshotTest.printSummary(results);
  //     NySnapshotTest.assertAllPassed(results);
  //   });
  // }
  // ```
  //
  // In your router, mark routes for snapshot testing:
  //
  // ```dart
  // NyRouterRoute.path(
  //   HomePage.path,
  //   (context) => HomePage(),
  // ).snapshot(
  //   name: 'home_page',
  //   devices: [DeviceConfig.iphone14, DeviceConfig.pixel7],
  // ),
  //
  // NyRouterRoute.path(
  //   ProfilePage.path,
  //   (context) => ProfilePage(),
  // ).snapshot(
  //   name: 'profile_page',
  //   setUp: () async {
  //     // Setup mock data for this route
  //     NyMockApi.respond('/api/profile', {'name': 'Test User'});
  //   },
  //   mockData: {'userId': 1},
  // ),
  // ```
}
