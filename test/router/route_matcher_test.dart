import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('RouteMatcher', () {
    late Map<String, NyRouterRoute> routeMappings;

    nySetUp(() {
      routeMappings = {
        '/home': NyRouterRoute(
          name: '/home',
          view: (context) => const SizedBox(),
        ),
        '/users': NyRouterRoute(
          name: '/users',
          view: (context) => const SizedBox(),
        ),
        '/users/{id}': NyRouterRoute(
          name: '/users/{id}',
          view: (context) => const SizedBox(),
        ),
        '/posts/{postId}/comments/{commentId}': NyRouterRoute(
          name: '/posts/{postId}/comments/{commentId}',
          view: (context) => const SizedBox(),
        ),
        '/products/{category}/{productId}': NyRouterRoute(
          name: '/products/{category}/{productId}',
          view: (context) => const SizedBox(),
        ),
      };
    });

    nyGroup('findMatch()', () {
      nyGroup('static routes', () {
        nyTest('should match exact static route', () async {
          final matcher = RouteMatcher('/home');

          final match = matcher.findMatch(routeMappings);

          expect(match, isNotNull);
          expect(match!.pattern, '/home');
          expect(match.parameters, isEmpty);
        });

        nyTest('should match static route with leading slash', () async {
          final matcher = RouteMatcher('/users');

          final match = matcher.findMatch(routeMappings);

          expect(match, isNotNull);
          expect(match!.pattern, '/users');
        });

        nyTest('should return null for non-existent route', () async {
          final matcher = RouteMatcher('/nonexistent');

          final match = matcher.findMatch(routeMappings);

          expect(match, isNull);
        });
      });

      nyGroup('parameterized routes', () {
        nyTest('should match single parameter route', () async {
          final matcher = RouteMatcher('/users/123');

          final match = matcher.findMatch(routeMappings);

          expect(match, isNotNull);
          expect(match!.pattern, '/users/{id}');
          expect(match.parameters['id'], '123');
        });

        nyTest('should match route with multiple parameters', () async {
          final matcher = RouteMatcher('/posts/42/comments/99');

          final match = matcher.findMatch(routeMappings);

          expect(match, isNotNull);
          expect(match!.pattern, '/posts/{postId}/comments/{commentId}');
          expect(match.parameters['postId'], '42');
          expect(match.parameters['commentId'], '99');
        });

        nyTest('should extract string parameters', () async {
          final matcher = RouteMatcher('/products/electronics/laptop-001');

          final match = matcher.findMatch(routeMappings);

          expect(match, isNotNull);
          expect(match!.parameters['category'], 'electronics');
          expect(match.parameters['productId'], 'laptop-001');
        });

        nyTest('should not match if segment count differs', () async {
          final matcher = RouteMatcher('/users/123/extra');

          final match = matcher.findMatch(routeMappings);

          expect(match, isNull);
        });
      });

      nyGroup('path normalization', () {
        nyTest('should handle path with trailing slash', () async {
          final matcher = RouteMatcher('/home/');

          final match = matcher.findMatch(routeMappings);

          expect(match, isNotNull);
          expect(match!.pattern, '/home');
        });

        nyTest('should handle path with multiple leading slashes', () async {
          final matcher = RouteMatcher('//home');

          final match = matcher.findMatch(routeMappings);

          expect(match, isNotNull);
          expect(match!.pattern, '/home');
        });

        nyTest('should handle path without leading slash', () async {
          final matcher = RouteMatcher('home');

          final match = matcher.findMatch(routeMappings);

          expect(match, isNotNull);
          expect(match!.pattern, '/home');
        });

        nyTest('should handle whitespace in path', () async {
          final matcher = RouteMatcher('  /home  ');

          final match = matcher.findMatch(routeMappings);

          expect(match, isNotNull);
          expect(match!.pattern, '/home');
        });
      });

      nyGroup('edge cases', () {
        nyTest('should return null for empty route mappings', () async {
          final matcher = RouteMatcher('/home');

          final match = matcher.findMatch({});

          expect(match, isNull);
        });

        nyTest('should prefer static routes over parameterized', () async {
          // Add a static /users route alongside parameterized
          routeMappings['/users'] = NyRouterRoute(
            name: '/users',
            view: (context) => const SizedBox(),
          );

          final matcher = RouteMatcher('/users');

          final match = matcher.findMatch(routeMappings);

          expect(match, isNotNull);
          expect(match!.pattern, '/users');
          expect(match.parameters, isEmpty);
        });
      });
    });
  });

  nyGroup('RouteMatch', () {
    nyTest('should store pattern correctly', () async {
      final match = RouteMatch(
        pattern: '/users/{id}',
        route: NyRouterRoute(
          name: '/users/{id}',
          view: (context) => const SizedBox(),
        ),
        parameters: {'id': '123'},
      );

      expect(match.pattern, '/users/{id}');
    });

    nyTest('should store parameters correctly', () async {
      final match = RouteMatch(
        pattern: '/test/{param}',
        route: NyRouterRoute(
          name: '/test/{param}',
          view: (context) => const SizedBox(),
        ),
        parameters: {'param': 'value'},
      );

      expect(match.parameters['param'], 'value');
    });

    nyTest('should provide meaningful toString', () async {
      final match = RouteMatch(
        pattern: '/users/{id}',
        route: NyRouterRoute(
          name: '/users/{id}',
          view: (context) => const SizedBox(),
        ),
        parameters: {'id': '42'},
      );

      final str = match.toString();

      expect(str, contains('RouteMatch'));
      expect(str, contains('/users/{id}'));
      expect(str, contains('42'));
    });
  });
}
