import 'dart:convert';

import 'ny_argument.dart';
import 'ny_page_transition_settings.dart';
import 'ny_query_parameters.dart';
import '../page_transition/page_transition.dart';

class ArgumentsWrapper {
  NyArgument? baseArguments;
  NyQueryParameters? queryParameters;
  TransitionType? transitionType;
  PageTransitionType? pageTransitionType;
  PageTransitionSettings? pageTransitionSettings;
  String? prefix;

  ArgumentsWrapper({
    this.baseArguments,
    this.queryParameters,
    this.transitionType,
    this.pageTransitionType,
    this.prefix,
    this.pageTransitionSettings,
  });

  ArgumentsWrapper copyWith({
    NyArgument? baseArguments,
    NyQueryParameters? queryParameters,
    TransitionType? transitionType,
    PageTransitionType? pageTransitionType,
  }) {
    return ArgumentsWrapper(
      baseArguments: baseArguments ?? this.baseArguments,
      queryParameters: queryParameters ?? this.queryParameters,
      transitionType: transitionType ?? this.transitionType,
      pageTransitionSettings: pageTransitionSettings ?? pageTransitionSettings,
      prefix: prefix,
      pageTransitionType: pageTransitionType ?? this.pageTransitionType,
    );
  }

  /// Safely converts [value] for JSON encoding.
  /// Returns the value as-is if it's a primitive type, otherwise falls back
  /// to [toString()] so that non-serializable route data (e.g. model instances,
  /// enums) won't crash [jsonEncode].
  static dynamic _safeEncode(dynamic value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    if (value is List) {
      return value.map(_safeEncode).toList();
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _safeEncode(v)));
    }
    try {
      return jsonDecode(jsonEncode(value));
    } catch (_) {
      return value.toString();
    }
  }

  @override
  String toString() {
    return jsonEncode({
      "type": "ArgumentsWrapper",
      'data': _safeEncode(baseArguments?.data),
      'queryParameters': _safeEncode(queryParameters?.data),
      'pageTransitionType': pageTransitionType?.toString(),
      'prefix': prefix,
    });
  }

  /// Get the data from the baseArguments
  dynamic getData() {
    return {
      "data": baseArguments?.data,
      "queryParameters": queryParameters?.data,
      "pageTransitionType": pageTransitionType,
      "pageTransitionSettings": pageTransitionSettings,
      "prefix": prefix,
    };
  }

  /// Converts to a serializable map for external consumers (e.g., error_stack)
  Map<String, dynamic> toMap() {
    return {
      'type': 'ArgumentsWrapper',
      'data': _safeEncode(baseArguments?.data),
      'queryParameters': _safeEncode(queryParameters?.data),
      'prefix': prefix,
      'pageTransitionType': pageTransitionType?.toString(),
      'transitionType': transitionType?.pageTransitionType?.toString(),
    };
  }

  /// Converts to a JSON-serializable map.
  /// Required by Flutter's [NavigatorState] which calls [jsonEncode] on route
  /// arguments during state restoration and post-navigation logging.
  Map<String, dynamic> toJson() => toMap();
}
