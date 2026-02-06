import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/testing/src/mocks/ny_mock_api.dart';

void main() {
  setUp(() {
    NyMockApi.clear();
  });

  tearDown(() {
    NyMockApi.clear();
  });

  group('NyMockApi', () {
    group('register() and getHandler()', () {
      test('registers handler for type', () {
        NyMockApi.register<String>((request) async => 'response');

        expect(NyMockApi.hasHandler<String>(), isTrue);
        expect(NyMockApi.getHandler<String>(), isNotNull);
      });

      test('returns null for unregistered type', () {
        expect(NyMockApi.hasHandler<String>(), isFalse);
        expect(NyMockApi.getHandler<String>(), isNull);
      });
    });

    group('getHandlerByType()', () {
      test('returns handler by runtime type', () {
        NyMockApi.register<String>((request) async => 'response');

        expect(NyMockApi.getHandlerByType(String), isNotNull);
      });
    });

    group('respond() and matchUrl()', () {
      test('matches exact URL', () {
        NyMockApi.respond('/users', {'data': 'users'});

        final result = NyMockApi.matchUrl('/users');

        expect(result, isNotNull);
        expect(result!.data, equals({'data': 'users'}));
      });

      test('matches URL with single wildcard', () {
        NyMockApi.respond('/users/*', {'id': 1});

        expect(NyMockApi.matchUrl('/users/1'), isNotNull);
        expect(NyMockApi.matchUrl('/users/abc'), isNotNull);
        expect(NyMockApi.matchUrl('/users/1/posts'), isNull);
      });

      test('matches URL with double wildcard', () {
        NyMockApi.respond('/api/**', {'data': []});

        expect(NyMockApi.matchUrl('/api/v1'), isNotNull);
        expect(NyMockApi.matchUrl('/api/v1/users'), isNotNull);
        expect(NyMockApi.matchUrl('/api/v1/users/1/posts'), isNotNull);
      });

      test('matches method', () {
        NyMockApi.respond('/users', {'data': 'get'}, method: 'GET');
        NyMockApi.respond('/users', {'data': 'post'}, method: 'POST');

        final getResult = NyMockApi.matchUrl('/users', method: 'GET');
        final postResult = NyMockApi.matchUrl('/users', method: 'POST');

        expect(getResult!.data, equals({'data': 'get'}));
        expect(postResult!.data, equals({'data': 'post'}));
      });

      test('returns statusCode', () {
        NyMockApi.respond('/users', {'error': 'Not found'}, statusCode: 404);

        final result = NyMockApi.matchUrl('/users');

        expect(result!.statusCode, equals(404));
      });

      test('returns headers', () {
        NyMockApi.respond(
          '/users',
          {'data': 'users'},
          headers: {'X-Custom': 'value'},
        );

        final result = NyMockApi.matchUrl('/users');

        expect(result!.headers, equals({'X-Custom': 'value'}));
      });

      test('returns delay', () {
        NyMockApi.respond('/users', {
          'data': 'users',
        }, delay: const Duration(milliseconds: 100));

        final result = NyMockApi.matchUrl('/users');

        expect(result!.delay, equals(const Duration(milliseconds: 100)));
      });

      test('later patterns take precedence', () {
        NyMockApi.respond('/users', {'version': 1});
        NyMockApi.respond('/users', {'version': 2});

        final result = NyMockApi.matchUrl('/users');

        expect(result!.data, equals({'version': 2}));
      });

      test('matches path from full URL', () {
        NyMockApi.respond('/users', {'data': 'users'});

        final result = NyMockApi.matchUrl('https://api.example.com/users');

        expect(result, isNotNull);
      });
    });

    group('URL pattern matching details', () {
      test('handles trailing slashes', () {
        NyMockApi.respond('/users/', {'data': 'users'});

        expect(NyMockApi.matchUrl('/users'), isNotNull);
      });

      test('handles multiple wildcards', () {
        NyMockApi.respond('/users/*/posts/*', {'data': 'post'});

        expect(NyMockApi.matchUrl('/users/1/posts/5'), isNotNull);
        expect(NyMockApi.matchUrl('/users/abc/posts/xyz'), isNotNull);
      });

      test('double wildcard at end matches everything', () {
        NyMockApi.respond('/api/**', {'api': true});

        expect(NyMockApi.matchUrl('/api'), isNotNull);
        expect(NyMockApi.matchUrl('/api/'), isNotNull);
        expect(
          NyMockApi.matchUrl('/api/v1/users/1/posts/2/comments'),
          isNotNull,
        );
      });

      test('ignores query parameters in matching', () {
        NyMockApi.respond('/users', {'data': 'users'});

        final result = NyMockApi.matchUrl('/users?page=1&limit=10');

        expect(result, isNotNull);
      });
    });

    group('recordCall() and getCalls()', () {
      test('records API calls', () {
        NyMockApi.recordCall('/users', method: 'GET');
        NyMockApi.recordCall('/users/1', method: 'GET', data: {'id': 1});

        final calls = NyMockApi.getCalls();

        expect(calls.length, equals(2));
        expect(calls[0].endpoint, equals('/users'));
        expect(calls[1].endpoint, equals('/users/1'));
      });

      test('records call with headers', () {
        NyMockApi.recordCall(
          '/users',
          headers: {'Authorization': 'Bearer token'},
        );

        final calls = NyMockApi.getCalls();

        expect(calls[0].headers, equals({'Authorization': 'Bearer token'}));
      });

      test('can disable recording', () {
        NyMockApi.setRecordCalls(false);
        NyMockApi.recordCall('/users');

        expect(NyMockApi.getCalls(), isEmpty);

        NyMockApi.setRecordCalls(true);
      });
    });

    group('getCallsFor()', () {
      test('filters calls by endpoint', () {
        NyMockApi.recordCall('/users');
        NyMockApi.recordCall('/posts');
        NyMockApi.recordCall('/users/1');

        final userCalls = NyMockApi.getCallsFor('/users');

        expect(userCalls.length, equals(2));
      });
    });

    group('wasCalled()', () {
      test('returns true when endpoint was called', () {
        NyMockApi.recordCall('/users');

        expect(NyMockApi.wasCalled('/users'), isTrue);
      });

      test('returns false when endpoint was not called', () {
        expect(NyMockApi.wasCalled('/users'), isFalse);
      });

      test('can filter by method', () {
        NyMockApi.recordCall('/users', method: 'GET');

        expect(NyMockApi.wasCalled('/users', method: 'GET'), isTrue);
        expect(NyMockApi.wasCalled('/users', method: 'POST'), isFalse);
      });

      test('can check call count', () {
        NyMockApi.recordCall('/users');
        NyMockApi.recordCall('/users');
        NyMockApi.recordCall('/users');

        expect(NyMockApi.wasCalled('/users', times: 3), isTrue);
        expect(NyMockApi.wasCalled('/users', times: 2), isFalse);
      });
    });

    group('callCount()', () {
      test('returns number of calls to endpoint', () {
        NyMockApi.recordCall('/users');
        NyMockApi.recordCall('/users');
        NyMockApi.recordCall('/posts');

        expect(NyMockApi.callCount('/users'), equals(2));
        expect(NyMockApi.callCount('/posts'), equals(1));
        expect(NyMockApi.callCount('/comments'), equals(0));
      });

      test('can filter by method', () {
        NyMockApi.recordCall('/users', method: 'GET');
        NyMockApi.recordCall('/users', method: 'GET');
        NyMockApi.recordCall('/users', method: 'POST');

        expect(NyMockApi.callCount('/users', method: 'GET'), equals(2));
        expect(NyMockApi.callCount('/users', method: 'POST'), equals(1));
      });
    });

    group('clear methods', () {
      test('clear() clears everything', () {
        NyMockApi.register<String>((r) async => 'test');
        NyMockApi.respond('/users', {});
        NyMockApi.recordCall('/users');

        NyMockApi.clear();

        expect(NyMockApi.handlerCount, equals(0));
        expect(NyMockApi.patternCount, equals(0));
        expect(NyMockApi.getCalls(), isEmpty);
      });

      test('clearPatterns() clears only patterns', () {
        NyMockApi.register<String>((r) async => 'test');
        NyMockApi.respond('/users', {});

        NyMockApi.clearPatterns();

        expect(NyMockApi.handlerCount, equals(1));
        expect(NyMockApi.patternCount, equals(0));
      });

      test('clearHandlers() clears only handlers', () {
        NyMockApi.register<String>((r) async => 'test');
        NyMockApi.respond('/users', {});

        NyMockApi.clearHandlers();

        expect(NyMockApi.handlerCount, equals(0));
        expect(NyMockApi.patternCount, equals(1));
      });

      test('clearHistory() clears only call history', () {
        NyMockApi.respond('/users', {});
        NyMockApi.recordCall('/users');

        NyMockApi.clearHistory();

        expect(NyMockApi.patternCount, equals(1));
        expect(NyMockApi.getCalls(), isEmpty);
      });
    });

    group('patternCount and handlerCount', () {
      test('returns correct counts', () {
        expect(NyMockApi.patternCount, equals(0));
        expect(NyMockApi.handlerCount, equals(0));

        NyMockApi.respond('/users', {});
        NyMockApi.respond('/posts', {});
        NyMockApi.register<String>((r) async => 'test');

        expect(NyMockApi.patternCount, equals(2));
        expect(NyMockApi.handlerCount, equals(1));
      });
    });

    group('createResponse()', () {
      test('creates Dio Response with data', () {
        final response = NyMockApi.createResponse<Map<String, dynamic>>(
          data: {'id': 1, 'name': 'Test'},
        );

        expect(response.data, equals({'id': 1, 'name': 'Test'}));
        expect(response.statusCode, equals(200));
      });

      test('creates Response with custom status code', () {
        final response = NyMockApi.createResponse<String>(
          data: 'Created',
          statusCode: 201,
          statusMessage: 'Created',
        );

        expect(response.statusCode, equals(201));
        expect(response.statusMessage, equals('Created'));
      });

      test('creates Response with headers', () {
        final response = NyMockApi.createResponse<String>(
          data: 'test',
          headers: {
            'Content-Type': ['application/json'],
          },
        );

        expect(response.headers['Content-Type'], equals(['application/json']));
      });
    });
  });

  group('MockApiRequest', () {
    test('creates request with required fields', () {
      final request = MockApiRequest(endpoint: '/users');

      expect(request.endpoint, equals('/users'));
      expect(request.method, equals('GET'));
    });

    test('creates request with all fields', () {
      final request = MockApiRequest(
        endpoint: '/users',
        method: 'POST',
        data: {'name': 'Test'},
        headers: {'Authorization': 'Bearer token'},
        queryParameters: {'page': 1},
      );

      expect(request.endpoint, equals('/users'));
      expect(request.method, equals('POST'));
      expect(request.data, equals({'name': 'Test'}));
      expect(request.headers, equals({'Authorization': 'Bearer token'}));
      expect(request.queryParameters, equals({'page': 1}));
    });
  });

  group('MockResponse', () {
    test('creates response with required fields', () {
      final response = MockResponse(data: {'id': 1});

      expect(response.data, equals({'id': 1}));
      expect(response.statusCode, equals(200));
    });

    test('creates response with all fields', () {
      final response = MockResponse(
        data: {'id': 1},
        statusCode: 201,
        headers: {'X-Custom': 'value'},
        delay: const Duration(milliseconds: 100),
      );

      expect(response.data, equals({'id': 1}));
      expect(response.statusCode, equals(201));
      expect(response.headers, equals({'X-Custom': 'value'}));
      expect(response.delay, equals(const Duration(milliseconds: 100)));
    });
  });

  group('ApiCallInfo', () {
    test('creates call info with required fields', () {
      final timestamp = DateTime.now();
      final info = ApiCallInfo(
        endpoint: '/users',
        method: 'GET',
        timestamp: timestamp,
      );

      expect(info.endpoint, equals('/users'));
      expect(info.method, equals('GET'));
      expect(info.timestamp, equals(timestamp));
    });

    test('toString() returns formatted string', () {
      final timestamp = DateTime(2025, 1, 1, 12, 0, 0);
      final info = ApiCallInfo(
        endpoint: '/users',
        method: 'POST',
        timestamp: timestamp,
      );

      expect(info.toString(), contains('POST'));
      expect(info.toString(), contains('/users'));
    });
  });
}
