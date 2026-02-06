import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NyRouter', () {
    late NyRouter router;

    nySetUp(() {
      router = NyRouter();
      // Reset NyNavigator instance router for each test
      NyNavigator.instance.router = router;
      NyNavigator.instance.prefixRoutes.clear();
    });

    nyGroup('constructor', () {
      nyTest('should create with default options', () async {
        final router = NyRouter();

        expect(router.options, isA<NyRouterOptions>());
        expect(router.options.handleNameNotFoundUI, isFalse);
        expect(router.options.isLoggingEnabled, isFalse);
      });

      nyTest('should create with custom options', () async {
        final options = NyRouterOptions(
          handleNameNotFoundUI: true,
          isLoggingEnabled: true,
        );
        final router = NyRouter(options: options);

        expect(router.options.handleNameNotFoundUI, isTrue);
        expect(router.options.isLoggingEnabled, isTrue);
      });

      nyTest('should create navigator key if not provided', () async {
        final router = NyRouter();

        expect(router.navigatorKey, isNotNull);
        expect(router.navigatorKey, isA<GlobalKey<NavigatorState>>());
      });

      nyTest('should use provided navigator key', () async {
        final customKey = GlobalKey<NavigatorState>();
        final options = NyRouterOptions(navigatorKey: customKey);
        final router = NyRouter(options: options);

        expect(router.navigatorKey, same(customKey));
      });
    });

    nyGroup('route()', () {
      nyTest('should add route with name and view', () async {
        router.route('/home', (context) => const SizedBox());

        expect(router.getRegisteredRouteNames(), contains('/home'));
      });

      nyTest('should return NyRouterRoute for chaining', () async {
        final result = router.route('/test', (context) => const SizedBox());

        expect(result, isA<NyRouterRoute>());
        expect(result.name, '/test');
      });

      nyTest('should add route with transition type', () async {
        final transitionType = TransitionType.fade();

        final result = router.route(
          '/animated',
          (context) => const SizedBox(),
          transitionType: transitionType,
        );

        expect(result.getTransitionType, transitionType);
      });

      nyTest('should add route with route guards', () async {
        final guard = _TestRouteGuard();

        final result = router.route(
          '/protected',
          (context) => const SizedBox(),
          routeGuards: [guard],
        );

        expect(result.getRouteGuards(), contains(guard));
      });

      nyTest('should add initial route', () async {
        final result = router.route(
          '/home',
          (context) => const SizedBox(),
          initialRoute: true,
        );

        expect(result.getInitialRoute(), isTrue);
      });

      nyTest('should add unknown route', () async {
        final result = router.route(
          '/404',
          (context) => const SizedBox(),
          unknownRoute: true,
        );

        expect(result.getUnknownRoute(), isTrue);
        expect(router.getUnknownRoutes(), isNotEmpty);
      });

      nyTest('should add authenticated route', () async {
        final result = router.route(
          '/dashboard',
          (context) => const SizedBox(),
          authenticatedRoute: true,
        );

        expect(result.getAuthRoute(), isTrue);
      });
    });

    nyGroup('add()', () {
      nyTest('should add route using RouteView tuple', () async {
        final routeView = ('/home', (BuildContext context) => const SizedBox());

        router.add(routeView);

        expect(router.getRegisteredRouteNames(), contains('/home'));
      });

      nyTest('should return NyRouterRoute for chaining', () async {
        final routeView = ('/test', (BuildContext context) => const SizedBox());

        final result = router.add(routeView);

        expect(result, isA<NyRouterRoute>());
        expect(result.name, '/test');
      });

      nyTest('should add with all options', () async {
        final guard = _TestRouteGuard();
        final routeView = (
          '/protected',
          (BuildContext context) => const SizedBox(),
        );

        final result = router.add(
          routeView,
          routeGuards: [guard],
          initialRoute: true,
          authenticatedRoute: true,
        );

        expect(result.getRouteGuards(), contains(guard));
        expect(result.getInitialRoute(), isTrue);
        expect(result.getAuthRoute(), isTrue);
      });
    });

    nyGroup('addRoutes()', () {
      nyTest('should add multiple routes', () async {
        final routes = [
          NyRouterRoute(name: '/route1', view: (context) => const SizedBox()),
          NyRouterRoute(name: '/route2', view: (context) => const SizedBox()),
          NyRouterRoute(name: '/route3', view: (context) => const SizedBox()),
        ];

        router.addRoutes(routes);

        expect(
          router.getRegisteredRouteNames(),
          containsAll(['/route1', '/route2', '/route3']),
        );
      });

      nyTest('should handle empty list', () async {
        final countBefore = router.getRegisteredRouteNames().length;

        router.addRoutes([]);

        expect(router.getRegisteredRouteNames().length, countBefore);
      });
    });

    nyGroup('updateRoute()', () {
      nyTest('should update existing route', () async {
        router.route('/test', (context) => const SizedBox());

        final updatedRoute = NyRouterRoute(
          name: '/test',
          view: (context) => const Text('Updated'),
          initialRoute: true,
        );

        router.updateRoute(updatedRoute);

        expect(
          router.getRegisteredRoutes()['/test']!.getInitialRoute(),
          isTrue,
        );
      });

      nyTest('should add route if it does not exist', () async {
        final newRoute = NyRouterRoute(
          name: '/new',
          view: (context) => const SizedBox(),
        );

        router.updateRoute(newRoute);

        expect(router.getRegisteredRouteNames(), contains('/new'));
      });
    });

    nyGroup('getRegisteredRouteNames()', () {
      nyTest('should return empty list for new router', () async {
        final newRouter = NyRouter();

        expect(newRouter.getRegisteredRouteNames(), isEmpty);
      });

      nyTest('should return list of route names', () async {
        router.route('/home', (context) => const SizedBox());
        router.route('/about', (context) => const SizedBox());
        router.route('/contact', (context) => const SizedBox());

        final names = router.getRegisteredRouteNames();

        expect(names.length, 3);
        expect(names, containsAll(['/home', '/about', '/contact']));
      });
    });

    nyGroup('getRegisteredRoutes()', () {
      nyTest('should return map of route name to route', () async {
        router.route('/test', (context) => const SizedBox());

        final routes = router.getRegisteredRoutes();

        expect(routes, isA<Map<String, NyRouterRoute>>());
        expect(routes['/test'], isNotNull);
        expect(routes['/test']!.name, '/test');
      });
    });

    nyGroup('routeNameMappingsContains()', () {
      nyTest('should return true for existing route', () async {
        router.route('/exists', (context) => const SizedBox());

        expect(router.routeNameMappingsContains('/exists'), isTrue);
      });

      nyTest('should return false for non-existing route', () async {
        expect(router.routeNameMappingsContains('/nonexistent'), isFalse);
      });

      nyTest('should return true for parameterized route match', () async {
        router.route('/users/{id}', (context) => const SizedBox());

        expect(router.routeNameMappingsContains('/users/123'), isTrue);
      });
    });

    nyGroup('isRouteNamedArg()', () {
      nyTest('should return false for exact route match', () async {
        router.route('/users', (context) => const SizedBox());

        expect(router.isRouteNamedArg('/users'), isFalse);
      });

      nyTest('should return true for parameterized route', () async {
        router.route('/users/{id}', (context) => const SizedBox());

        expect(router.isRouteNamedArg('/users/42'), isTrue);
      });

      nyTest('should return false for non-matching route', () async {
        router.route('/users', (context) => const SizedBox());

        expect(router.isRouteNamedArg('/posts'), isFalse);
      });
    });

    nyGroup('containsRoutes()', () {
      nyTest('should return true when all routes exist', () async {
        router.route('/home', (context) => const SizedBox());
        router.route('/about', (context) => const SizedBox());

        expect(router.containsRoutes(['/home', '/about']), isTrue);
      });

      nyTest('should return false when any route is missing', () async {
        router.route('/home', (context) => const SizedBox());

        expect(router.containsRoutes(['/home', '/missing']), isFalse);
      });

      nyTest('should return true for empty list', () async {
        expect(router.containsRoutes([]), isTrue);
      });
    });

    nyGroup('group()', () {
      nyTest('should add routes with shared prefix', () async {
        // The group() function stores prefix in NyNavigator.instance.prefixRoutes
        // Routes are stored with original keys, prefix is stored separately
        router.group(
          () {
            return {'prefix': '/api'};
          },
          (r) {
            r.route('/users', (context) => const SizedBox());
            r.route('/posts', (context) => const SizedBox());
          },
        );

        // Routes are stored with their original keys
        expect(
          router.getRegisteredRouteNames(),
          containsAll(['/users', '/posts']),
        );
        // Prefix is stored separately in NyNavigator
        expect(NyNavigator.instance.prefixRoutes['/users'], '/api');
        expect(NyNavigator.instance.prefixRoutes['/posts'], '/api');
      });

      nyTest('should add routes with shared route guards', () async {
        final guard = _TestRouteGuard();

        router.group(
          () {
            return {
              'route_guards': [guard],
            };
          },
          (r) {
            r.route('/protected1', (context) => const SizedBox());
            r.route('/protected2', (context) => const SizedBox());
          },
        );

        final routes = router.getRegisteredRoutes();
        expect(routes['/protected1']!.getRouteGuards(), contains(guard));
        expect(routes['/protected2']!.getRouteGuards(), contains(guard));
      });

      nyTest('should add routes with shared transition type', () async {
        final transitionType = TransitionType.fade();

        router.group(
          () {
            return {'transition_type': transitionType};
          },
          (r) {
            r.route('/animated1', (context) => const SizedBox());
            r.route('/animated2', (context) => const SizedBox());
          },
        );

        final routes = router.getRegisteredRoutes();
        expect(
          routes['/animated1']!.pageTransitionType,
          PageTransitionType.fade,
        );
        expect(
          routes['/animated2']!.pageTransitionType,
          PageTransitionType.fade,
        );
      });

      nyTest('should combine prefix and guards', () async {
        final guard = _TestRouteGuard();

        router.group(
          () {
            return {
              'prefix': '/admin',
              'route_guards': [guard],
            };
          },
          (r) {
            r.route('/dashboard', (context) => const SizedBox());
          },
        );

        // Route is stored with original key, prefix stored separately
        expect(router.getRegisteredRouteNames(), contains('/dashboard'));
        expect(NyNavigator.instance.prefixRoutes['/dashboard'], '/admin');
        expect(
          router.getRegisteredRoutes()['/dashboard']!.getRouteGuards(),
          contains(guard),
        );
      });
    });

    nyGroup('getInitialRouteName()', () {
      nyTest('should return "/" when no initial route set', () async {
        router.route('/home', (context) => const SizedBox());
        NyNavigator.instance.router = router;

        expect(router.getInitialRouteName(), '/');
      });

      nyTest('should return initial route name when set', () async {
        router.route(
          '/home',
          (context) => const SizedBox(),
          initialRoute: true,
        );
        NyNavigator.instance.router = router;

        expect(router.getInitialRouteName(), '/home');
      });
    });

    nyGroup('getUnknownRouteName()', () {
      nyTest('should return "/" when no unknown route set', () async {
        router.route('/home', (context) => const SizedBox());
        NyNavigator.instance.router = router;

        expect(router.getUnknownRouteName(), '/');
      });

      nyTest('should return unknown route name when set', () async {
        router.route('/404', (context) => const SizedBox(), unknownRoute: true);
        NyNavigator.instance.router = router;

        expect(router.getUnknownRouteName(), '/404');
      });
    });

    nyGroup('route history', () {
      nyTest('should start with empty history', () async {
        expect(router.getRouteHistory(), isEmpty);
      });

      nyTest('should add route to history', () async {
        final route = MaterialPageRoute(
          builder: (context) => const SizedBox(),
          settings: const RouteSettings(name: '/test'),
        );

        router.addRouteHistory(route);

        expect(router.getRouteHistory().length, 1);
        expect(router.getCurrentRoute(), same(route));
      });

      nyTest('should remove route from history', () async {
        final route = MaterialPageRoute(
          builder: (context) => const SizedBox(),
          settings: const RouteSettings(name: '/test'),
        );

        router.addRouteHistory(route);
        router.removeRouteHistory(route);

        expect(router.getRouteHistory(), isEmpty);
      });

      nyTest('should remove last route from history', () async {
        final route1 = MaterialPageRoute(
          builder: (context) => const SizedBox(),
          settings: const RouteSettings(name: '/first'),
        );
        final route2 = MaterialPageRoute(
          builder: (context) => const SizedBox(),
          settings: const RouteSettings(name: '/second'),
        );

        router.addRouteHistory(route1);
        router.addRouteHistory(route2);
        router.removeLastRouteHistory();

        expect(router.getRouteHistory().length, 1);
        expect(router.getCurrentRoute(), same(route1));
      });

      nyTest('should return current route', () async {
        final route1 = MaterialPageRoute(
          builder: (context) => const SizedBox(),
          settings: const RouteSettings(name: '/first'),
        );
        final route2 = MaterialPageRoute(
          builder: (context) => const SizedBox(),
          settings: const RouteSettings(name: '/second'),
        );

        router.addRouteHistory(route1);
        router.addRouteHistory(route2);

        expect(router.getCurrentRoute()!.settings.name, '/second');
      });

      nyTest(
        'should return null for current route when history is empty',
        () async {
          expect(router.getCurrentRoute(), isNull);
        },
      );

      nyTest('should return previous route', () async {
        final route1 = MaterialPageRoute(
          builder: (context) => const SizedBox(),
          settings: const RouteSettings(name: '/first'),
        );
        final route2 = MaterialPageRoute(
          builder: (context) => const SizedBox(),
          settings: const RouteSettings(name: '/second'),
        );

        router.addRouteHistory(route1);
        router.addRouteHistory(route2);

        expect(router.getPreviousRoute()!.settings.name, '/first');
      });

      nyTest(
        'should return null for previous route when only one route exists',
        () async {
          final route = MaterialPageRoute(
            builder: (context) => const SizedBox(),
            settings: const RouteSettings(name: '/only'),
          );

          router.addRouteHistory(route);

          expect(router.getPreviousRoute(), isNull);
        },
      );

      nyTest(
        'should return null for previous route when history is empty',
        () async {
          expect(router.getPreviousRoute(), isNull);
        },
      );
    });

    nyGroup('setRegisteredRoutes()', () {
      nyTest('should add routes from map', () async {
        final routes = {
          '/route1': NyRouterRoute(
            name: '/route1',
            view: (context) => const SizedBox(),
          ),
          '/route2': NyRouterRoute(
            name: '/route2',
            view: (context) => const SizedBox(),
          ),
        };

        router.setRegisteredRoutes(routes);

        expect(
          router.getRegisteredRouteNames(),
          containsAll(['/route1', '/route2']),
        );
      });

      nyTest('should add to existing routes', () async {
        router.route('/existing', (context) => const SizedBox());

        router.setRegisteredRoutes({
          '/new': NyRouterRoute(
            name: '/new',
            view: (context) => const SizedBox(),
          ),
        });

        expect(
          router.getRegisteredRouteNames(),
          containsAll(['/existing', '/new']),
        );
      });
    });

    nyGroup('setUnknownRoutes()', () {
      nyTest('should add unknown routes from map', () async {
        final routes = {
          '/404': NyRouterRoute(
            name: '/404',
            view: (context) => const SizedBox(),
            unknownRoute: true,
          ),
        };

        router.setUnknownRoutes(routes);

        expect(router.getUnknownRoutes().containsKey('/404'), isTrue);
      });
    });

    nyGroup('updateRegisteredRoutes()', () {
      nyTest('should replace all registered routes', () async {
        router.route('/old', (context) => const SizedBox());

        final newRoutes = {
          '/new1': NyRouterRoute(
            name: '/new1',
            view: (context) => const SizedBox(),
          ),
          '/new2': NyRouterRoute(
            name: '/new2',
            view: (context) => const SizedBox(),
          ),
        };

        router.updateRegisteredRoutes(newRoutes);

        expect(router.getRegisteredRouteNames(), isNot(contains('/old')));
        expect(
          router.getRegisteredRouteNames(),
          containsAll(['/new1', '/new2']),
        );
      });
    });

    nyGroup('setNyRoutes()', () {
      nyTest('should add routes from another NyRouter', () async {
        final otherRouter = NyRouter();
        otherRouter.route('/from-other', (context) => const SizedBox());

        router.setNyRoutes(otherRouter);

        expect(router.getRegisteredRouteNames(), contains('/from-other'));
      });
    });

    nyGroup('generator()', () {
      nyTest('should return RouteFactory', () async {
        final generator = router.generator();

        expect(generator, isA<RouteFactory>());
      });

      nyTest('should return null for null settings name', () async {
        router.route('/test', (context) => const SizedBox());
        final generator = router.generator();

        final result = generator(const RouteSettings(name: null));

        expect(result, isNull);
      });
    });

    nyGroup('unknownRoute() factory', () {
      nyTest('should return RouteFactory', () async {
        router.route('/404', (context) => const SizedBox(), unknownRoute: true);
        final factory = router.unknownRoute();

        expect(factory, isA<RouteFactory>());
      });

      nyTest('should return null when no unknown routes registered', () async {
        final factory = router.unknownRoute();

        final result = factory(const RouteSettings(name: '/missing'));

        expect(result, isNull);
      });
    });

    nyGroup('static methods', () {
      nyTest('unknownRouteGenerator should return RouteFactory', () async {
        final generator = NyRouter.unknownRouteGenerator();

        expect(generator, isA<RouteFactory>());
      });
    });
  });

  nyGroup('nyRoutes()', () {
    nyTest('should create NyRouter with routes', () async {
      final router = nyRoutes((r) {
        r.route('/home', (context) => const SizedBox());
        r.route('/about', (context) => const SizedBox());
      });

      expect(router, isA<NyRouter>());
      expect(
        router.getRegisteredRouteNames(),
        containsAll(['/home', '/about']),
      );
    });
  });

  nyGroup('NavigationType', () {
    nyTest('should have all expected values', () async {
      expect(
        NavigationType.values,
        containsAll([
          NavigationType.push,
          NavigationType.pushReplace,
          NavigationType.pushAndRemoveUntil,
          NavigationType.popAndPushNamed,
          NavigationType.pushAndForgetAll,
        ]),
      );
    });
  });
}

class _TestRouteGuard extends NyRouteGuard {
  @override
  Future<PageRequest?> onRequest(PageRequest pageRequest) async {
    return null;
  }
}
