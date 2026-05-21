import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();
  // Register a minimal env so NyLogger (used by the deep-link error paths)
  // resolves APP_DEBUG instead of throwing "Environment not initialized".
  NyEnvRegistry.register(getter: (key, {defaultValue}) => defaultValue);

  nyGroup('NyDeepLinkHandler', () {
    late NyRouter router;
    late List<_DispatchCall> dispatched;

    void dispatcher(String route, Map<String, dynamic> queryParameters) {
      dispatched.add(_DispatchCall(route, queryParameters));
    }

    nySetUp(() {
      router = NyRouter();
      router.route('/home', (context) => const SizedBox());
      router.route('/user/{id}', (context) => const SizedBox());
      NyNavigator.instance.router = router;
      Backpack.instance.save('nylo', Nylo(router: router));
      Nylo.instance.onIncomingLinkAction = null;
      dispatched = [];
    });

    nyGroup('constructor', () {
      nyTest('stores fallbackRoute', () async {
        final handler = NyDeepLinkHandler(fallbackRoute: '/home');
        expect(handler.fallbackRoute, '/home');
      });

      nyTest('fallbackRoute is null by default', () async {
        final handler = NyDeepLinkHandler();
        expect(handler.fallbackRoute, isNull);
      });
    });

    nyGroup('handle()', () {
      nyWidgetTest('routes a URI with a known path', (tester) async {
        await tester.pumpWidget(const SizedBox());
        final handler = NyDeepLinkHandler(dispatcher: dispatcher);

        await handler.handle(Uri.parse('https://example.com/home'));
        await tester.pumpAndSettle();

        expect(dispatched, hasLength(1));
        expect(dispatched.first.route, '/home');
        expect(dispatched.first.queryParameters, isEmpty);
      });

      nyWidgetTest('passes query parameters through', (tester) async {
        await tester.pumpWidget(const SizedBox());
        final handler = NyDeepLinkHandler(dispatcher: dispatcher);

        await handler.handle(
          Uri.parse('https://example.com/home?ref=email&utm=spring'),
        );
        await tester.pump();

        expect(dispatched, hasLength(1));
        expect(dispatched.first.route, '/home');
        expect(dispatched.first.queryParameters['ref'], 'email');
        expect(dispatched.first.queryParameters['utm'], 'spring');
      });

      nyWidgetTest('matches parameterized routes', (tester) async {
        await tester.pumpWidget(const SizedBox());
        final handler = NyDeepLinkHandler(dispatcher: dispatcher);

        await handler.handle(Uri.parse('https://example.com/user/42'));
        await tester.pump();

        expect(dispatched, hasLength(1));
        expect(dispatched.first.route, '/user/42');
      });

      nyWidgetTest('routes a custom-scheme URI (first segment is the host)', (
        tester,
      ) async {
        await tester.pumpWidget(const SizedBox());
        final handler = NyDeepLinkHandler(dispatcher: dispatcher);

        await handler.handle(Uri.parse('myapp://home'));
        await tester.pump();

        expect(dispatched, hasLength(1));
        expect(dispatched.first.route, '/home');
      });

      nyWidgetTest('matches parameterized routes on a custom scheme', (
        tester,
      ) async {
        await tester.pumpWidget(const SizedBox());
        final handler = NyDeepLinkHandler(dispatcher: dispatcher);

        await handler.handle(Uri.parse('myapp://user/42?ref=email'));
        await tester.pump();

        expect(dispatched, hasLength(1));
        expect(dispatched.first.route, '/user/42');
        expect(dispatched.first.queryParameters['ref'], 'email');
      });

      nyWidgetTest('uses fallbackRoute when path is unknown', (tester) async {
        await tester.pumpWidget(const SizedBox());
        final handler = NyDeepLinkHandler(
          fallbackRoute: '/home',
          dispatcher: dispatcher,
        );

        await handler.handle(Uri.parse('https://example.com/does-not-exist'));
        await tester.pump();

        expect(dispatched, hasLength(1));
        expect(dispatched.first.route, '/home');
      });

      nyWidgetTest('forwards the unknown path when no fallback is set', (
        tester,
      ) async {
        await tester.pumpWidget(const SizedBox());
        final handler = NyDeepLinkHandler(dispatcher: dispatcher);

        await handler.handle(Uri.parse('https://example.com/does-not-exist'));
        await tester.pump();

        expect(dispatched, hasLength(1));
        expect(dispatched.first.route, '/does-not-exist');
      });

      nyWidgetTest('invokes onIncomingLinkAction with the URI', (tester) async {
        await tester.pumpWidget(const SizedBox());
        final captured = <Uri>[];
        Nylo.instance.onIncomingLinkAction = (uri) async {
          captured.add(uri);
          return true;
        };
        final handler = NyDeepLinkHandler(dispatcher: dispatcher);

        await handler.handle(Uri.parse('https://example.com/home?x=1'));
        await tester.pump();

        expect(captured, hasLength(1));
        expect(captured.first.path, '/home');
        expect(dispatched, hasLength(1));
      });

      nyWidgetTest('suppresses dispatch when callback returns false', (
        tester,
      ) async {
        await tester.pumpWidget(const SizedBox());
        Nylo.instance.onIncomingLinkAction = (uri) async => false;
        final handler = NyDeepLinkHandler(dispatcher: dispatcher);

        await handler.handle(Uri.parse('https://example.com/home'));
        await tester.pump();

        expect(dispatched, isEmpty);
      });

      nyWidgetTest('does not rethrow when the callback throws', (tester) async {
        await tester.pumpWidget(const SizedBox());
        Nylo.instance.onIncomingLinkAction = (uri) async {
          throw StateError('callback failure');
        };
        final handler = NyDeepLinkHandler(dispatcher: dispatcher);

        await handler.handle(Uri.parse('https://example.com/home'));
        await tester.pump();

        expect(dispatched, isEmpty);
      });
    });

    nyGroup('init()', () {
      nyWidgetTest('replays the cold-start URI through the router', (
        tester,
      ) async {
        await tester.pumpWidget(const SizedBox());
        final appLinks = _FakeAppLinks(
          initialLink: Uri.parse('https://example.com/home'),
        );
        final handler = NyDeepLinkHandler(
          appLinks: appLinks,
          dispatcher: dispatcher,
        );

        await handler.init();

        expect(dispatched, hasLength(1));
        expect(dispatched.first.route, '/home');
      });

      nyWidgetTest('does nothing when there is no cold-start URI', (
        tester,
      ) async {
        await tester.pumpWidget(const SizedBox());
        final handler = NyDeepLinkHandler(
          appLinks: _FakeAppLinks(),
          dispatcher: dispatcher,
        );

        await handler.init();

        expect(dispatched, isEmpty);
      });
    });

    // These exercise a real StreamController, so they run as plain async
    // tests (nyTest) rather than nyWidgetTest — a stream subscription
    // delivering inside testWidgets' FakeAsync zone deadlocks the isolate.
    nyGroup('listen()', () {
      nyTest('routes warm-start URIs from the stream', () async {
        final appLinks = _FakeAppLinks();
        final handler = NyDeepLinkHandler(
          appLinks: appLinks,
          dispatcher: dispatcher,
        );

        handler.listen();
        appLinks.emit(Uri.parse('https://example.com/user/7'));
        await Future<void>.delayed(Duration.zero);

        expect(dispatched, hasLength(1));
        expect(dispatched.first.route, '/user/7');

        await handler.dispose();
        await appLinks.closeController();
      });

      nyTest('cancels the previous subscription when called again', () async {
        final appLinks = _FakeAppLinks();
        final handler = NyDeepLinkHandler(
          appLinks: appLinks,
          dispatcher: dispatcher,
        );

        handler.listen();
        handler.listen();
        appLinks.emit(Uri.parse('https://example.com/home'));
        await Future<void>.delayed(Duration.zero);

        expect(dispatched, hasLength(1));

        await handler.dispose();
        await appLinks.closeController();
      });

      nyTest('logs stream errors instead of crashing', () async {
        final appLinks = _FakeAppLinks();
        final handler = NyDeepLinkHandler(
          appLinks: appLinks,
          dispatcher: dispatcher,
        );

        handler.listen();
        appLinks.emitError(StateError('platform failure'));
        await Future<void>.delayed(Duration.zero);

        expect(dispatched, isEmpty);

        await handler.dispose();
        await appLinks.closeController();
      });
    });

    nyGroup('dispose()', () {
      nyTest('stops routing warm-start URIs', () async {
        final appLinks = _FakeAppLinks();
        final handler = NyDeepLinkHandler(
          appLinks: appLinks,
          dispatcher: dispatcher,
        );

        handler.listen();
        await handler.dispose();
        appLinks.emit(Uri.parse('https://example.com/home'));
        await Future<void>.delayed(Duration.zero);

        expect(dispatched, isEmpty);

        await appLinks.closeController();
      });
    });
  });
}

class _DispatchCall {
  _DispatchCall(this.route, this.queryParameters);
  final String route;
  final Map<String, dynamic> queryParameters;
}

/// Minimal in-memory [AppLinks] stand-in for exercising
/// [NyDeepLinkHandler]'s cold-start and warm-start paths.
class _FakeAppLinks implements AppLinks {
  _FakeAppLinks({this.initialLink});

  final Uri? initialLink;
  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();

  @override
  Future<Uri?> getInitialLink() async => initialLink;

  @override
  Stream<Uri> get uriLinkStream => _controller.stream;

  /// Emits a warm-start URI to subscribers.
  void emit(Uri uri) => _controller.add(uri);

  /// Emits a stream error to subscribers.
  void emitError(Object error) => _controller.addError(error);

  /// Closes the underlying controller once a test is done.
  Future<void> closeController() => _controller.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
