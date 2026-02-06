import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/networking/src/interceptors/network_logger.dart';

void main() {
  group('NetworkLogger', () {
    group('constructor and defaults', () {
      test('should have default values', () {
        final logger = NetworkLogger();

        expect(logger.logLevel, LogLevelType.verbose);
        expect(logger.request, true);
        expect(logger.requestHeader, true);
        expect(logger.requestBody, true);
        expect(logger.responseBody, true);
        expect(logger.responseHeader, false);
        expect(logger.error, true);
        expect(logger.compact, true);
        expect(logger.maxWidth, 90);
        expect(logger.enabled, true);
        expect(logger.useColors, false);
        expect(logger.structuredOutput, false);
      });

      test('should accept custom values', () {
        final logger = NetworkLogger(
          logLevel: LogLevelType.minimal,
          request: false,
          requestHeader: true,
          requestBody: true,
          responseBody: false,
          responseHeader: true,
          error: false,
          compact: false,
          maxWidth: 120,
          enabled: false,
          useColors: false,
          structuredOutput: true,
        );

        expect(logger.logLevel, LogLevelType.minimal);
        expect(logger.request, false);
        expect(logger.requestHeader, true);
        expect(logger.requestBody, true);
        expect(logger.responseBody, false);
        expect(logger.responseHeader, true);
        expect(logger.error, false);
        expect(logger.compact, false);
        expect(logger.maxWidth, 120);
        expect(logger.enabled, false);
        expect(logger.useColors, false);
        expect(logger.structuredOutput, true);
      });
    });

    group('LogLevel', () {
      test('should have correct values', () {
        expect(LogLevelType.values, contains(LogLevelType.verbose));
        expect(LogLevelType.values, contains(LogLevelType.minimal));
        expect(LogLevelType.values, contains(LogLevelType.none));
        expect(LogLevelType.values.length, 3);
      });

      test('none level should disable logging', () {
        final logs = <String>[];
        final logger = NetworkLogger(
          logLevel: LogLevelType.none,
          logPrint: (obj) => logs.add(obj.toString()),
        );

        final options = RequestOptions(path: '/test');
        final handler = _MockRequestInterceptorHandler();
        logger.onRequest(options, handler);

        expect(logs, isEmpty);
      });

      test('minimal level should produce single line output', () {
        final logs = <String>[];
        final logger = NetworkLogger(
          logLevel: LogLevelType.minimal,
          useColors: false,
          logPrint: (obj) => logs.add(obj.toString()),
        );

        final options = RequestOptions(path: '/test', method: 'GET');
        final handler = _MockRequestInterceptorHandler();
        logger.onRequest(options, handler);

        expect(logs.length, 1);
        expect(logs.first, contains('[GET]'));
        expect(logs.first, contains('/test'));
        expect(logs.first, contains('ID:'));
      });
    });

    group('color output', () {
      test('should include ANSI codes when useColors is true', () {
        final logs = <String>[];
        final logger = NetworkLogger(
          logLevel: LogLevelType.minimal,
          useColors: true,
          logPrint: (obj) => logs.add(obj.toString()),
        );

        final options = RequestOptions(path: '/test', method: 'GET');
        final handler = _MockRequestInterceptorHandler();
        logger.onRequest(options, handler);

        expect(logs.first, contains('\x1B['));
      });

      test('should not include ANSI codes when useColors is false', () {
        final logs = <String>[];
        final logger = NetworkLogger(
          logLevel: LogLevelType.minimal,
          useColors: false,
          logPrint: (obj) => logs.add(obj.toString()),
        );

        final options = RequestOptions(path: '/test', method: 'GET');
        final handler = _MockRequestInterceptorHandler();
        logger.onRequest(options, handler);

        expect(logs.first.contains('\x1B['), false);
      });
    });

    group('structured output', () {
      test('should output JSON format when structuredOutput is true', () {
        final logs = <String>[];
        final logger = NetworkLogger(
          logLevel: LogLevelType.verbose,
          structuredOutput: true,
          useColors: false,
          logPrint: (obj) => logs.add(obj.toString()),
        );

        final options = RequestOptions(path: '/test', method: 'POST');
        final handler = _MockRequestInterceptorHandler();
        logger.onRequest(options, handler);

        expect(logs.first, contains('[REQUEST]'));
        expect(logs.first, contains('"type": "request"'));
        expect(logs.first, contains('"method": "POST"'));
        expect(logs.first, contains('"requestId"'));
      });
    });

    group('request ID tracking', () {
      test('should add unique request ID to options.extra', () {
        final logger = NetworkLogger(
          logLevel: LogLevelType.none, // Disable output for cleaner test
        );

        final options1 = RequestOptions(path: '/test1');
        final options2 = RequestOptions(path: '/test2');
        final handler = _MockRequestInterceptorHandler();

        logger.onRequest(options1, handler);
        logger.onRequest(options2, handler);

        final requestId1 = options1.extra['_network_logger_request_id_'];
        final requestId2 = options2.extra['_network_logger_request_id_'];

        expect(requestId1, isNotNull);
        expect(requestId2, isNotNull);
        expect(requestId1, isNot(equals(requestId2)));
        expect(requestId1.length, 8); // UUID first 8 chars
      });

      test('should include request ID in response logging', () {
        final logs = <String>[];
        final logger = NetworkLogger(
          logLevel: LogLevelType.minimal,
          useColors: false,
          logPrint: (obj) => logs.add(obj.toString()),
        );

        final options = RequestOptions(path: '/test');
        options.extra['_network_logger_request_id_'] = 'test1234';
        options.extra['_network_logger_timestamp_'] =
            DateTime.timestamp().millisecondsSinceEpoch;

        final response = Response(
          requestOptions: options,
          statusCode: 200,
          statusMessage: 'OK',
        );
        final handler = _MockResponseInterceptorHandler();
        logger.onResponse(response, handler);

        expect(logs.first, contains('test1234'));
      });

      test('should include request ID in error logging', () {
        final logs = <String>[];
        final logger = NetworkLogger(
          logLevel: LogLevelType.minimal,
          useColors: false,
          logPrint: (obj) => logs.add(obj.toString()),
        );

        final options = RequestOptions(path: '/test');
        options.extra['_network_logger_request_id_'] = 'err12345';
        options.extra['_network_logger_timestamp_'] =
            DateTime.timestamp().millisecondsSinceEpoch;

        final error = DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timeout',
        );
        final handler = _MockErrorInterceptorHandler();
        logger.onError(error, handler);

        expect(logs.first, contains('err12345'));
      });
    });

    group('filter', () {
      test('should skip logging when filter returns false', () {
        final logs = <String>[];
        final logger = NetworkLogger(
          logLevel: LogLevelType.verbose,
          useColors: false,
          logPrint: (obj) => logs.add(obj.toString()),
          filter: (options, args) => false,
        );

        final options = RequestOptions(path: '/test');
        final handler = _MockRequestInterceptorHandler();
        logger.onRequest(options, handler);

        expect(logs, isEmpty);
      });

      test('should log when filter returns true', () {
        final logs = <String>[];
        final logger = NetworkLogger(
          logLevel: LogLevelType.minimal,
          useColors: false,
          logPrint: (obj) => logs.add(obj.toString()),
          filter: (options, args) => true,
        );

        final options = RequestOptions(path: '/test');
        final handler = _MockRequestInterceptorHandler();
        logger.onRequest(options, handler);

        expect(logs, isNotEmpty);
      });

      test('should pass correct FilterArgs for request', () {
        FilterArgs? capturedArgs;
        final logger = NetworkLogger(
          logLevel: LogLevelType.minimal,
          logPrint: (_) {}, // Suppress output
          filter: (options, args) {
            capturedArgs = args;
            return false;
          },
        );

        final options = RequestOptions(path: '/test', data: {'key': 'value'});
        final handler = _MockRequestInterceptorHandler();
        logger.onRequest(options, handler);

        expect(capturedArgs, isNotNull);
        expect(capturedArgs!.isResponse, false);
        expect(capturedArgs!.data, {'key': 'value'});
      });

      test('should pass correct FilterArgs for response', () {
        FilterArgs? capturedArgs;
        final logger = NetworkLogger(
          logLevel: LogLevelType.minimal,
          logPrint: (_) {}, // Suppress output
          filter: (options, args) {
            capturedArgs = args;
            return false;
          },
        );

        final options = RequestOptions(path: '/test');
        final response = Response(
          requestOptions: options,
          statusCode: 200,
          data: {'result': 'success'},
        );
        final handler = _MockResponseInterceptorHandler();
        logger.onResponse(response, handler);

        expect(capturedArgs, isNotNull);
        expect(capturedArgs!.isResponse, true);
        expect(capturedArgs!.data, {'result': 'success'});
      });
    });

    group('toJson and fromJson', () {
      test('toJson should return correct map', () {
        final logger = NetworkLogger(
          logLevel: LogLevelType.minimal,
          request: false,
          requestHeader: true,
          useColors: false,
          structuredOutput: true,
        );

        final json = logger.toJson();

        expect(json['logLevel'], 'minimal');
        expect(json['request'], false);
        expect(json['requestHeader'], true);
        expect(json['useColors'], false);
        expect(json['structuredOutput'], true);
      });

      test('fromJson should create correct logger', () {
        final json = {
          'logLevel': 'minimal',
          'request': false,
          'requestHeader': true,
          'useColors': false,
          'structuredOutput': true,
          'maxWidth': 120,
        };

        final logger = NetworkLogger.fromJson(json);

        expect(logger.logLevel, LogLevelType.minimal);
        expect(logger.request, false);
        expect(logger.requestHeader, true);
        expect(logger.useColors, false);
        expect(logger.structuredOutput, true);
        expect(logger.maxWidth, 120);
      });

      test('fromJson should use defaults for missing values', () {
        final logger = NetworkLogger.fromJson({});

        expect(logger.logLevel, LogLevelType.verbose);
        expect(logger.request, true);
        expect(logger.useColors, false);
      });
    });

    group('copyWith', () {
      test('should create copy with overridden values', () {
        final original = NetworkLogger(
          logLevel: LogLevelType.verbose,
          useColors: true,
          structuredOutput: false,
        );

        final copy = original.copyWith(
          logLevel: LogLevelType.minimal,
          structuredOutput: true,
        );

        expect(copy.logLevel, LogLevelType.minimal);
        expect(copy.useColors, true); // Unchanged
        expect(copy.structuredOutput, true);
      });

      test('should preserve original values when not overridden', () {
        final original = NetworkLogger(
          logLevel: LogLevelType.minimal,
          useColors: false,
          maxWidth: 120,
        );

        final copy = original.copyWith();

        expect(copy.logLevel, LogLevelType.minimal);
        expect(copy.useColors, false);
        expect(copy.maxWidth, 120);
      });
    });

    group('enabled flag', () {
      test('should not log when enabled is false', () {
        final logs = <String>[];
        final logger = NetworkLogger(
          enabled: false,
          logPrint: (obj) => logs.add(obj.toString()),
        );

        final options = RequestOptions(path: '/test');
        final handler = _MockRequestInterceptorHandler();
        logger.onRequest(options, handler);

        expect(logs, isEmpty);
      });
    });
  });

  group('FilterArgs', () {
    test('hasStringData returns true for string data', () {
      final args = FilterArgs(false, 'test string');
      expect(args.hasStringData, true);
      expect(args.hasMapData, false);
      expect(args.hasListData, false);
    });

    test('hasMapData returns true for map data', () {
      final args = FilterArgs(true, {'key': 'value'});
      expect(args.hasMapData, true);
      expect(args.hasStringData, false);
      expect(args.hasListData, false);
    });

    test('hasListData returns true for list data', () {
      final args = FilterArgs(false, [1, 2, 3]);
      expect(args.hasListData, true);
      expect(args.hasMapData, false);
      expect(args.hasStringData, false);
    });

    test('hasUint8ListData returns true for Uint8List data', () {
      final args = FilterArgs(true, Uint8List.fromList([1, 2, 3]));
      expect(args.hasUint8ListData, true);
    });

    test('hasJsonData returns true for map or list data', () {
      expect(FilterArgs(false, {'key': 'value'}).hasJsonData, true);
      expect(FilterArgs(false, [1, 2, 3]).hasJsonData, true);
      expect(FilterArgs(false, 'string').hasJsonData, false);
    });

    test('toString returns readable representation', () {
      final args = FilterArgs(true, {'key': 'value'});
      expect(args.toString(), contains('FilterArgs'));
      expect(args.toString(), contains('isResponse: true'));
    });
  });
}

// Mock handlers for testing
class _MockRequestInterceptorHandler extends RequestInterceptorHandler {
  @override
  void next(RequestOptions requestOptions) {}

  @override
  void reject(
    DioException error, [
    bool callFollowingErrorInterceptor = false,
  ]) {}

  @override
  void resolve(
    Response response, [
    bool callFollowingResponseInterceptor = false,
  ]) {}
}

class _MockResponseInterceptorHandler extends ResponseInterceptorHandler {
  @override
  void next(Response response) {}

  @override
  void reject(
    DioException error, [
    bool callFollowingErrorInterceptor = false,
  ]) {}

  @override
  void resolve(
    Response response, [
    bool callFollowingResponseInterceptor = false,
  ]) {}
}

class _MockErrorInterceptorHandler extends ErrorInterceptorHandler {
  @override
  void next(DioException error) {}

  @override
  void reject(DioException error) {}

  @override
  void resolve(Response response) {}
}
