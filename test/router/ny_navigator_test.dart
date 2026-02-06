import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NyNavigator', () {
    nySetUp(() {
      // Reset for each test
      NyNavigator.instance.prefixRoutes.clear();
      NyNavigator.instance.router = NyRouter();
    });

    nyGroup('singleton instance', () {
      nyTest('should return same instance', () async {
        final instance1 = NyNavigator.instance;
        final instance2 = NyNavigator.instance;

        expect(instance1, same(instance2));
      });

      nyTest('should have a router by default', () async {
        expect(NyNavigator.instance.router, isNotNull);
        expect(NyNavigator.instance.router, isA<NyRouter>());
      });
    });

    nyGroup('router property', () {
      nyTest('should be assignable', () async {
        final newRouter = NyRouter();
        newRouter.route('/test', (context) => const SizedBox());

        NyNavigator.instance.router = newRouter;

        expect(NyNavigator.instance.router, same(newRouter));
        expect(
          NyNavigator.instance.router.getRegisteredRouteNames(),
          contains('/test'),
        );
      });
    });

    nyGroup('prefixRoutes', () {
      nyTest('should start empty', () async {
        NyNavigator.instance.prefixRoutes.clear();

        expect(NyNavigator.instance.prefixRoutes, isEmpty);
      });

      nyTest('should allow adding prefix routes', () async {
        NyNavigator.instance.prefixRoutes['/users'] = '/api';
        NyNavigator.instance.prefixRoutes['/posts'] = '/api';

        expect(NyNavigator.instance.prefixRoutes['/users'], '/api');
        expect(NyNavigator.instance.prefixRoutes['/posts'], '/api');
      });

      nyTest('should allow checking if prefix exists', () async {
        NyNavigator.instance.prefixRoutes['/dashboard'] = '/admin';

        expect(
          NyNavigator.instance.prefixRoutes.containsKey('/dashboard'),
          isTrue,
        );
        expect(
          NyNavigator.instance.prefixRoutes.containsKey('/settings'),
          isFalse,
        );
      });

      nyTest('should allow clearing prefixes', () async {
        NyNavigator.instance.prefixRoutes['/test'] = '/prefix';
        NyNavigator.instance.prefixRoutes.clear();

        expect(NyNavigator.instance.prefixRoutes, isEmpty);
      });
    });
  });
}
