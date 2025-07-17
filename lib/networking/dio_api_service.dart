import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '/helpers/helper.dart';
import '/helpers/ny_cache.dart' as ny_cache;
import '/helpers/ny_logger.dart';
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
  Map<Type, Interceptor> get interceptors => {};

  /// Decoders for morphing json into models
  final Map<Type, dynamic>? decoders = {};

  /// how many times should the request retry
  int retry = 0;

  /// how long should the request wait before retrying
  Duration retryDelay = const Duration(seconds: 1);

  /// should the request retry if the [retryIf] callback returns true
  bool Function(DioException dioException)? retryIf;

  /// should the request retry if the [retryIf] callback returns true
  bool shouldSetAuthHeaders = true;

  /// Callback for when the request is successful
  Function(Response response, dynamic data)? _onSuccessEvent;

  /// Callback for when the request fails
  Function(DioException dioException)? _onErrorEvent;

  /// Set the [onSuccess] callback for the request
  void onSuccess(Function(Response response, dynamic data) onSuccess) {
    _onSuccessEvent = onSuccess;
  }

  /// Set the [onError] callback for the request
  void onError(Function(DioException dioException) onError) {
    _onErrorEvent = onError;
  }

  DioApiService(BuildContext? context,
      {BaseOptions Function(BaseOptions baseOptions)? baseOptions,
      Dio Function(Dio api)? initDio}) {
    _initDio = initDio;
    _context = context;
    if (baseOptions != null) {
      BaseOptions baseOptionsFinal = BaseOptions();
      this.baseOptions = baseOptions(baseOptionsFinal);
      if (this.baseOptions?.baseUrl == null ||
          this.baseOptions?.baseUrl == '') {
        this.baseOptions?.baseUrl = baseUrl;
      }
    } else {
      this.baseOptions = BaseOptions(
        baseUrl: baseUrl,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
        },
        connectTimeout: const Duration(seconds: 5),
      );
    }
    init();
  }

  /// Set the build context (optional)
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Get the build context
  BuildContext? getContext() => _context;

  /// Set new [headers] to the baseOptions variable.
  void setHeaders(Map<String, dynamic> headers) {
    _api.options.headers.addAll(headers);
  }

  /// Set a bearer token [headers] to the baseOptions variable.
  void setBearerToken(String bearerToken) {
    _api.options.headers.addAll({"Authorization": "Bearer $bearerToken"});
  }

  /// Set a [baseUrl] for the request.
  void setBaseUrl(String baseUrl) {
    _api.options.baseUrl = baseUrl;
  }

  /// Set how many times the request should [retry] if it fails.
  void setRetry(int retry) {
    this.retry = retry;
  }

  /// Set the [Duration] how long the request should wait before retrying.
  void setRetryDelay(Duration retryDelay) {
    this.retryDelay = retryDelay;
  }

  /// Set if the request should [shouldRetry] if the [retryIf] returns true.
  void setRetryIf(bool Function(DioException dioException) retryIf) {
    this.retryIf = retryIf;
  }

  /// Set if the request should [shouldSetAuthHeaders] if the [shouldRefreshToken] returns true.
  void setShouldSetAuthHeaders(bool shouldSetAuthHeaders) {
    this.shouldSetAuthHeaders = shouldSetAuthHeaders;
  }

  /// Set the [baseOptions] for the request.
  void setOptions(BaseOptions baseOptions) {
    _api.options = baseOptions;
  }

  /// Set the [connectTimeout] for the request.
  void setConnectTimeout(Duration duration) {
    _api.options.connectTimeout = duration;
  }

  /// Set the [receiveTimeout] for the request.
  void setReceiveTimeout(Duration duration) {
    _api.options.receiveTimeout = duration;
  }

  /// Set the [method] for the request.
  void setMethod(String method) {
    _api.options.method = method;
  }

  /// Set the [sendTimeout] for the request.
  void setSendTimeout(Duration duration) {
    _api.options.sendTimeout = duration;
  }

  /// Set the [contentType] for the request.
  void setContentType(String contentType) {
    _api.options.contentType = contentType;
  }

  /// Set the [Duration] for the cache.
  /// If cacheDuration is null, the cache will be disabled.
  Duration? _cacheDuration;

  /// Cache key
  String? _cacheKey;

  /// Set the cache for the request.
  void setCache(Duration? duration, String cacheKey) {
    _cacheDuration = duration;
    _cacheKey = cacheKey;
  }

  /// Apply a pagination query to the HTTP request
  void setPagination(int page,
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

    if (_initDio != null) {
      _api = _initDio!(_api);
    }
  }

  Dio Function(Dio api)? _initDio;

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
      Duration? cacheDuration,
      String? cacheKey,
      Map<String, dynamic>? headers}) async {
    headers ??= {};
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

      Response? response;

      Duration? cacheDurationRequest = cacheDuration;
      cacheDurationRequest ??= _cacheDuration;

      String? cacheKeyRequest = cacheKey;
      cacheKeyRequest ??= _cacheKey;

      if (cacheDurationRequest != null || cacheKeyRequest != null) {
        assert(cacheDurationRequest != null, 'Cache duration is required');
        assert(cacheKeyRequest != null, 'Cache key is required');

        int inSeconds = cacheDurationRequest?.inSeconds ?? 60;
        bool cacheHit = true;
        Map responseMap = await ny_cache
            .cache()
            .saveRemember(cacheKeyRequest!, inSeconds, () async {
          cacheHit = false;
          Response requestData = await request(_api);
          return {
            'requestOptions': {
              'path': requestData.requestOptions.path,
              'method': requestData.requestOptions.method,
              'baseUrl': requestData.requestOptions.baseUrl,
            },
            'statusCode': requestData.statusCode,
            'statusMessage': requestData.statusMessage,
            'data': requestData.data,
          };
        });
        response = Response(
          requestOptions: RequestOptions(
            path: responseMap['requestOptions']['path'],
            method: responseMap['requestOptions']['method'],
            baseUrl: responseMap['requestOptions']['baseUrl'],
          ),
          statusCode: responseMap['statusCode'],
          statusMessage: responseMap['statusMessage'],
          data: responseMap['data'],
        );

        if (cacheHit) {
          printDebug('');
          printDebug('╔╣ ${response.requestOptions.uri}');
          printDebug('║  Cache ${cacheHit ? 'hit' : 'miss'}: $cacheKeyRequest');
          printDebug('║  Status: ${response.statusCode}');
          printDebug('╚╣ Response');
          printDebug(response.data);
        } else {
          printDebug('Cached response $cacheKeyRequest');
        }
      } else {
        response = await request(_api);
      }

      _api.options.headers = oldHeader; // reset headers
      _api.options.baseUrl = oldBaseUrl; //  reset base url
      _api.options.queryParameters = {}; // reset query parameters

      dynamic data = handleResponse<T>(response!, handleSuccess: handleSuccess);
      if (data != T && useUndefinedResponse) {
        onUndefinedResponse(data, response, _context);
      }
      if (_onSuccessEvent != null) {
        _onSuccessEvent!(response, data);
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
      error(dioException);
      if (_context != null) {
        displayError(dioException, _context!);
      }

      if (handleFailure != null) {
        return handleFailure(dioException);
      }

      if (_onErrorEvent != null) {
        _onErrorEvent!(dioException);
      }

      return null;
    } on Exception catch (e) {
      NyLogger.error(e.toString());
      return null;
    }
  }

  /// Handle the [DioException] response if there is an issue.
  void error(DioException dioException) {}

  /// Display a error to the user
  /// This method is only called if you provide the API service
  /// with a [BuildContext].
  void displayError(DioException dioException, BuildContext context) {}

  /// Handle the undefined response's for HTTP requests.
  /// The [data] parameter contains what was returned from your decoder.
  void onUndefinedResponse(
      dynamic data, Response response, BuildContext? context) {}

  /// Handles an API network response from [Dio].
  /// [handleSuccess] overrides the return value
  /// [handleFailure] is called then the response status is not 200.
  /// You can return a different value using this callback.
  dynamic handleResponse<T>(Response response,
      {Function(Response response)? handleSuccess}) {
    bool wasSuccessful = false;
    if (response.statusCode != null) {
      wasSuccessful =
          (response.statusCode!) >= 200 && (response.statusCode!) < 300;
    }

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
  dynamic _morphJsonResponse<T>(dynamic json) {
    DefaultResponse defaultResponse =
        DefaultResponse<T>.fromJson(json, decoders ?? {}, type: T);
    return defaultResponse.data;
  }

  /// Adds all the [interceptors] to [dio].
  void _addInterceptors() => _api.interceptors.addAll(interceptors.values);

  /// Perform a [Dio] request to update the users auth token.
  /// This method is called when [shouldRefreshToken] returns true.
  /// You can override this method to perform your own request.
  /// The [dio] parameter is a new instance of [Dio].
  /// You can use this to perform a request without affecting the
  /// original [Dio] instance.
  Future<void> refreshToken(Dio dio) async {}

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
    if (containsKey("Authorization")) {
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
    return containsKey(key);
  }
}
