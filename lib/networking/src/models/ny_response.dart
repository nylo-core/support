import 'package:dio/dio.dart';

/// Enhanced API Response class that provides access to the full Dio Response
/// along with morphed data and useful response utilities
class NyResponse<T> {
  /// The original Dio Response object
  final Response? response;

  /// The morphed/decoded data of type T
  final T? data;

  /// The raw response data
  final dynamic rawData;

  /// Response headers
  Headers? get headers => response?.headers;

  /// HTTP status code
  int? get statusCode => response?.statusCode;

  /// HTTP status message
  String? get statusMessage => response?.statusMessage;

  /// Request options used for this request
  RequestOptions? get requestOptions => response?.requestOptions;

  /// Response redirect information
  List<RedirectRecord>? get redirects => response?.redirects;

  /// Additional response information
  Map<String, dynamic>? get extra => response?.extra;

  /// Check if the response was successful (status code 200-299)
  bool get isSuccessful {
    if (statusCode == null) return false;
    return statusCode! >= 200 && statusCode! < 300;
  }

  /// Check if the response is a client error (status code 400-499)
  bool get isClientError {
    if (statusCode == null) return false;
    return statusCode! >= 400 && statusCode! < 500;
  }

  /// Check if the response is a server error (status code 500-599)
  bool get isServerError {
    if (statusCode == null) return false;
    return statusCode! >= 500 && statusCode! < 600;
  }

  /// Check if the response is a redirect (status code 300-399)
  bool get isRedirect {
    if (statusCode == null) return false;
    return statusCode! >= 300 && statusCode! < 400;
  }

  /// Check if the response has data
  bool get hasData => data != null;

  /// Check if the response is unauthorized (401)
  bool get isUnauthorized => statusCode == 401;

  /// Check if the response is forbidden (403)
  bool get isForbidden => statusCode == 403;

  /// Check if the resource was not found (404)
  bool get isNotFound => statusCode == 404;

  /// Check if the request timed out (408)
  bool get isTimeout => statusCode == 408;

  /// Check if there was a conflict (409)
  bool get isConflict => statusCode == 409;

  /// Check if the request was rate limited (429)
  bool get isRateLimited => statusCode == 429;

  /// Get content type from headers
  String? get contentType => headers?.value('content-type');

  /// Get content length from headers
  String? get contentLength => headers?.value('content-length');

  /// Constructor
  NyResponse({
    required this.response,
    required this.data,
    required this.rawData,
  });

  /// Factory constructor to create from Dio Response and morphed data
  factory NyResponse.fromResponse({
    required Response response,
    required T? morphedData,
  }) {
    return NyResponse<T>(
      response: response,
      data: morphedData,
      rawData: response.data,
    );
  }

  /// Get a header value by name
  String? getHeader(String name) {
    return headers?.value(name);
  }

  /// Get all header values for a given name
  List<String>? getHeaderValues(String name) {
    return headers?[name];
  }

  /// Convert response to a Map representation
  Map<String, dynamic> toMap() {
    return {
      'statusCode': statusCode,
      'statusMessage': statusMessage,
      'headers': headers?.map,
      'data': data,
      'rawData': rawData,
      'isSuccessful': isSuccessful,
      'contentType': contentType,
      'contentLength': contentLength,
      'requestUri': requestOptions?.uri.toString(),
      'requestMethod': requestOptions?.method,
    };
  }

  /// Get the data or throw an exception if data is null.
  ///
  /// Useful when you're confident the data should exist.
  ///
  /// Example:
  /// ```dart
  /// final user = response.dataOrThrow();
  /// ```
  T dataOrThrow([String? message]) {
    if (data == null) {
      throw Exception(message ?? 'Response data is null (status: $statusCode)');
    }
    return data!;
  }

  /// Get the data or return a fallback value if data is null.
  ///
  /// Example:
  /// ```dart
  /// final users = response.dataOr([]);
  /// ```
  T dataOr(T fallback) => data ?? fallback;

  /// Execute a callback if the response is successful, otherwise return null.
  ///
  /// Example:
  /// ```dart
  /// final result = response.ifSuccessful((data) => processData(data));
  /// ```
  R? ifSuccessful<R>(R Function(T data) callback) {
    final d = data;
    if (isSuccessful && d != null) {
      return callback(d);
    }
    return null;
  }

  /// Execute different callbacks based on success/failure.
  ///
  /// Example:
  /// ```dart
  /// final result = response.when(
  ///   success: (data) => 'Got ${data.length} items',
  ///   failure: (response) => 'Error: ${response.statusMessage}',
  /// );
  /// ```
  R when<R>({
    required R Function(T data) success,
    required R Function(NyResponse<T> response) failure,
  }) {
    final d = data;
    if (isSuccessful && d != null) {
      return success(d);
    }
    return failure(this);
  }

  /// Get an error message from the response.
  ///
  /// Attempts to extract an error message from common response formats.
  String? get errorMessage {
    if (rawData is Map) {
      final map = rawData as Map;
      // Try common error message keys
      return map['message']?.toString() ??
          map['error']?.toString() ??
          map['error_message']?.toString() ??
          map['errors']?.toString();
    }
    return statusMessage;
  }

  @override
  String toString() {
    return 'NyResponse<$T>('
        'statusCode: $statusCode, '
        'statusMessage: $statusMessage, '
        'hasData: $hasData, '
        'isSuccessful: $isSuccessful'
        ')';
  }
}
