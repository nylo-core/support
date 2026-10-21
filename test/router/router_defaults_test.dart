import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  late NyRouter router;

  nySetUp(() {
    NyEnvRegistry.register(
      getter: (String key, {dynamic defaultValue}) => defaultValue,
      containsKey: (String key) => false,
    );
    Backpack.instance.save('nylo', Nylo());
    router = NyRouter();
    NyNavigator.instance.router = router;
    NyNavigator.instance.prefixRoutes.clear();
  });

  nyGroup('previewRoute(data:)', () {
    nyTest('stores the data as previewArgs', () async {
      final NyRouterRoute route = router
          .route('/product', (context) => const SizedBox())
          .previewRoute(data: {'id': 1});

      expect(route.previewArgs?.data, {'id': 1});
      expect(route.getPreviewRoute(), isTrue);
    });

    nyTest('has no previewArgs without data', () async {
      final NyRouterRoute route = router
          .route('/product', (context) => const SizedBox())
          .previewRoute();

      expect(route.previewArgs, isNull);
    });

    nyTest(
      'clears previewArgs when another route becomes the preview',
      () async {
        final NyRouterRoute first = router
            .route('/first', (context) => const SizedBox())
            .previewRoute(data: 'first');
        router.route('/second', (context) => const SizedBox()).previewRoute();

        expect(first.getPreviewRoute(), isFalse);
        expect(first.previewArgs, isNull);
      },
    );

    nyWidgetTest('passes the data to the page on launch', (tester) async {
      NyArgument? received;
      final NyRouterRoute route = router
          .route('/product', (context) => const Text('Product'))
          .previewRoute(data: {'id': 2});
      route.builder = (context, args, queryParameters) {
        received = args;
        return const Text('Product');
      };

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: router.navigatorKey,
          onGenerateRoute: router.generator(),
          initialRoute: router.getInitialRouteName(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Product'), findsOneWidget);
      expect(received?.data, {'id': 2});
    });

    nyWidgetTest('navigation data wins over preview data', (tester) async {
      NyArgument? received;
      router.route('/home', (context) => const Text('Home')).initialRoute();
      final NyRouterRoute route = router
          .route('/product', (context) => const Text('Product'))
          .previewRoute(data: 'preview');
      route.builder = (context, args, queryParameters) {
        received = args;
        return const Text('Product');
      };

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: router.navigatorKey,
          onGenerateRoute: router.generator(),
          initialRoute: '/home',
        ),
      );
      await tester.pumpAndSettle();

      router.navigate('/product', args: NyArgument('navigated'));
      await tester.pumpAndSettle();

      expect(received?.data, 'navigated');
    });
  });

  nyGroup('nyRoutes(transitionType:)', () {
    nyTest('applies the default to routes without a transition', () async {
      final NyRouter router = nyRoutes(
        (r) {
          r.route('/home', (context) => const SizedBox());
        },
        transitionType: TransitionType.fade(
          duration: const Duration(milliseconds: 123),
        ),
      );

      final NyRouterRoute home = router.getRegisteredRoutes()['/home']!;
      expect(home.pageTransitionType, PageTransitionType.fade);
      expect(
        home.pageTransitionSettings?.duration,
        const Duration(milliseconds: 123),
      );
    });

    nyTest('keeps a route\'s own transition', () async {
      final NyRouter router = nyRoutes(
        (r) {
          r.route(
            '/settings',
            (context) => const SizedBox(),
            transitionType: TransitionType.bottomToTop(
              duration: const Duration(milliseconds: 456),
            ),
          );
        },
        transitionType: TransitionType.fade(
          duration: const Duration(milliseconds: 123),
        ),
      );

      final NyRouterRoute settings = router.getRegisteredRoutes()['/settings']!;
      expect(settings.pageTransitionType, PageTransitionType.bottomToTop);
      expect(
        settings.pageTransitionSettings?.duration,
        const Duration(milliseconds: 456),
      );
    });

    nyTest('applies the default to grouped and unknown routes', () async {
      final NyRouter router = nyRoutes((r) {
        r.group(() => {'prefix': '/account'}, (g) {
          g.route('/profile', (context) => const SizedBox());
        });
        r.route('/404', (context) => const SizedBox(), unknownRoute: true);
      }, transitionType: TransitionType.fade());

      expect(
        router.getRegisteredRoutes()['/profile']!.pageTransitionType,
        PageTransitionType.fade,
      );
      expect(
        router.getUnknownRoutes()['/404']!.pageTransitionType,
        PageTransitionType.fade,
      );
    });

    nyTest('leaves routes unchanged without a default', () async {
      final NyRouter router = nyRoutes((r) {
        r.route('/home', (context) => const SizedBox());
      });

      expect(router.getRegisteredRoutes()['/home']!.pageTransitionType, isNull);
    });
  });

  nyGroup('group() transitions', () {
    nyTest('keeps a route\'s own transition and settings', () async {
      router.group(
        () => {
          'transition_type': TransitionType.fade(
            duration: const Duration(milliseconds: 123),
          ),
        },
        (r) {
          r.route(
            '/own',
            (context) => const SizedBox(),
            transitionType: TransitionType.bottomToTop(
              duration: const Duration(milliseconds: 456),
            ),
          );
          r.route('/shared', (context) => const SizedBox());
        },
      );

      final Map<String, NyRouterRoute> routes = router.getRegisteredRoutes();
      expect(
        routes['/own']!.pageTransitionType,
        PageTransitionType.bottomToTop,
      );
      expect(
        routes['/own']!.pageTransitionSettings?.duration,
        const Duration(milliseconds: 456),
      );
      expect(routes['/shared']!.pageTransitionType, PageTransitionType.fade);
      expect(
        routes['/shared']!.pageTransitionSettings?.duration,
        const Duration(milliseconds: 123),
      );
    });

    nyTest('registers an unknown route declared in the group', () async {
      router.group(() => {'transition_type': TransitionType.fade()}, (r) {
        r.route('/home', (context) => const SizedBox());
        r.route('/404', (context) => const SizedBox(), unknownRoute: true);
      });

      expect(router.getUnknownRoutes().keys, contains('/404'));
      expect(
        router.getUnknownRoutes()['/404']!.pageTransitionType,
        PageTransitionType.fade,
      );
    });
  });
}
