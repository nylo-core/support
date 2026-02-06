import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/networking/src/models/ny_response.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Helper to create a mock Dio Response
Response<T> createMockResponse<T>({
  T? data,
  int statusCode = 200,
  String statusMessage = 'OK',
  Map<String, List<String>>? headers,
  String path = '/test',
  String method = 'GET',
}) {
  return Response<T>(
    data: data,
    statusCode: statusCode,
    statusMessage: statusMessage,
    headers: Headers.fromMap(headers ?? {}),
    requestOptions: RequestOptions(
      path: path,
      method: method,
      baseUrl: 'https://api.example.com',
    ),
  );
}

void main() {
  NyTest.init();

  nyGroup('NyResponse', () {
    nyGroup('constructor', () {
      nyTest('creates with all required parameters', () async {
        final dioResponse = createMockResponse(data: {'id': 1});

        final response = NyResponse<Map<String, dynamic>>(
          response: dioResponse,
          data: {'id': 1},
          rawData: dioResponse.data,
        );

        expect(response.response, dioResponse);
        expect(response.data, isNotNull);
        expect(response.rawData, isNotNull);
      });

      nyTest('creates with null data', () async {
        final dioResponse = createMockResponse<dynamic>(data: null);

        final response = NyResponse<String>(
          response: dioResponse,
          data: null,
          rawData: null,
        );

        expect(response.data, isNull);
        expect(response.hasData, isFalse);
      });
    });

    nyGroup('fromResponse factory', () {
      nyTest('creates from Dio Response with morphed data', () async {
        final dioResponse = createMockResponse(
          data: {'name': 'John'},
          statusCode: 200,
        );

        final response = NyResponse<Map<String, dynamic>>.fromResponse(
          response: dioResponse,
          morphedData: {'name': 'John'},
        );

        expect(response.statusCode, 200);
        expect(response.data?['name'], 'John');
        expect(response.rawData, dioResponse.data);
      });
    });

    nyGroup('status code helpers', () {
      nyTest('isSuccessful returns true for 2xx status codes', () async {
        for (final code in [200, 201, 202, 204, 299]) {
          final response = NyResponse<String>(
            response: createMockResponse(statusCode: code),
            data: 'test',
            rawData: 'test',
          );
          expect(
            response.isSuccessful,
            isTrue,
            reason: 'Status $code should be successful',
          );
        }
      });

      nyTest('isSuccessful returns false for non-2xx status codes', () async {
        for (final code in [100, 301, 400, 404, 500]) {
          final response = NyResponse<String>(
            response: createMockResponse(statusCode: code),
            data: null,
            rawData: null,
          );
          expect(
            response.isSuccessful,
            isFalse,
            reason: 'Status $code should not be successful',
          );
        }
      });

      nyTest('isClientError returns true for 4xx status codes', () async {
        for (final code in [400, 401, 403, 404, 422, 429, 499]) {
          final response = NyResponse<String>(
            response: createMockResponse(statusCode: code),
            data: null,
            rawData: null,
          );
          expect(
            response.isClientError,
            isTrue,
            reason: 'Status $code should be client error',
          );
        }
      });

      nyTest('isServerError returns true for 5xx status codes', () async {
        for (final code in [500, 501, 502, 503, 504, 599]) {
          final response = NyResponse<String>(
            response: createMockResponse(statusCode: code),
            data: null,
            rawData: null,
          );
          expect(
            response.isServerError,
            isTrue,
            reason: 'Status $code should be server error',
          );
        }
      });

      nyTest('isRedirect returns true for 3xx status codes', () async {
        for (final code in [300, 301, 302, 303, 307, 308]) {
          final response = NyResponse<String>(
            response: createMockResponse(statusCode: code),
            data: null,
            rawData: null,
          );
          expect(
            response.isRedirect,
            isTrue,
            reason: 'Status $code should be redirect',
          );
        }
      });
    });

    nyGroup('specific status code checks', () {
      nyTest('isUnauthorized returns true for 401', () async {
        final response = NyResponse<String>(
          response: createMockResponse(statusCode: 401),
          data: null,
          rawData: null,
        );

        expect(response.isUnauthorized, isTrue);
        expect(response.isForbidden, isFalse);
      });

      nyTest('isForbidden returns true for 403', () async {
        final response = NyResponse<String>(
          response: createMockResponse(statusCode: 403),
          data: null,
          rawData: null,
        );

        expect(response.isForbidden, isTrue);
        expect(response.isUnauthorized, isFalse);
      });

      nyTest('isNotFound returns true for 404', () async {
        final response = NyResponse<String>(
          response: createMockResponse(statusCode: 404),
          data: null,
          rawData: null,
        );

        expect(response.isNotFound, isTrue);
      });

      nyTest('isTimeout returns true for 408', () async {
        final response = NyResponse<String>(
          response: createMockResponse(statusCode: 408),
          data: null,
          rawData: null,
        );

        expect(response.isTimeout, isTrue);
      });

      nyTest('isConflict returns true for 409', () async {
        final response = NyResponse<String>(
          response: createMockResponse(statusCode: 409),
          data: null,
          rawData: null,
        );

        expect(response.isConflict, isTrue);
      });

      nyTest('isRateLimited returns true for 429', () async {
        final response = NyResponse<String>(
          response: createMockResponse(statusCode: 429),
          data: null,
          rawData: null,
        );

        expect(response.isRateLimited, isTrue);
      });
    });

    nyGroup('headers and metadata', () {
      nyTest('headers returns response headers', () async {
        final response = NyResponse<String>(
          response: createMockResponse(
            headers: {
              'content-type': ['application/json'],
              'x-custom': ['value'],
            },
          ),
          data: 'test',
          rawData: 'test',
        );

        expect(response.headers, isNotNull);
      });

      nyTest('getHeader returns specific header value', () async {
        final response = NyResponse<String>(
          response: createMockResponse(
            headers: {
              'x-request-id': ['abc-123'],
            },
          ),
          data: 'test',
          rawData: 'test',
        );

        expect(response.getHeader('x-request-id'), 'abc-123');
      });

      nyTest('getHeaderValues returns all values for a header', () async {
        final response = NyResponse<String>(
          response: createMockResponse(
            headers: {
              'set-cookie': ['session=abc', 'token=xyz'],
            },
          ),
          data: 'test',
          rawData: 'test',
        );

        final cookies = response.getHeaderValues('set-cookie');
        expect(cookies, isNotNull);
        expect(cookies?.length, 2);
      });

      nyTest('contentType returns content-type header', () async {
        final response = NyResponse<String>(
          response: createMockResponse(
            headers: {
              'content-type': ['application/json; charset=utf-8'],
            },
          ),
          data: 'test',
          rawData: 'test',
        );

        expect(response.contentType, 'application/json; charset=utf-8');
      });

      nyTest('requestOptions returns request options', () async {
        final response = NyResponse<String>(
          response: createMockResponse(path: '/users', method: 'POST'),
          data: 'test',
          rawData: 'test',
        );

        expect(response.requestOptions?.path, '/users');
        expect(response.requestOptions?.method, 'POST');
      });
    });

    nyGroup('hasData', () {
      nyTest('returns true when data is not null', () async {
        final response = NyResponse<String>(
          response: createMockResponse(),
          data: 'test data',
          rawData: 'test data',
        );

        expect(response.hasData, isTrue);
      });

      nyTest('returns false when data is null', () async {
        final response = NyResponse<String>(
          response: createMockResponse(),
          data: null,
          rawData: null,
        );

        expect(response.hasData, isFalse);
      });
    });

    nyGroup('dataOrThrow', () {
      nyTest('returns data when not null', () async {
        final response = NyResponse<String>(
          response: createMockResponse(),
          data: 'success',
          rawData: 'success',
        );

        expect(response.dataOrThrow(), 'success');
      });

      nyTest('throws exception when data is null', () async {
        final response = NyResponse<String>(
          response: createMockResponse(statusCode: 404),
          data: null,
          rawData: null,
        );

        expect(() => response.dataOrThrow(), throwsA(isA<Exception>()));
      });

      nyTest('throws with custom message when provided', () async {
        final response = NyResponse<String>(
          response: createMockResponse(),
          data: null,
          rawData: null,
        );

        expect(
          () => response.dataOrThrow('Custom error message'),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('Custom error message'),
            ),
          ),
        );
      });
    });

    nyGroup('dataOr', () {
      nyTest('returns data when not null', () async {
        final response = NyResponse<String>(
          response: createMockResponse(),
          data: 'actual data',
          rawData: 'actual data',
        );

        expect(response.dataOr('fallback'), 'actual data');
      });

      nyTest('returns fallback when data is null', () async {
        final response = NyResponse<String>(
          response: createMockResponse(),
          data: null,
          rawData: null,
        );

        expect(response.dataOr('fallback'), 'fallback');
      });

      nyTest('works with complex fallback values', () async {
        final response = NyResponse<List<int>>(
          response: createMockResponse(),
          data: null,
          rawData: null,
        );

        expect(response.dataOr([1, 2, 3]), [1, 2, 3]);
      });
    });

    nyGroup('ifSuccessful', () {
      nyTest('executes callback when successful with data', () async {
        final response = NyResponse<String>(
          response: createMockResponse(statusCode: 200),
          data: 'test',
          rawData: 'test',
        );

        final result = response.ifSuccessful((data) => 'processed: $data');

        expect(result, 'processed: test');
      });

      nyTest('returns null when not successful', () async {
        final response = NyResponse<String>(
          response: createMockResponse(statusCode: 500),
          data: 'test',
          rawData: 'test',
        );

        final result = response.ifSuccessful((data) => 'processed: $data');

        expect(result, isNull);
      });

      nyTest('returns null when data is null', () async {
        final response = NyResponse<String>(
          response: createMockResponse(statusCode: 200),
          data: null,
          rawData: null,
        );

        final result = response.ifSuccessful((data) => 'processed: $data');

        expect(result, isNull);
      });
    });

    nyGroup('when', () {
      nyTest('executes success callback when successful', () async {
        final response = NyResponse<String>(
          response: createMockResponse(statusCode: 200),
          data: 'hello',
          rawData: 'hello',
        );

        final result = response.when(
          success: (data) => 'success: $data',
          failure: (response) => 'failure: ${response.statusCode}',
        );

        expect(result, 'success: hello');
      });

      nyTest('executes failure callback when not successful', () async {
        final response = NyResponse<String>(
          response: createMockResponse(statusCode: 404),
          data: null,
          rawData: null,
        );

        final result = response.when(
          success: (data) => 'success: $data',
          failure: (response) => 'failure: ${response.statusCode}',
        );

        expect(result, 'failure: 404');
      });

      nyTest('executes failure callback when data is null', () async {
        final response = NyResponse<String>(
          response: createMockResponse(statusCode: 200),
          data: null,
          rawData: null,
        );

        final result = response.when(
          success: (data) => 'success: $data',
          failure: (r) => 'no data',
        );

        expect(result, 'no data');
      });
    });

    nyGroup('errorMessage', () {
      nyTest('extracts message from Map response', () async {
        final response = NyResponse<String>(
          response: createMockResponse(),
          data: null,
          rawData: {'message': 'Something went wrong'},
        );

        expect(response.errorMessage, 'Something went wrong');
      });

      nyTest('extracts error from Map response', () async {
        final response = NyResponse<String>(
          response: createMockResponse(),
          data: null,
          rawData: {'error': 'Validation failed'},
        );

        expect(response.errorMessage, 'Validation failed');
      });

      nyTest('extracts error_message from Map response', () async {
        final response = NyResponse<String>(
          response: createMockResponse(),
          data: null,
          rawData: {'error_message': 'API error'},
        );

        expect(response.errorMessage, 'API error');
      });

      nyTest('falls back to statusMessage for non-Map response', () async {
        final response = NyResponse<String>(
          response: createMockResponse(statusMessage: 'Not Found'),
          data: null,
          rawData: 'string error',
        );

        expect(response.errorMessage, 'Not Found');
      });
    });

    nyGroup('toMap', () {
      nyTest('converts response to Map representation', () async {
        final response = NyResponse<String>(
          response: createMockResponse(
            statusCode: 201,
            statusMessage: 'Created',
            path: '/users',
            method: 'POST',
          ),
          data: 'created user',
          rawData: {'id': 1},
        );

        final map = response.toMap();

        expect(map['statusCode'], 201);
        expect(map['statusMessage'], 'Created');
        expect(map['data'], 'created user');
        expect(map['rawData'], {'id': 1});
        expect(map['isSuccessful'], isTrue);
        expect(map['requestMethod'], 'POST');
      });
    });

    nyGroup('toString', () {
      nyTest('returns formatted string representation', () async {
        final response = NyResponse<String>(
          response: createMockResponse(statusCode: 200, statusMessage: 'OK'),
          data: 'test',
          rawData: 'test',
        );

        final str = response.toString();

        expect(str, contains('NyResponse<String>'));
        expect(str, contains('statusCode: 200'));
        expect(str, contains('hasData: true'));
        expect(str, contains('isSuccessful: true'));
      });
    });

    nyGroup('null response handling', () {
      nyTest('handles null statusCode gracefully', () async {
        final response = NyResponse<String>(
          response: null,
          data: null,
          rawData: null,
        );

        expect(response.statusCode, isNull);
        expect(response.isSuccessful, isFalse);
        expect(response.isClientError, isFalse);
        expect(response.isServerError, isFalse);
        expect(response.isRedirect, isFalse);
      });

      nyTest('handles null headers gracefully', () async {
        final response = NyResponse<String>(
          response: null,
          data: null,
          rawData: null,
        );

        expect(response.headers, isNull);
        expect(response.getHeader('any'), isNull);
        expect(response.contentType, isNull);
      });
    });
  });
}
