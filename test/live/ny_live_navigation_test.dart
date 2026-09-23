import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/live/ny_live.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

class _BlockGuard extends NyRouteGuard {
  @override
  Future<GuardResult> onBefore(RouteContext context) async => abort();
}

void main() {
  NyTest.init();

  late NyRouter router;

  setUp(() {
    Backpack.instance.save('nylo', Nylo());
    router = NyRouter();
    NyNavigator.instance.router = router;
    NyNavigator.instance.prefixRoutes.clear();
    router.route('/home', (context) => const Text('Home')).initialRoute();
    router.route('/cart', (context) => const Text('Cart'));
    router.route('/checkout', (context) => const Text('Checkout'));
    router
        .route('/missing-page', (context) => const Text('404'))
        .unknownRoute();
    router.route(
      '/admin',
      (context) => const Text('Admin'),
      routeGuards: [_BlockGuard()],
    );
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: router.navigatorKey,
        onGenerateRoute: router.generator(),
        initialRoute: '/home',
        navigatorObservers: [NyRouteHistoryObserver()],
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Runs a live command while pumping frames so navigation can finish.
  Future<Object?> run(
    WidgetTester tester,
    String command, [
    Map<String, dynamic> args = const {},
  ]) async {
    Object? result;
    Object? error;
    bool done = false;
    NyLive.dispatch(command, args).then(
      (value) {
        result = value;
        done = true;
      },
      onError: (Object e) {
        error = e;
        done = true;
      },
    );
    for (int i = 0; i < 400 && !done; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    if (error != null) throw error!;
    return result;
  }

  /// Runs a live command that is expected to fail and returns the error.
  Future<LiveException> runError(
    WidgetTester tester,
    String command, [
    Map<String, dynamic> args = const {},
  ]) async {
    try {
      await run(tester, command, args);
    } on LiveException catch (e) {
      return e;
    }
    fail('Expected "$command" to fail');
  }

  nyWidgetTest('routes lists registered routes and markers', (tester) async {
    await pumpApp(tester);

    expect(await run(tester, 'routes'), {
      'initial': '/home',
      'auth': null,
      'unknown': '/missing-page',
      'routes': ['/home', '/cart', '/checkout', '/missing-page', '/admin'],
    });
  });

  nyWidgetTest('route.push opens a page and returns once it is shown', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(
      await run(tester, 'route.push', {
        'path': '/cart',
        'data': {'items': 2},
      }),
      {
        'from': '/home',
        'current': '/cart',
        'stack': ['/home', '/cart'],
        'changed': true,
      },
    );
    expect(find.text('Cart'), findsOneWidget);
    expect(await run(tester, 'route.current'), {
      'current': '/cart',
      'data': {'items': 2},
      'stack': ['/home', '/cart'],
    });
  });

  nyWidgetTest('route.push supports replace and clear', (tester) async {
    await pumpApp(tester);

    await run(tester, 'route.push', {'path': '/cart'});
    expect(
      ((await run(tester, 'route.push', {
            'path': '/checkout',
            'navigation': 'replace',
          }))
          as Map)['stack'],
      ['/home', '/checkout'],
    );
    expect(
      ((await run(tester, 'route.push', {
            'path': '/cart',
            'navigation': 'clear',
          }))
          as Map)['stack'],
      ['/cart'],
    );
  });

  nyWidgetTest('route.push reports a guard that stops navigation', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(await run(tester, 'route.push', {'path': '/admin'}), {
      'from': '/home',
      'current': '/home',
      'stack': ['/home'],
      'changed': false,
    });
  });

  nyWidgetTest('route.push explains unknown routes and bad arguments', (
    tester,
  ) async {
    await pumpApp(tester);

    final LiveException missing = await runError(tester, 'route.push', {
      'path': '/missing',
    });
    expect(missing.message, contains('No route named "/missing"'));

    final LiveException invalid = await runError(tester, 'route.push', {
      'path': '/cart',
      'navigation': 'teleport',
    });
    expect(invalid.code, LiveException.invalidParamsCode);
  });

  nyWidgetTest('toast.show displays a toast over the current page', (
    tester,
  ) async {
    await pumpApp(tester);
    await run(tester, 'route.push', {'path': '/cart'});

    expect(
      await run(tester, 'toast.show', {
        'title': 'Metro',
        'description': 'Cart seeded',
      }),
      {'shown': true},
    );
    expect(find.text('Cart seeded'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });

  nyWidgetTest('deeplink.show reports the setup and the routes', (
    tester,
  ) async {
    await pumpApp(tester);

    final Map result = (await run(tester, 'deeplink.show')) as Map;

    expect(result['enabled'], false);
    expect(result['fallbackRoute'], isNull);
    expect(result['hasCallback'], false);
    expect(result['routes'], contains('/cart'));
  });

  nyWidgetTest('deeplink.open routes a custom scheme through its host', (
    tester,
  ) async {
    await pumpApp(tester);

    final Map result =
        (await run(tester, 'deeplink.open', {'uri': 'myapp://cart'})) as Map;

    expect(result['path'], '/cart');
    expect(result['registered'], true);
    expect(result['target'], '/cart');
    expect(result['routed'], true);
    expect(result['from'], '/home');
    expect(result['current'], '/cart');
    expect(find.text('Cart'), findsOneWidget);
  });

  nyWidgetTest('deeplink.open routes an https link on its path', (
    tester,
  ) async {
    await pumpApp(tester);

    final Map result =
        (await run(tester, 'deeplink.open', {
              'uri': 'https://shop.example.com/checkout?ref=email',
            }))
            as Map;

    expect(result['path'], '/checkout');
    expect(result['queryParameters'], {'ref': 'email'});
    expect(result['current'], '/checkout');
  });

  nyWidgetTest('deeplink.open resolves without routing when dry', (
    tester,
  ) async {
    await pumpApp(tester);

    final Map result =
        (await run(tester, 'deeplink.open', {
              'uri': 'myapp://cart',
              'dry': true,
            }))
            as Map;

    expect(result['path'], '/cart');
    expect(result['registered'], true);
    expect(result['routed'], false);
    expect(result['dry'], true);
    expect(result['current'], '/home', reason: 'a dry run changes nothing');
  });

  nyWidgetTest('deeplink.open reports an unregistered path', (tester) async {
    await pumpApp(tester);

    final Map result =
        (await run(tester, 'deeplink.open', {
              'uri': 'myapp://promo/summer',
              'dry': true,
            }))
            as Map;

    expect(result['path'], '/promo/summer');
    expect(result['registered'], false);
    expect(result['usedFallback'], false, reason: 'no fallback is configured');
  });

  nyWidgetTest('deeplink.open runs onIncomingLink, and it can stop routing', (
    tester,
  ) async {
    await pumpApp(tester);
    final List<Uri> seen = [];
    Nylo.instance.onIncomingLink((Uri uri) async {
      seen.add(uri);
      return false;
    });
    addTearDown(() => Nylo.instance.onIncomingLinkAction = null);

    final Map result =
        (await run(tester, 'deeplink.open', {'uri': 'myapp://cart'})) as Map;

    expect(seen.single.toString(), 'myapp://cart');
    expect(result['callback'], 'stopped');
    expect(result['routed'], false);
    expect(result['current'], '/home');
  });

  nyWidgetTest('deeplink.open can skip the callback', (tester) async {
    await pumpApp(tester);
    bool ran = false;
    Nylo.instance.onIncomingLink((Uri uri) async {
      ran = true;
      return false;
    });
    addTearDown(() => Nylo.instance.onIncomingLinkAction = null);

    final Map result =
        (await run(tester, 'deeplink.open', {
              'uri': 'myapp://cart',
              'callback': false,
            }))
            as Map;

    expect(ran, isFalse);
    expect(result['callback'], 'skipped');
    expect(result['current'], '/cart');
  });

  nyWidgetTest('deeplink.open refuses something that isn\'t a link', (
    tester,
  ) async {
    await pumpApp(tester);

    final LiveException error = await runError(tester, 'deeplink.open', {
      'uri': '/cart',
    });

    expect(error.message, contains('It needs a scheme'));
    expect(error.code, LiveException.invalidParamsCode);
  });

  nyWidgetTest('route.back pops once or back to a named route', (tester) async {
    await pumpApp(tester);
    await run(tester, 'route.push', {'path': '/cart'});
    await run(tester, 'route.push', {'path': '/checkout'});

    expect(await run(tester, 'route.back'), {
      'from': '/checkout',
      'current': '/cart',
      'stack': ['/home', '/cart'],
    });

    await run(tester, 'route.push', {'path': '/checkout'});
    expect(await run(tester, 'route.back', {'path': '/home'}), {
      'from': '/checkout',
      'current': '/home',
      'stack': ['/home'],
    });
    expect(find.text('Home'), findsOneWidget);
  });

  nyWidgetTest('route.back refuses when there is nowhere to go', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(
      (await runError(tester, 'route.back')).message,
      contains('no page to go back to'),
    );
    expect(
      (await runError(tester, 'route.back', {'path': '/checkout'})).message,
      contains('isn\'t in the navigation stack'),
    );
  });
}
