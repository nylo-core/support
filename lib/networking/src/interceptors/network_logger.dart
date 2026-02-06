import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

const _requestIdKey = '_network_logger_request_id_';
const _timeStampKey = '_network_logger_timestamp_';

/// Log level for [NetworkLogger]
enum LogLevelType {
  /// Print all request and response details including headers, body, etc.
  verbose,

  /// Print minimal information (method, URL, status code, time)
  minimal,

  /// No logging output
  none,
}

/// ANSI color codes for terminal output
class _AnsiColors {
  static const String reset = '\x1B[0m';
  static const String brightRed = '\x1B[91m';
  static const String brightGreen = '\x1B[92m';
  static const String brightYellow = '\x1B[93m';
  static const String brightCyan = '\x1B[96m';
}

/// A network logger interceptor for Dio
/// Provides pretty-printed request/response logging with:
/// - Log level support (verbose, minimal, none)
/// - Color output for terminals
/// - Structured JSON output mode
/// - UUID-based request ID tracking for concurrent request correlation
class NetworkLogger extends Interceptor {
  /// Log level controlling output verbosity
  final LogLevelType logLevel;

  /// Print request [Options]
  final bool request;

  /// Print request header [Options.headers]
  final bool requestHeader;

  /// Print request data [Options.data]
  final bool requestBody;

  /// Print [Response.data]
  final bool responseBody;

  /// Print [Response.headers]
  final bool responseHeader;

  /// Print error message
  final bool error;

  /// InitialTab count to logPrint json response
  static const int kInitialTab = 1;

  /// 1 tab length
  static const String tabStep = '    ';

  /// Print compact json response
  final bool compact;

  /// Width size per logPrint
  final int maxWidth;

  /// Size in which the Uint8List will be split
  static const int chunkSize = 20;

  /// Log printer; defaults logPrint log to console.
  /// In flutter, you'd better use debugPrint.
  /// you can also write log in a file.
  final void Function(Object object) logPrint;

  /// Filter request/response by [RequestOptions]
  final bool Function(RequestOptions options, FilterArgs args)? filter;

  /// Enable logPrint
  final bool enabled;

  /// Enable ANSI color output for terminal
  final bool useColors;

  /// Enable structured JSON output mode
  final bool structuredOutput;

  /// UUID generator for request ID tracking
  static const Uuid _uuid = Uuid();

  /// Default constructor
  NetworkLogger({
    this.logLevel = LogLevelType.verbose,
    this.request = true,
    this.requestHeader = true,
    this.requestBody = true,
    this.responseHeader = false,
    this.responseBody = true,
    this.error = true,
    this.maxWidth = 90,
    this.compact = true,
    this.logPrint = print,
    this.filter,
    this.enabled = true,
    this.useColors = false,
    this.structuredOutput = false,
  });

  /// Get colored text if colors are enabled
  String _colorize(String text, String color) {
    if (!useColors) return text;
    return '$color$text${_AnsiColors.reset}';
  }

  /// Get success color (green)
  String _success(String text) => _colorize(text, _AnsiColors.brightGreen);

  /// Get error color (red)
  String _error(String text) => _colorize(text, _AnsiColors.brightRed);

  /// Get warning color (yellow)
  String _warning(String text) => _colorize(text, _AnsiColors.brightYellow);

  /// Get info color (cyan)
  String _info(String text) => _colorize(text, _AnsiColors.brightCyan);

  /// Calculate payload size in bytes from response data
  int _calculatePayloadSize(dynamic data) {
    if (data == null) return 0;
    if (data is Uint8List) return data.length;
    if (data is String) return data.length;
    // For other types (Map, List), convert to string representation
    return data.toString().length;
  }

  /// Format bytes to human-readable size (B, KB, MB)
  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Always generate unique request ID and timestamp for correlation
    final requestId = _uuid.v4().substring(0, 8);
    options.extra[_requestIdKey] = requestId;
    options.extra[_timeStampKey] = DateTime.timestamp().millisecondsSinceEpoch;

    if (!enabled || logLevel == LogLevelType.none) {
      handler.next(options);
      return;
    }

    if (filter != null && !filter!(options, FilterArgs(false, options.data))) {
      handler.next(options);
      return;
    }

    if (structuredOutput) {
      _printStructuredRequest(options, requestId);
    } else {
      _printPrettyRequest(options, requestId);
    }

    handler.next(options);
  }

  void _printStructuredRequest(RequestOptions options, String requestId) {
    final Map<String, dynamic> logData = {
      'type': 'request',
      'requestId': requestId,
      'method': options.method,
      'uri': options.uri.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (logLevel == LogLevelType.verbose) {
      if (options.queryParameters.isNotEmpty) {
        logData['queryParameters'] = options.queryParameters;
      }
      if (requestHeader) {
        logData['headers'] = options.headers;
        logData['contentType'] = options.contentType;
        logData['responseType'] = options.responseType.toString();
      }
      if (requestBody && options.data != null && options.method != 'GET') {
        logData['body'] = options.data;
      }
    }

    logPrint(_info('[REQUEST] ${_toJsonString(logData)}'));
  }

  void _printPrettyRequest(RequestOptions options, String requestId) {
    if (logLevel == LogLevelType.minimal) {
      logPrint(_info('→ [${options.method}] ${options.uri} (ID: $requestId)'));
      return;
    }

    if (request) {
      _printRequestHeader(options, requestId);
    }
    if (requestHeader) {
      _printMapAsTable(options.queryParameters, header: 'Query Parameters');
      final requestHeaders = <String, dynamic>{};
      requestHeaders.addAll(options.headers);
      if (options.contentType != null) {
        requestHeaders['contentType'] = options.contentType?.toString();
      }
      requestHeaders['responseType'] = options.responseType.toString();
      requestHeaders['followRedirects'] = options.followRedirects;
      if (options.connectTimeout != null) {
        requestHeaders['connectTimeout'] = options.connectTimeout?.toString();
      }
      if (options.receiveTimeout != null) {
        requestHeaders['receiveTimeout'] = options.receiveTimeout?.toString();
      }
      _printMapAsTable(requestHeaders, header: 'Headers');
      _printMapAsTable(
        Map.of(options.extra)
          ..remove(_requestIdKey)
          ..remove(_timeStampKey),
        header: 'Extras',
      );
    }
    if (requestBody && options.method != 'GET') {
      final dynamic data = options.data;
      if (data != null) {
        if (data is Map) _printMapAsTable(options.data as Map?, header: 'Body');
        if (data is FormData) {
          final formDataMap = <String, dynamic>{}
            ..addEntries(data.fields)
            ..addEntries(data.files);
          _printMapAsTable(formDataMap, header: 'Form data | ${data.boundary}');
        } else {
          _printBlock(data.toString());
        }
      }
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enabled || logLevel == LogLevelType.none) {
      handler.next(err);
      return;
    }

    if (filter != null &&
        !filter!(err.requestOptions, FilterArgs(true, err.response?.data))) {
      handler.next(err);
      return;
    }

    final requestId =
        err.requestOptions.extra[_requestIdKey] as String? ?? 'unknown';
    final triggerTime = err.requestOptions.extra[_timeStampKey];
    int diff = 0;
    if (triggerTime is int) {
      diff = DateTime.timestamp().millisecondsSinceEpoch - triggerTime;
    }

    if (error) {
      if (structuredOutput) {
        _printStructuredError(err, requestId, diff);
      } else {
        _printPrettyError(err, requestId, diff);
      }
    }
    handler.next(err);
  }

  void _printStructuredError(
    DioException err,
    String requestId,
    int responseTime,
  ) {
    final payloadSizeBytes = _calculatePayloadSize(err.response?.data);
    final Map<String, dynamic> logData = {
      'type': 'error',
      'requestId': requestId,
      'errorType': err.type.toString(),
      'method': err.requestOptions.method,
      'uri': err.requestOptions.uri.toString(),
      'responseTimeMs': responseTime,
      'payloadSizeBytes': payloadSizeBytes,
      'payloadSize': _formatSize(payloadSizeBytes),
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (err.response != null) {
      logData['statusCode'] = err.response?.statusCode;
      logData['statusMessage'] = err.response?.statusMessage;
      if (logLevel == LogLevelType.verbose && err.response?.data != null) {
        logData['data'] = err.response?.data;
      }
    }

    if (err.message != null) {
      logData['message'] = err.message;
    }

    logPrint(_error('[ERROR] ${_toJsonString(logData)}'));
  }

  void _printPrettyError(DioException err, String requestId, int responseTime) {
    final payloadSize = _formatSize(_calculatePayloadSize(err.response?.data));

    if (logLevel == LogLevelType.minimal) {
      final statusCode = err.response?.statusCode ?? 'N/A';
      logPrint(
        _error(
          '✗ [${err.requestOptions.method}] ${err.requestOptions.uri} → $statusCode (${responseTime}ms) [$payloadSize] [ID: $requestId]',
        ),
      );
      return;
    }

    if (err.type == DioExceptionType.badResponse) {
      final uri = err.response?.requestOptions.uri;
      _printBoxed(
        header: _error(
          'DioError ║ Status: ${err.response?.statusCode} ${err.response?.statusMessage} ║ Time: $responseTime ms ║ Size: $payloadSize ║ ID: $requestId',
        ),
        text: uri.toString(),
      );
      if (err.response != null && err.response?.data != null) {
        logPrint('╔ ${err.type.toString()}');
        _printResponse(err.response!);
      }
      _printLine('╚');
      logPrint('');
    } else {
      _printBoxed(
        header: _error('DioError ║ ${err.type} ║ ID: $requestId'),
        text: err.message,
      );
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!enabled || logLevel == LogLevelType.none) {
      handler.next(response);
      return;
    }

    if (filter != null &&
        !filter!(response.requestOptions, FilterArgs(true, response.data))) {
      handler.next(response);
      return;
    }

    final requestId =
        response.requestOptions.extra[_requestIdKey] as String? ?? 'unknown';
    final triggerTime = response.requestOptions.extra[_timeStampKey];
    int diff = 0;
    if (triggerTime is int) {
      diff = DateTime.timestamp().millisecondsSinceEpoch - triggerTime;
    }

    if (structuredOutput) {
      _printStructuredResponse(response, requestId, diff);
    } else {
      _printPrettyResponse(response, requestId, diff);
    }

    handler.next(response);
  }

  void _printStructuredResponse(
    Response response,
    String requestId,
    int responseTime,
  ) {
    final payloadSizeBytes = _calculatePayloadSize(response.data);
    final Map<String, dynamic> logData = {
      'type': 'response',
      'requestId': requestId,
      'method': response.requestOptions.method,
      'uri': response.requestOptions.uri.toString(),
      'statusCode': response.statusCode,
      'statusMessage': response.statusMessage,
      'responseTimeMs': responseTime,
      'payloadSizeBytes': payloadSizeBytes,
      'payloadSize': _formatSize(payloadSizeBytes),
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (logLevel == LogLevelType.verbose) {
      if (responseHeader) {
        final responseHeaders = <String, String>{};
        response.headers.forEach(
          (k, list) => responseHeaders[k] = list.toString(),
        );
        logData['headers'] = responseHeaders;
      }
      if (responseBody && response.data != null) {
        logData['data'] = response.data;
      }
    }

    final isSuccess =
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300;
    logPrint(
      isSuccess
          ? _success('[RESPONSE] ${_toJsonString(logData)}')
          : _warning('[RESPONSE] ${_toJsonString(logData)}'),
    );
  }

  void _printPrettyResponse(
    Response response,
    String requestId,
    int responseTime,
  ) {
    final isSuccess =
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300;
    final statusText = '${response.statusCode} ${response.statusMessage}';

    if (logLevel == LogLevelType.minimal) {
      final symbol = isSuccess ? '✓' : '⚠';
      final colorFn = isSuccess ? _success : _warning;
      final payloadSize = _formatSize(_calculatePayloadSize(response.data));
      logPrint(
        colorFn(
          '$symbol [${response.requestOptions.method}] ${response.requestOptions.uri} → $statusText (${responseTime}ms) [$payloadSize] [ID: $requestId]',
        ),
      );
      return;
    }

    _printResponseHeader(response, responseTime, requestId, isSuccess);
    if (responseHeader) {
      final responseHeaders = <String, String>{};
      response.headers.forEach(
        (k, list) => responseHeaders[k] = list.toString(),
      );
      _printMapAsTable(responseHeaders, header: 'Headers');
    }

    if (responseBody) {
      logPrint('╔ Body');
      logPrint('║');
      _printResponse(response);
      logPrint('║');
      _printLine('╚');
    }
  }

  String _toJsonString(Map<String, dynamic> data) {
    try {
      // Simple JSON serialization
      return _serializeJson(data);
    } catch (e) {
      return data.toString();
    }
  }

  String _serializeJson(dynamic value, [int indent = 0]) {
    if (value == null) return 'null';
    if (value is bool || value is num) return value.toString();
    if (value is String)
      return '"${value.replaceAll('"', '\\"').replaceAll('\n', '\\n')}"';
    if (value is List) {
      if (value.isEmpty) return '[]';
      final items = value.map((e) => _serializeJson(e, indent + 1)).join(', ');
      return '[$items]';
    }
    if (value is Map) {
      if (value.isEmpty) return '{}';
      final items = value.entries
          .map((e) => '"${e.key}": ${_serializeJson(e.value, indent + 1)}')
          .join(', ');
      return '{$items}';
    }
    return '"${value.toString()}"';
  }

  void _printBoxed({String? header, String? text}) {
    logPrint('');
    logPrint('╔╣ $header');
    logPrint('║  $text');
    _printLine('╚');
  }

  void _printResponse(Response response) {
    if (response.data != null) {
      if (response.data is Map) {
        _printPrettyMap(response.data as Map);
      } else if (response.data is Uint8List) {
        logPrint('║${_indent()}[');
        _printUint8List(response.data as Uint8List);
        logPrint('║${_indent()}]');
      } else if (response.data is List) {
        logPrint('║${_indent()}[');
        _printList(response.data as List);
        logPrint('║${_indent()}]');
      } else {
        _printBlock(response.data.toString());
      }
    }
  }

  void _printResponseHeader(
    Response response,
    int responseTime,
    String requestId,
    bool isSuccess,
  ) {
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method;
    final payloadSize = _formatSize(_calculatePayloadSize(response.data));
    final header =
        'Response ║ $method ║ Status: ${response.statusCode} ${response.statusMessage} ║ Time: $responseTime ms ║ Size: $payloadSize ║ ID: $requestId';
    _printBoxed(
      header: isSuccess ? _success(header) : _warning(header),
      text: uri.toString(),
    );
  }

  void _printRequestHeader(RequestOptions options, String requestId) {
    final uri = options.uri;
    final method = options.method;
    _printBoxed(
      header: _info('Request ║ $method ║ ID: $requestId'),
      text: uri.toString(),
    );
  }

  void _printLine([String pre = '', String suf = '╝']) =>
      logPrint('$pre${'═' * maxWidth}$suf');

  void _printKV(String? key, Object? v) {
    final pre = '╟ $key: ';
    final msg = v.toString();

    if (pre.length + msg.length > maxWidth) {
      logPrint(pre);
      _printBlock(msg);
    } else {
      logPrint('$pre$msg');
    }
  }

  void _printBlock(String msg) {
    final lines = (msg.length / maxWidth).ceil();
    for (var i = 0; i < lines; ++i) {
      logPrint(
        (i >= 0 ? '║ ' : '') +
            msg.substring(
              i * maxWidth,
              math.min<int>(i * maxWidth + maxWidth, msg.length),
            ),
      );
    }
  }

  String _indent([int tabCount = kInitialTab]) => tabStep * tabCount;

  void _printPrettyMap(
    Map data, {
    int initialTab = kInitialTab,
    bool isListItem = false,
    bool isLast = false,
  }) {
    var tabs = initialTab;
    final isRoot = tabs == kInitialTab;
    final initialIndent = _indent(tabs);
    tabs++;

    if (isRoot || isListItem) logPrint('║$initialIndent{');

    for (var index = 0; index < data.length; index++) {
      final isLast = index == data.length - 1;
      final key = '"${data.keys.elementAt(index)}"';
      dynamic value = data[data.keys.elementAt(index)];
      if (value is String) {
        value = '"${value.toString().replaceAll(RegExp(r'([\r\n])+'), " ")}"';
      }
      if (value is Map) {
        if (compact && _canFlattenMap(value)) {
          logPrint('║${_indent(tabs)} $key: $value${!isLast ? ',' : ''}');
        } else {
          logPrint('║${_indent(tabs)} $key: {');
          _printPrettyMap(value, initialTab: tabs);
        }
      } else if (value is List) {
        if (compact && _canFlattenList(value)) {
          logPrint('║${_indent(tabs)} $key: ${value.toString()}');
        } else {
          logPrint('║${_indent(tabs)} $key: [');
          _printList(value, tabs: tabs);
          logPrint('║${_indent(tabs)} ]${isLast ? '' : ','}');
        }
      } else {
        final msg = value.toString().replaceAll('\n', '');
        final indent = _indent(tabs);
        final linWidth = maxWidth - indent.length;
        if (msg.length + indent.length > linWidth) {
          final lines = (msg.length / linWidth).ceil();
          for (var i = 0; i < lines; ++i) {
            final multilineKey = i == 0 ? "$key:" : "";
            logPrint(
              '║${_indent(tabs)} $multilineKey ${msg.substring(i * linWidth, math.min<int>(i * linWidth + linWidth, msg.length))}',
            );
          }
        } else {
          logPrint('║${_indent(tabs)} $key: $msg${!isLast ? ',' : ''}');
        }
      }
    }

    logPrint('║$initialIndent}${isListItem && !isLast ? ',' : ''}');
  }

  void _printList(List list, {int tabs = kInitialTab}) {
    for (var i = 0; i < list.length; i++) {
      final element = list[i];
      final isLast = i == list.length - 1;
      if (element is Map) {
        if (compact && _canFlattenMap(element)) {
          logPrint('║${_indent(tabs)}  $element${!isLast ? ',' : ''}');
        } else {
          _printPrettyMap(
            element,
            initialTab: tabs + 1,
            isListItem: true,
            isLast: isLast,
          );
        }
      } else {
        logPrint('║${_indent(tabs + 2)} $element${isLast ? '' : ','}');
      }
    }
  }

  void _printUint8List(Uint8List list, {int tabs = kInitialTab}) {
    var chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize > list.length ? list.length : i + chunkSize,
        ),
      );
    }
    for (var element in chunks) {
      logPrint('║${_indent(tabs)} ${element.join(", ")}');
    }
  }

  bool _canFlattenMap(Map map) {
    return map.values
            .where((dynamic val) => val is Map || val is List)
            .isEmpty &&
        map.toString().length < maxWidth;
  }

  bool _canFlattenList(List list) {
    return list.length < 10 && list.toString().length < maxWidth;
  }

  void _printMapAsTable(Map? map, {String? header}) {
    if (map == null || map.isEmpty) return;
    logPrint('╔ $header ');
    for (final entry in map.entries) {
      _printKV(entry.key.toString(), entry.value);
    }
    _printLine('╚');
  }

  /// Convert the current logger state to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'logLevel': logLevel.name,
      'request': request,
      'requestHeader': requestHeader,
      'requestBody': requestBody,
      'responseBody': responseBody,
      'responseHeader': responseHeader,
      'error': error,
      'compact': compact,
      'maxWidth': maxWidth,
      'enabled': enabled,
      'useColors': useColors,
      'structuredOutput': structuredOutput,
    };
  }

  /// Create a NetworkLogger from a JSON map
  factory NetworkLogger.fromJson(Map<String, dynamic> json) {
    return NetworkLogger(
      logLevel: LogLevelType.values.firstWhere(
        (e) => e.name == json['logLevel'],
        orElse: () => LogLevelType.verbose,
      ),
      request: json['request'] ?? true,
      requestHeader: json['requestHeader'] ?? false,
      requestBody: json['requestBody'] ?? false,
      responseBody: json['responseBody'] ?? true,
      responseHeader: json['responseHeader'] ?? false,
      error: json['error'] ?? true,
      compact: json['compact'] ?? true,
      maxWidth: json['maxWidth'] ?? 90,
      enabled: json['enabled'] ?? true,
      useColors: json['useColors'] ?? false,
      structuredOutput: json['structuredOutput'] ?? false,
    );
  }

  /// Create a copy of this logger with optional overrides
  NetworkLogger copyWith({
    LogLevelType? logLevel,
    bool? request,
    bool? requestHeader,
    bool? requestBody,
    bool? responseBody,
    bool? responseHeader,
    bool? error,
    bool? compact,
    int? maxWidth,
    void Function(Object object)? logPrint,
    bool Function(RequestOptions options, FilterArgs args)? filter,
    bool? enabled,
    bool? useColors,
    bool? structuredOutput,
  }) {
    return NetworkLogger(
      logLevel: logLevel ?? this.logLevel,
      request: request ?? this.request,
      requestHeader: requestHeader ?? this.requestHeader,
      requestBody: requestBody ?? this.requestBody,
      responseBody: responseBody ?? this.responseBody,
      responseHeader: responseHeader ?? this.responseHeader,
      error: error ?? this.error,
      compact: compact ?? this.compact,
      maxWidth: maxWidth ?? this.maxWidth,
      logPrint: logPrint ?? this.logPrint,
      filter: filter ?? this.filter,
      enabled: enabled ?? this.enabled,
      useColors: useColors ?? this.useColors,
      structuredOutput: structuredOutput ?? this.structuredOutput,
    );
  }
}

/// Filter arguments for [NetworkLogger.filter]
class FilterArgs {
  /// If the filter is for a request or response
  final bool isResponse;

  /// if the [isResponse] is false, the data is the [RequestOptions.data]
  /// if the [isResponse] is true, the data is the [Response.data]
  final dynamic data;

  /// Returns true if the data is a string
  bool get hasStringData => data is String;

  /// Returns true if the data is a map
  bool get hasMapData => data is Map;

  /// Returns true if the data is a list
  bool get hasListData => data is List;

  /// Returns true if the data is a Uint8List
  bool get hasUint8ListData => data is Uint8List;

  /// Returns true if the data is a json data
  bool get hasJsonData => hasMapData || hasListData;

  /// Default constructor
  const FilterArgs(this.isResponse, this.data);

  @override
  String toString() =>
      'FilterArgs(isResponse: $isResponse, dataType: ${data.runtimeType})';
}
