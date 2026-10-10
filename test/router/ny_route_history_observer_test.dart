import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NyRouteHistoryObserver', () {
    late NyRouteHistoryObserver observer;
    late NyRouter router;

    nySetUp(() {
      observer = NyRouteHistoryObserver();
      router = NyRouter();
      NyNavigator.instance.router = router;
    });

    nyTearDown(() {
      // Clear route history after each test
      while (router.getRouteHistory().isNotEmpty) {
        router.removeLastRouteHistory();
      }
    });

    Route<dynamic> createRoute(String name) {
      return MaterialPageRoute(
        builder: (context) => const SizedBox(),
        settings: RouteSettings(name: name),
      );
    }

    nyGroup('didPush()', () {
      nyTest('should add route to history when pushed', () async {
        final Route<dynamic> route = createRoute('/home');

        observer.didPush(route, null);

        expect(router.getRouteHistory().length, 1);
        expect(router.getCurrentRoute(), same(route));
      });

      nyTest('should add multiple routes to history', () async {
        final Route<dynamic> route1 = createRoute('/first');
        final Route<dynamic> route2 = createRoute('/second');
        final Route<dynamic> route3 = createRoute('/third');

        observer.didPush(route1, null);
        observer.didPush(route2, route1);
        observer.didPush(route3, route2);

        expect(router.getRouteHistory().length, 3);
        expect(router.getCurrentRoute()!.settings.name, '/third');
      });

      nyTest('should track previous route parameter', () async {
        final Route<dynamic> route1 = createRoute('/previous');
        final Route<dynamic> route2 = createRoute('/current');

        observer.didPush(route1, null);
        observer.didPush(route2, route1);

        expect(router.getPreviousRoute()!.settings.name, '/previous');
        expect(router.getCurrentRoute()!.settings.name, '/current');
      });
    });

    nyGroup('didPop()', () {
      nyTest('should remove last route from history when popped', () async {
        final Route<dynamic> route1 = createRoute('/first');
        final Route<dynamic> route2 = createRoute('/second');

        observer.didPush(route1, null);
        observer.didPush(route2, route1);
        observer.didPop(route2, route1);

        expect(router.getRouteHistory().length, 1);
        expect(router.getCurrentRoute()!.settings.name, '/first');
      });

      nyTest('should handle pop on single route', () async {
        final Route<dynamic> route = createRoute('/only');

        observer.didPush(route, null);
        observer.didPop(route, null);

        expect(router.getRouteHistory(), isEmpty);
      });

      nyTest('should handle multiple pops', () async {
        final Route<dynamic> route1 = createRoute('/first');
        final Route<dynamic> route2 = createRoute('/second');
        final Route<dynamic> route3 = createRoute('/third');

        observer.didPush(route1, null);
        observer.didPush(route2, route1);
        observer.didPush(route3, route2);

        observer.didPop(route3, route2);
        observer.didPop(route2, route1);

        expect(router.getRouteHistory().length, 1);
        expect(router.getCurrentRoute()!.settings.name, '/first');
      });
    });

    nyGroup('didRemove()', () {
      nyTest('should remove specific route from history', () async {
        final Route<dynamic> route1 = createRoute('/first');
        final Route<dynamic> route2 = createRoute('/second');
        final Route<dynamic> route3 = createRoute('/third');

        observer.didPush(route1, null);
        observer.didPush(route2, route1);
        observer.didPush(route3, route2);

        observer.didRemove(route2, route1);

        expect(router.getRouteHistory().length, 2);
        // route1 and route3 should remain
        expect(
          router.getRouteHistory().any((r) => r.settings.name == '/first'),
          isTrue,
        );
        expect(
          router.getRouteHistory().any((r) => r.settings.name == '/third'),
          isTrue,
        );
        expect(
          router.getRouteHistory().any((r) => r.settings.name == '/second'),
          isFalse,
        );
      });

      nyTest('should handle removing non-existent route gracefully', () async {
        final Route<dynamic> route1 = createRoute('/existing');
        final Route<dynamic> route2 = createRoute('/nonexistent');

        observer.didPush(route1, null);

        // This should not throw
        observer.didRemove(route2, route1);

        expect(router.getRouteHistory().length, 1);
      });
    });

    nyGroup('didReplace()', () {
      nyTest('should replace old route with new route', () async {
        final Route<dynamic> route1 = createRoute('/first');
        final Route<dynamic> route2 = createRoute('/second');
        final Route<dynamic> newRoute = createRoute('/replacement');

        observer.didPush(route1, null);
        observer.didPush(route2, route1);

        observer.didReplace(newRoute: newRoute, oldRoute: route2);

        expect(router.getRouteHistory().length, 2);
        expect(
          router.getRouteHistory().any(
            (r) => r.settings.name == '/replacement',
          ),
          isTrue,
        );
        expect(
          router.getRouteHistory().any((r) => r.settings.name == '/second'),
          isFalse,
        );
      });

      nyTest('should handle null newRoute', () async {
        final Route<dynamic> route = createRoute('/test');

        observer.didPush(route, null);

        // This should not throw
        observer.didReplace(newRoute: null, oldRoute: route);

        // Old route should be removed, but no new route added
        expect(router.getRouteHistory(), isEmpty);
      });

      nyTest('should handle null oldRoute', () async {
        final Route<dynamic> newRoute = createRoute('/new');

        // This should not throw
        observer.didReplace(newRoute: newRoute, oldRoute: null);

        // New route should be added
        expect(router.getRouteHistory().length, 1);
        expect(router.getCurrentRoute()!.settings.name, '/new');
      });

      nyTest('should handle both null', () async {
        // This should not throw
        observer.didReplace(newRoute: null, oldRoute: null);

        expect(router.getRouteHistory(), isEmpty);
      });
    });

    nyGroup('integration scenarios', () {
      nyTest(
        'should maintain correct history for typical navigation flow',
        () async {
          final Route<dynamic> home = createRoute('/home');
          final Route<dynamic> list = createRoute('/list');
          final Route<dynamic> detail = createRoute('/detail');

          // User navigates: home -> list -> detail
          observer.didPush(home, null);
          observer.didPush(list, home);
          observer.didPush(detail, list);

          expect(router.getRouteHistory().length, 3);
          expect(router.getCurrentRoute()!.settings.name, '/detail');

          // User pops back: detail -> list
          observer.didPop(detail, list);

          expect(router.getRouteHistory().length, 2);
          expect(router.getCurrentRoute()!.settings.name, '/list');

          // User pops back: list -> home
          observer.didPop(list, home);

          expect(router.getRouteHistory().length, 1);
          expect(router.getCurrentRoute()!.settings.name, '/home');
        },
      );

      nyTest('should handle pushReplacement scenario', () async {
        final Route<dynamic> login = createRoute('/login');
        final Route<dynamic> home = createRoute('/home');

        // User starts at login
        observer.didPush(login, null);
        expect(router.getRouteHistory().length, 1);

        // Login succeeds, replace with home
        observer.didReplace(newRoute: home, oldRoute: login);

        expect(router.getRouteHistory().length, 1);
        expect(router.getCurrentRoute()!.settings.name, '/home');
      });

      nyTest('should handle pushAndRemoveUntil scenario', () async {
        final Route<dynamic> home = createRoute('/home');
        final Route<dynamic> step1 = createRoute('/step1');
        final Route<dynamic> step2 = createRoute('/step2');
        final Route<dynamic> step3 = createRoute('/step3');
        final Route<dynamic> success = createRoute('/success');

        // Multi-step flow
        observer.didPush(home, null);
        observer.didPush(step1, home);
        observer.didPush(step2, step1);
        observer.didPush(step3, step2);

        expect(router.getRouteHistory().length, 4);

        // Complete flow and clear all steps, push success
        observer.didRemove(step3, step2);
        observer.didRemove(step2, step1);
        observer.didRemove(step1, home);
        observer.didPush(success, home);

        expect(router.getRouteHistory().length, 2);
        expect(
          router.getRouteHistory().any((r) => r.settings.name == '/home'),
          isTrue,
        );
        expect(
          router.getRouteHistory().any((r) => r.settings.name == '/success'),
          isTrue,
        );
      });
    });

    nyGroup('observer is NavigatorObserver', () {
      nyTest('should extend NavigatorObserver', () async {
        expect(observer, isA<NavigatorObserver>());
      });
    });

    nyGroup('external listener (onRouteChange)', () {
      nyTearDown(() {
        // Reset the external listener after each test
        NyRouteHistoryObserver.onRouteChange = null;
      });

      nyTest('should have no external listener by default', () async {
        expect(NyRouteHistoryObserver.hasExternalListener, isFalse);
        expect(NyRouteHistoryObserver.onRouteChange, isNull);
      });

      nyTest(
        'should report hasExternalListener when callback is set',
        () async {
          NyRouteHistoryObserver.onRouteChange =
              (action, routeName, {arguments, previousRoute}) {};

          expect(NyRouteHistoryObserver.hasExternalListener, isTrue);
        },
      );

      nyTest('should notify external listener on push', () async {
        String? capturedAction;
        String? capturedRouteName;
        Object? capturedArguments;
        String? capturedPreviousRoute;

        NyRouteHistoryObserver.onRouteChange =
            (action, routeName, {arguments, previousRoute}) {
              capturedAction = action;
              capturedRouteName = routeName;
              capturedArguments = arguments;
              capturedPreviousRoute = previousRoute;
            };

        final Route<dynamic> previousRoute = createRoute('/previous');
        final MaterialPageRoute<dynamic> route = MaterialPageRoute(
          builder: (context) => const SizedBox(),
          settings: const RouteSettings(
            name: '/current',
            arguments: {'id': 123},
          ),
        );

        observer.didPush(route, previousRoute);

        expect(capturedAction, 'push');
        expect(capturedRouteName, '/current');
        expect(capturedArguments, {'id': 123});
        expect(capturedPreviousRoute, '/previous');
      });

      nyTest('should notify external listener on pop', () async {
        String? capturedAction;
        String? capturedRouteName;
        String? capturedPreviousRoute;

        NyRouteHistoryObserver.onRouteChange =
            (action, routeName, {arguments, previousRoute}) {
              capturedAction = action;
              capturedRouteName = routeName;
              capturedPreviousRoute = previousRoute;
            };

        final Route<dynamic> route1 = createRoute('/first');
        final Route<dynamic> route2 = createRoute('/second');

        observer.didPush(route1, null);
        observer.didPush(route2, route1);
        observer.didPop(route2, route1);

        expect(capturedAction, 'pop');
        expect(capturedRouteName, '/second');
        expect(capturedPreviousRoute, '/first');
      });

      nyTest('should notify external listener on remove', () async {
        String? capturedAction;
        String? capturedRouteName;
        String? capturedPreviousRoute;

        NyRouteHistoryObserver.onRouteChange =
            (action, routeName, {arguments, previousRoute}) {
              capturedAction = action;
              capturedRouteName = routeName;
              capturedPreviousRoute = previousRoute;
            };

        final Route<dynamic> route1 = createRoute('/first');
        final Route<dynamic> route2 = createRoute('/second');

        observer.didPush(route1, null);
        observer.didPush(route2, route1);
        observer.didRemove(route2, route1);

        expect(capturedAction, 'remove');
        expect(capturedRouteName, '/second');
        expect(capturedPreviousRoute, '/first');
      });

      nyTest('should notify external listener on replace', () async {
        String? capturedAction;
        String? capturedRouteName;
        Object? capturedArguments;
        String? capturedPreviousRoute;

        NyRouteHistoryObserver.onRouteChange =
            (action, routeName, {arguments, previousRoute}) {
              capturedAction = action;
              capturedRouteName = routeName;
              capturedArguments = arguments;
              capturedPreviousRoute = previousRoute;
            };

        final Route<dynamic> oldRoute = createRoute('/old');
        final MaterialPageRoute<dynamic> newRoute = MaterialPageRoute(
          builder: (context) => const SizedBox(),
          settings: const RouteSettings(
            name: '/new',
            arguments: {'replaced': true},
          ),
        );

        observer.didPush(oldRoute, null);
        observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);

        expect(capturedAction, 'replace');
        expect(capturedRouteName, '/new');
        expect(capturedArguments, {'replaced': true});
        expect(capturedPreviousRoute, '/old');
      });

      nyTest('should not notify when route name is null on push', () async {
        var listenerCalled = false;

        NyRouteHistoryObserver.onRouteChange =
            (action, routeName, {arguments, previousRoute}) {
              listenerCalled = true;
            };

        final MaterialPageRoute<dynamic> routeWithNullName = MaterialPageRoute(
          builder: (context) => const SizedBox(),
          settings: const RouteSettings(name: null),
        );

        observer.didPush(routeWithNullName, null);

        expect(listenerCalled, isFalse);
      });

      nyTest('should not notify when route name is null on pop', () async {
        var listenerCalled = false;

        NyRouteHistoryObserver.onRouteChange =
            (action, routeName, {arguments, previousRoute}) {
              listenerCalled = true;
            };

        final MaterialPageRoute<dynamic> routeWithNullName = MaterialPageRoute(
          builder: (context) => const SizedBox(),
          settings: const RouteSettings(name: null),
        );

        observer.didPush(routeWithNullName, null);
        listenerCalled = false; // Reset before pop
        observer.didPop(routeWithNullName, null);

        expect(listenerCalled, isFalse);
      });

      nyTest('should track all navigation actions in sequence', () async {
        final List<String> actions = [];

        NyRouteHistoryObserver.onRouteChange =
            (action, routeName, {arguments, previousRoute}) {
              actions.add('$action:$routeName');
            };

        final Route<dynamic> home = createRoute('/home');
        final Route<dynamic> list = createRoute('/list');
        final Route<dynamic> detail = createRoute('/detail');
        final Route<dynamic> edit = createRoute('/edit');

        observer.didPush(home, null);
        observer.didPush(list, home);
        observer.didPush(detail, list);
        observer.didPop(detail, list);
        observer.didReplace(newRoute: edit, oldRoute: list);

        expect(actions, [
          'push:/home',
          'push:/list',
          'push:/detail',
          'pop:/detail',
          'replace:/edit',
        ]);
      });
    });
  });
}
