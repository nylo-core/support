import '/router/models/ny_argument.dart';
import '/router/models/ny_page_transition_settings.dart';
import '/router/models/ny_query_parameters.dart';
import '/router/page_transition/page_transition.dart';

class ArgumentsWrapper {
  NyArgument? baseArguments;
  NyQueryParameters? queryParameters;
  TransitionType? transitionType;
  PageTransitionType? pageTransitionType;
  PageTransitionSettings? pageTransitionSettings;
  String? prefix;

  ArgumentsWrapper(
      {this.baseArguments,
      this.queryParameters,
      this.transitionType,
      this.pageTransitionType,
      this.prefix,
      this.pageTransitionSettings});

  ArgumentsWrapper copyWith(
      {NyArgument? baseArguments,
      NyQueryParameters? queryParameters,
      TransitionType? transitionType,
      PageTransitionType? pageTransitionType}) {
    return ArgumentsWrapper(
        baseArguments: baseArguments ?? this.baseArguments,
        queryParameters: queryParameters ?? this.queryParameters,
        transitionType: transitionType ?? this.transitionType,
        pageTransitionSettings:
            pageTransitionSettings ?? pageTransitionSettings,
        prefix: prefix,
        pageTransitionType: pageTransitionType ?? this.pageTransitionType);
  }

  @override
  String toString() {
    return 'ArgumentsWrapper{baseArguments: $baseArguments, '
        'pageTransitionSettings: $pageTransitionSettings, '
        'QueryParameters: $queryParameters, '
        'prefix: $prefix,'
        'pageTransitionType: $pageTransitionType}';
  }

  /// Get the data from the baseArguments
  dynamic getData() {
    return {
      "data": baseArguments?.data,
      "queryParameters": queryParameters?.data,
      "pageTransitionType": pageTransitionType,
      "pageTransitionSettings": pageTransitionSettings,
      "prefix": prefix
    };
  }
}
