import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/providers/ny_providers.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/nylo.dart';

/// Tests for the BootConfig class.
///
/// BootConfig is the configuration object that defines how a Nylo application
/// bootstraps. It contains two functions:
/// - setup: Initializes the application and returns a Nylo instance
/// - boot: Called after setup completes to finalize initialization
void main() {
  NyTest.init();

  // =============================================================================
  // BootConfig Constructor Tests
  // =============================================================================

  nyGroup('BootConfig', () {
    nyGroup('constructor', () {
      nyTest(
        'should create instance with required setup and boot functions',
        () async {
          bool setupCalled = false;
          bool bootCalled = false;

          final config = BootConfig(
            setup: () async {
              setupCalled = true;
              return Nylo();
            },
            boot: (Nylo nylo) async {
              bootCalled = true;
            },
          );

          expect(config.setup, isNotNull);
          expect(config.boot, isNotNull);

          // Verify functions can be called
          final nylo = await config.setup();
          await config.boot(nylo);

          expect(setupCalled, isTrue);
          expect(bootCalled, isTrue);
        },
      );

      nyTest('should allow setup to return existing Nylo instance', () async {
        final existingNylo = Nylo();

        final config = BootConfig(
          setup: () async => existingNylo,
          boot: (Nylo nylo) async {},
        );

        final result = await config.setup();
        expect(result, same(existingNylo));
      });

      nyTest('should pass Nylo instance from setup to boot', () async {
        late Nylo capturedNylo;
        Nylo? receivedNylo;

        final config = BootConfig(
          setup: () async {
            capturedNylo = Nylo();
            return capturedNylo;
          },
          boot: (Nylo nylo) async {
            receivedNylo = nylo;
          },
        );

        final nylo = await config.setup();
        await config.boot(nylo);

        expect(receivedNylo, same(capturedNylo));
      });
    });

    nyGroup('setup function', () {
      nyTest('should support async operations', () async {
        int setupOrder = 0;

        final config = BootConfig(
          setup: () async {
            await Future.delayed(Duration(milliseconds: 10));
            setupOrder = 1;
            return Nylo();
          },
          boot: (Nylo nylo) async {},
        );

        expect(setupOrder, equals(0));
        await config.setup();
        expect(setupOrder, equals(1));
      });

      nyTest('should propagate exceptions', () async {
        final config = BootConfig(
          setup: () async {
            throw Exception('Setup error');
          },
          boot: (Nylo nylo) async {},
        );

        expect(
          () => config.setup(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Setup error'),
            ),
          ),
        );
      });

      nyTest('should allow configuring Nylo instance', () async {
        final config = BootConfig(
          setup: () async {
            final nylo = Nylo();
            nylo.addModelDecoders({String: (data) => data.toString()});
            return nylo;
          },
          boot: (Nylo nylo) async {},
        );

        final nylo = await config.setup();
        expect(nylo.getModelDecoders(), containsPair(String, isNotNull));
      });
    });

    nyGroup('boot function', () {
      nyTest('should support async operations', () async {
        int bootOrder = 0;

        final config = BootConfig(
          setup: () async => Nylo(),
          boot: (Nylo nylo) async {
            await Future.delayed(Duration(milliseconds: 10));
            bootOrder = 1;
          },
        );

        final nylo = await config.setup();
        expect(bootOrder, equals(0));
        await config.boot(nylo);
        expect(bootOrder, equals(1));
      });

      nyTest('should propagate exceptions', () async {
        final config = BootConfig(
          setup: () async => Nylo(),
          boot: (Nylo nylo) async {
            throw Exception('Boot error');
          },
        );

        final nylo = await config.setup();
        expect(
          () => config.boot(nylo),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Boot error'),
            ),
          ),
        );
      });

      nyTest('should receive the correct Nylo instance', () async {
        Nylo? receivedNylo;

        final config = BootConfig(
          setup: () async => Nylo(),
          boot: (Nylo nylo) async {
            receivedNylo = nylo;
          },
        );

        final nylo = await config.setup();
        await config.boot(nylo);

        expect(receivedNylo, same(nylo));
      });

      nyTest('should be able to modify Nylo instance', () async {
        final config = BootConfig(
          setup: () async => Nylo(),
          boot: (Nylo nylo) async {
            nylo.addModelDecoders({int: (data) => int.parse(data.toString())});
          },
        );

        final nylo = await config.setup();
        await config.boot(nylo);

        expect(nylo.getModelDecoders(), containsPair(int, isNotNull));
      });
    });

    nyGroup('lifecycle order', () {
      nyTest('should execute setup before boot', () async {
        List<String> executionOrder = [];

        final config = BootConfig(
          setup: () async {
            executionOrder.add('setup');
            return Nylo();
          },
          boot: (Nylo nylo) async {
            executionOrder.add('boot');
          },
        );

        final nylo = await config.setup();
        await config.boot(nylo);

        expect(executionOrder, equals(['setup', 'boot']));
      });

      nyTest('should allow multiple sequential calls', () async {
        int setupCount = 0;
        int bootCount = 0;

        final config = BootConfig(
          setup: () async {
            setupCount++;
            return Nylo();
          },
          boot: (Nylo nylo) async {
            bootCount++;
          },
        );

        // First lifecycle
        final nylo1 = await config.setup();
        await config.boot(nylo1);

        // Second lifecycle
        final nylo2 = await config.setup();
        await config.boot(nylo2);

        expect(setupCount, equals(2));
        expect(bootCount, equals(2));
      });
    });
  });
}
