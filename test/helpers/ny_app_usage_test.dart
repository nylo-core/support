import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NyAppUsage', () {
    nyGroup('prefix', () {
      nyTest('should be ny_app_usage_', () async {
        expect(NyAppUsage.prefix, 'ny_app_usage_');
      });
    });

    nyGroup('key', () {
      nyTest('should prepend prefix to name', () async {
        expect(NyAppUsage.key('test'), 'ny_app_usage_test');
      });

      nyTest('should handle empty name', () async {
        expect(NyAppUsage.key(''), 'ny_app_usage_');
      });

      nyTest('should handle launch_count key', () async {
        expect(NyAppUsage.key('launch_count'), 'ny_app_usage_launch_count');
      });

      nyTest('should handle first_launch key', () async {
        expect(NyAppUsage.key('first_launch'), 'ny_app_usage_first_launch');
      });
    });

    nyGroup('appLaunched', () {
      const MethodChannel secureStorage = MethodChannel(
        'plugins.it_nomads.com/flutter_secure_storage',
      );

      nySetUp(() {
        NyEnvRegistry.register(
          getter: (String key, {dynamic defaultValue}) =>
              {'APP_DEBUG': false}[key] ?? defaultValue,
        );
        Backpack.instance.save('nylo', Nylo()..monitorAppUsage());
      });

      /// iOS refuses keychain access (errSecInteractionNotAllowed) while the
      /// device is locked, e.g. when a push launches the app in the background.
      void lockKeychain() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(secureStorage, (MethodCall call) async {
              throw PlatformException(
                code: 'Unexpected security result code',
                message:
                    'Code: -25308, Message: User interaction is not allowed.',
              );
            });
        addTearDown(() {
          // Put NyTest's in-memory secure storage back
          NyMockChannels.tearDown();
          NyMockChannels.setup();
        });
      }

      nyTest('counts each launch', () async {
        await NyAppUsage.appLaunched();
        await NyAppUsage.appLaunched();

        expect(await NyAppUsage.appLaunchCount(), 2);
      });

      nyTest('does not throw while the keychain is locked', () async {
        lockKeychain();

        await NyAppUsage.appLaunched();
      });

      nyTest('reading the count still reports a locked keychain', () async {
        lockKeychain();

        await expectLater(
          NyAppUsage.appLaunchCount(),
          throwsA(isA<PlatformException>()),
        );
      });
    });
  });
}
