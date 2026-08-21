import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/src/state_name.dart';
import 'package:nylo_support/router/ny_router.dart';

/// Stands in for a page widget - only its class name matters here.
class StubPage extends StatelessWidget {
  const StubPage({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// A builder declared to return [Widget], so the route names no page and
/// [nyStateNameForRoute] reaches for the logger.
Widget buildStubPage(BuildContext context) => const StubPage();

/// This file boots nothing on purpose - no Nylo, no env, no [Backpack].
///
/// State names are built from static initializers, e.g.
/// `static NavigationHubStateActions stateActions =
/// NavigationHubStateActions(path.stateName());`, which run before an app
/// registers its env. Building a name has to hold there.
void main() {
  test('a name is built for a route that names no page, unbooted', () {
    final RouteView tearOff = ("/unbooted-tear-off", buildStubPage);

    expect(nyStateNameForRoute(tearOff), 'Closure: () => _WidgetState');
  });

  test('a name is built for a route that names its page, unbooted', () {
    final RouteView stubPath = ("/unbooted-stub", (_) => const StubPage());

    expect(nyStateNameForRoute(stubPath), 'Closure: () => _StubPageState');
  });
}
