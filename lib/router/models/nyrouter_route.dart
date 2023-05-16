import 'package:nylo_support/controllers/controller.dart';
import 'package:nylo_support/router/models/ny_page_transition_settings.dart';
import 'package:nylo_support/router/models/ny_query_parameters.dart';
import 'package:nylo_support/router/models/nyrouter_route_guard.dart';
import 'package:nylo_support/router/router.dart';
import 'package:nylo_support/widgets/ny_stateful_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:page_transition/page_transition.dart';

import 'ny_argument.dart';

typedef NyRouterRouteBuilder = Widget Function(
  BuildContext context,
  NyArgument? args,
  NyQueryParameters? queryParameters,
);

class NyRouterRoute {
  final String name;
  late NyRouterRouteBuilder builder;
  final NyArgument? defaultArgs;
  final NyQueryParameters? queryParameters;
  final NyRouteView view;
  PageTransitionType pageTransitionType;
  PageTransitionSettings? pageTransitionSettings;
  final bool initialRoute, authPage;

  /// Ran before opening the route itself.
  /// If every route guard returns [true], the route is approved and opened.
  /// Anything else will result in the route being rejected and not open.
  final List<RouteGuard>? routeGuards;

  NyRouterRoute(
      {required this.name,
      required this.view,
      this.defaultArgs,
      this.queryParameters,
      this.routeGuards,
      this.pageTransitionType = PageTransitionType.rightToLeft,
      this.pageTransitionSettings,
      this.initialRoute = false,
      this.authPage = false}) {
    this.builder = (context, arg, queryParameters) {
      Widget widget = view(context);
      if (widget is NyStatefulWidget) {
        if (widget.controller != null) {
          widget.controller!.request = NyRequest(
            currentRoute: name,
            args: arg,
            queryParameters: queryParameters,
          );
          widget.controller!.construct(context);
        }
      }
      return widget;
    };
  }
}
