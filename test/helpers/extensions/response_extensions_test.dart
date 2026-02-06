import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/src/extensions/response_extensions.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  // ===========================================================================
  // NyResponseExt.path tests
  // ===========================================================================

  nyGroup('NyResponseExt.path', () {
    nyTest('should return the request path', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/api/users'),
        statusCode: 200,
      );
      expect(response.path, '/api/users');
    });

    nyTest('should return empty path', () async {
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
      );
      expect(response.path, '');
    });

    nyTest('should return path with query parameters in path string', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/users/123/profile'),
        statusCode: 200,
      );
      expect(response.path, '/users/123/profile');
    });
  });

  // ===========================================================================
  // NyResponseExt.toJson tests
  // ===========================================================================

  nyGroup('NyResponseExt.toJson', () {
    nyTest('should return map with correct keys', () async {
      final response = Response(
        requestOptions: RequestOptions(
          path: '/api/users',
          method: 'GET',
          baseUrl: 'https://example.com',
          queryParameters: {'page': '1'},
        ),
        statusCode: 200,
        statusMessage: 'OK',
        data: {'id': 1, 'name': 'Test'},
      );

      final json = response.toJson();
      expect(json, containsPair('statusCode', 200));
      expect(json, containsPair('statusMessage', 'OK'));
      expect(json, containsPair('data', {'id': 1, 'name': 'Test'}));
      expect(json['requestOptions'], isA<Map>());
      expect(json['requestOptions']['path'], '/api/users');
      expect(json['requestOptions']['method'], 'GET');
      expect(json['requestOptions']['baseUrl'], 'https://example.com');
      expect(json['requestOptions']['queryParameters'], {'page': '1'});
    });

    nyTest('should handle null data', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 204,
        data: null,
      );

      final json = response.toJson();
      expect(json['data'], isNull);
      expect(json['statusCode'], 204);
    });

    nyTest('should handle POST method', () async {
      final response = Response(
        requestOptions: RequestOptions(
          path: '/api/users',
          method: 'POST',
          baseUrl: 'https://api.test.com',
        ),
        statusCode: 201,
        statusMessage: 'Created',
        data: {'id': 42},
      );

      final json = response.toJson();
      expect(json['requestOptions']['method'], 'POST');
      expect(json['statusCode'], 201);
    });

    nyTest('should handle empty query parameters', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/test', queryParameters: {}),
        statusCode: 200,
      );

      final json = response.toJson();
      expect(json['requestOptions']['queryParameters'], isEmpty);
    });
  });
}
