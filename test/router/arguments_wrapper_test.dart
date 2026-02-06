import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('ArgumentsWrapper', () {
    nyGroup('constructor', () {
      nyTest('should create with no arguments', () async {
        final wrapper = ArgumentsWrapper();

        expect(wrapper.baseArguments, isNull);
        expect(wrapper.queryParameters, isNull);
        expect(wrapper.transitionType, isNull);
        expect(wrapper.pageTransitionType, isNull);
        expect(wrapper.pageTransitionSettings, isNull);
        expect(wrapper.prefix, isNull);
      });

      nyTest('should create with baseArguments', () async {
        final args = NyArgument({'key': 'value'});

        final wrapper = ArgumentsWrapper(baseArguments: args);

        expect(wrapper.baseArguments, same(args));
        expect(wrapper.baseArguments!.data['key'], 'value');
      });

      nyTest('should create with queryParameters', () async {
        final params = NyQueryParameters({'sort': 'asc'});

        final wrapper = ArgumentsWrapper(queryParameters: params);

        expect(wrapper.queryParameters, same(params));
        expect(wrapper.queryParameters!.data['sort'], 'asc');
      });

      nyTest('should create with transitionType', () async {
        final transitionType = TransitionType.fade();

        final wrapper = ArgumentsWrapper(transitionType: transitionType);

        expect(wrapper.transitionType, same(transitionType));
      });

      nyTest('should create with pageTransitionType', () async {
        final wrapper = ArgumentsWrapper(
          pageTransitionType: PageTransitionType.bottomToTop,
        );

        expect(wrapper.pageTransitionType, PageTransitionType.bottomToTop);
      });

      nyTest('should create with pageTransitionSettings', () async {
        final settings = const PageTransitionSettings(
          duration: Duration(milliseconds: 500),
        );

        final wrapper = ArgumentsWrapper(pageTransitionSettings: settings);

        expect(wrapper.pageTransitionSettings, same(settings));
      });

      nyTest('should create with prefix', () async {
        final wrapper = ArgumentsWrapper(prefix: '/api');

        expect(wrapper.prefix, '/api');
      });

      nyTest('should create with all parameters', () async {
        final args = NyArgument({'id': 1});
        final params = NyQueryParameters({'page': '1'});
        final transitionType = TransitionType.rightToLeft();
        final settings = const PageTransitionSettings();

        final wrapper = ArgumentsWrapper(
          baseArguments: args,
          queryParameters: params,
          transitionType: transitionType,
          pageTransitionType: PageTransitionType.fade,
          pageTransitionSettings: settings,
          prefix: '/admin',
        );

        expect(wrapper.baseArguments, same(args));
        expect(wrapper.queryParameters, same(params));
        expect(wrapper.transitionType, same(transitionType));
        expect(wrapper.pageTransitionType, PageTransitionType.fade);
        expect(wrapper.pageTransitionSettings, same(settings));
        expect(wrapper.prefix, '/admin');
      });
    });

    nyGroup('copyWith()', () {
      nyTest('should create copy with same values', () async {
        final original = ArgumentsWrapper(
          baseArguments: NyArgument('test'),
          queryParameters: NyQueryParameters({'key': 'value'}),
          pageTransitionType: PageTransitionType.fade,
        );

        final copy = original.copyWith();

        expect(copy.baseArguments, same(original.baseArguments));
        expect(copy.queryParameters, same(original.queryParameters));
        expect(copy.pageTransitionType, original.pageTransitionType);
      });

      nyTest('should override baseArguments', () async {
        final original = ArgumentsWrapper(
          baseArguments: NyArgument('original'),
        );
        final newArgs = NyArgument('new');

        final copy = original.copyWith(baseArguments: newArgs);

        expect(copy.baseArguments, same(newArgs));
        expect(original.baseArguments!.data, 'original');
      });

      nyTest('should override queryParameters', () async {
        final original = ArgumentsWrapper(
          queryParameters: NyQueryParameters({'old': 'value'}),
        );
        final newParams = NyQueryParameters({'new': 'value'});

        final copy = original.copyWith(queryParameters: newParams);

        expect(copy.queryParameters, same(newParams));
      });

      nyTest('should override transitionType', () async {
        final original = ArgumentsWrapper(
          transitionType: TransitionType.fade(),
        );
        final newTransition = TransitionType.bottomToTop();

        final copy = original.copyWith(transitionType: newTransition);

        expect(copy.transitionType, same(newTransition));
      });

      nyTest('should override pageTransitionType', () async {
        final original = ArgumentsWrapper(
          pageTransitionType: PageTransitionType.fade,
        );

        final copy = original.copyWith(
          pageTransitionType: PageTransitionType.scale,
        );

        expect(copy.pageTransitionType, PageTransitionType.scale);
      });

      nyTest('should preserve prefix', () async {
        final original = ArgumentsWrapper(prefix: '/api');

        final copy = original.copyWith();

        expect(copy.prefix, '/api');
      });
    });

    nyGroup('getData()', () {
      nyTest('should return map with all data', () async {
        final args = NyArgument({'id': 42});
        final params = NyQueryParameters({'sort': 'desc'});
        final settings = const PageTransitionSettings(
          duration: Duration(seconds: 1),
        );

        final wrapper = ArgumentsWrapper(
          baseArguments: args,
          queryParameters: params,
          pageTransitionType: PageTransitionType.fade,
          pageTransitionSettings: settings,
          prefix: '/v1',
        );

        final data = wrapper.getData();

        expect(data['data'], {'id': 42});
        expect(data['queryParameters'], {'sort': 'desc'});
        expect(data['pageTransitionType'], PageTransitionType.fade);
        expect(data['pageTransitionSettings'], same(settings));
        expect(data['prefix'], '/v1');
      });

      nyTest('should handle null values', () async {
        final wrapper = ArgumentsWrapper();

        final data = wrapper.getData();

        expect(data['data'], isNull);
        expect(data['queryParameters'], isNull);
        expect(data['pageTransitionType'], isNull);
        expect(data['pageTransitionSettings'], isNull);
        expect(data['prefix'], isNull);
      });
    });

    nyGroup('toString()', () {
      nyTest('should return string representation', () async {
        final wrapper = ArgumentsWrapper(
          baseArguments: NyArgument('test'),
          prefix: '/api',
        );

        final str = wrapper.toString();

        expect(str, contains('ArgumentsWrapper'));
        expect(str, contains('"prefix":"/api"'));
      });
    });
  });
}
