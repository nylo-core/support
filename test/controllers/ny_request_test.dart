import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/controllers/ny_controllers.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NyRequest', () {
    nyGroup('data()', () {
      nyTest('returns data when args are set', () async {
        final request = NyRequest(
          currentRoute: '/test-page',
          args: NyArgument({'userId': 123, 'name': 'Test User'}),
        );

        final result = request.data<Map<String, dynamic>>();

        expect(result, isNotNull);
        expect(result!['userId'], 123);
        expect(result['name'], 'Test User');
      });

      nyTest('returns defaultValue when args are null', () async {
        final request = NyRequest(currentRoute: '/test-page');

        final result = request.data<String>(defaultValue: 'default');

        expect(result, 'default');
      });

      nyTest('returns defaultValue when args data is null', () async {
        final request = NyRequest(
          currentRoute: '/test-page',
          args: NyArgument(null),
        );

        final result = request.data<String>(defaultValue: 'fallback');

        expect(result, 'fallback');
      });

      nyTest('returns typed data correctly', () async {
        final request = NyRequest(
          currentRoute: '/test-page',
          args: NyArgument('simple string'),
        );

        final result = request.data<String>();

        expect(result, 'simple string');
      });

      nyTest('handles integer data', () async {
        final request = NyRequest(
          currentRoute: '/test-page',
          args: NyArgument(42),
        );

        final result = request.data<int>();

        expect(result, 42);
      });

      nyTest('handles list data', () async {
        final request = NyRequest(
          currentRoute: '/test-page',
          args: NyArgument([1, 2, 3]),
        );

        final result = request.data<List<int>>();

        expect(result, [1, 2, 3]);
      });
    });

    nyGroup('setData()', () {
      nyTest('updates existing args data', () async {
        final args = NyArgument('initial');
        final request = NyRequest(currentRoute: '/test-page', args: args);

        request.setData('updated');

        expect(request.data<String>(), 'updated');
      });

      nyTest('does nothing when args are null', () async {
        final request = NyRequest(currentRoute: '/test-page');

        // Should not throw
        request.setData('new data');

        // Data still returns null since args was null
        expect(request.data<String>(), isNull);
      });
    });

    nyGroup('queryParameters()', () {
      nyTest('returns full map when no key specified', () async {
        final request = NyRequest(
          currentRoute: '/test-page',
          queryParameters: NyQueryParameters({
            'tab': 'settings',
            'page': '2',
            'filter': 'active',
          }),
        );

        final result = request.queryParameters();

        expect(result, isA<Map>());
        expect(result['tab'], 'settings');
        expect(result['page'], '2');
        expect(result['filter'], 'active');
      });

      nyTest('returns single value when key is specified', () async {
        final request = NyRequest(
          currentRoute: '/test-page',
          queryParameters: NyQueryParameters({'tab': 'settings', 'page': '2'}),
        );

        final result = request.queryParameters(key: 'tab');

        expect(result, 'settings');
      });

      nyTest('returns null for non-existent key', () async {
        final request = NyRequest(
          currentRoute: '/test-page',
          queryParameters: NyQueryParameters({'tab': 'settings'}),
        );

        final result = request.queryParameters(key: 'nonexistent');

        expect(result, isNull);
      });

      nyTest('returns null when queryParameters are not set', () async {
        final request = NyRequest(currentRoute: '/test-page');

        final result = request.queryParameters();

        expect(result, isNull);
      });

      nyTest('returns null for key when queryParameters are not set', () async {
        final request = NyRequest(currentRoute: '/test-page');

        final result = request.queryParameters(key: 'anyKey');

        expect(result, isNull);
      });

      nyTest('handles empty query parameters map', () async {
        final request = NyRequest(
          currentRoute: '/test-page',
          queryParameters: NyQueryParameters({}),
        );

        final result = request.queryParameters();

        expect(result, isA<Map>());
        expect(result.isEmpty, true);
      });
    });

    nyGroup('currentRoute', () {
      nyTest('stores and returns current route', () async {
        final request = NyRequest(currentRoute: '/my-page');

        expect(request.currentRoute, '/my-page');
      });

      nyTest('can be null', () async {
        final request = NyRequest();

        expect(request.currentRoute, isNull);
      });
    });
  });
}
