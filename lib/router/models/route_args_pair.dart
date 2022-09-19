import 'package:nylo_support/router/models/base_arguments.dart';
import 'package:nylo_support/router/models/ny_page_transition_settings.dart';
import 'package:page_transition/page_transition.dart';

class RouteArgsPair {
  final String name;
  final BaseArguments? args;
  final PageTransitionType? pageTransition;
  final PageTransitionSettings? pageTransitionSettings;

  RouteArgsPair(this.name,
      {this.args, this.pageTransition, this.pageTransitionSettings});
}
