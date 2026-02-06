import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/controllers/ny_controllers.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Test implementation of BaseController for testing abstract class
class TestController extends BaseController {
  TestController({super.context, super.request, super.state});
}

/// Test RouteGuard implementation
class TestRouteGuard extends RouteGuard {
  final String name;
  TestRouteGuard(this.name);

  @override
  Future<PageRequest?> onRequest(PageRequest pageRequest) async => null;
}

void main() {
  NyTest.init();

  nyGroup('BaseController', () {
    nyGroup('initialization', () {
      nyTest('creates controller with default state', () async {
        final controller = TestController();

        expect(controller.context, isNull);
        expect(controller.request, isNull);
        expect(controller.state, '/');
      });

      nyTest('creates controller with custom state', () async {
        final controller = TestController(state: 'CustomState');

        expect(controller.state, 'CustomState');
      });

      nyTest('creates controller with request', () async {
        final request = NyRequest(
          currentRoute: '/test',
          args: NyArgument({'key': 'value'}),
        );
        final controller = TestController(request: request);

        expect(controller.request, isNotNull);
        expect(controller.request?.currentRoute, '/test');
      });
    });

    nyGroup('routeGuards', () {
      nyTest('has empty route guards by default', () async {
        final controller = TestController();

        expect(controller.routeGuards, isEmpty);
      });

      nyTest('can add route guards', () async {
        final controller = TestController();
        final guard1 = TestRouteGuard('auth');
        final guard2 = TestRouteGuard('admin');

        controller.routeGuards = [guard1, guard2];

        expect(controller.routeGuards.length, 2);
        expect(controller.routeGuards[0], guard1);
        expect(controller.routeGuards[1], guard2);
      });

      nyTest('can modify route guards list', () async {
        final controller = TestController();
        controller.routeGuards.add(TestRouteGuard('first'));

        expect(controller.routeGuards.length, 1);

        controller.routeGuards.add(TestRouteGuard('second'));

        expect(controller.routeGuards.length, 2);
      });
    });

    nyGroup('data()', () {
      nyTest('returns data from request', () async {
        final request = NyRequest(
          currentRoute: '/test',
          args: NyArgument({'userId': 123}),
        );
        final controller = TestController(request: request);

        final result = controller.data<Map<String, dynamic>>();

        expect(result, isNotNull);
        expect(result!['userId'], 123);
      });

      nyTest('returns defaultValue when request is null', () async {
        final controller = TestController();

        final result = controller.data<String>(defaultValue: 'fallback');

        expect(result, 'fallback');
      });

      nyTest('returns defaultValue when request data is null', () async {
        final request = NyRequest(currentRoute: '/test');
        final controller = TestController(request: request);

        final result = controller.data<String>(defaultValue: 'default');

        expect(result, 'default');
      });
    });

    nyGroup('queryParameters()', () {
      nyTest('returns query parameters from request', () async {
        final request = NyRequest(
          currentRoute: '/test',
          queryParameters: NyQueryParameters({'page': '1', 'sort': 'asc'}),
        );
        final controller = TestController(request: request);

        final result = controller.queryParameters();

        expect(result, isA<Map>());
        expect(result['page'], '1');
        expect(result['sort'], 'asc');
      });

      nyTest('returns specific query parameter by key', () async {
        final request = NyRequest(
          currentRoute: '/test',
          queryParameters: NyQueryParameters({'filter': 'active'}),
        );
        final controller = TestController(request: request);

        final result = controller.queryParameters(key: 'filter');

        expect(result, 'active');
      });

      nyTest('returns null when request is null', () async {
        final controller = TestController();

        final result = controller.queryParameters();

        expect(result, isNull);
      });

      nyTest('returns null for key when request is null', () async {
        final controller = TestController();

        final result = controller.queryParameters(key: 'anyKey');

        expect(result, isNull);
      });
    });

    nyGroup('construct()', () {
      nyWidgetTest('sets context when called', (tester) async {
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

        final controller = TestController();
        expect(controller.context, isNull);

        await controller.construct(capturedContext);

        expect(controller.context, isNotNull);
        expect(controller.context, capturedContext);
      });

      nyWidgetTest('preserves existing state when constructing', (
        tester,
      ) async {
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

        final controller = TestController(state: 'MyPageState');
        await controller.construct(capturedContext);

        expect(controller.state, 'MyPageState');
        expect(controller.context, capturedContext);
      });

      nyWidgetTest('preserves request when constructing', (tester) async {
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

        final request = NyRequest(
          currentRoute: '/test',
          args: NyArgument('test data'),
        );
        final controller = TestController(request: request);
        await controller.construct(capturedContext);

        expect(controller.request, request);
        expect(controller.data<String>(), 'test data');
      });
    });
  });
}
