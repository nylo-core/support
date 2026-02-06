import 'package:dio/dio.dart';

/// API mocking utilities for testing.
///
/// This class allows you to mock API responses using type-based handlers
/// or URL pattern matching with wildcards.
///
/// Example:
/// ```dart
/// // Mock by API service type
/// NyMockApi.register<UserApiService>((request) async {
///   return Response(data: {'id': 1, 'name': 'Test User'});
/// });
///
/// // Mock by URL pattern
/// NyMockApi.respond('/users/*', {'id': 1, 'name': 'Test User'});
/// NyMockApi.respond('/posts/**', {'posts': []});
/// ```
class NyMockApi {
  static final Map<Type, MockApiHandler> _handlers = {};
  static final List<_UrlPattern> _urlPatterns = [];
  static final List<_ApiCallRecord> _callHistory = [];
  static bool _recordCalls = true;

  /// Register a mock handler for a specific API service type.
  ///
  /// Example:
  /// ```dart
  /// NyMockApi.register<UserApiService>((request) async {
  ///   if (request.endpoint == '/users/1') {
  ///     return {'id': 1, 'name': 'John'};
  ///   }
  ///   return {'error': 'Not found'};
  /// });
  /// ```
  static void register<T>(MockApiHandler handler) {
    _handlers[T] = handler;
  }

  /// Check if a type has a registered handler.
  static bool hasHandler<T>() => _handlers.containsKey(T);

  /// Get the handler for a specific type.
  static MockApiHandler? getHandler<T>() => _handlers[T];

  /// Get handler by type.
  static MockApiHandler? getHandlerByType(Type type) => _handlers[type];

  /// Register a URL pattern with a mock response.
  ///
  /// Patterns support:
  /// - `*` matches any single path segment
  /// - `**` matches any number of path segments
  ///
  /// Example:
  /// ```dart
  /// NyMockApi.respond('/users/*', {'id': 1}); // matches /users/1, /users/abc
  /// NyMockApi.respond('/api/**', {'data': []}); // matches /api/v1/users/1
  /// ```
  static void respond(
    String pattern,
    dynamic response, {
    int statusCode = 200,
    String method = 'GET',
    Map<String, dynamic>? headers,
    Duration? delay,
  }) {
    _urlPatterns.add(
      _UrlPattern(
        pattern: pattern,
        response: response,
        statusCode: statusCode,
        method: method.toUpperCase(),
        headers: headers,
        delay: delay,
      ),
    );
  }

  /// Match a URL against registered patterns.
  /// Matches against both the full URL and just the path portion.
  static MockResponse? matchUrl(String url, {String method = 'GET'}) {
    // Try matching against both the full URL and just the path
    final urlPath = Uri.parse(url).path;

    for (final pattern in _urlPatterns.reversed) {
      if (pattern.method != method.toUpperCase()) continue;
      // Match against full URL first, then path only
      if (_matchPattern(pattern.pattern, url) ||
          _matchPattern(pattern.pattern, urlPath)) {
        return MockResponse(
          data: pattern.response,
          statusCode: pattern.statusCode,
          headers: pattern.headers,
          delay: pattern.delay,
        );
      }
    }
    return null;
  }

  static bool _matchPattern(String pattern, String url) {
    // Normalize URLs
    pattern = pattern.trim();
    url = url.trim();

    // Extract path from pattern if it's a full URL
    if (pattern.startsWith('http://') || pattern.startsWith('https://')) {
      pattern = Uri.parse(pattern).path;
    }

    // Remove query parameters from URL for matching
    final urlPath = Uri.parse(url).path;

    // Handle exact match
    if (pattern == urlPath) return true;

    // Split into segments
    final patternParts = pattern.split('/').where((s) => s.isNotEmpty).toList();
    final urlParts = urlPath.split('/').where((s) => s.isNotEmpty).toList();

    int patternIndex = 0;
    int urlIndex = 0;

    while (patternIndex < patternParts.length && urlIndex < urlParts.length) {
      final patternPart = patternParts[patternIndex];

      if (patternPart == '**') {
        // ** matches zero or more segments
        if (patternIndex == patternParts.length - 1) {
          return true; // ** at end matches everything
        }
        // Look ahead to find next pattern part
        final nextPatternPart = patternParts[patternIndex + 1];
        while (urlIndex < urlParts.length) {
          if (urlParts[urlIndex] == nextPatternPart ||
              nextPatternPart == '*' ||
              nextPatternPart == '**') {
            break;
          }
          urlIndex++;
        }
        patternIndex++;
      } else if (patternPart == '*') {
        // * matches exactly one segment
        patternIndex++;
        urlIndex++;
      } else if (patternPart == urlParts[urlIndex]) {
        // Exact match
        patternIndex++;
        urlIndex++;
      } else {
        return false;
      }
    }

    // Handle trailing **
    while (patternIndex < patternParts.length &&
        patternParts[patternIndex] == '**') {
      patternIndex++;
    }

    return patternIndex == patternParts.length && urlIndex == urlParts.length;
  }

  /// Record an API call for later assertions.
  static void recordCall(
    String endpoint, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? headers,
  }) {
    if (!_recordCalls) return;
    _callHistory.add(
      _ApiCallRecord(
        endpoint: endpoint,
        method: method.toUpperCase(),
        data: data,
        headers: headers,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Get all recorded calls.
  static List<ApiCallInfo> getCalls() => _callHistory
      .map(
        (r) => ApiCallInfo(
          endpoint: r.endpoint,
          method: r.method,
          data: r.data,
          headers: r.headers,
          timestamp: r.timestamp,
        ),
      )
      .toList();

  /// Get calls for a specific endpoint.
  static List<ApiCallInfo> getCallsFor(String endpoint) {
    return getCalls().where((c) => c.endpoint.contains(endpoint)).toList();
  }

  /// Get calls for a specific API type.
  static List<ApiCallInfo> getCallsForType<T>() {
    // This would need to be integrated with actual API calls
    return getCalls();
  }

  /// Check if an endpoint was called.
  static bool wasCalled(String endpoint, {String? method, int? times}) {
    final calls = getCallsFor(endpoint).where((c) {
      if (method != null && c.method != method.toUpperCase()) return false;
      return true;
    }).toList();

    if (times != null) {
      return calls.length == times;
    }
    return calls.isNotEmpty;
  }

  /// Get the number of times an endpoint was called.
  static int callCount(String endpoint, {String? method}) {
    return getCallsFor(endpoint).where((c) {
      if (method != null && c.method != method.toUpperCase()) return false;
      return true;
    }).length;
  }

  /// Enable or disable call recording.
  static void setRecordCalls(bool record) {
    _recordCalls = record;
  }

  /// Clear all mocks and history.
  static void clear() {
    _handlers.clear();
    _urlPatterns.clear();
    _callHistory.clear();
  }

  /// Clear only URL patterns.
  static void clearPatterns() {
    _urlPatterns.clear();
  }

  /// Clear only type handlers.
  static void clearHandlers() {
    _handlers.clear();
  }

  /// Clear only call history.
  static void clearHistory() {
    _callHistory.clear();
  }

  /// Get count of registered patterns.
  static int get patternCount => _urlPatterns.length;

  /// Get count of registered handlers.
  static int get handlerCount => _handlers.length;

  /// Create a mock Dio response.
  static Response<T> createResponse<T>({
    required T data,
    int statusCode = 200,
    String statusMessage = 'OK',
    Map<String, List<String>>? headers,
    RequestOptions? requestOptions,
  }) {
    return Response<T>(
      data: data,
      statusCode: statusCode,
      statusMessage: statusMessage,
      headers: Headers.fromMap(headers ?? {}),
      requestOptions: requestOptions ?? RequestOptions(path: ''),
    );
  }
}

/// Handler function type for mock API responses.
typedef MockApiHandler = Future<dynamic> Function(MockApiRequest request);

/// Represents a mock API request.
class MockApiRequest {
  final String endpoint;
  final String method;
  final dynamic data;
  final Map<String, dynamic>? headers;
  final Map<String, dynamic>? queryParameters;

  MockApiRequest({
    required this.endpoint,
    this.method = 'GET',
    this.data,
    this.headers,
    this.queryParameters,
  });
}

/// Represents a mock API response.
class MockResponse {
  final dynamic data;
  final int statusCode;
  final Map<String, dynamic>? headers;
  final Duration? delay;

  MockResponse({
    required this.data,
    this.statusCode = 200,
    this.headers,
    this.delay,
  });
}

class _UrlPattern {
  final String pattern;
  final dynamic response;
  final int statusCode;
  final String method;
  final Map<String, dynamic>? headers;
  final Duration? delay;

  _UrlPattern({
    required this.pattern,
    required this.response,
    required this.statusCode,
    required this.method,
    this.headers,
    this.delay,
  });
}

class _ApiCallRecord {
  final String endpoint;
  final String method;
  final dynamic data;
  final Map<String, dynamic>? headers;
  final DateTime timestamp;

  _ApiCallRecord({
    required this.endpoint,
    required this.method,
    this.data,
    this.headers,
    required this.timestamp,
  });
}

/// Public info about an API call for assertions.
class ApiCallInfo {
  final String endpoint;
  final String method;
  final dynamic data;
  final Map<String, dynamic>? headers;
  final DateTime timestamp;

  ApiCallInfo({
    required this.endpoint,
    required this.method,
    this.data,
    this.headers,
    required this.timestamp,
  });

  @override
  String toString() =>
      'ApiCallInfo($method $endpoint at ${timestamp.toIso8601String()})';
}
