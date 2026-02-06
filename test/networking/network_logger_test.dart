import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/networking/src/interceptors/network_logger.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  // ===========================================================================
  // LogLevelType tests
  // ===========================================================================

  nyGroup('LogLevelType', () {
    nyTest('should have all expected values', () async {
      expect(LogLevelType.values, hasLength(3));
      expect(LogLevelType.values, contains(LogLevelType.verbose));
      expect(LogLevelType.values, contains(LogLevelType.minimal));
      expect(LogLevelType.values, contains(LogLevelType.none));
    });
  });

  // ===========================================================================
  // FilterArgs tests
  // ===========================================================================

  nyGroup('FilterArgs', () {
    nyTest('should create with isResponse and data', () async {
      final args = FilterArgs(true, {'key': 'value'});
      expect(args.isResponse, isTrue);
      expect(args.data, {'key': 'value'});
    });

    nyTest('hasStringData should return true for String', () async {
      final args = FilterArgs(false, 'hello');
      expect(args.hasStringData, isTrue);
      expect(args.hasMapData, isFalse);
    });

    nyTest('hasMapData should return true for Map', () async {
      final args = FilterArgs(false, {'key': 'value'});
      expect(args.hasMapData, isTrue);
      expect(args.hasStringData, isFalse);
    });

    nyTest('hasListData should return true for List', () async {
      final args = FilterArgs(false, [1, 2, 3]);
      expect(args.hasListData, isTrue);
    });

    nyTest('hasUint8ListData should return true for Uint8List', () async {
      final args = FilterArgs(false, Uint8List.fromList([1, 2, 3]));
      expect(args.hasUint8ListData, isTrue);
    });

    nyTest('hasJsonData should return true for Map or List', () async {
      expect(FilterArgs(false, {'k': 'v'}).hasJsonData, isTrue);
      expect(FilterArgs(false, [1]).hasJsonData, isTrue);
      expect(FilterArgs(false, 'str').hasJsonData, isFalse);
    });

    nyTest('toString should include isResponse and dataType', () async {
      final args = FilterArgs(true, 'test');
      expect(args.toString(), contains('isResponse: true'));
      expect(args.toString(), contains('String'));
    });
  });

  // ===========================================================================
  // NetworkLogger constructor tests
  // ===========================================================================

  nyGroup('NetworkLogger constructor', () {
    nyTest('should create with default values', () async {
      final logger = NetworkLogger();
      expect(logger.logLevel, LogLevelType.verbose);
      expect(logger.request, isTrue);
      expect(logger.requestHeader, isTrue);
      expect(logger.requestBody, isTrue);
      expect(logger.responseHeader, isFalse);
      expect(logger.responseBody, isTrue);
      expect(logger.error, isTrue);
      expect(logger.maxWidth, 90);
      expect(logger.compact, isTrue);
      expect(logger.enabled, isTrue);
      expect(logger.useColors, isFalse);
      expect(logger.structuredOutput, isFalse);
    });

    nyTest('should create with custom values', () async {
      final logger = NetworkLogger(
        logLevel: LogLevelType.minimal,
        request: false,
        requestHeader: false,
        requestBody: false,
        responseHeader: true,
        responseBody: false,
        error: false,
        maxWidth: 120,
        compact: false,
        enabled: false,
        useColors: true,
        structuredOutput: true,
      );
      expect(logger.logLevel, LogLevelType.minimal);
      expect(logger.request, isFalse);
      expect(logger.requestHeader, isFalse);
      expect(logger.requestBody, isFalse);
      expect(logger.responseHeader, isTrue);
      expect(logger.responseBody, isFalse);
      expect(logger.error, isFalse);
      expect(logger.maxWidth, 120);
      expect(logger.compact, isFalse);
      expect(logger.enabled, isFalse);
      expect(logger.useColors, isTrue);
      expect(logger.structuredOutput, isTrue);
    });

    nyTest('should accept custom logPrint function', () async {
      final logs = <Object>[];
      final logger = NetworkLogger(logPrint: logs.add);
      expect(logger.logPrint, isNotNull);
    });

    nyTest('should accept filter function', () async {
      final logger = NetworkLogger(
        filter: (options, args) => options.method == 'GET',
      );
      expect(logger.filter, isNotNull);
    });
  });

  // ===========================================================================
  // NetworkLogger.toJson / fromJson tests
  // ===========================================================================

  nyGroup('NetworkLogger serialization', () {
    nyTest('toJson should return correct map', () async {
      final logger = NetworkLogger();
      final json = logger.toJson();
      expect(json['logLevel'], 'verbose');
      expect(json['request'], isTrue);
      expect(json['requestHeader'], isTrue);
      expect(json['requestBody'], isTrue);
      expect(json['responseBody'], isTrue);
      expect(json['responseHeader'], isFalse);
      expect(json['error'], isTrue);
      expect(json['compact'], isTrue);
      expect(json['maxWidth'], 90);
      expect(json['enabled'], isTrue);
      expect(json['useColors'], isFalse);
      expect(json['structuredOutput'], isFalse);
    });

    nyTest('fromJson should create correct instance', () async {
      final json = {
        'logLevel': 'minimal',
        'request': false,
        'requestHeader': false,
        'requestBody': false,
        'responseBody': false,
        'responseHeader': true,
        'error': false,
        'compact': false,
        'maxWidth': 120,
        'enabled': false,
        'useColors': true,
        'structuredOutput': true,
      };
      final logger = NetworkLogger.fromJson(json);
      expect(logger.logLevel, LogLevelType.minimal);
      expect(logger.request, isFalse);
      expect(logger.requestHeader, isFalse);
      expect(logger.requestBody, isFalse);
      expect(logger.responseBody, isFalse);
      expect(logger.responseHeader, isTrue);
      expect(logger.error, isFalse);
      expect(logger.compact, isFalse);
      expect(logger.maxWidth, 120);
      expect(logger.enabled, isFalse);
      expect(logger.useColors, isTrue);
      expect(logger.structuredOutput, isTrue);
    });

    nyTest('fromJson should handle missing fields with defaults', () async {
      final logger = NetworkLogger.fromJson({});
      expect(logger.logLevel, LogLevelType.verbose);
      expect(logger.request, isTrue);
      expect(logger.enabled, isTrue);
    });

    nyTest('round-trip toJson/fromJson should preserve values', () async {
      final original = NetworkLogger(
        logLevel: LogLevelType.minimal,
        maxWidth: 150,
        useColors: true,
      );
      final restored = NetworkLogger.fromJson(original.toJson());
      expect(restored.logLevel, original.logLevel);
      expect(restored.maxWidth, original.maxWidth);
      expect(restored.useColors, original.useColors);
    });
  });

  // ===========================================================================
  // NetworkLogger.copyWith tests
  // ===========================================================================

  nyGroup('NetworkLogger.copyWith', () {
    nyTest('should create copy with no changes', () async {
      final original = NetworkLogger();
      final copy = original.copyWith();
      expect(copy.logLevel, original.logLevel);
      expect(copy.maxWidth, original.maxWidth);
      expect(copy.enabled, original.enabled);
    });

    nyTest('should override specified fields', () async {
      final original = NetworkLogger();
      final copy = original.copyWith(
        logLevel: LogLevelType.none,
        maxWidth: 200,
        enabled: false,
      );
      expect(copy.logLevel, LogLevelType.none);
      expect(copy.maxWidth, 200);
      expect(copy.enabled, isFalse);
      // Unchanged fields
      expect(copy.useColors, original.useColors);
      expect(copy.compact, original.compact);
    });

    nyTest('should preserve filter', () async {
      bool Function(RequestOptions, FilterArgs) myFilter = (opts, args) => true;
      final original = NetworkLogger(filter: myFilter);
      final copy = original.copyWith(maxWidth: 100);
      expect(copy.filter, myFilter);
    });
  });

  // ===========================================================================
  // NetworkLogger interceptor behavior tests
  // ===========================================================================

  nyGroup('NetworkLogger interceptor behavior', () {
    nyTest('should not log when disabled', () async {
      final logs = <Object>[];
      final logger = NetworkLogger(enabled: false, logPrint: logs.add);
      final options = RequestOptions(path: '/test');
      logger.onRequest(options, RequestInterceptorHandler());
      expect(logs, isEmpty);
    });

    nyTest('should not log when logLevel is none', () async {
      final logs = <Object>[];
      final logger = NetworkLogger(
        logLevel: LogLevelType.none,
        logPrint: logs.add,
      );
      final options = RequestOptions(path: '/test');
      logger.onRequest(options, RequestInterceptorHandler());
      expect(logs, isEmpty);
    });

    nyTest('should log request when enabled', () async {
      final logs = <Object>[];
      final logger = NetworkLogger(logPrint: logs.add);
      final options = RequestOptions(path: '/test');
      logger.onRequest(options, RequestInterceptorHandler());
      expect(logs, isNotEmpty);
    });

    nyTest('should add request ID to extras', () async {
      final logger = NetworkLogger(logPrint: (_) {});
      final options = RequestOptions(path: '/test');
      logger.onRequest(options, RequestInterceptorHandler());
      expect(options.extra, contains('_network_logger_request_id_'));
      expect(options.extra, contains('_network_logger_timestamp_'));
    });

    nyTest('should filter requests', () async {
      final logs = <Object>[];
      final logger = NetworkLogger(
        logPrint: logs.add,
        filter: (options, args) => options.method == 'POST',
      );
      final getOptions = RequestOptions(path: '/test', method: 'GET');
      logger.onRequest(getOptions, RequestInterceptorHandler());
      expect(logs, isEmpty);
    });

    nyTest('should log matching filtered requests', () async {
      final logs = <Object>[];
      final logger = NetworkLogger(
        logPrint: logs.add,
        filter: (options, args) => options.method == 'GET',
      );
      final getOptions = RequestOptions(path: '/test', method: 'GET');
      logger.onRequest(getOptions, RequestInterceptorHandler());
      expect(logs, isNotEmpty);
    });

    nyTest('minimal log should include method and URI', () async {
      final logs = <Object>[];
      final logger = NetworkLogger(
        logLevel: LogLevelType.minimal,
        logPrint: logs.add,
      );
      final options = RequestOptions(path: '/api/users', method: 'GET');
      logger.onRequest(options, RequestInterceptorHandler());
      final logStr = logs.join(' ');
      expect(logStr, contains('GET'));
      expect(logStr, contains('/api/users'));
    });

    nyTest('structured output should produce JSON-like output', () async {
      final logs = <Object>[];
      final logger = NetworkLogger(structuredOutput: true, logPrint: logs.add);
      final options = RequestOptions(path: '/test', method: 'POST');
      logger.onRequest(options, RequestInterceptorHandler());
      final logStr = logs.join(' ');
      expect(logStr, contains('[REQUEST]'));
      expect(logStr, contains('POST'));
    });
  });

  // ===========================================================================
  // NetworkLogger response tests
  // ===========================================================================

  nyGroup('NetworkLogger response logging', () {
    nyTest('should log response', () async {
      final logs = <Object>[];
      final logger = NetworkLogger(logPrint: logs.add);
      final requestOptions = RequestOptions(path: '/test');
      requestOptions.extra['_network_logger_request_id_'] = 'test-id';
      requestOptions.extra['_network_logger_timestamp_'] =
          DateTime.timestamp().millisecondsSinceEpoch;

      final response = Response(
        requestOptions: requestOptions,
        statusCode: 200,
        statusMessage: 'OK',
        data: {'message': 'success'},
      );
      logger.onResponse(response, ResponseInterceptorHandler());
      expect(logs, isNotEmpty);
    });

    nyTest('should not log response when disabled', () async {
      final logs = <Object>[];
      final logger = NetworkLogger(enabled: false, logPrint: logs.add);
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 200,
      );
      logger.onResponse(response, ResponseInterceptorHandler());
      expect(logs, isEmpty);
    });
  });

  // ===========================================================================
  // NetworkLogger error tests
  // ===========================================================================

  nyGroup('NetworkLogger error configuration', () {
    nyTest('should have error logging enabled by default', () async {
      final logger = NetworkLogger();
      expect(logger.error, isTrue);
    });

    nyTest('should disable error logging when configured', () async {
      final logger = NetworkLogger(error: false);
      expect(logger.error, isFalse);
    });

    nyTest('is an Interceptor', () async {
      final logger = NetworkLogger();
      expect(logger, isA<Interceptor>());
    });
  });
}
