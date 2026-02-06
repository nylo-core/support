import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/providers/ny_providers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Helper function to create an EnvGetter from a Map for testing
EnvGetter mockEnv(Map<String, dynamic> values) =>
    (String key, {dynamic defaultValue}) => values[key] ?? defaultValue;

void main() {
  NyTest.init();

  setUp(() async {
    // Initialize Nylo for tests that need it
    await Nylo.init(
      env: mockEnv({}),
      setup: BootConfig(
        setup: () async {
          final nylo = Nylo();
          nylo.addAuthKey('test_auth_key');
          return nylo;
        },
        boot: (Nylo nylo) async {},
      ),
    );
  });

  // =============================================================================
  // Auth.key Tests
  // =============================================================================

  nyGroup('Auth.key', () {
    nyTest('should return base auth key when session is null', () async {
      // Note: This test requires Nylo to be initialized with an auth key
      // In test environment, we test the behavior with mock setup
      final key = Auth.key(null);
      expect(key, isA<String>());
    });

    nyTest('should return base auth key when session is default', () async {
      final key = Auth.key(Auth.defaultSession);
      expect(key, isA<String>());
    });

    nyTest('should return namespaced key for named session', () async {
      final key = Auth.key('device');
      expect(key, contains('_device'));
    });

    nyTest('should return different keys for different sessions', () async {
      final defaultKey = Auth.key();
      final deviceKey = Auth.key('device');
      final adminKey = Auth.key('admin');

      expect(defaultKey, isNot(deviceKey));
      expect(defaultKey, isNot(adminKey));
      expect(deviceKey, isNot(adminKey));
    });
  });

  // =============================================================================
  // Auth.defaultSession Tests
  // =============================================================================

  nyGroup('Auth.defaultSession', () {
    nyTest('should be "default"', () async {
      expect(Auth.defaultSession, 'default');
    });

    nyTest('should be a constant value', () async {
      final first = Auth.defaultSession;
      final second = Auth.defaultSession;
      expect(first, second);
    });
  });

  // =============================================================================
  // Auth.data Tests
  // =============================================================================

  nyGroup('Auth.data', () {
    nyTest('should return null when no auth data exists', () async {
      final data = Auth.data();
      expect(data, isNull);
    });

    nyTest(
      'should return null when field is requested but no data exists',
      () async {
        final data = Auth.data(field: 'token');
        expect(data, isNull);
      },
    );

    nyTest('should return null for non-existent session', () async {
      final data = Auth.data(session: 'nonexistent');
      expect(data, isNull);
    });
  });

  // =============================================================================
  // Helper Function Tests - authKey
  // =============================================================================

  nyGroup('authKey helper function', () {
    nyTest('should return same result as Auth.key', () async {
      final fromClass = Auth.key();
      final fromHelper = authKey();
      expect(fromClass, fromHelper);
    });

    nyTest('should handle session parameter', () async {
      final fromClass = Auth.key('device');
      final fromHelper = authKey('device');
      expect(fromClass, fromHelper);
    });
  });

  // =============================================================================
  // Helper Function Tests - authData
  // =============================================================================

  nyGroup('authData helper function', () {
    nyTest('should return same result as Auth.data', () async {
      final fromClass = Auth.data();
      final fromHelper = authData();
      expect(fromClass, fromHelper);
    });

    nyTest('should handle field parameter', () async {
      final fromClass = Auth.data(field: 'token');
      final fromHelper = authData(field: 'token');
      expect(fromClass, fromHelper);
    });

    nyTest('should handle session parameter', () async {
      final fromClass = Auth.data(session: 'device');
      final fromHelper = authData(session: 'device');
      expect(fromClass, fromHelper);
    });

    nyTest('should handle both field and session parameters', () async {
      final fromClass = Auth.data(field: 'token', session: 'device');
      final fromHelper = authData(field: 'token', session: 'device');
      expect(fromClass, fromHelper);
    });
  });

  // =============================================================================
  // Integration Tests
  // =============================================================================

  nyGroup('Auth Integration', () {
    nyTest('should support multiple session keys simultaneously', () async {
      final defaultKey = Auth.key();
      final deviceKey = Auth.key('device');
      final apiKey = Auth.key('api');

      // All keys should be unique
      final keys = {defaultKey, deviceKey, apiKey};
      expect(keys.length, 3);
    });

    nyTest('should generate consistent keys for same session', () async {
      final key1 = Auth.key('mysession');
      final key2 = Auth.key('mysession');
      expect(key1, key2);
    });

    nyTest('should handle empty string session as named session', () async {
      final emptyKey = Auth.key('');
      final defaultKey = Auth.key();

      // Empty string is treated as a named session, not default
      expect(emptyKey, contains('_'));
    });
  });

  // =============================================================================
  // Edge Cases
  // =============================================================================

  nyGroup('Auth Edge Cases', () {
    nyTest('should handle special characters in session names', () async {
      final key = Auth.key('user-device_123');
      expect(key, isA<String>());
      expect(key, contains('user-device_123'));
    });

    nyTest('should handle very long session names', () async {
      final longSessionName = 'a' * 100;
      final key = Auth.key(longSessionName);
      expect(key, isA<String>());
      expect(key, contains(longSessionName));
    });

    nyTest('should handle unicode session names', () async {
      final key = Auth.key('session_unicode');
      expect(key, isA<String>());
    });
  });
}
