import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/router/src/models/ny_argument.dart';
import 'package:nylo_support/router/src/models/ny_query_parameters.dart';
import 'package:nylo_support/router/src/models/ny_page_transition_settings.dart';
import 'package:nylo_support/router/src/models/nyrouter_options.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  // ===========================================================================
  // NyArgument tests
  // ===========================================================================

  nyGroup('NyArgument', () {
    nyTest('should store data', () async {
      final arg = NyArgument('hello');
      expect(arg.data, 'hello');
    });

    nyTest('should accept any type of data', () async {
      expect(NyArgument(42).data, 42);
      expect(NyArgument([1, 2]).data, [1, 2]);
      expect(NyArgument({'key': 'val'}).data, {'key': 'val'});
      expect(NyArgument(null).data, isNull);
    });

    nyTest('setData should update data', () async {
      final arg = NyArgument('old');
      arg.setData('new');
      expect(arg.data, 'new');
    });

    nyTest('data should be mutable', () async {
      final arg = NyArgument('first');
      arg.data = 'second';
      expect(arg.data, 'second');
    });
  });

  // ===========================================================================
  // NyQueryParameters tests
  // ===========================================================================

  nyGroup('NyQueryParameters', () {
    nyTest('should store query parameter data', () async {
      final params = NyQueryParameters({'userId': '2', 'page': '1'});
      expect(params.data['userId'], '2');
      expect(params.data['page'], '1');
    });

    nyTest('should handle empty parameters', () async {
      final params = NyQueryParameters({});
      expect(params.data, isEmpty);
    });

    nyTest('data should be mutable', () async {
      final params = NyQueryParameters({'a': '1'});
      params.data = {'b': '2'};
      expect(params.data, {'b': '2'});
    });
  });

  // ===========================================================================
  // PageTransitionSettings tests
  // ===========================================================================

  nyGroup('PageTransitionSettings', () {
    nyTest('should create with default null values', () async {
      const settings = PageTransitionSettings();
      expect(settings.childCurrent, isNull);
      expect(settings.context, isNull);
      expect(settings.inheritTheme, isNull);
      expect(settings.curve, isNull);
      expect(settings.alignment, isNull);
      expect(settings.duration, isNull);
      expect(settings.reverseDuration, isNull);
      expect(settings.fullscreenDialog, isNull);
      expect(settings.opaque, isNull);
      expect(settings.isIos, isNull);
      expect(settings.matchingBuilder, isNull);
    });

    nyTest('base constructor should have defaults', () async {
      const settings = PageTransitionSettings.base();
      expect(settings.inheritTheme, isFalse);
      expect(settings.fullscreenDialog, isFalse);
      expect(settings.opaque, isFalse);
      expect(settings.matchingBuilder, isNotNull);
    });

    nyTest('should accept custom duration', () async {
      const settings = PageTransitionSettings(
        duration: Duration(milliseconds: 500),
        reverseDuration: Duration(milliseconds: 300),
      );
      expect(settings.duration, const Duration(milliseconds: 500));
      expect(settings.reverseDuration, const Duration(milliseconds: 300));
    });

    nyTest('toString should include field values', () async {
      const settings = PageTransitionSettings(
        fullscreenDialog: true,
        opaque: false,
      );
      final str = settings.toString();
      expect(str, contains('PageTransitionSettings'));
      expect(str, contains('fullscreenDialog: true'));
      expect(str, contains('opaque: false'));
    });

    nyTest('should be const constructible', () async {
      const settings = PageTransitionSettings();
      expect(settings, isA<PageTransitionSettings>());
    });
  });

  // ===========================================================================
  // NyRouterOptions tests
  // ===========================================================================

  nyGroup('NyRouterOptions', () {
    nyTest('should have sensible defaults', () async {
      const options = NyRouterOptions();
      expect(options.handleNameNotFoundUI, isFalse);
      expect(options.isLoggingEnabled, isFalse);
      expect(options.navigatorKey, isNull);
      expect(options.pageTransitionSettings, isA<PageTransitionSettings>());
    });

    nyTest('should accept custom values', () async {
      const options = NyRouterOptions(
        handleNameNotFoundUI: true,
        isLoggingEnabled: true,
      );
      expect(options.handleNameNotFoundUI, isTrue);
      expect(options.isLoggingEnabled, isTrue);
    });

    nyTest('should be const constructible', () async {
      const options = NyRouterOptions();
      expect(options, isA<NyRouterOptions>());
    });
  });
}
