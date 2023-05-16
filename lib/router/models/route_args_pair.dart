import 'package:nylo_support/router/models/ny_argument.dart';
import 'package:nylo_support/router/models/ny_page_transition_settings.dart';
import 'package:page_transition/page_transition.dart';

class RouteArgsPair {
  final String name;
  final NyArgument? args;
  final PageTransitionType? pageTransition;
  final PageTransitionSettings? pageTransitionSettings;

  RouteArgsPair(this.name,
      {this.args, this.pageTransition, this.pageTransitionSettings});
}
