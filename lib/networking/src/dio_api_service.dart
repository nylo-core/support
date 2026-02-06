import 'package:dio/dio.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import '/helpers/ny_helpers.dart' as ny_cache;
import '/networking/ny_networking.dart';

/// Base API Service class
class DioApiService {
  /// Dio instance
  late Dio _api;

  /// Get the Dio instance for making custom requests
  Dio get dio => _api;

  /// Base options for the request
  BaseOptions? baseOptions;

  /// Base URL for the request
  final String baseUrl = "";

  /// Use interceptors
  bool get useInterceptors => interceptors.isNotEmpty;

  /// Use HTTP on response
  final bool useHttpOnResponse = true;

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

  /// Whether to check connectivity before making a request.
  /// If true and the device is offline, the request will fail immediately
  /// with a [DioExceptionType.connectionError] instead of waiting for timeout.
  bool checkConnectivityBeforeRequest = false;

  /// List of active cancel tokens for request management
  final List<CancelToken> _activeCancelTokens = [];

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

  DioApiService({
    BaseOptions Function(BaseOptions baseOptions)? baseOptions,
    Dio Function(Dio api)? initDio,
  }) {
    _initDio = initDio;
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

  /// Set whether to check connectivity before making requests.
  /// When enabled, requests will fail immediately if the device is offline.
  void setCheckConnectivityBeforeRequest(bool check) {
    checkConnectivityBeforeRequest = check;
  }

  /// Create a managed [CancelToken] that is tracked by this service.
  /// Use this to create tokens that can be cancelled with [cancelAllRequests].
  ///
  /// Example:
  /// ```dart
  /// final token = api.createCancelToken();
  /// await api.get('/endpoint', cancelToken: token);
  /// ```
  CancelToken createCancelToken() {
    final token = CancelToken();
    _activeCancelTokens.add(token);
    return token;
  }

  /// Cancel all active requests that were created with [createCancelToken].
  /// Optionally provide a [reason] that will be included in the cancellation error.
  ///
  /// Example:
  /// ```dart
  /// // Cancel all pending requests on logout
  /// api.cancelAllRequests('User logged out');
  /// ```
  void cancelAllRequests([String? reason]) {
    for (final token in _activeCancelTokens) {
      if (!token.isCancelled) {
        token.cancel(reason);
      }
    }
    _activeCancelTokens.clear();
  }

  /// Remove a specific cancel token from the tracked list.
  /// Call this when a request completes to clean up the token.
  void removeCancelToken(CancelToken token) {
    _activeCancelTokens.remove(token);
  }

  /// Get the count of active (non-cancelled) requests.
  int get activeRequestCount =>
      _activeCancelTokens.where((t) => !t.isCancelled).length;

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
  void setPagination(
    int page, {
    String? paramPage,
    String? paramPerPage,
    String? perPage,
  }) {
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

  /// Creates a new [Dio] instance for a single request, copying the base
  /// configuration and interceptors from [_api] with per-request overrides.
  /// This prevents concurrent requests from corrupting each other's state.
  Dio _createRequestDio({
    Map<String, dynamic>? additionalHeaders,
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    final mergedHeaders = Map<String, dynamic>.from(_api.options.headers);
    if (additionalHeaders != null) {
      mergedHeaders.addAll(additionalHeaders);
    }

    final requestDio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? _api.options.baseUrl,
        headers: mergedHeaders,
        connectTimeout: connectTimeout ?? _api.options.connectTimeout,
        receiveTimeout: receiveTimeout ?? _api.options.receiveTimeout,
        sendTimeout: sendTimeout ?? _api.options.sendTimeout,
        queryParameters: Map<String, dynamic>.from(
          _api.options.queryParameters,
        ),
        contentType: _api.options.contentType,
        responseType: _api.options.responseType,
        validateStatus: _api.options.validateStatus,
        receiveDataWhenStatusError: _api.options.receiveDataWhenStatusError,
        followRedirects: _api.options.followRedirects,
        maxRedirects: _api.options.maxRedirects,
        persistentConnection: _api.options.persistentConnection,
        requestEncoder: _api.options.requestEncoder,
        responseDecoder: _api.options.responseDecoder,
        listFormat: _api.options.listFormat,
      ),
    );

    // Share interceptors from the main Dio instance
    requestDio.interceptors.addAll(_api.interceptors);

    return requestDio;
  }

  /// Networking class to handle API requests
  /// Use the [request] callback to call an API
  /// [handleSuccess] overrides the response on a successful status code
  /// [handleFailure] overrides the response on a failure
  ///
  /// Usage:
  /// Future<NyResponse<List<User>>> fetchUsers() async {
  ///     return await network<List<User>>(
  ///         request: (request) => request.get("/users"),
  ///     );
  ///   }
  Future<T?> network<T>({
    required Function(Dio api) request,
    Function(NyResponse<T> response)? handleSuccess,
    Function(NyResponse<T> response)? handleFailure,
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
    CachePolicy? cachePolicy,
    bool? checkConnectivity,
    Map<String, dynamic>? headers,
  }) async {
    NyResponse<T> response = await networkResponse<T>(
      request: request,
      handleSuccess: handleSuccess,
      handleFailure: handleFailure,
      bearerToken: bearerToken,
      baseUrl: baseUrl,
      useUndefinedResponse: useUndefinedResponse,
      shouldRetry: shouldRetry,
      shouldSetAuthHeaders: shouldSetAuthHeaders,
      retry: retry,
      retryDelay: retryDelay,
      retryIf: retryIf,
      connectionTimeout: connectionTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      cacheDuration: cacheDuration,
      cacheKey: cacheKey,
      cachePolicy: cachePolicy,
      checkConnectivity: checkConnectivity,
      headers: headers,
    );
    return response.data;
  }

  Future<NyResponse<T>> networkResponse<T>({
    required Function(Dio api) request,
    Function(NyResponse<T> response)? handleSuccess,
    Function(NyResponse<T> response)? handleFailure,
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
    CachePolicy? cachePolicy,
    bool? checkConnectivity,
    Map<String, dynamic>? headers,
  }) async {
    headers ??= {};
    Stopwatch stopwatch = Stopwatch();
    String? requestTime;

    // Resolve cache policy - default to networkOnly if no cache settings
    CachePolicy effectivePolicy = cachePolicy ?? CachePolicy.networkOnly;
    String? cacheKeyRequest = cacheKey ?? _cacheKey;
    Duration? cacheDurationRequest = cacheDuration ?? _cacheDuration;

    // If cache key/duration provided but no policy, use cacheFirst for backward compatibility
    if (cachePolicy == null &&
        (cacheKeyRequest != null || cacheDurationRequest != null)) {
      effectivePolicy = CachePolicy.cacheFirst;
    }

    try {
      // Compute per-request headers
      Map<String, dynamic> newValuesToAddToHeader = {};
      if (headers.isNotEmpty) {
        for (var header in headers.entries) {
          if (!_api.options.headers.containsKey(header.key)) {
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

      // Create a per-request Dio instance to avoid shared mutable state
      // across concurrent requests (prevents header/auth token leakage).
      Dio requestDio = _createRequestDio(
        additionalHeaders: newValuesToAddToHeader,
        baseUrl: baseUrl,
        connectTimeout: connectionTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
      );

      // Handle cache-first policies
      if (effectivePolicy.shouldTryCacheFirst && cacheKeyRequest != null) {
        final cachedData = await _tryGetFromCache(cacheKeyRequest);
        if (cachedData != null) {
          printDebug('');
          printDebug('╔╣ Cache hit: $cacheKeyRequest');
          printDebug('╚╣ Policy: ${effectivePolicy.description}');

          // For staleWhileRevalidate, trigger background refresh
          if (effectivePolicy.shouldRevalidateInBackground) {
            _revalidateInBackground(
              request: request,
              cacheKey: cacheKeyRequest,
              cacheDuration: cacheDurationRequest,
              requestDio: requestDio,
            );
          }

          return _createResponseFromCache<T>(cachedData, handleSuccess);
        } else if (effectivePolicy == CachePolicy.cacheOnly) {
          throw DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.unknown,
            message: 'No cached data available for key: $cacheKeyRequest',
          );
        }
      }

      // Check connectivity before making request if enabled
      bool shouldCheckConnectivity =
          checkConnectivity ?? checkConnectivityBeforeRequest;
      if (shouldCheckConnectivity && await NyConnectivity.isOffline()) {
        // For networkFirst, try cache on offline
        if (effectivePolicy.shouldFallbackToCache && cacheKeyRequest != null) {
          final cachedData = await _tryGetFromCache(cacheKeyRequest);
          if (cachedData != null) {
            printDebug('Offline - using cached data for: $cacheKeyRequest');
            return _createResponseFromCache<T>(cachedData, handleSuccess);
          }
        }
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
          message: 'No network connection',
        );
      }

      Response? response;

      // Make the network request using the per-request Dio
      stopwatch.start();
      requestDio.options.extra['timestamp'] =
          DateTime.now().microsecondsSinceEpoch;
      response = await request(requestDio);
      stopwatch.stop();
      requestTime = "${stopwatch.elapsedMilliseconds}ms";
      _recordApiResponse(
        handleResponse<T>(response!, handleSuccess: handleSuccess),
        requestTime,
      );

      // Cache the response if caching is enabled
      if (cacheKeyRequest != null && effectivePolicy.shouldTryNetwork) {
        await _saveToCache(cacheKeyRequest, response, cacheDurationRequest);
        printDebug('Cached response: $cacheKeyRequest');
      }

      NyResponse<T> apiResponse = handleResponse<T>(
        response,
        handleSuccess: handleSuccess,
      );

      if (apiResponse.data == null && useUndefinedResponse) {
        onUndefinedResponse(apiResponse.data, response);
      }
      if (_onSuccessEvent != null) {
        _onSuccessEvent!(response, apiResponse.data);
      }

      return apiResponse;
    } on DioException catch (dioException) {
      NyResponse response = NyResponse(
        response: dioException.response ?? null,
        data: null,
        rawData: dioException.response?.data,
      );
      stopwatch.stop();
      requestTime = "${stopwatch.elapsedMilliseconds}ms";
      _recordApiResponse(response, requestTime);

      int nyRetries = retry ?? this.retry;
      Duration nyRetryDelay = retryDelay ?? this.retryDelay;
      bool Function(DioException dioException)? retryIfFinal = this.retryIf;
      if (retryIf != null) {
        retryIfFinal = retryIf;
      }
      if (retryIfFinal != null) {
        shouldRetry = retryIfFinal(dioException);
      }
      if (shouldRetry == true && nyRetries > 0) {
        for (var i = 0; i < nyRetries; i++) {
          await Future.delayed(nyRetryDelay);
          NyLogger.debug("[${i + 1}] Retrying request...");
          dynamic response = await networkResponse(
            request: request,
            handleSuccess: handleSuccess,
            handleFailure: handleFailure,
            bearerToken: bearerToken,
            baseUrl: baseUrl,
            useUndefinedResponse: useUndefinedResponse,
            shouldSetAuthHeaders: shouldSetAuthHeaders,
            connectionTimeout: connectionTimeout,
            receiveTimeout: receiveTimeout,
            sendTimeout: sendTimeout,
            headers: headers,
            shouldRetry: false,
          );
          if (response != null) {
            return response;
          }
        }
      }

      NyLogger.error(dioException.toString());
      error(dioException);

      if (handleFailure != null) {
        NyResponse<T> errorResponse = _createErrorResponse<T>(dioException);
        return handleFailure(errorResponse);
      }

      if (_onErrorEvent != null) {
        _onErrorEvent!(dioException);
      }

      // Create an error response from the DioException
      return _createErrorResponse<T>(dioException);
    } on Exception catch (e) {
      NyLogger.error(e.toString());
      return _createGenericErrorResponse<T>(e);
    } finally {
      _api.options.queryParameters = {};
      _cacheDuration = null;
      _cacheKey = null;
    }
  }

  /// Handle the [DioException] response if there is an issue.
  void error(DioException dioException) {}

  /// Handle the undefined response's for HTTP requests.
  /// The [data] parameter contains what was returned from your decoder.
  void onUndefinedResponse(dynamic data, Response response) {}

  /// Handles an API network response from [Dio].
  /// Returns a comprehensive NyResponse object containing the original Dio Response,
  /// morphed data, and useful utilities.
  ///
  /// This method provides access to:
  /// - The original Dio Response object with headers, status codes, etc.
  /// - Morphed/decoded data using your decoders
  /// - Utility methods for checking response status
  /// - Raw response data
  ///
  /// Example usage:
  /// ```dart
  /// NyResponse<User> response = handleResponse<User>(dioResponse);
  ///
  /// if (response.isSuccessful) {
  ///   User? user = response.data;
  ///   print('Status: ${response.statusCode}');
  ///   print('Headers: ${response.headers}');
  /// } else {
  ///   print('Error: ${response.statusMessage}');
  /// }
  /// ```
  ///
  /// [handleSuccess] callback is called when response is successful (2xx status)
  /// [handleFailure] callback is called when response is not successful
  NyResponse<T> handleResponse<T>(
    Response response, {
    Function(NyResponse<T> response)? handleSuccess,
    Function(NyResponse<T> response)? handleFailure,
  }) {
    T? morphedData;

    // Morph the response data if T is not dynamic
    if (T.toString() != 'dynamic') {
      morphedData = _morphJsonResponse<T>(response.data);
    } else {
      morphedData = response.data as T?;
    }

    // Create the enhanced response object
    NyResponse<T> nyResponse = NyResponse.fromResponse(
      response: response,
      morphedData: morphedData,
    );

    // Handle success callback
    if (nyResponse.isSuccessful && handleSuccess != null) {
      return handleSuccess(nyResponse) ?? nyResponse;
    }

    // Handle failure callback
    if (!nyResponse.isSuccessful && handleFailure != null) {
      return handleFailure(nyResponse) ?? nyResponse;
    }

    return nyResponse;
  }

  /// Creates an error response from a DioException
  NyResponse<T> _createErrorResponse<T>(DioException dioException) {
    // Create a mock response from the exception
    Response response = Response(
      requestOptions: dioException.requestOptions,
      statusCode: dioException.response?.statusCode ?? 500,
      statusMessage: dioException.response?.statusMessage ?? 'Network Error',
      data: dioException.response?.data ?? {'error': dioException.message},
      headers: dioException.response?.headers ?? Headers(),
    );

    return NyResponse<T>(
      response: response,
      data: null,
      rawData: response.data,
    );
  }

  /// Creates a generic error response from any Exception
  NyResponse<T> _createGenericErrorResponse<T>(Exception exception) {
    // Create a mock response for generic exceptions
    Response response = Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: 500,
      statusMessage: 'Internal Error',
      data: {'error': exception.toString()},
      headers: Headers(),
    );

    return NyResponse<T>(
      response: response,
      data: null,
      rawData: response.data,
    );
  }

  /// Morphs json into Object using 'bootstrap/decoders.dart'.
  dynamic _morphJsonResponse<T>(dynamic json) {
    DefaultResponse defaultResponse = DefaultResponse<T>.fromJson(
      json,
      decoders ?? {},
      type: T,
    );
    return defaultResponse.data;
  }

  /// Creates an enhanced API response from a Dio response and type
  /// This is a convenience method for creating NyResponse objects
  NyResponse<T> createEnhancedResponse<T>(Response response) {
    T? morphedData;

    if (T.toString() != 'dynamic') {
      morphedData = _morphJsonResponse<T>(response.data);
    } else {
      morphedData = response.data as T?;
    }

    return NyResponse.fromResponse(
      response: response,
      morphedData: morphedData,
    );
  }

  /// Convenience method to extract just the data from an enhanced response
  /// This helps with migration from the old handleResponse method
  T? extractData<T>(NyResponse<T> enhancedResponse) {
    return enhancedResponse.data;
  }

  /// Convenience method to check if an enhanced response is successful
  /// and return the data or null if not successful
  T? getDataIfSuccessful<T>(NyResponse<T> enhancedResponse) {
    return enhancedResponse.isSuccessful ? enhancedResponse.data : null;
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
  Future<RequestHeaders> setAuthHeaders(RequestHeaders headers) async {
    return headers;
  }

  void _recordApiResponse(NyResponse response, String requestTime) {
    Backpack.instance.append(
      'NY_API_LOGS',
      {response: requestTime},
      append: true,
      limit: 100,
    );
  }

  /// Try to get cached data for the given key.
  Future<Map?> _tryGetFromCache(String cacheKey) async {
    try {
      final cached = await ny_cache.cache().get(cacheKey);
      if (cached != null && cached is Map) {
        return cached;
      }
    } catch (e) {
      printDebug('Cache read error: $e');
    }
    return null;
  }

  /// Save response data to cache.
  Future<void> _saveToCache(
    String cacheKey,
    Response response,
    Duration? duration,
  ) async {
    try {
      final cacheData = {
        'requestOptions': {
          'path': response.requestOptions.path,
          'method': response.requestOptions.method,
          'baseUrl': response.requestOptions.baseUrl,
        },
        'statusCode': response.statusCode,
        'statusMessage': response.statusMessage,
        'data': response.data,
        'cachedAt': DateTime.now().toIso8601String(),
      };
      final inSeconds = duration?.inSeconds ?? 3600; // Default 1 hour
      await ny_cache.cache().put(cacheKey, cacheData, seconds: inSeconds);
    } catch (e) {
      printDebug('Cache save error: $e');
    }
  }

  /// Create an NyResponse from cached data.
  NyResponse<T> _createResponseFromCache<T>(
    Map cachedData,
    Function(NyResponse<T> response)? handleSuccess,
  ) {
    final response = Response(
      requestOptions: RequestOptions(
        path: cachedData['requestOptions']?['path'] ?? '',
        method: cachedData['requestOptions']?['method'] ?? 'GET',
        baseUrl: cachedData['requestOptions']?['baseUrl'] ?? '',
      ),
      statusCode: cachedData['statusCode'] ?? 200,
      statusMessage: cachedData['statusMessage'] ?? 'OK',
      data: cachedData['data'],
    );

    return handleResponse<T>(response, handleSuccess: handleSuccess);
  }

  /// Revalidate cache in the background (for staleWhileRevalidate policy).
  /// Uses the provided [requestDio] instance to avoid shared mutable state.
  void _revalidateInBackground({
    required Function(Dio api) request,
    required String cacheKey,
    Duration? cacheDuration,
    required Dio requestDio,
  }) {
    // Fire and forget - don't await
    Future(() async {
      try {
        final response = await request(requestDio);
        await _saveToCache(cacheKey, response, cacheDuration);
        printDebug('Background revalidation complete: $cacheKey');
      } catch (e) {
        printDebug('Background revalidation failed: $e');
      }
    });
  }

  /// Clear a specific cache entry.
  Future<void> clearCache(String cacheKey) async {
    await ny_cache.cache().clear(cacheKey);
  }

  /// Clear all API cache entries.
  Future<void> clearAllCache() async {
    await ny_cache.cache().flush();
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
