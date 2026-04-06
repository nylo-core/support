import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Helper function to create an EnvGetter from a Map for testing
EnvGetter mockEnv(Map<String, dynamic> values) =>
    (String key, {dynamic defaultValue}) => values[key] ?? defaultValue;

/// Helper function to create an EnvContainsKey from a Map for testing
EnvContainsKey mockContainsKey(Map<String, dynamic> values) =>
    (String key) => values.containsKey(key);

void main() {
  NyTest.init();

  nyGroup('NyEnvRegistry', () {
    nyGroup('register', () {
      nyTest('should register getter function', () async {
        NyEnvRegistry.register(getter: mockEnv({'APP_NAME': 'TestApp'}));

        expect(NyEnvRegistry.isInitialized, isTrue);
      });

      nyTest('should register getter and containsKey functions', () async {
        final envValues = {'APP_NAME': 'TestApp', 'DEBUG': true};

        NyEnvRegistry.register(
          getter: mockEnv(envValues),
          containsKey: mockContainsKey(envValues),
        );

        expect(NyEnvRegistry.isInitialized, isTrue);
      });
    });

    nyGroup('get', () {
      nyTest('should return value for existing key', () async {
        NyEnvRegistry.register(
          getter: mockEnv({'APP_NAME': 'MyApp', 'APP_VERSION': '1.0.0'}),
        );

        final result = NyEnvRegistry.get('APP_NAME');

        expect(result, 'MyApp');
      });

      nyTest('should return string value', () async {
        NyEnvRegistry.register(getter: mockEnv({'STRING_KEY': 'string_value'}));

        final result = NyEnvRegistry.get('STRING_KEY');

        expect(result, 'string_value');
        expect(result, isA<String>());
      });

      nyTest('should return bool value', () async {
        NyEnvRegistry.register(getter: mockEnv({'BOOL_KEY': true}));

        final result = NyEnvRegistry.get('BOOL_KEY');

        expect(result, isTrue);
        expect(result, isA<bool>());
      });

      nyTest('should return int value', () async {
        NyEnvRegistry.register(getter: mockEnv({'INT_KEY': 42}));

        final result = NyEnvRegistry.get('INT_KEY');

        expect(result, 42);
        expect(result, isA<int>());
      });

      nyTest('should return defaultValue for nonexistent key', () async {
        NyEnvRegistry.register(getter: mockEnv({'EXISTING': 'value'}));

        final result = NyEnvRegistry.get(
          'NONEXISTENT',
          defaultValue: 'fallback',
        );

        expect(result, 'fallback');
      });

      nyTest(
        'should return null for nonexistent key without default',
        () async {
          NyEnvRegistry.register(getter: mockEnv({'EXISTING': 'value'}));

          final result = NyEnvRegistry.get('NONEXISTENT');

          expect(result, isNull);
        },
      );
    });

    nyGroup('containsKey', () {
      nyTest('should return true for existing key', () async {
        final envValues = {'APP_NAME': 'TestApp'};

        NyEnvRegistry.register(
          getter: mockEnv(envValues),
          containsKey: mockContainsKey(envValues),
        );

        final result = NyEnvRegistry.containsKey('APP_NAME');

        expect(result, isTrue);
      });

      nyTest('should return false for nonexistent key', () async {
        final envValues = {'APP_NAME': 'TestApp'};

        NyEnvRegistry.register(
          getter: mockEnv(envValues),
          containsKey: mockContainsKey(envValues),
        );

        final result = NyEnvRegistry.containsKey('NONEXISTENT');

        expect(result, isFalse);
      });

      nyTest('should return false when containsKey not registered', () async {
        NyEnvRegistry.register(
          getter: mockEnv({'APP_NAME': 'TestApp'}),
          // containsKey not provided
        );

        final result = NyEnvRegistry.containsKey('APP_NAME');

        expect(result, isFalse);
      });
    });

    nyGroup('isInitialized', () {
      nyTest('should return true after registration', () async {
        NyEnvRegistry.register(getter: mockEnv({'KEY': 'value'}));

        expect(NyEnvRegistry.isInitialized, isTrue);
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // getEnv Helper Function Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('getEnv helper function', () {
    nyTest('should return value from registered env', () async {
      NyEnvRegistry.register(
        getter: mockEnv({'APP_NAME': 'GetEnvTestApp', 'APP_DEBUG': true}),
      );

      final result = getEnv('APP_NAME');

      expect(result, 'GetEnvTestApp');
    });

    nyTest('should return bool value', () async {
      NyEnvRegistry.register(getter: mockEnv({'APP_DEBUG': true}));

      final result = getEnv('APP_DEBUG');

      expect(result, isTrue);
    });

    nyTest('should return defaultValue when key not found', () async {
      NyEnvRegistry.register(getter: mockEnv({'EXISTING': 'value'}));

      final result = getEnv('MISSING_KEY', defaultValue: 'default');

      expect(result, 'default');
    });

    nyTest('should support various value types', () async {
      NyEnvRegistry.register(
        getter: mockEnv({
          'STRING_VAL': 'text',
          'INT_VAL': 100,
          'DOUBLE_VAL': 3.14,
          'BOOL_VAL': false,
          'LIST_VAL': [1, 2, 3],
        }),
      );

      expect(getEnv('STRING_VAL'), 'text');
      expect(getEnv('INT_VAL'), 100);
      expect(getEnv('DOUBLE_VAL'), 3.14);
      expect(getEnv('BOOL_VAL'), isFalse);
      expect(getEnv('LIST_VAL'), [1, 2, 3]);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Variable Interpolation
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('variable interpolation', () {
    nyTest('should resolve basic interpolation', () async {
      NyEnvRegistry.register(
        getter: mockEnv({
          'APP_DOMAIN': 'example.com',
          'APP_URL': 'https://\${APP_DOMAIN}',
        }),
      );

      expect(NyEnvRegistry.get('APP_URL'), 'https://example.com');
    });

    nyTest('should resolve multiple references in one value', () async {
      NyEnvRegistry.register(
        getter: mockEnv({
          'FIRST': 'John',
          'LAST': 'Doe',
          'GREETING': 'Hello \${FIRST} \${LAST}',
        }),
      );

      expect(NyEnvRegistry.get('GREETING'), 'Hello John Doe');
    });

    nyTest('should resolve chained references', () async {
      NyEnvRegistry.register(
        getter: mockEnv({'A': 'base', 'B': '\${A}/mid', 'C': '\${B}/end'}),
      );

      expect(NyEnvRegistry.get('C'), 'base/mid/end');
    });

    nyTest('should leave missing references as-is', () async {
      NyEnvRegistry.register(
        getter: mockEnv({'URL': 'https://\${UNDEFINED}/path'}),
      );

      expect(NyEnvRegistry.get('URL'), 'https://\${UNDEFINED}/path');
    });

    nyTest('should handle circular references without looping', () async {
      NyEnvRegistry.register(getter: mockEnv({'A': '\${B}', 'B': '\${A}'}));

      // Should not throw or hang — circular ref left unresolved
      final result = NyEnvRegistry.get('A');
      expect(result, isA<String>());
    });

    nyTest('should not interpolate non-string values', () async {
      NyEnvRegistry.register(
        getter: mockEnv({'DEBUG': true, 'PORT': 8080, 'RATE': 3.14}),
      );

      expect(NyEnvRegistry.get('DEBUG'), isTrue);
      expect(NyEnvRegistry.get('PORT'), 8080);
      expect(NyEnvRegistry.get('RATE'), 3.14);
    });

    nyTest('should convert non-string referenced value to string', () async {
      NyEnvRegistry.register(
        getter: mockEnv({'PORT': 8080, 'URL': 'http://localhost:\${PORT}'}),
      );

      expect(NyEnvRegistry.get('URL'), 'http://localhost:8080');
    });

    nyTest('should leave dollar signs without braces unchanged', () async {
      NyEnvRegistry.register(getter: mockEnv({'PRICE': 'costs \$5'}));

      expect(NyEnvRegistry.get('PRICE'), 'costs \$5');
    });

    nyTest('should handle self-reference without looping', () async {
      NyEnvRegistry.register(getter: mockEnv({'A': '\${A}'}));

      expect(NyEnvRegistry.get('A'), '\${A}');
    });

    nyTest('should return plain strings unchanged', () async {
      NyEnvRegistry.register(getter: mockEnv({'PLAIN': 'hello world'}));

      expect(NyEnvRegistry.get('PLAIN'), 'hello world');
    });

    nyTest('should work through getEnv helper', () async {
      NyEnvRegistry.register(
        getter: mockEnv({
          'DOMAIN': 'example.com',
          'API_URL': 'https://api.\${DOMAIN}',
        }),
      );

      expect(getEnv('API_URL'), 'https://api.example.com');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Edge Cases and Error Handling
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('Edge Cases', () {
    nyTest('should handle empty string values', () async {
      NyEnvRegistry.register(getter: mockEnv({'EMPTY_STRING': ''}));

      final result = getEnv('EMPTY_STRING');

      expect(result, '');
    });

    nyTest('should handle null values in env', () async {
      NyEnvRegistry.register(getter: mockEnv({'NULL_VALUE': null}));

      final result = getEnv('NULL_VALUE', defaultValue: 'default');

      expect(result, 'default');
    });

    nyTest('should handle special characters in values', () async {
      NyEnvRegistry.register(
        getter: mockEnv({
          'SPECIAL': 'value with spaces & symbols!@#\$%',
          'URL': 'https://example.com?param=value&other=123',
        }),
      );

      expect(getEnv('SPECIAL'), 'value with spaces & symbols!@#\$%');
      expect(getEnv('URL'), 'https://example.com?param=value&other=123');
    });

    nyTest('should handle unicode values', () async {
      NyEnvRegistry.register(
        getter: mockEnv({'UNICODE': 'Hello World!', 'EMOJI': 'Test App'}),
      );

      expect(getEnv('UNICODE'), 'Hello World!');
      expect(getEnv('EMOJI'), 'Test App');
    });

    nyTest('should handle numeric string values', () async {
      NyEnvRegistry.register(
        getter: mockEnv({'PORT': '8080', 'VERSION': '1.0.0'}),
      );

      expect(getEnv('PORT'), '8080');
      expect(getEnv('VERSION'), '1.0.0');
    });

    nyTest('should handle case-sensitive keys', () async {
      NyEnvRegistry.register(
        getter: mockEnv({
          'app_name': 'lowercase',
          'APP_NAME': 'uppercase',
          'App_Name': 'mixedcase',
        }),
      );

      expect(getEnv('app_name'), 'lowercase');
      expect(getEnv('APP_NAME'), 'uppercase');
      expect(getEnv('App_Name'), 'mixedcase');
    });
  });
}
