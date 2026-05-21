import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'extensions.dart';

import '/nylo.dart';
import 'backpack.dart';
import 'helper.dart';

/// Represents a single log entry with metadata.
class NyLogEntry {
  final String message;
  final String? type;
  final DateTime dateTime;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? context;

  NyLogEntry({
    required this.message,
    this.type,
    required this.dateTime,
    this.stackTrace,
    this.context,
  });
}

/// Callback type for log listeners.
typedef NyLogCallback = void Function(NyLogEntry entry);

/// Logger used for messages you want to print to the console.
class NyLogger {
  // Private constants for magic strings
  static const String _showLogKey = 'SHOW_LOG';
  static const String _consoleLogsKey = 'NY_CONSOLE_LOGS';
  static const String _appDebugKey = 'APP_DEBUG';

  // ANSI color codes for terminal output
  static const String _reset = '\x1B[0m';
  static const Map<String, String> _colors = {
    'debug': '\x1B[36m', // Cyan
    'info': '\x1B[34m', // Blue
    'warning': '\x1B[33m', // Yellow
    'error': '\x1B[31m', // Red
    'success': '\x1B[32m', // Green
    'verbose': '\x1B[37m', // White/Gray
    'emergency': '\x1B[41m\x1B[97m', // Bright white text on red background
    'alert': '\x1B[35m', // Magenta
  };

  /// Whether to use colored output in the console.
  /// Defaults to true in debug mode.
  static bool useColors = true;

  /// Optional callback that receives all log entries.
  /// Set this to listen to log updates in real-time.
  ///
  /// Example:
  /// ```dart
  /// NyLogger.onLog = (entry) {
  ///   print('[${entry.type}] ${entry.message}');
  /// };
  /// ```
  static NyLogCallback? onLog;

  /// Interpolates context values into a message string.
  /// Example: _interpolate('User {id} logged in', {'id': '123'}) => 'User 123 logged in'
  static String _interpolate(String message, Map<String, dynamic>? context) {
    if (context == null || context.isEmpty) return message;
    String result = message;
    context.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }

  /// Formats context map as JSON string for console output.
  /// Returns empty string if context is null or empty.
  static String _formatContext(Map<String, dynamic>? context) {
    if (context == null || context.isEmpty) return '';
    return ' ${jsonEncode(context)}';
  }

  /// Logs a debug [message] to the console.
  /// It will only print if your app's environment is in debug mode.
  /// You can override this by setting [alwaysPrint] = true.
  /// Use [context] to interpolate values into the message, e.g. 'User {id}' with {'id': '123'}.
  static void debug(
    dynamic message, {
    Map<String, dynamic>? context,
    bool alwaysPrint = false,
  }) {
    _loggerPrint(message ?? "", 'debug', alwaysPrint, context: context);
  }

  /// Logs an error [message] to the console.
  /// It will only print if your app's environment is in debug mode.
  /// You can override this by setting [alwaysPrint] = true.
  /// Optionally provide a [stackTrace] to include in the output.
  /// Use [context] to interpolate values into the message, e.g. 'User {id}' with {'id': '123'}.
  static void error(
    dynamic message, {
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
    bool alwaysPrint = false,
  }) {
    if (message is Exception) {
      _loggerPrint(
        message.toString(),
        'error',
        alwaysPrint,
        context: context,
        stackTrace: stackTrace,
      );
      return;
    }
    _loggerPrint(
      message,
      'error',
      alwaysPrint,
      context: context,
      stackTrace: stackTrace,
    );
  }

  /// Log an info [message] to the console.
  /// It will only print if your app's environment is in debug mode.
  /// You can override this by setting [alwaysPrint] = true.
  /// Use [context] to interpolate values into the message, e.g. 'User {id}' with {'id': '123'}.
  static void info(
    dynamic message, {
    Map<String, dynamic>? context,
    bool alwaysPrint = false,
  }) {
    _loggerPrint(message ?? "", 'info', alwaysPrint, context: context);
  }

  /// Logs a warning [message] to the console.
  /// It will only print if your app's environment is in debug mode.
  /// You can override this by setting [alwaysPrint] = true.
  /// Use [context] to interpolate values into the message, e.g. 'User {id}' with {'id': '123'}.
  static void warning(
    dynamic message, {
    Map<String, dynamic>? context,
    bool alwaysPrint = false,
  }) {
    _loggerPrint(message ?? "", 'warning', alwaysPrint, context: context);
  }

  /// Logs a success [message] to the console.
  /// It will only print if your app's environment is in debug mode.
  /// You can override this by setting [alwaysPrint] = true.
  /// Use [context] to interpolate values into the message, e.g. 'User {id}' with {'id': '123'}.
  static void success(
    dynamic message, {
    Map<String, dynamic>? context,
    bool alwaysPrint = false,
  }) {
    _loggerPrint(message ?? "", 'success', alwaysPrint, context: context);
  }

  /// Logs a verbose [message] to the console for granular debugging.
  /// It will only print if your app's environment is in debug mode.
  /// You can override this by setting [alwaysPrint] = true.
  /// Use [context] to interpolate values into the message, e.g. 'User {id}' with {'id': '123'}.
  static void verbose(
    dynamic message, {
    Map<String, dynamic>? context,
    bool alwaysPrint = false,
  }) {
    _loggerPrint(message ?? "", 'verbose', alwaysPrint, context: context);
  }

  /// Logs an emergency [message] to the console.
  /// Emergency is the highest severity level for system-wide critical failures.
  /// It will only print if your app's environment is in debug mode.
  /// You can override this by setting [alwaysPrint] = true.
  /// Use [context] to interpolate values into the message, e.g. 'User {id}' with {'id': '123'}.
  static void emergency(
    dynamic message, {
    Map<String, dynamic>? context,
    bool alwaysPrint = false,
  }) {
    _loggerPrint(message ?? "", 'emergency', alwaysPrint, context: context);
  }

  /// Logs an alert [message] to the console.
  /// Alert is for conditions that require immediate attention.
  /// It will only print if your app's environment is in debug mode.
  /// You can override this by setting [alwaysPrint] = true.
  /// Use [context] to interpolate values into the message, e.g. 'User {id}' with {'id': '123'}.
  static void alert(
    dynamic message, {
    Map<String, dynamic>? context,
    bool alwaysPrint = false,
  }) {
    _loggerPrint(message ?? "", 'alert', alwaysPrint, context: context);
  }

  /// Dumps a [message] with a tag.
  static void dump(dynamic message, String? tag, {bool alwaysPrint = false}) {
    _loggerPrint(message ?? "", tag, alwaysPrint);
  }

  /// Dumps a [message] (with optional [tag]) to the console, then exits the app.
  ///
  /// The exit is skipped on web, where `dart:io`'s `exit()` is unavailable and
  /// would throw `UnsupportedError`. On web this behaves like [dump].
  static void dd(dynamic message, String? tag) {
    dump(message, tag);
    if (kIsWeb) return;
    exit(0);
  }

  /// Log json data [message] to the console.
  /// It will only print if your app's environment is in debug mode.
  /// You can override this by setting [alwaysPrint] = true.
  /// Set [prettyPrint] to true for formatted JSON output with indentation.
  static void json(
    dynamic message, {
    bool alwaysPrint = false,
    bool prettyPrint = false,
  }) {
    // Early exit check before any processing
    bool canPrint = (getEnv(_appDebugKey, defaultValue: true));
    if (!canPrint && !alwaysPrint) return;

    try {
      final encoder = prettyPrint
          ? JsonEncoder.withIndent('  ')
          : const JsonEncoder();
      log(encoder.convert(message));
    } on JsonUnsupportedObjectError catch (e) {
      NyLogger.error('Cannot encode to JSON: ${e.cause}');
    } on Exception catch (e) {
      NyLogger.error(e.toString());
    }
  }

  /// Applies ANSI color to a message based on the log type.
  /// ANSI colors are not supported on web (dart:io unavailable).
  static String _colorize(String message, String? type) {
    if (kIsWeb || !useColors || !kDebugMode) return message;
    if (!stdout.supportsAnsiEscapes) return message;
    final color = _colors[type];
    if (color == null) return message;
    return '$color$message$_reset';
  }

  /// Safely formats DateTime, falling back to ISO format if locale not initialized.
  /// This prevents LocaleDataException during early boot before Nylo.init() completes.
  static String _safeFormatDateTime(DateTime dateTime) {
    try {
      return dateTime.toDateTimeString() ?? dateTime.toIso8601String();
    } catch (_) {
      // Fallback when locale data not initialized (during early boot)
      return dateTime.toIso8601String();
    }
  }

  /// Print a new log message
  static void _loggerPrint(
    dynamic message,
    String? type,
    bool alwaysPrint, {
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) {
    final now = DateTime.now();

    // Interpolate context into message
    final interpolatedMessage = _interpolate(message.toString(), context);

    // Always notify listener if set (even in production)
    onLog?.call(
      NyLogEntry(
        message: interpolatedMessage,
        type: type,
        dateTime: now,
        stackTrace: stackTrace,
        context: context,
      ),
    );

    // Check if we should print to console
    bool canPrint = (getEnv(_appDebugKey, defaultValue: true));
    bool showLog = Backpack.instance.read(_showLogKey, defaultValue: false);
    if (!showLog && !canPrint && !alwaysPrint) return;

    if (showLog) {
      backpackSave(_showLogKey, false);
    }

    String nowToDateTime = _safeFormatDateTime(now);
    String contextSuffix = _formatContext(context);
    try {
      String logMessage;
      if (Nylo.instance.shouldShowDateTimeInLogs()) {
        String dateTimeFormatted = "$nowToDateTime";
        logMessage =
            '[$dateTimeFormatted] ${type != null ? "[$type] " : ""}$interpolatedMessage$contextSuffix';
      } else {
        logMessage =
            '${type != null ? "[$type] " : ""}$interpolatedMessage$contextSuffix';
      }

      _logMessage(_colorize(logMessage, type));

      // Print stack trace if provided
      if (stackTrace != null) {
        _logMessage(_colorize(stackTrace.toString(), type));
      }
    } on Exception catch (_) {
      String fallbackMessage =
          '${type != null ? "[$type] " : ""}$interpolatedMessage$contextSuffix';

      Backpack.instance.append(
        _consoleLogsKey,
        {'message': fallbackMessage, 'type': type, 'dateTime': nowToDateTime},
        append: true,
        limit: 100,
      );

      _logMessage(_colorize(fallbackMessage, type));

      // Print stack trace if provided (even in fallback)
      if (stackTrace != null) {
        _logMessage(_colorize(stackTrace.toString(), type));
      }
    }
  }

  /// Log a message to the console.
  static void _logMessage(dynamic message) {
    if (kDebugMode) {
      if (message is String && message.length > 800) {
        log(message);
        return;
      }
      print(message);
    }
  }
}
