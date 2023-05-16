import 'package:nylo_support/router/models/ny_argument.dart';
import 'package:nylo_support/router/models/ny_page_transition_settings.dart';
import 'package:nylo_support/router/models/ny_query_parameters.dart';
import 'package:page_transition/page_transition.dart';

class ArgumentsWrapper {
  NyArgument? baseArguments;
  NyQueryParameters? queryParameters;
  PageTransitionType? pageTransitionType;
  PageTransitionSettings? pageTransitionSettings;

  ArgumentsWrapper(
      {this.baseArguments,
      this.queryParameters,
      this.pageTransitionType,
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
        pageTransitionType: pageTransitionType ?? this.pageTransitionType);
  }

  @override
  String toString() {
    return 'ArgumentsWrapper{baseArguments: $baseArguments, '
        'pageTransitionSettings: $pageTransitionSettings, '
        'QueryParameters: $queryParameters, '
        'pageTransitionType: $pageTransitionType}';
  }
}
