import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '/helpers/helper.dart';
import '/networking/models/default_response.dart';

/// Base API Service class
class DioApiService {
  /// Dio instance
  late Dio _api;

  /// Build context
  BuildContext? _context;

  /// Base options for the request
  BaseOptions? baseOptions;

  /// Base URL for the request
  final String baseUrl = "";

  /// Use interceptors
  bool get useInterceptors => interceptors.isNotEmpty;

  /// Use HTTP on response
  final bool useHttpOnResponse = true;

  /// Check if the request is [_retrying]
  bool _retrying = false;

  /// Interceptors for the request
  final Map<Type, Interceptor> interceptors = {};

  /// Decoders for morphing json into models
  final Map<Type, dynamic>? decoders = {};

  /// how many times should the request retry
  int retry = 0;

  /// how long should the request wait before retrying
  Duration retryDelay = Duration(seconds: 1);

  /// should the request retry if the [retryIf] callback returns true
  bool Function(DioException dioException)? retryIf;

  /// should the request retry if the [retryIf] callback returns true
  bool shouldSetAuthHeaders = true;

  DioApiService(BuildContext? context,
      {BaseOptions Function(BaseOptions baseOptions)? baseOptions}) {
    _context = context;
    if (baseOptions != null) {
      BaseOptions baseOptionsFinal = BaseOptions();
      this.baseOptions = baseOptions(baseOptionsFinal);
      if (this.baseOptions?.baseUrl == null ||
          this.baseOptions?.baseUrl == '') {
        this.baseOptions?.baseUrl = this.baseUrl;
      }
    } else {
      this.baseOptions = BaseOptions(
        baseUrl: baseUrl,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
        },
        connectTimeout: Duration(seconds: 5),
      );
    }
    init();
  }

  /// Set the build context (optional)
  setContext(BuildContext context) {
    _context = context;
  }

  /// Get the build context
  BuildContext? getContext() => _context;

  /// Set new [headers] to the baseOptions variable.
  setHeaders(Map<String, dynamic> headers) {
    _api.options.headers.addAll(headers);
  }

  /// Set a bearer token [headers] to the baseOptions variable.
  setBearerToken(String bearerToken) {
    _api.options.headers.addAll({"Authorization": "Bearer $bearerToken"});
  }

  /// Set a [baseUrl] for the request.
  setBaseUrl(String baseUrl) {
    _api.options.baseUrl = baseUrl;
  }

  /// Set how many times the request should [retry] if it fails.
  setRetry(int retry) {
    this.retry = retry;
  }

  /// Set the [Duration] how long the request should wait before retrying.
  setRetryDelay(Duration retryDelay) {
    this.retryDelay = retryDelay;
  }

  /// Set if the request should [shouldRetry] if the [retryIf] returns true.
  setRetryIf(bool Function(DioException dioException) retryIf) {
    this.retryIf = retryIf;
  }

  /// Set if the request should [shouldSetAuthHeaders] if the [shouldRefreshToken] returns true.
  setShouldSetAuthHeaders(bool shouldSetAuthHeaders) {
    this.shouldSetAuthHeaders = shouldSetAuthHeaders;
  }

  /// Set the [baseOptions] for the request.
  setOptions(BaseOptions baseOptions) {
    _api.options = baseOptions;
  }

  /// Set the [connectTimeout] for the request.
  setConnectTimeout(Duration duration) {
    _api.options.connectTimeout = duration;
  }

  /// Set the [receiveTimeout] for the request.
  setReceiveTimeout(Duration duration) {
    _api.options.receiveTimeout = duration;
  }

  /// Set the [method] for the request.
  setMethod(String method) {
    _api.options.method = method;
  }

  /// Set the [sendTimeout] for the request.
  setSendTimeout(Duration duration) {
    _api.options.sendTimeout = duration;
  }

  /// Set the [contentType] for the request.
  setContentType(String contentType) {
    _api.options.contentType = contentType;
  }

  /// Apply a pagination query to the HTTP request
  setPagination(int page,
      {String? paramPage, String? paramPerPage, String? perPage}) {
    Map<String, dynamic> query = {(paramPage ?? "page"): page};
    if (perPage != null) {
      query.addAll({(paramPerPage ?? "per_page"): perPage});
    }
    _api.options.queryParameters.addAll(query);
  }

  /// Initialize class
  void init() {
    _api = Dio(baseOptions);

    if (useInterceptors) {
      _addInterceptors();
    }
  }

  /// Networking class to handle API requests
  /// Use the [request] callback to call an API
  /// [handleSuccess] overrides the response on a successful status code
  /// [handleFailure] overrides the response on a failure
  ///
  /// Usage:
  /// Future<List<User>?> fetchUsers() async {
  ///     return await network<List<User>>(
  ///         request: (request) => request.get("/users"),
  ///     );
  ///   }
  Future<T?> network<T>(
      {required Function(Dio api) request,
      Function(Response response)? handleSuccess,
      Function(DioException error)? handleFailure,
      String? bearerToken,
      String? baseUrl,
      bool useUndefinedResponse = true,
      bool shouldRetry = true,
      bool? shouldSetAuthHeaders,
      int? retry,
      Duration? retryDelay,
      bool Function(DioException dioException)? retryIf,
      Duration? connectionTimeout,
      Duration? receiveTimeout,
      Duration? sendTimeout,
      Map<String, dynamic>? headers}) async {
    if (headers == null) {
      headers = {};
    }
    try {
      Map<String, dynamic> oldHeader = _api.options.headers;
      Map<String, dynamic> newValuesToAddToHeader = {};
      if (headers.isNotEmpty) {
        for (var header in headers.entries) {
          if (!oldHeader.containsKey(header.key)) {
            newValuesToAddToHeader.addAll({header.key: header.value});
          }
        }
      }
      if (await shouldRefreshToken()) {
        await refreshToken(Dio());
      }

      if (bearerToken != null) {
        newValuesToAddToHeader.addAll({"Authorization": "Bearer $bearerToken"});
      } else {
        if ((shouldSetAuthHeaders ?? this.shouldSetAuthHeaders) == true) {
          newValuesToAddToHeader.addAll(await setAuthHeaders(headers));
        }
      }
      _api.options.headers.addAll(newValuesToAddToHeader);
      String oldBaseUrl = _api.options.baseUrl;
      if (baseUrl != null) {
        _api.options.baseUrl = baseUrl;
      }
      if (connectionTimeout != null) {
        _api.options.connectTimeout = connectionTimeout;
      }
      if (receiveTimeout != null) {
        _api.options.receiveTimeout = receiveTimeout;
      }
      if (sendTimeout != null) {
        _api.options.sendTimeout = sendTimeout;
      }
      Response response = await request(_api);
      _api.options.headers = oldHeader; // reset headers
      _api.options.baseUrl = oldBaseUrl; //  reset base url
      _api.options.queryParameters = {}; // reset query parameters

      dynamic data = handleResponse<T>(response, handleSuccess: handleSuccess);
      if (data != T && useUndefinedResponse) {
        onUndefinedResponse(data, response, _context);
      }
      _context = null;
      return data;
    } on DioException catch (dioException) {
      int nyRetries = retry ?? this.retry;
      Duration nyRetryDelay = retryDelay ?? this.retryDelay;
      bool Function(DioException dioException)? retryIfFinal = this.retryIf;
      if (retryIf != null) {
        retryIfFinal = retryIf;
      }
      if (retryIfFinal != null) {
        shouldRetry = retryIfFinal(dioException);
      }
      if (_retrying == false && shouldRetry == true && nyRetries > 0) {
        _retrying = true;
        for (var i = 0; i < nyRetries; i++) {
          await Future.delayed(nyRetryDelay);
          NyLogger.debug("[${i + 1}] Retrying request...");
          dynamic response = await network(
            request: request,
            handleSuccess: handleSuccess,
            handleFailure: handleFailure,
            bearerToken: bearerToken,
            baseUrl: baseUrl,
            useUndefinedResponse: useUndefinedResponse,
            headers: headers,
            shouldRetry: false,
          );
          if (response != null) {
            _retrying = false;
            return response;
          }
        }
        _retrying = false;
      }

      NyLogger.error(dioException.toString());
      onError(dioException);
      if (_context != null) {
        displayError(dioException, _context!);
      }

      if (handleFailure != null) {
        return handleFailure(dioException);
      }

      return null;
    } on Exception catch (e) {
      NyLogger.error(e.toString());
      return null;
    }
  }

  /// Handle the [DioException] response if there is an issue.
  onError(DioException dioException) {}

  /// Display a error to the user
  /// This method is only called if you provide the API service
  /// with a [BuildContext].
  displayError(DioException dioException, BuildContext context) {}

  /// Handle the undefined response's for HTTP requests.
  /// The [data] parameter contains what was returned from your decoder.
  onUndefinedResponse(dynamic data, Response response, BuildContext? context) {}

  /// Handles an API network response from [Dio].
  /// [handleSuccess] overrides the return value
  /// [handleFailure] is called then the response status is not 200.
  /// You can return a different value using this callback.
  handleResponse<T>(Response response,
      {Function(Response response)? handleSuccess}) {
    bool wasSuccessful = response.statusCode == 200;

    if (wasSuccessful == true && handleSuccess != null) {
      return handleSuccess(response);
    }

    if (T.toString() != 'dynamic') {
      return _morphJsonResponse<T>(response.data);
    } else {
      return response.data;
    }
  }

  /// Morphs json into Object using 'config/decoders.dart'.
  _morphJsonResponse<T>(dynamic json) {
    DefaultResponse defaultResponse =
        DefaultResponse<T>.fromJson(json, decoders ?? {}, type: T);
    return defaultResponse.data;
  }

  /// Adds all the [interceptors] to [dio].
  _addInterceptors() => _api.interceptors.addAll(interceptors.values);

  /// Perform a [Dio] request to update the users auth token.
  /// This method is called when [shouldRefreshToken] returns true.
  /// You can override this method to perform your own request.
  /// The [dio] parameter is a new instance of [Dio].
  /// You can use this to perform a request without affecting the
  /// original [Dio] instance.
  refreshToken(Dio dio) async {}

  /// Check if the users auth token should be refreshed.
  /// This method is called before every request.
  /// You can override this method to perform your own checks.
  Future<bool> shouldRefreshToken() async {
    return false;
  }

  /// Set the auth headers for the request.
  /// The [headers] parameter contains the current headers.
  ///
  /// Usage:
  /// headers.addBearerToken('123') // add a bearer token
  /// headers.addHeader('key', 'value') // add a header
  /// headers.getBearerToken() // get the bearer token
  /// headers.hasHeader('key') // check if a header exists
  Future<RequestHeaders> setAuthHeaders(
    RequestHeaders headers,
  ) async {
    return headers;
  }
}

/// Typedef for [RequestHeaders]
typedef RequestHeaders = Map<String, dynamic>;

extension NyRequestHeaders on RequestHeaders {
  /// Add a bearer token to the request headers.
  Map<String, dynamic> addBearerToken(String token) {
    this['Authorization'] = "Bearer $token";
    return this;
  }

  /// Get the bearer token from the request headers.
  String? getBearerToken() {
    if (this.containsKey("Authorization")) {
      String? auth = this["Authorization"];
      if (auth != null) {
        return auth.replaceFirst("Bearer ", "");
      }
    }
    return null;
  }

  /// Add a new header value to the request headers.
  Map<String, dynamic> addHeader(String key, dynamic value) {
    this[key] = value;
    return this;
  }

  /// Add a new header value to the request headers.
  bool hasHeader(String key) {
    return this.containsKey(key);
  }
}
