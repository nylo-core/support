import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/local_storage/ny_local_storage.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/providers/ny_providers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Helper function to create an EnvGetter from a Map for testing
EnvGetter mockEnv(Map<String, dynamic> values) =>
    (String key, {dynamic defaultValue}) => values[key] ?? defaultValue;

void main() {
  NyTest.init();
  _isAuthenticatedTests();

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
      final String key = Auth.key(null);
      expect(key, isA<String>());
    });

    nyTest('should return base auth key when session is default', () async {
      final String key = Auth.key(Auth.defaultSession);
      expect(key, isA<String>());
    });

    nyTest('should return namespaced key for named session', () async {
      final String key = Auth.key('device');
      expect(key, contains('_device'));
    });

    nyTest('should return different keys for different sessions', () async {
      final String defaultKey = Auth.key();
      final String deviceKey = Auth.key('device');
      final String adminKey = Auth.key('admin');

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
      final String first = Auth.defaultSession;
      final String second = Auth.defaultSession;
      expect(first, second);
    });
  });

  // =============================================================================
  // Auth.data Tests
  // =============================================================================

  nyGroup('Auth.data', () {
    nyTest('should return null when no auth data exists', () async {
      final dynamic data = Auth.data();
      expect(data, isNull);
    });

    nyTest(
      'should return null when field is requested but no data exists',
      () async {
        final dynamic data = Auth.data(field: 'token');
        expect(data, isNull);
      },
    );

    nyTest('should return null for non-existent session', () async {
      final dynamic data = Auth.data(session: 'nonexistent');
      expect(data, isNull);
    });
  });

  // =============================================================================
  // Helper Function Tests - authKey
  // =============================================================================

  nyGroup('authKey helper function', () {
    nyTest('should return same result as Auth.key', () async {
      final String fromClass = Auth.key();
      final String fromHelper = authKey();
      expect(fromClass, fromHelper);
    });

    nyTest('should handle session parameter', () async {
      final String fromClass = Auth.key('device');
      final String fromHelper = authKey('device');
      expect(fromClass, fromHelper);
    });
  });

  // =============================================================================
  // Helper Function Tests - authData
  // =============================================================================

  nyGroup('authData helper function', () {
    nyTest('should return same result as Auth.data', () async {
      final dynamic fromClass = Auth.data();
      final dynamic fromHelper = authData();
      expect(fromClass, fromHelper);
    });

    nyTest('should handle field parameter', () async {
      final dynamic fromClass = Auth.data(field: 'token');
      final dynamic fromHelper = authData(field: 'token');
      expect(fromClass, fromHelper);
    });

    nyTest('should handle session parameter', () async {
      final dynamic fromClass = Auth.data(session: 'device');
      final dynamic fromHelper = authData(session: 'device');
      expect(fromClass, fromHelper);
    });

    nyTest('should handle both field and session parameters', () async {
      final dynamic fromClass = Auth.data(field: 'token', session: 'device');
      final dynamic fromHelper = authData(field: 'token', session: 'device');
      expect(fromClass, fromHelper);
    });
  });

  // =============================================================================
  // Integration Tests
  // =============================================================================

  nyGroup('Auth Integration', () {
    nyTest('should support multiple session keys simultaneously', () async {
      final String defaultKey = Auth.key();
      final String deviceKey = Auth.key('device');
      final String apiKey = Auth.key('api');

      // All keys should be unique
      final keys = {defaultKey, deviceKey, apiKey};
      expect(keys.length, 3);
    });

    nyTest('should generate consistent keys for same session', () async {
      final String key1 = Auth.key('mysession');
      final String key2 = Auth.key('mysession');
      expect(key1, key2);
    });

    nyTest('should handle empty string session as named session', () async {
      final String emptyKey = Auth.key('');

      // Empty string is treated as a named session, not default
      expect(emptyKey, contains('_'));
    });
  });

  // =============================================================================
  // Edge Cases
  // =============================================================================

  nyGroup('Auth Edge Cases', () {
    nyTest('should handle special characters in session names', () async {
      final String key = Auth.key('user-device_123');
      expect(key, isA<String>());
      expect(key, contains('user-device_123'));
    });

    nyTest('should handle very long session names', () async {
      final String longSessionName = 'a' * 100;
      final String key = Auth.key(longSessionName);
      expect(key, isA<String>());
      expect(key, contains(longSessionName));
    });

    nyTest('should handle unicode session names', () async {
      final String key = Auth.key('session_unicode');
      expect(key, isA<String>());
    });
  });
}

// =============================================================================
// Auth.isAuthenticated (PERFORMANCE_AUDIT_ROUND2 HIGH 6)
// =============================================================================

/// Counts secure-storage channel calls by method, forwarding to the
/// NyMockChannels in-memory store so behaviour is unchanged.
class _StorageCallCounter {
  static const _channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  final Map<String, int> calls = {};
  final Map<String, String> store = {};

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (MethodCall call) async {
          calls[call.method] = (calls[call.method] ?? 0) + 1;
          final dynamic key = call.arguments is Map
              ? call.arguments['key']
              : null;
          switch (call.method) {
            case 'read':
              return store[key];
            case 'write':
              store[key] = call.arguments['value'] as String;
              return null;
            case 'delete':
              store.remove(key);
              return null;
            case 'deleteAll':
              store.clear();
              return null;
            case 'readAll':
              return store;
            case 'containsKey':
              return store.containsKey(key);
          }
          return null;
        });
  }

  void uninstall() {
    // Restore the default Nylo test mocks.
    NyMockChannels.setup();
  }

  int operator [](String method) => calls[method] ?? 0;
}

void _isAuthenticatedTests() {
  nyGroup('Auth.isAuthenticated', () {
    late _StorageCallCounter storage;

    setUp(() {
      storage = _StorageCallCounter()..install();
      Backpack.instance.delete(Auth.key(null));
      Backpack.instance.delete(Auth.key('device'));
    });

    tearDown(() {
      storage.uninstall();
    });

    nyTest(
      'answers from Backpack without a storage read after authenticate',
      () async {
        await Auth.authenticate(data: {'id': 1, 'name': 'Anthony'});
        storage.calls.clear();

        expect(await Auth.isAuthenticated(), isTrue);
        expect(await Auth.isAuthenticated(), isTrue);

        expect(storage['read'], 0, reason: 'auth key is already in Backpack');
        expect(storage['containsKey'], 0);
      },
    );

    nyTest(
      'returns false from Backpack after logout without a storage read',
      () async {
        await Auth.authenticate(data: {'id': 1});
        await Auth.logout();
        storage.calls.clear();

        // logout removes the key from Backpack, so this falls back to a
        // containsKey probe (no value transfer) rather than a read + decode.
        expect(await Auth.isAuthenticated(), isFalse);
        expect(storage['read'], 0);
        expect(storage['containsKey'], 1);
      },
    );

    nyTest(
      'treats a Backpack entry synced as null as unauthenticated',
      () async {
        // Nylo.syncKeys stores null for keys with no stored value.
        Backpack.instance.save(Auth.key(null), null);
        storage.calls.clear();

        expect(await Auth.isAuthenticated(), isFalse);
        expect(storage['read'], 0);
        expect(storage['containsKey'], 0);
      },
    );

    nyTest(
      'falls back to a containsKey probe when not synced to Backpack',
      () async {
        // Stored directly, bypassing Backpack (e.g. written before boot sync).
        await NyStorage.saveJson(Auth.key(null), {'id': 7});
        Backpack.instance.delete(Auth.key(null));
        storage.calls.clear();

        expect(await Auth.isAuthenticated(), isTrue);
        expect(storage['read'], 0, reason: 'must not decode the payload');
        expect(storage['containsKey'], 1);
      },
    );

    nyTest('sessions are independent', () async {
      await Auth.authenticate(data: {'id': 1});
      storage.calls.clear();

      expect(await Auth.isAuthenticated(), isTrue);
      expect(await Auth.isAuthenticated(session: 'device'), isFalse);
      expect(storage['read'], 0);
    });
  });
}
