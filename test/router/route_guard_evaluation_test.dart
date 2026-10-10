import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

/// Counts its runs and, when [redirectTo] is set, redirects there.
class _CountingGuard extends RouteGuard {
  _CountingGuard({this.redirectTo});

  final String? redirectTo;
  int runs = 0;

  @override
  Future<PageRequest?> onRequest(PageRequest pageRequest) async {
    runs++;
    if (redirectTo != null) return PageRequest.redirect(redirectTo);
    return null;
  }
}

class _DashboardPage extends NyStatefulWidget {
  _DashboardPage() : super(child: () => _DashboardPageState());
}

class _DashboardPageState extends NyPage<_DashboardPage> {
  @override
  Widget view(BuildContext context) => const Text('Dashboard');
}

void main() {
  NyTest.init();
  NyEnvRegistry.register(getter: (key, {defaultValue}) => defaultValue);

  late NyRouter router;
  late _CountingGuard routeGuard;
  late _CountingGuard controllerGuard;

  /// Registers `/dashboard` with [routeGuard] on the route and
  /// [controllerGuard] declared on the page's controller.
  void registerDashboard() {
    router.route('/dashboard', (context) {
      final page = _DashboardPage();
      page.controller.routeGuards = [controllerGuard];
      return page;
    }, routeGuards: [routeGuard]);
  }

  setUp(() {
    Backpack.instance.save('nylo', Nylo());
    router = NyRouter();
    NyNavigator.instance.router = router;
    NyNavigator.instance.prefixRoutes.clear();
    router.route('/home', (context) => const Text('Home')).initialRoute();
    router.route('/login', (context) => const Text('Login'));
    routeGuard = _CountingGuard();
    controllerGuard = _CountingGuard();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: router.navigatorKey,
        onGenerateRoute: router.generator(),
        initialRoute: '/home',
      ),
    );
    await tester.pumpAndSettle();
  }

  nyWidgetTest('navigate() runs a route guard once', (tester) async {
    router.route(
      '/dashboard',
      (context) => _DashboardPage(),
      routeGuards: [routeGuard],
    );
    await pumpApp(tester);

    router.navigate('/dashboard');
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(routeGuard.runs, 1);
  });

  nyWidgetTest('navigate() still runs guards declared on the controller', (
    tester,
  ) async {
    registerDashboard();
    await pumpApp(tester);

    router.navigate('/dashboard');
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(routeGuard.runs, 1);
    expect(controllerGuard.runs, 1);
  });

  nyWidgetTest('a controller guard redirect blocks the page after navigate()', (
    tester,
  ) async {
    controllerGuard = _CountingGuard(redirectTo: '/login');
    registerDashboard();
    await pumpApp(tester);

    router.navigate('/dashboard');
    await tester.pumpAndSettle();

    expect(controllerGuard.runs, 1);
    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('Login'), findsOneWidget);
  });

  nyWidgetTest('the raw Navigator runs every guard on the page', (
    tester,
  ) async {
    registerDashboard();
    await pumpApp(tester);

    router.navigatorKey!.currentState!.pushNamed('/dashboard');
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(routeGuard.runs, 1);
    expect(controllerGuard.runs, 1);
  });
}
