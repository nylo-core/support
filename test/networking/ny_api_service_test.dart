import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/networking/src/ny_api_service.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Test API service extending NyApiService
class TestNyApiService extends NyApiService {
  TestNyApiService()
    : super(
        decoders: {
          TestModel: (data) => TestModel.fromJson(data),
          List<TestModel>: (data) =>
              (data as List).map((e) => TestModel.fromJson(e)).toList(),
        },
      );

  @override
  String get baseUrl => 'https://api.example.com';

  // Disable debug logging for tests
  @override
  Map<Type, Interceptor> get interceptors => {};
}

/// Test model for decoding
class TestModel {
  final int id;
  final String name;

  TestModel({required this.id, required this.name});

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(id: json['id'] as int, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

void main() {
  NyTest.init();

  late TestNyApiService apiService;

  nySetUp(() {
    apiService = TestNyApiService();
    NyMockApi.clear();
  });

  nyTearDown(() {
    NyMockApi.clear();
  });

  nyGroup('NyApiService', () {
    nyGroup('initialization', () {
      nyTest('creates with decoders', () async {
        expect(apiService.decoders, isNotNull);
        expect(apiService.decoders!.containsKey(TestModel), isTrue);
      });

      nyTest('inherits from DioApiService', () async {
        expect(apiService.dio, isNotNull);
        expect(apiService.dio.options.baseUrl, 'https://api.example.com');
      });
    });

    nyGroup('HTTP method helpers structure', () {
      nyTest('get method exists and is callable', () async {
        // Just verify the method exists
        expect(apiService.get, isA<Function>());
      });

      nyTest('post method exists and is callable', () async {
        expect(apiService.post, isA<Function>());
      });

      nyTest('put method exists and is callable', () async {
        expect(apiService.put, isA<Function>());
      });

      nyTest('delete method exists and is callable', () async {
        expect(apiService.delete, isA<Function>());
      });

      nyTest('patch method exists and is callable', () async {
        expect(apiService.patch, isA<Function>());
      });

      nyTest('head method exists and is callable', () async {
        expect(apiService.head, isA<Function>());
      });

      nyTest('upload method exists and is callable', () async {
        expect(apiService.upload, isA<Function>());
      });

      nyTest('uploadMultiple method exists and is callable', () async {
        expect(apiService.uploadMultiple, isA<Function>());
      });

      nyTest('download method exists and is callable', () async {
        expect(apiService.download, isA<Function>());
      });
    });
  });

  nyGroup('MockResponse', () {
    nyTest('creates with required data', () async {
      final response = MockResponse(data: {'key': 'value'});

      expect(response.data, {'key': 'value'});
      expect(response.statusCode, 200);
    });

    nyTest('creates with custom status code', () async {
      final response = MockResponse(
        data: {'error': 'Not found'},
        statusCode: 404,
      );

      expect(response.statusCode, 404);
    });

    nyTest('creates with headers', () async {
      final response = MockResponse(data: {}, headers: {'X-Custom': 'value'});

      expect(response.headers?['X-Custom'], 'value');
    });

    nyTest('creates with delay', () async {
      final response = MockResponse(
        data: {},
        delay: const Duration(milliseconds: 100),
      );

      expect(response.delay, const Duration(milliseconds: 100));
    });
  });

  nyGroup('MockApiRequest', () {
    nyTest('creates with endpoint', () async {
      final request = MockApiRequest(endpoint: '/users');

      expect(request.endpoint, '/users');
      expect(request.method, 'GET');
    });

    nyTest('creates with all parameters', () async {
      final request = MockApiRequest(
        endpoint: '/users',
        method: 'POST',
        data: {'name': 'John'},
        headers: {'Authorization': 'Bearer token'},
        queryParameters: {'page': '1'},
      );

      expect(request.endpoint, '/users');
      expect(request.method, 'POST');
      expect(request.data['name'], 'John');
      expect(request.headers?['Authorization'], 'Bearer token');
      expect(request.queryParameters?['page'], '1');
    });
  });

  nyGroup('ApiCallInfo', () {
    nyTest('creates with required fields', () async {
      final info = ApiCallInfo(
        endpoint: '/users/1',
        method: 'GET',
        timestamp: DateTime.now(),
      );

      expect(info.endpoint, '/users/1');
      expect(info.method, 'GET');
      expect(info.timestamp, isNotNull);
    });

    nyTest('toString returns formatted string', () async {
      final timestamp = DateTime(2024, 1, 15, 10, 30);
      final info = ApiCallInfo(
        endpoint: '/users',
        method: 'POST',
        timestamp: timestamp,
      );

      final str = info.toString();

      expect(str, contains('POST'));
      expect(str, contains('/users'));
    });
  });

  nyGroup('NyMockApi URL pattern matching', () {
    nyTest('matches exact URL', () async {
      NyMockApi.respond('/users', {'users': []});

      final response = NyMockApi.matchUrl('/users');

      expect(response, isNotNull);
      expect(response?.data['users'], []);
    });

    nyTest('matches wildcard single segment', () async {
      NyMockApi.respond('/users/*', {'id': 1});

      expect(NyMockApi.matchUrl('/users/1'), isNotNull);
      expect(NyMockApi.matchUrl('/users/abc'), isNotNull);
      expect(NyMockApi.matchUrl('/users/123/posts'), isNull);
    });

    nyTest('matches double wildcard multiple segments', () async {
      NyMockApi.respond('/api/**', {'data': 'any'});

      expect(NyMockApi.matchUrl('/api/v1'), isNotNull);
      expect(NyMockApi.matchUrl('/api/v1/users'), isNotNull);
      expect(NyMockApi.matchUrl('/api/v1/users/1/posts'), isNotNull);
    });

    nyTest('matches by HTTP method', () async {
      NyMockApi.respond('/users', {'method': 'GET'}, method: 'GET');
      NyMockApi.respond('/users', {'method': 'POST'}, method: 'POST');

      final getResponse = NyMockApi.matchUrl('/users', method: 'GET');
      final postResponse = NyMockApi.matchUrl('/users', method: 'POST');
      final deleteResponse = NyMockApi.matchUrl('/users', method: 'DELETE');

      expect(getResponse?.data['method'], 'GET');
      expect(postResponse?.data['method'], 'POST');
      expect(deleteResponse, isNull);
    });

    nyTest('later patterns override earlier ones', () async {
      NyMockApi.respond('/users', {'version': 1});
      NyMockApi.respond('/users', {'version': 2});

      final response = NyMockApi.matchUrl('/users');

      expect(response?.data['version'], 2);
    });

    nyTest('clearPatterns removes URL patterns only', () async {
      NyMockApi.respond('/test', {});
      NyMockApi.recordCall('/test');

      NyMockApi.clearPatterns();

      expect(NyMockApi.matchUrl('/test'), isNull);
      expect(NyMockApi.getCalls(), isNotEmpty);
    });

    nyTest('clearHistory removes call history only', () async {
      NyMockApi.respond('/test', {});
      NyMockApi.recordCall('/test');

      NyMockApi.clearHistory();

      expect(NyMockApi.matchUrl('/test'), isNotNull);
      expect(NyMockApi.getCalls(), isEmpty);
    });
  });

  nyGroup('NyMockApi call tracking', () {
    nyTest('recordCall stores call information', () async {
      NyMockApi.recordCall('/users', method: 'POST', data: {'name': 'John'});

      final calls = NyMockApi.getCalls();

      expect(calls.length, 1);
      expect(calls.first.endpoint, '/users');
      expect(calls.first.method, 'POST');
      expect(calls.first.data?['name'], 'John');
    });

    nyTest('getCallsFor filters by endpoint', () async {
      NyMockApi.recordCall('/users', method: 'GET');
      NyMockApi.recordCall('/posts', method: 'GET');
      NyMockApi.recordCall('/users/1', method: 'GET');

      final userCalls = NyMockApi.getCallsFor('/users');

      expect(userCalls.length, 2);
    });

    nyTest('wasCalled with times parameter', () async {
      NyMockApi.recordCall('/users', method: 'GET');
      NyMockApi.recordCall('/users', method: 'GET');

      expect(NyMockApi.wasCalled('/users', times: 2), isTrue);
      expect(NyMockApi.wasCalled('/users', times: 1), isFalse);
      expect(NyMockApi.wasCalled('/users', times: 3), isFalse);
    });

    nyTest('setRecordCalls controls recording', () async {
      NyMockApi.setRecordCalls(false);
      NyMockApi.recordCall('/test');

      expect(NyMockApi.getCalls(), isEmpty);

      NyMockApi.setRecordCalls(true);
      NyMockApi.recordCall('/test');

      expect(NyMockApi.getCalls(), isNotEmpty);
    });
  });

  nyGroup('NyMockApi handler registration', () {
    nyTest('register adds type handler', () async {
      NyMockApi.register<TestNyApiService>((request) async {
        return {'mocked': true};
      });

      expect(NyMockApi.hasHandler<TestNyApiService>(), isTrue);
    });

    nyTest('getHandler returns registered handler', () async {
      NyMockApi.register<TestNyApiService>((request) async {
        return {'mocked': true};
      });

      final handler = NyMockApi.getHandler<TestNyApiService>();

      expect(handler, isNotNull);
    });

    nyTest('clearHandlers removes type handlers only', () async {
      NyMockApi.register<TestNyApiService>((request) async => {});
      NyMockApi.respond('/test', {});

      NyMockApi.clearHandlers();

      expect(NyMockApi.hasHandler<TestNyApiService>(), isFalse);
      expect(NyMockApi.matchUrl('/test'), isNotNull);
    });

    nyTest('patternCount returns correct count', () async {
      NyMockApi.clear();
      NyMockApi.respond('/a', {});
      NyMockApi.respond('/b', {});
      NyMockApi.respond('/c', {});

      expect(NyMockApi.patternCount, 3);
    });

    nyTest('handlerCount returns correct count', () async {
      NyMockApi.clear();
      NyMockApi.register<TestNyApiService>((r) async => {});
      NyMockApi.register<TestModel>((r) async => {});

      expect(NyMockApi.handlerCount, 2);
    });
  });
}
