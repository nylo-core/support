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

  @override
  String toString() {
    return jsonEncode({
      "type": "ArgumentsWrapper",
      'data': baseArguments?.data,
      'queryParameters': queryParameters?.data,
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
      'data': baseArguments?.data,
      'queryParameters': queryParameters?.data,
      'prefix': prefix,
      'pageTransitionType': pageTransitionType?.toString(),
      'transitionType': transitionType?.pageTransitionType?.toString(),
    };
  }
}
