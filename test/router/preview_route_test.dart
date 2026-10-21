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
    NyRouterRoute.previewsEnabled = true;
  });

  nyTearDown(() {
    NyRouterRoute.previewsEnabled = true;
  });

  /// Pumps an app the way `NyApp.materialApp` builds it.
  Future<void> pumpApp(WidgetTester tester) async {
    final RouteFactory generator = router.generator();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: router.navigatorKey,
        onGenerateRoute: generator,
        onGenerateInitialRoutes: NyRouter.previewInitialRoutes(generator),
        initialRoute: router.getInitialRouteName(),
      ),
    );
    await tester.pumpAndSettle();
  }

  nyGroup('previewRoute in release builds', () {
    nyTest('is ignored, so the initial route stays', () async {
      NyRouterRoute.previewsEnabled = false;
      router.route('/home', (context) => const SizedBox()).initialRoute();
      final NyRouterRoute product = router
          .route('/product', (context) => const SizedBox())
          .previewRoute(data: 'preview', stack: ['/home']);

      expect(product.getPreviewRoute(), isFalse);
      expect(product.previewArgs, isNull);
      expect(product.previewStack, isEmpty);
      expect(router.getInitialRouteName(), '/home');
    });
  });

  nyGroup('previewRoute(queryParameters:)', () {
    nyTest('stores the query parameters', () async {
      final NyRouterRoute route = router
          .route('/product', (context) => const SizedBox())
          .previewRoute(queryParameters: {'tab': 'reviews'});

      expect(route.previewQueryParameters?.data, {'tab': 'reviews'});
    });

    nyWidgetTest('passes them to the page on launch', (tester) async {
      NyQueryParameters? received;
      final NyRouterRoute route = router
          .route('/product', (context) => const Text('Product'))
          .previewRoute(queryParameters: {'tab': 'reviews'});
      route.builder = (context, args, queryParameters) {
        received = queryParameters;
        return const Text('Product');
      };

      await pumpApp(tester);

      expect(received?.data, {'tab': 'reviews'});
    });

    nyTest('are cleared when another route becomes the preview', () async {
      final NyRouterRoute first = router
          .route('/first', (context) => const SizedBox())
          .previewRoute(queryParameters: {'a': '1'}, stack: ['/second']);
      router.route('/second', (context) => const SizedBox()).previewRoute();

      expect(first.previewQueryParameters, isNull);
      expect(first.previewStack, isEmpty);
    });
  });

  nyGroup('previewRoute(stack:)', () {
    nyWidgetTest('opens the stack underneath the preview', (tester) async {
      router.route('/home', (context) => const Text('Home')).initialRoute();
      router.route('/cart', (context) => const Text('Cart'));
      router
          .route('/checkout', (context) => const Text('Checkout'))
          .previewRoute(stack: ['/home', '/cart']);

      await pumpApp(tester);

      expect(find.text('Checkout'), findsOneWidget);

      final NavigatorState navigator = router.navigatorKey!.currentState!;
      expect(navigator.canPop(), isTrue);

      navigator.pop();
      await tester.pumpAndSettle();
      expect(find.text('Cart'), findsOneWidget);

      navigator.pop();
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(navigator.canPop(), isFalse);
    });

    nyTest('previewInitialRoutes is null without a stack', () async {
      router.route('/product', (context) => const SizedBox()).previewRoute();

      expect(NyRouter.previewInitialRoutes(router.generator()), isNull);
    });

    nyTest('previewInitialRoutes is null without a preview', () async {
      router.route('/home', (context) => const SizedBox()).initialRoute();

      expect(NyRouter.previewInitialRoutes(router.generator()), isNull);
    });
  });

  nyGroup('applyPreview (PREVIEW_ROUTE dart-define)', () {
    nyTest('previews the route with its query string', () async {
      final NyRouterRoute product = router.route(
        '/product',
        (context) => const SizedBox(),
      );

      router.applyPreview('/product?tab=reviews');

      expect(product.getPreviewRoute(), isTrue);
      expect(product.previewQueryParameters?.data, {'tab': 'reviews'});
      expect(router.getInitialRouteName(), '/product');
    });

    nyTest('decodes JSON data', () async {
      final NyRouterRoute product = router.route(
        '/product',
        (context) => const SizedBox(),
      );

      router.applyPreview('/product', data: '{"id":1,"name":"Lamp"}');

      expect(product.previewArgs?.data, {'id': 1, 'name': 'Lamp'});
    });

    nyTest('passes data that is not JSON as a string', () async {
      final NyRouterRoute product = router.route(
        '/product',
        (context) => const SizedBox(),
      );

      router.applyPreview('/product', data: 'lamp');

      expect(product.previewArgs?.data, 'lamp');
    });

    nyTest('splits the stack on commas', () async {
      final NyRouterRoute product = router.route(
        '/product',
        (context) => const SizedBox(),
      );

      router.applyPreview('/product', stack: '/home, /cart,');

      expect(product.previewStack, ['/home', '/cart']);
    });

    nyTest('ignores a route that is not registered', () async {
      router.route('/home', (context) => const SizedBox()).initialRoute();

      router.applyPreview('/missing');

      expect(router.getInitialRouteName(), '/home');
    });
  });
}
