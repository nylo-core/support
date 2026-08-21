import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/helpers/src/state_name.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Stands in for a page widget - only its class name matters here.
class StubPage extends StatelessWidget {
  const StubPage({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// A builder declared to return [Widget], as a named function or a variable
/// typed as the [RouteView] signature is. It carries `Widget` as its runtime
/// return type, so the page it builds cannot be read back from the route.
Widget buildStubPage(BuildContext context) => const StubPage();

void main() {
  NyTest.init();

  final RouteView stubPath = ("/stub-page", (_) => const StubPage());

  nyGroup('state names', () {
    nyGroup('nyStateNameForWidget', () {
      nyTest('builds the name from the widget class', () async {
        expect(nyStateNameForWidget('MyPage'), 'Closure: () => _MyPageState');
      });

      nyTest('exposes the signature without the Closure prefix', () async {
        expect(nyStateSignatureForWidget('MyPage'), '() => _MyPageState');
      });
    });

    nyGroup('nyWidgetTypeNameForRoute', () {
      nyTest('reads the widget class the route builds', () async {
        expect(nyWidgetTypeNameForRoute(stubPath), 'StubPage');
      });
    });

    nyGroup('nyStateNameForRoute', () {
      nyTest('builds the name from the route', () async {
        expect(nyStateNameForRoute(stubPath), 'Closure: () => _StubPageState');
      });

      nyTest('matches the name built from the widget instance', () async {
        /// Both ends of a state update read the same class, so a compiler that
        /// renames classes renames both names together.
        expect(
          nyStateNameForRoute(stubPath),
          nyStateNameForWidget(const StubPage().runtimeType.toString()),
        );
      });
    });

    nyGroup('RouteViewExt', () {
      nyTest('stateName() resolves through nyStateNameForRoute', () async {
        expect(stubPath.stateName(), nyStateNameForRoute(stubPath));
      });

      nyTest('nyPageName() drops the Closure prefix', () async {
        expect(stubPath.nyPageName(), '() => _StubPageState');
      });
    });

    nyGroup('nyRouteIdentifiesItsPage', () {
      nyTest('reads the page from a closure that returns it', () async {
        expect(nyRouteIdentifiesItsPage(stubPath), isTrue);
      });

      nyTest('finds no page behind a builder returning Widget', () async {
        final RouteView tearOff = ("/tear-off", buildStubPage);

        expect(nyWidgetTypeNameForRoute(tearOff), 'Widget');
        expect(nyRouteIdentifiesItsPage(tearOff), isFalse);
      });
    });

    nyGroup('a route that names no page', () {
      final List<NyLogEntry> logged = [];

      setUp(() {
        NyEnvRegistry.register(
          getter: (String key, {dynamic defaultValue}) => defaultValue,
          containsKey: (String key) => false,
        );
        Backpack.instance.save("nylo", Nylo());
        logged.clear();
        NyLogger.onLog = logged.add;
      });

      tearDown(() {
        NyLogger.onLog = null;
      });

      nyTest('is reported by nyStateNameForRoute', () async {
        final RouteView tearOff = ("/reported-tear-off", buildStubPage);

        nyStateNameForRoute(tearOff);

        expect(logged, hasLength(1));
        expect(logged.single.type, 'error');
        expect(logged.single.message, contains('"/reported-tear-off"'));
        expect(logged.single.message, contains('stateName:'));
      });

      nyTest('is reported once, however often it is addressed', () async {
        final RouteView tearOff = ("/repeated-tear-off", buildStubPage);

        nyStateNameForRoute(tearOff);
        nyStateNameForRoute(tearOff);
        tearOff.stateName();

        expect(logged, hasLength(1));
      });

      nyTest('leaves a route that names its page unreported', () async {
        nyStateNameForRoute(stubPath);

        expect(logged, isEmpty);
      });
    });
  });
}
