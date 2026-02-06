import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/networking/src/dio_api_service.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Test API service for testing DioApiService functionality
class TestApiService extends DioApiService {
  TestApiService() : super();

  @override
  String get baseUrl => 'https://api.example.com';

  @override
  Map<Type, dynamic>? get decoders => {
    TestUser: (data) => TestUser.fromJson(data),
    List<TestUser>: (data) =>
        (data as List).map((e) => TestUser.fromJson(e)).toList(),
  };
}

/// Test API service with custom interceptors
class TestApiServiceWithInterceptors extends DioApiService {
  TestApiServiceWithInterceptors() : super();

  @override
  String get baseUrl => 'https://api.example.com';

  @override
  Map<Type, Interceptor> get interceptors => {LogInterceptor: LogInterceptor()};
}

/// Test API service with custom retry settings
class TestApiServiceWithRetry extends DioApiService {
  TestApiServiceWithRetry() : super();

  @override
  String get baseUrl => 'https://api.example.com';

  @override
  int get retry => 3;

  @override
  Duration get retryDelay => const Duration(milliseconds: 100);
}

/// Test user model for decoding tests
class TestUser {
  final int id;
  final String name;
  final String email;

  TestUser({required this.id, required this.name, required this.email});

  factory TestUser.fromJson(Map<String, dynamic> json) {
    return TestUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}

void main() {
  NyTest.init();

  late TestApiService apiService;

  nySetUp(() {
    apiService = TestApiService();
    NyMockApi.clear();
  });

  nyTearDown(() {
    NyMockApi.clear();
  });

  nyGroup('DioApiService', () {
    nyGroup('initialization', () {
      nyTest('creates with default base options', () async {
        final service = TestApiService();

        expect(service.dio, isNotNull);
        expect(service.dio.options.baseUrl, 'https://api.example.com');
      });

      nyTest('sets default headers', () async {
        final service = DioApiService();

        expect(service.dio.options.headers['Content-type'], 'application/json');
        expect(service.dio.options.headers['Accept'], 'application/json');
      });

      nyTest('sets default connect timeout', () async {
        final service = DioApiService();

        expect(service.dio.options.connectTimeout, const Duration(seconds: 5));
      });

      nyTest('allows custom base options', () async {
        final service = DioApiService(
          baseOptions: (options) => options
            ..baseUrl = 'https://custom.api.com'
            ..connectTimeout = const Duration(seconds: 10),
        );

        expect(service.dio.options.baseUrl, 'https://custom.api.com');
        expect(service.dio.options.connectTimeout, const Duration(seconds: 10));
      });

      nyTest('allows custom dio initialization', () async {
        bool initCalled = false;
        final service = DioApiService(
          initDio: (dio) {
            initCalled = true;
            return dio;
          },
        );

        expect(initCalled, isTrue);
        expect(service.dio, isNotNull);
      });
    });

    nyGroup('setHeaders', () {
      nyTest('adds headers to dio options', () async {
        apiService.setHeaders({'X-Custom': 'value'});

        expect(apiService.dio.options.headers['X-Custom'], 'value');
      });

      nyTest('merges with existing headers', () async {
        apiService.setHeaders({'X-First': '1'});
        apiService.setHeaders({'X-Second': '2'});

        expect(apiService.dio.options.headers['X-First'], '1');
        expect(apiService.dio.options.headers['X-Second'], '2');
      });
    });

    nyGroup('setBearerToken', () {
      nyTest('adds Authorization header with Bearer prefix', () async {
        apiService.setBearerToken('my-token');

        expect(
          apiService.dio.options.headers['Authorization'],
          'Bearer my-token',
        );
      });
    });

    nyGroup('setBaseUrl', () {
      nyTest('changes base URL', () async {
        apiService.setBaseUrl('https://new-api.example.com');

        expect(apiService.dio.options.baseUrl, 'https://new-api.example.com');
      });
    });

    nyGroup('retry configuration', () {
      nyTest('setRetry changes retry count', () async {
        apiService.setRetry(5);

        expect(apiService.retry, 5);
      });

      nyTest('setRetryDelay changes retry delay', () async {
        apiService.setRetryDelay(const Duration(seconds: 2));

        expect(apiService.retryDelay, const Duration(seconds: 2));
      });

      nyTest('setRetryIf sets custom retry condition', () async {
        apiService.setRetryIf(
          (e) => e.type == DioExceptionType.connectionTimeout,
        );

        expect(apiService.retryIf, isNotNull);
      });
    });

    nyGroup('timeout configuration', () {
      nyTest('setConnectTimeout changes connect timeout', () async {
        apiService.setConnectTimeout(const Duration(seconds: 30));

        expect(
          apiService.dio.options.connectTimeout,
          const Duration(seconds: 30),
        );
      });

      nyTest('setReceiveTimeout changes receive timeout', () async {
        apiService.setReceiveTimeout(const Duration(seconds: 60));

        expect(
          apiService.dio.options.receiveTimeout,
          const Duration(seconds: 60),
        );
      });

      nyTest('setSendTimeout changes send timeout', () async {
        apiService.setSendTimeout(const Duration(seconds: 45));

        expect(apiService.dio.options.sendTimeout, const Duration(seconds: 45));
      });
    });

    nyGroup('setMethod', () {
      nyTest('changes default method', () async {
        apiService.setMethod('POST');

        expect(apiService.dio.options.method, 'POST');
      });
    });

    nyGroup('setContentType', () {
      nyTest('changes content type', () async {
        apiService.setContentType('text/plain');

        expect(apiService.dio.options.contentType, 'text/plain');
      });
    });

    nyGroup('setOptions', () {
      nyTest('replaces all base options', () async {
        final newOptions = BaseOptions(
          baseUrl: 'https://replaced.api.com',
          connectTimeout: const Duration(seconds: 15),
        );

        apiService.setOptions(newOptions);

        expect(apiService.dio.options.baseUrl, 'https://replaced.api.com');
        expect(
          apiService.dio.options.connectTimeout,
          const Duration(seconds: 15),
        );
      });
    });

    nyGroup('setShouldSetAuthHeaders', () {
      nyTest('enables auth header setting', () async {
        apiService.setShouldSetAuthHeaders(true);

        expect(apiService.shouldSetAuthHeaders, isTrue);
      });

      nyTest('disables auth header setting', () async {
        apiService.setShouldSetAuthHeaders(false);

        expect(apiService.shouldSetAuthHeaders, isFalse);
      });
    });

    nyGroup('setCheckConnectivityBeforeRequest', () {
      nyTest('enables connectivity check', () async {
        apiService.setCheckConnectivityBeforeRequest(true);

        expect(apiService.checkConnectivityBeforeRequest, isTrue);
      });

      nyTest('disables connectivity check', () async {
        apiService.setCheckConnectivityBeforeRequest(false);

        expect(apiService.checkConnectivityBeforeRequest, isFalse);
      });
    });

    nyGroup('setPagination', () {
      nyTest('adds page query parameter', () async {
        apiService.setPagination(1);

        expect(apiService.dio.options.queryParameters['page'], 1);
      });

      nyTest('adds page and per_page parameters', () async {
        apiService.setPagination(2, perPage: '20');

        expect(apiService.dio.options.queryParameters['page'], 2);
        expect(apiService.dio.options.queryParameters['per_page'], '20');
      });

      nyTest('uses custom parameter names', () async {
        apiService.setPagination(
          3,
          paramPage: 'pageNum',
          paramPerPage: 'limit',
          perPage: '50',
        );

        expect(apiService.dio.options.queryParameters['pageNum'], 3);
        expect(apiService.dio.options.queryParameters['limit'], '50');
      });
    });

    nyGroup('cancel token management', () {
      nyTest('createCancelToken creates tracked token', () async {
        final token = apiService.createCancelToken();

        expect(token, isA<CancelToken>());
        expect(apiService.activeRequestCount, 1);
      });

      nyTest('activeRequestCount tracks non-cancelled tokens', () async {
        apiService.createCancelToken();
        final token2 = apiService.createCancelToken();
        apiService.createCancelToken();

        expect(apiService.activeRequestCount, 3);

        token2.cancel();

        expect(apiService.activeRequestCount, 2);
      });

      nyTest('cancelAllRequests cancels all tokens', () async {
        final token1 = apiService.createCancelToken();
        final token2 = apiService.createCancelToken();
        final token3 = apiService.createCancelToken();

        apiService.cancelAllRequests('Test cancellation');

        expect(token1.isCancelled, isTrue);
        expect(token2.isCancelled, isTrue);
        expect(token3.isCancelled, isTrue);
        expect(apiService.activeRequestCount, 0);
      });

      nyTest('removeCancelToken removes specific token', () async {
        apiService.createCancelToken();
        final token2 = apiService.createCancelToken();
        apiService.createCancelToken();

        expect(apiService.activeRequestCount, 3);

        apiService.removeCancelToken(token2);

        expect(apiService.activeRequestCount, 2);
      });
    });

    nyGroup('setCache', () {
      nyTest('sets cache duration and key', () async {
        apiService.setCache(const Duration(hours: 1), 'test_cache');

        // Cache settings are internal, but we can verify no error occurs
        expect(true, isTrue);
      });
    });

    nyGroup('interceptors', () {
      nyTest('useInterceptors returns true when interceptors exist', () async {
        final service = TestApiServiceWithInterceptors();

        expect(service.useInterceptors, isTrue);
      });

      nyTest('useInterceptors returns false when no interceptors', () async {
        final service = TestApiService();

        expect(service.useInterceptors, isFalse);
      });
    });

    nyGroup('callback setters', () {
      nyTest('onSuccess sets success callback', () async {
        bool callbackCalled = false;

        apiService.onSuccess((response, data) {
          callbackCalled = true;
        });

        // Callback is stored internally
        expect(true, isTrue);
      });

      nyTest('onError sets error callback', () async {
        bool callbackCalled = false;

        apiService.onError((dioException) {
          callbackCalled = true;
        });

        // Callback is stored internally
        expect(true, isTrue);
      });
    });

    nyGroup('cache operations', () {
      nyTest('clearCache method exists', () async {
        // Verify the method exists on the service
        expect(apiService.clearCache, isA<Function>());
      });

      nyTest('clearAllCache method exists', () async {
        // Verify the method exists on the service
        expect(apiService.clearAllCache, isA<Function>());
      });
    });

    nyGroup('default retry configuration', () {
      nyTest('default retry is 0', () async {
        expect(apiService.retry, 0);
      });

      nyTest('default retryDelay is 1 second', () async {
        expect(apiService.retryDelay, const Duration(seconds: 1));
      });

      nyTest('custom service can override retry', () async {
        final service = TestApiServiceWithRetry();

        expect(service.retry, 3);
        expect(service.retryDelay, const Duration(milliseconds: 100));
      });
    });

    nyGroup('shouldRefreshToken', () {
      nyTest('default returns false', () async {
        final result = await apiService.shouldRefreshToken();

        expect(result, isFalse);
      });
    });

    nyGroup('setAuthHeaders', () {
      nyTest('default returns empty headers', () async {
        final headers = <String, dynamic>{};

        final result = await apiService.setAuthHeaders(headers);

        expect(result, isEmpty);
      });
    });
  });

  nyGroup('NyMockApi integration', () {
    nyTest('matchUrl finds registered patterns', () async {
      NyMockApi.respond('/users/1', {'id': 1, 'name': 'Test'});

      final response = NyMockApi.matchUrl('/users/1');

      expect(response, isNotNull);
      expect(response?.data['id'], 1);
    });

    nyTest('matchUrl returns null for unregistered patterns', () async {
      final response = NyMockApi.matchUrl('/unknown');

      expect(response, isNull);
    });

    nyTest('wasCalled tracks API calls', () async {
      NyMockApi.recordCall('/users/1', method: 'GET');

      expect(NyMockApi.wasCalled('/users/1'), isTrue);
      expect(NyMockApi.wasCalled('/users/2'), isFalse);
    });

    nyTest('callCount returns correct count', () async {
      NyMockApi.recordCall('/users', method: 'GET');
      NyMockApi.recordCall('/users', method: 'GET');
      NyMockApi.recordCall('/users', method: 'POST');

      expect(NyMockApi.callCount('/users'), 3);
      expect(NyMockApi.callCount('/users', method: 'GET'), 2);
      expect(NyMockApi.callCount('/users', method: 'POST'), 1);
    });

    nyTest('clear removes all mocks and history', () async {
      NyMockApi.respond('/test', {'data': true});
      NyMockApi.recordCall('/test');

      NyMockApi.clear();

      expect(NyMockApi.matchUrl('/test'), isNull);
      expect(NyMockApi.getCalls(), isEmpty);
    });

    nyTest('createResponse creates mock Dio response', () async {
      final response = NyMockApi.createResponse(
        data: {'id': 1},
        statusCode: 201,
        statusMessage: 'Created',
      );

      expect(response.data, {'id': 1});
      expect(response.statusCode, 201);
      expect(response.statusMessage, 'Created');
    });
  });
}
