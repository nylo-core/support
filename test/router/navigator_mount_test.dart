import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();
  NyEnvRegistry.register(getter: (key, {defaultValue}) => defaultValue);

  late NyRouter router;

  setUp(() {
    Backpack.instance.save('nylo', Nylo());
    router = NyRouter();
    NyNavigator.instance.router = router;
    NyNavigator.instance.prefixRoutes.clear();
    router.route('/home', (context) => const Text('Home')).initialRoute();
    router.route('/login', (context) => const Text('Login'));
  });

  nyWidgetTest('navigate() before the app is built waits for the navigator', (
    tester,
  ) async {
    Object? error;
    router
        .navigate('/login', navigationType: NavigationType.pushAndForgetAll)
        .catchError((Object e) {
          error = e;
          return null;
        });

    await tester.pump(const Duration(milliseconds: 200));
    expect(error, isNull);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: router.navigatorKey,
        onGenerateRoute: router.generator(),
        initialRoute: '/home',
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(error, isNull);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });

  nyWidgetTest('navigate() throws a StateError when no navigator ever mounts', (
    tester,
  ) async {
    Object? error;
    router.navigate('/login').catchError((Object e) {
      error = e;
      return null;
    });

    await tester.pump(
      NyRouter.navigatorMountTimeout - const Duration(seconds: 1),
    );
    expect(error, isNull);

    await tester.pump(const Duration(seconds: 2));
    expect(error, isA<StateError>());
    expect(
      (error as StateError).message,
      contains('Cannot navigate to "/login"'),
    );
  });
}
