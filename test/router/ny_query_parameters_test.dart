import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NyQueryParameters', () {
    nyGroup('constructor', () {
      nyTest('should create with empty map', () async {
        final params = NyQueryParameters({});

        expect(params.data, isEmpty);
      });

      nyTest('should create with single parameter', () async {
        final params = NyQueryParameters({'key': 'value'});

        expect(params.data, {'key': 'value'});
        expect(params.data['key'], 'value');
      });

      nyTest('should create with multiple parameters', () async {
        final params = NyQueryParameters({
          'userId': '123',
          'sort': 'asc',
          'page': '1',
        });

        expect(params.data.length, 3);
        expect(params.data['userId'], '123');
        expect(params.data['sort'], 'asc');
        expect(params.data['page'], '1');
      });
    });

    nyGroup('data property', () {
      nyTest('should return correct Map type', () async {
        final params = NyQueryParameters({'test': 'value'});

        expect(params.data, isA<Map<String, String>>());
      });

      nyTest('should be mutable', () async {
        final params = NyQueryParameters({'initial': 'value'});

        params.data['new'] = 'newValue';

        expect(params.data['new'], 'newValue');
      });

      nyTest('should allow reassignment', () async {
        final params = NyQueryParameters({'old': 'data'});

        params.data = {'new': 'data'};

        expect(params.data['old'], isNull);
        expect(params.data['new'], 'data');
      });
    });

    nyGroup('typical URL query parameter scenarios', () {
      nyTest('should handle pagination parameters', () async {
        final params = NyQueryParameters({
          'page': '1',
          'limit': '10',
          'offset': '0',
        });

        expect(params.data['page'], '1');
        expect(params.data['limit'], '10');
        expect(params.data['offset'], '0');
      });

      nyTest('should handle filter parameters', () async {
        final params = NyQueryParameters({
          'status': 'active',
          'category': 'electronics',
          'minPrice': '100',
          'maxPrice': '500',
        });

        expect(params.data['status'], 'active');
        expect(params.data['category'], 'electronics');
      });

      nyTest('should handle special characters as values', () async {
        final params = NyQueryParameters({
          'query': 'hello world',
          'email': 'test@example.com',
        });

        expect(params.data['query'], 'hello world');
        expect(params.data['email'], 'test@example.com');
      });

      nyTest('should handle empty string values', () async {
        final params = NyQueryParameters({
          'emptyParam': '',
          'normalParam': 'value',
        });

        expect(params.data['emptyParam'], '');
        expect(params.data['normalParam'], 'value');
      });
    });
  });
}
