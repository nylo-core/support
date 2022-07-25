import 'package:nylo_support/router/models/base_arguments.dart';
import 'package:nylo_support/router/models/ny_query_parameters.dart';
import 'package:page_transition/page_transition.dart';

class ArgumentsWrapper {
  BaseArguments? baseArguments;
  NyQueryParameters? queryParameters;
  PageTransitionType? pageTransitionType;
  Duration? transitionDuration;

  ArgumentsWrapper(
      {this.baseArguments,
      this.queryParameters,
      this.transitionDuration,
      this.pageTransitionType});

  ArgumentsWrapper copyWith(
      {BaseArguments? baseArguments,
      NyQueryParameters? queryParameters,
      PageTransitionType? pageTransitionType}) {
    return ArgumentsWrapper(
        baseArguments: baseArguments ?? this.baseArguments,
        queryParameters: queryParameters ?? this.queryParameters,
        transitionDuration: transitionDuration ?? this.transitionDuration,
        pageTransitionType: pageTransitionType ?? this.pageTransitionType);
  }

  @override
  String toString() {
    return 'ArgumentsWrapper{baseArguments: $baseArguments, '
        'transitionDuration: $transitionDuration, '
        'QueryParameters: $queryParameters, '
        'pageTransitionType: $pageTransitionType}';
  }
}
