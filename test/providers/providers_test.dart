import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/providers/ny_providers.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/nylo.dart';

import 'mocks/mock_provider.dart';

/// Helper function to create an EnvGetter from a Map for testing
EnvGetter mockEnv(Map<String, dynamic> values) =>
    (String key, {dynamic defaultValue}) => values[key] ?? defaultValue;

void main() {
  NyTest.init();

  nySetUp(() {
    // Register mock environment before each test
    NyEnvRegistry.register(
      getter: mockEnv({
        'APP_DEBUG': false,
        'APP_ENV': 'testing',
        'DEFAULT_LOCALE': 'en',
        'ASSET_PATH': 'assets',
      }),
    );
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // NyProvider Abstract Class Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('NyProvider', () {
    nyTest('setup() can be implemented and called', () async {
      final provider = MockProvider();
      final nylo = Nylo();

      await provider.setup(nylo);

      expect(provider.setupCalled, isTrue);
    });

    nyTest('setup() receives Nylo instance', () async {
      final provider = MockProvider();
      final nylo = Nylo();

      await provider.setup(nylo);

      expect(provider.receivedNylo, same(nylo));
    });

    nyTest('setup() can return Nylo instance', () async {
      final provider = MockProvider();
      final nylo = Nylo();

      final result = await provider.setup(nylo);

      expect(result, same(nylo));
    });

    nyTest('setup() can return null', () async {
      final provider = NullReturningProvider();
      final nylo = Nylo();

      final result = await provider.setup(nylo);

      expect(result, isNull);
    });

    nyTest('boot() can be implemented and called', () async {
      final provider = MockProvider();
      final nylo = Nylo();

      await provider.boot(nylo);

      expect(provider.bootCalled, isTrue);
    });

    nyTest('boot() receives Nylo instance', () async {
      final provider = MockProvider();
      final nylo = Nylo();

      await provider.boot(nylo);

      expect(provider.receivedNylo, same(nylo));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // setupApplication() Function Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('setupApplication()', () {
    nyGroup('basic functionality', () {
      nyTest('sets up single provider successfully', () async {
        final provider = MockProvider();
        final providers = {MockProvider: provider};

        final nylo = await setupApplication(providers);

        expect(nylo, isA<Nylo>());
        expect(provider.setupCalled, isTrue);
      });

      nyTest('sets up multiple providers', () async {
        final provider1 = MockProvider();
        final provider2 = NullReturningProvider();
        final providers = <Type, NyProvider>{
          MockProvider: provider1,
          NullReturningProvider: provider2,
        };

        await setupApplication(providers);

        expect(provider1.setupCalled, isTrue);
        expect(provider2.setupCalled, isTrue);
      });

      nyTest('returns Nylo instance', () async {
        final provider = MockProvider();
        final providers = {MockProvider: provider};

        final nylo = await setupApplication(providers);

        expect(nylo, isA<Nylo>());
      });

      nyTest('handles provider returning null', () async {
        final nullProvider = NullReturningProvider();
        final providers = {NullReturningProvider: nullProvider};

        final nylo = await setupApplication(providers);

        expect(nylo, isA<Nylo>());
        expect(nullProvider.setupCalled, isTrue);
      });

      nyTest('handles empty provider map', () async {
        final providers = <Type, NyProvider>{};

        final nylo = await setupApplication(providers);

        expect(nylo, isA<Nylo>());
      });

      nyTest('provider that modifies Nylo works correctly', () async {
        final modifyingProvider = ModifyingProvider();
        final providers = {ModifyingProvider: modifyingProvider};

        final nylo = await setupApplication(providers);

        expect(nylo, isA<Nylo>());
        expect(modifyingProvider.setupCalled, isTrue);
      });
    });

    nyGroup('error handling', () {
      nyTest('rethrows exception when provider setup fails', () async {
        final failingProvider = MockProvider()..shouldThrow = true;
        final providers = {MockProvider: failingProvider};

        expect(() => setupApplication(providers), throwsA(isA<Exception>()));
      });

      nyTest('stops setting up remaining providers on failure', () async {
        final failingProvider = MockProvider()..shouldThrow = true;
        final nextProvider = NullReturningProvider();

        final providers = <Type, NyProvider>{
          MockProvider: failingProvider,
          NullReturningProvider: nextProvider,
        };

        try {
          await setupApplication(providers);
        } catch (_) {}

        expect(nextProvider.setupCalled, isFalse);
      });
    });

    nyGroup('debug logging', () {
      nyTest('sets up successfully when enableDebugLogging is true', () async {
        final provider = MockProvider();
        final providers = {MockProvider: provider};

        final nylo = await setupApplication(
          providers,
          enableDebugLogging: true,
        );

        expect(nylo, isA<Nylo>());
        expect(provider.setupCalled, isTrue);
      });

      nyTest('sets up successfully when enableDebugLogging is false', () async {
        final provider = MockProvider();
        final providers = {MockProvider: provider};

        final nylo = await setupApplication(
          providers,
          enableDebugLogging: false,
        );

        expect(nylo, isA<Nylo>());
        expect(provider.setupCalled, isTrue);
      });

      nyTest(
        'uses APP_DEBUG env when enableDebugLogging not specified',
        () async {
          NyEnvRegistry.register(getter: mockEnv({'APP_DEBUG': true}));

          final provider = MockProvider();
          final providers = {MockProvider: provider};

          final nylo = await setupApplication(providers);

          expect(nylo, isA<Nylo>());
          expect(provider.setupCalled, isTrue);
        },
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // bootFinished() Function Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('bootFinished()', () {
    nyGroup('basic functionality', () {
      nyTest('calls boot on single provider', () async {
        final provider = MockProvider();
        final providers = {MockProvider: provider};
        final nylo = Nylo();

        await bootFinished(nylo, providers);

        expect(provider.bootCalled, isTrue);
      });

      nyTest('calls boot on all providers', () async {
        final provider1 = MockProvider();
        final provider2 = NullReturningProvider();
        final providers = <Type, NyProvider>{
          MockProvider: provider1,
          NullReturningProvider: provider2,
        };
        final nylo = Nylo();

        await bootFinished(nylo, providers);

        expect(provider1.bootCalled, isTrue);
        expect(provider2.bootCalled, isTrue);
      });

      nyTest('saves Nylo to Backpack with default key', () async {
        final provider = MockProvider();
        final providers = {MockProvider: provider};
        final nylo = Nylo();

        await bootFinished(nylo, providers);

        expectBackpackContains('nylo');
      });

      nyTest('saves Nylo to Backpack with custom key', () async {
        final provider = MockProvider();
        final providers = {MockProvider: provider};
        final nylo = Nylo();

        await bootFinished(nylo, providers, key: 'custom_nylo');

        expectBackpackContains('custom_nylo');
      });

      nyTest('returns Nylo instance', () async {
        final provider = MockProvider();
        final providers = {MockProvider: provider};
        final nylo = Nylo();

        final result = await bootFinished(nylo, providers);

        expect(result, same(nylo));
      });

      nyTest('handles empty provider map', () async {
        final providers = <Type, NyProvider>{};
        final nylo = Nylo();

        final result = await bootFinished(nylo, providers);

        expect(result, same(nylo));
        expectBackpackContains('nylo');
      });
    });

    nyGroup('error handling', () {
      nyTest('does not throw when throwOnError is false (default)', () async {
        final failingProvider = BootFailingProvider();
        final providers = {BootFailingProvider: failingProvider};
        final nylo = Nylo();

        // Should not throw
        final result = await bootFinished(nylo, providers);

        expect(result, same(nylo));
      });

      nyTest('throws when throwOnError is true', () async {
        final failingProvider = BootFailingProvider();
        final providers = {BootFailingProvider: failingProvider};
        final nylo = Nylo();

        expect(
          () => bootFinished(nylo, providers, throwOnError: true),
          throwsA(isA<Exception>()),
        );
      });

      nyTest(
        'continues to next provider when one fails and throwOnError is false',
        () async {
          final failingProvider = BootFailingProvider();
          final successProvider = MockProvider();
          final providers = <Type, NyProvider>{
            BootFailingProvider: failingProvider,
            MockProvider: successProvider,
          };
          final nylo = Nylo();

          await bootFinished(nylo, providers);

          expect(failingProvider.bootCalled, isTrue);
          expect(successProvider.bootCalled, isTrue);
        },
      );
    });

    nyGroup('debug logging', () {
      nyTest('works when enableDebugLogging is true', () async {
        final provider = MockProvider();
        final providers = {MockProvider: provider};
        final nylo = Nylo();

        await bootFinished(nylo, providers, enableDebugLogging: true);

        expect(provider.bootCalled, isTrue);
      });

      nyTest('works when enableDebugLogging is false', () async {
        final provider = MockProvider();
        final providers = {MockProvider: provider};
        final nylo = Nylo();

        await bootFinished(nylo, providers, enableDebugLogging: false);

        expect(provider.bootCalled, isTrue);
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Integration Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('Provider Lifecycle Integration', () {
    nyTest('full provider lifecycle works correctly', () async {
      final provider = MockProvider();
      final providers = {MockProvider: provider};

      // Setup application
      final nylo = await setupApplication(providers);
      expect(provider.setupCalled, isTrue);
      expect(provider.bootCalled, isFalse);

      // Finish boot
      await bootFinished(nylo, providers);
      expect(provider.bootCalled, isTrue);
    });

    nyTest('multiple providers in complete lifecycle', () async {
      final provider1 = MockProvider();
      final provider2 = NullReturningProvider();
      final provider3 = ModifyingProvider();
      final providers = <Type, NyProvider>{
        MockProvider: provider1,
        NullReturningProvider: provider2,
        ModifyingProvider: provider3,
      };

      final nylo = await setupApplication(providers);
      await bootFinished(nylo, providers);

      expect(provider1.setupCalled, isTrue);
      expect(provider1.bootCalled, isTrue);
      expect(provider2.setupCalled, isTrue);
      expect(provider2.bootCalled, isTrue);
      expect(provider3.setupCalled, isTrue);
      expect(provider3.bootCalled, isTrue);
    });

    nyTest('Nylo is accessible from Backpack after bootFinished', () async {
      final provider = MockProvider();
      final providers = {MockProvider: provider};

      final nylo = await setupApplication(providers);
      await bootFinished(nylo, providers);

      expectBackpackContains('nylo');
      final storedNylo = Backpack.instance.read('nylo');
      expect(storedNylo, same(nylo));
    });

    nyTest('setup failure prevents bootFinished from being called', () async {
      final failingProvider = MockProvider()..shouldThrow = true;
      final providers = {MockProvider: failingProvider};

      bool bootFinishedCalled = false;
      try {
        await setupApplication(providers);
        bootFinishedCalled = true;
      } catch (_) {}

      // bootFinished should not have been called since setup threw
      expect(bootFinishedCalled, isFalse);
      expect(failingProvider.bootCalled, isFalse);
    });
  });
}
