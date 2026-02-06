import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NyRouterRoute', () {
    nyGroup('constructor', () {
      nyTest('should create route with required parameters', () async {
        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
        );

        expect(route.name, '/test');
        expect(route.getInitialRoute(), isFalse);
        expect(route.getUnknownRoute(), isFalse);
        expect(route.getAuthRoute(), isFalse);
      });

      nyTest('should create route with defaultArgs', () async {
        final defaultArgs = NyArgument({'key': 'value'});

        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
          defaultArgs: defaultArgs,
        );

        expect(route.defaultArgs, defaultArgs);
        expect(route.defaultArgs!.data['key'], 'value');
      });

      nyTest('should create route with queryParameters', () async {
        final queryParams = NyQueryParameters({'sort': 'asc'});

        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
          queryParameters: queryParams,
        );

        expect(route.queryParameters, queryParams);
        expect(route.queryParameters!.data['sort'], 'asc');
      });

      nyTest('should create route with pageTransitionType', () async {
        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
          pageTransitionType: PageTransitionType.fade,
        );

        expect(route.pageTransitionType, PageTransitionType.fade);
      });

      nyTest('should create route with transitionType', () async {
        final transitionType = TransitionType.fade();

        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
          transitionType: transitionType,
        );

        expect(route.getTransitionType, transitionType);
      });

      nyTest('should create initial route', () async {
        final route = NyRouterRoute(
          name: '/home',
          view: (context) => const SizedBox(),
          initialRoute: true,
        );

        expect(route.getInitialRoute(), isTrue);
      });

      nyTest('should create unknown route', () async {
        final route = NyRouterRoute(
          name: '/404',
          view: (context) => const SizedBox(),
          unknownRoute: true,
        );

        expect(route.getUnknownRoute(), isTrue);
      });

      nyTest('should create auth route', () async {
        final route = NyRouterRoute(
          name: '/dashboard',
          view: (context) => const SizedBox(),
          authPage: true,
        );

        expect(route.getAuthRoute(), isTrue);
      });

      nyTest('should create route with route guards', () async {
        final guard = _TestRouteGuard();

        final route = NyRouterRoute(
          name: '/protected',
          view: (context) => const SizedBox(),
          routeGuards: [guard],
        );

        expect(route.getRouteGuards(), contains(guard));
        expect(route.getRouteGuards().length, 1);
      });
    });

    nyGroup('initialRoute()', () {
      nyTest(
        'should set initial route when called without condition',
        () async {
          final route = NyRouterRoute(
            name: '/home',
            view: (context) => const SizedBox(),
          );

          route.initialRoute();

          expect(route.getInitialRoute(), isTrue);
        },
      );

      nyTest('should set initial route when condition is true', () async {
        final route = NyRouterRoute(
          name: '/home',
          view: (context) => const SizedBox(),
        );

        route.initialRoute(when: () => true);

        expect(route.getInitialRoute(), isTrue);
      });

      nyTest('should not set initial route when condition is false', () async {
        final route = NyRouterRoute(
          name: '/home',
          view: (context) => const SizedBox(),
        );

        route.initialRoute(when: () => false);

        expect(route.getInitialRoute(), isFalse);
      });

      nyTest('should return the route for chaining', () async {
        final route = NyRouterRoute(
          name: '/home',
          view: (context) => const SizedBox(),
        );

        final result = route.initialRoute();

        expect(result, same(route));
      });
    });

    nyGroup('authenticatedRoute()', () {
      nyTest('should set auth route when called without condition', () async {
        final route = NyRouterRoute(
          name: '/protected',
          view: (context) => const SizedBox(),
        );

        route.authenticatedRoute();

        expect(route.getAuthRoute(), isTrue);
      });

      nyTest('should set auth route when condition is true', () async {
        final route = NyRouterRoute(
          name: '/protected',
          view: (context) => const SizedBox(),
        );

        route.authenticatedRoute(when: () => true);

        expect(route.getAuthRoute(), isTrue);
      });

      nyTest('should not set auth route when condition is false', () async {
        final route = NyRouterRoute(
          name: '/protected',
          view: (context) => const SizedBox(),
        );

        route.authenticatedRoute(when: () => false);

        expect(route.getAuthRoute(), isFalse);
      });

      nyTest('should return the route for chaining', () async {
        final route = NyRouterRoute(
          name: '/protected',
          view: (context) => const SizedBox(),
        );

        final result = route.authenticatedRoute();

        expect(result, same(route));
      });
    });

    nyGroup('unknownRoute()', () {
      nyTest('should set unknown route flag', () async {
        final route = NyRouterRoute(
          name: '/404',
          view: (context) => const SizedBox(),
        );

        route.unknownRoute();

        expect(route.getUnknownRoute(), isTrue);
      });

      nyTest('should return the route for chaining', () async {
        final route = NyRouterRoute(
          name: '/404',
          view: (context) => const SizedBox(),
        );

        final result = route.unknownRoute();

        expect(result, same(route));
      });
    });

    nyGroup('addRouteGuard()', () {
      nyTest('should add single route guard', () async {
        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
        );
        final guard = _TestRouteGuard();

        route.addRouteGuard(guard);

        expect(route.getRouteGuards(), contains(guard));
        expect(route.getRouteGuards().length, 1);
      });

      nyTest('should add multiple route guards', () async {
        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
        );
        final guard1 = _TestRouteGuard();
        final guard2 = _TestRouteGuard();

        route.addRouteGuard(guard1);
        route.addRouteGuard(guard2);

        expect(route.getRouteGuards().length, 2);
        expect(route.getRouteGuards(), contains(guard1));
        expect(route.getRouteGuards(), contains(guard2));
      });

      nyTest('should return the route for chaining', () async {
        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
        );

        final result = route.addRouteGuard(_TestRouteGuard());

        expect(result, same(route));
      });
    });

    nyGroup('addRouteGuards()', () {
      nyTest('should add list of route guards', () async {
        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
        );
        final guards = [_TestRouteGuard(), _TestRouteGuard()];

        route.addRouteGuards(guards);

        expect(route.getRouteGuards().length, 2);
      });

      nyTest('should add to existing guards', () async {
        final existingGuard = _TestRouteGuard();
        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
          routeGuards: [existingGuard],
        );
        final newGuards = [_TestRouteGuard(), _TestRouteGuard()];

        route.addRouteGuards(newGuards);

        expect(route.getRouteGuards().length, 3);
        expect(route.getRouteGuards(), contains(existingGuard));
      });

      nyTest('should handle empty list', () async {
        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
        );

        route.addRouteGuards([]);

        expect(route.getRouteGuards(), isEmpty);
      });

      nyTest('should return the route for chaining', () async {
        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
        );

        final result = route.addRouteGuards([_TestRouteGuard()]);

        expect(result, same(route));
      });
    });

    nyGroup('addPrefixToName()', () {
      nyTest('should add prefix to route name', () async {
        final route = NyRouterRoute(
          name: '/dashboard',
          view: (context) => const SizedBox(),
        );

        route.addPrefixToName('/admin');

        expect(route.name, '/admin/dashboard');
      });

      nyTest('should handle empty prefix', () async {
        final route = NyRouterRoute(
          name: '/page',
          view: (context) => const SizedBox(),
        );

        route.addPrefixToName('');

        expect(route.name, '/page');
      });

      nyTest('should return the route for chaining', () async {
        final route = NyRouterRoute(
          name: '/page',
          view: (context) => const SizedBox(),
        );

        final result = route.addPrefixToName('/api');

        expect(result, same(route));
      });
    });

    nyGroup('transition()', () {
      nyTest('should set page transition type', () async {
        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
        );

        route.transition(PageTransitionType.fade);

        expect(route.pageTransitionType, PageTransitionType.fade);
      });

      nyTest('should override existing transition', () async {
        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
          pageTransitionType: PageTransitionType.rightToLeft,
        );

        route.transition(PageTransitionType.bottomToTop);

        expect(route.pageTransitionType, PageTransitionType.bottomToTop);
      });

      nyTest('should return the route for chaining', () async {
        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
        );

        final result = route.transition(PageTransitionType.scale);

        expect(result, same(route));
      });
    });

    nyGroup('transitionSettings()', () {
      nyTest('should set page transition settings', () async {
        final settings = const PageTransitionSettings(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
        );

        route.transitionSettings(settings);

        expect(route.pageTransitionSettings, settings);
        expect(
          route.pageTransitionSettings!.duration,
          const Duration(milliseconds: 500),
        );
        expect(route.pageTransitionSettings!.curve, Curves.easeIn);
      });

      nyTest('should return the route for chaining', () async {
        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
        );

        final result = route.transitionSettings(const PageTransitionSettings());

        expect(result, same(route));
      });
    });

    nyGroup('getWhen()', () {
      nyTest('should return true when no when function set', () async {
        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const SizedBox(),
        );

        expect(route.getWhen(), isTrue);
      });

      nyTest(
        'should return result of when function for initialRoute',
        () async {
          var condition = false;
          final route = NyRouterRoute(
            name: '/test',
            view: (context) => const SizedBox(),
          );

          route.initialRoute(when: () => condition);
          expect(route.getWhen(), isFalse);

          condition = true;
          expect(route.getWhen(), isTrue);
        },
      );

      nyTest(
        'should return result of when function for authenticatedRoute',
        () async {
          var condition = true;
          final route = NyRouterRoute(
            name: '/test',
            view: (context) => const SizedBox(),
          );

          route.authenticatedRoute(when: () => condition);
          expect(route.getWhen(), isTrue);

          condition = false;
          expect(route.getWhen(), isFalse);
        },
      );
    });

    nyGroup('builder function', () {
      nyWidgetTest('should build widget from view', (tester) async {
        late BuildContext capturedContext;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox();
              },
            ),
          ),
        );

        final route = NyRouterRoute(
          name: '/test',
          view: (context) => const Text('Test Widget'),
        );

        final widget = route.builder(capturedContext, null, null);

        expect(widget, isA<Text>());
      });
    });
  });
}

class _TestRouteGuard extends RouteGuard {
  @override
  Future<PageRequest?> onRequest(PageRequest pageRequest) async {
    return null;
  }
}
