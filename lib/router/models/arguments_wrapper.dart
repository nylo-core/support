import '/router/models/ny_argument.dart';
import '/router/models/ny_page_transition_settings.dart';
import '/router/models/ny_query_parameters.dart';
import 'package:page_transition/page_transition.dart';

class ArgumentsWrapper {
  NyArgument? baseArguments;
  NyQueryParameters? queryParameters;
  PageTransitionType? pageTransitionType;
  PageTransitionSettings? pageTransitionSettings;
  String? prefix;

  ArgumentsWrapper(
      {this.baseArguments,
      this.queryParameters,
      this.pageTransitionType,
      this.prefix,
      this.pageTransitionSettings});

  ArgumentsWrapper copyWith(
      {NyArgument? baseArguments,
      NyQueryParameters? queryParameters,
      PageTransitionType? pageTransitionType}) {
    return ArgumentsWrapper(
        baseArguments: baseArguments ?? this.baseArguments,
        queryParameters: queryParameters ?? this.queryParameters,
        pageTransitionSettings:
            pageTransitionSettings ?? this.pageTransitionSettings,
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
