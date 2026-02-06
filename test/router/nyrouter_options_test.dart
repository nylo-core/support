import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NyRouterOptions', () {
    nyGroup('constructor', () {
      nyTest('should create with default values', () async {
        const options = NyRouterOptions();

        expect(options.handleNameNotFoundUI, isFalse);
        expect(options.isLoggingEnabled, isFalse);
        expect(options.pageTransitionSettings, isNotNull);
        expect(options.navigatorKey, isNull);
      });

      nyTest('should create with custom handleNameNotFoundUI', () async {
        const options = NyRouterOptions(handleNameNotFoundUI: true);

        expect(options.handleNameNotFoundUI, isTrue);
      });

      nyTest('should create with custom isLoggingEnabled', () async {
        const options = NyRouterOptions(isLoggingEnabled: true);

        expect(options.isLoggingEnabled, isTrue);
      });

      nyTest('should create with custom pageTransitionSettings', () async {
        const settings = PageTransitionSettings(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
        const options = NyRouterOptions(pageTransitionSettings: settings);

        expect(options.pageTransitionSettings, same(settings));
        expect(
          options.pageTransitionSettings.duration,
          const Duration(milliseconds: 500),
        );
        expect(options.pageTransitionSettings.curve, Curves.easeIn);
      });

      nyTest('should create with custom navigatorKey', () async {
        final key = GlobalKey<NavigatorState>();
        final options = NyRouterOptions(navigatorKey: key);

        expect(options.navigatorKey, same(key));
      });

      nyTest('should create with all custom values', () async {
        final key = GlobalKey<NavigatorState>();
        const settings = PageTransitionSettings(duration: Duration(seconds: 1));

        final options = NyRouterOptions(
          handleNameNotFoundUI: true,
          isLoggingEnabled: true,
          pageTransitionSettings: settings,
          navigatorKey: key,
        );

        expect(options.handleNameNotFoundUI, isTrue);
        expect(options.isLoggingEnabled, isTrue);
        expect(options.pageTransitionSettings, same(settings));
        expect(options.navigatorKey, same(key));
      });
    });

    nyGroup('const constructor', () {
      nyTest('should support const creation', () async {
        const options = NyRouterOptions();

        expect(options.handleNameNotFoundUI, isFalse);
      });
    });

    nyGroup('default pageTransitionSettings', () {
      nyTest('should use base settings by default', () async {
        const options = NyRouterOptions();
        final settings = options.pageTransitionSettings;

        // PageTransitionSettings.base() defaults
        expect(settings.inheritTheme, isFalse);
        expect(settings.fullscreenDialog, isFalse);
        expect(settings.opaque, isFalse);
      });
    });
  });
}
