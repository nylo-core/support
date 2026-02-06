import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('RouteGuard (Legacy)', () {
    nyGroup('onRequest()', () {
      nyTest('should return null by default', () async {
        final guard = _BasicRouteGuard();
        final request = PageRequest();

        final result = await guard.onRequest(request);

        expect(result, isNull);
      });
    });

    nyGroup('pageRequest property', () {
      nyTest('should be settable', () async {
        final guard = _BasicRouteGuard();
        final request = PageRequest();

        guard.pageRequest = request;

        expect(guard.pageRequest, same(request));
      });

      nyTest('should be nullable', () async {
        final guard = _BasicRouteGuard();

        expect(guard.pageRequest, isNull);
      });
    });
  });

  nyGroup('NyRouteGuard', () {
    nyGroup('GuardResult enum', () {
      nyTest('should have next and handled values', () async {
        expect(GuardResult.values, contains(GuardResult.next));
        expect(GuardResult.values, contains(GuardResult.handled));
      });
    });

    nyGroup('RouteContext', () {
      nyTest('should create with required routeName', () async {
        final context = RouteContext(routeName: '/home');

        expect(context.routeName, '/home');
        expect(context.data, isNull);
        expect(context.queryParameters, isEmpty);
        expect(context.context, isNull);
      });

      nyTest('should create with all parameters', () async {
        final context = RouteContext(
          routeName: '/profile',
          data: {'id': 123},
          queryParameters: {'tab': 'settings'},
          originalRouteName: '/profile?tab=settings',
        );

        expect(context.routeName, '/profile');
        expect(context.data, {'id': 123});
        expect(context.queryParameters, {'tab': 'settings'});
        expect(context.originalRouteName, '/profile?tab=settings');
      });

      nyTest('withData() should create copy with new data', () async {
        final original = RouteContext<Map<String, dynamic>>(
          routeName: '/test',
          data: {'original': true},
        );

        final modified = original.withData({'new': 'data'});

        expect(modified.routeName, '/test');
        expect(modified.data, {'new': 'data'});
        expect(original.data, {'original': true}); // Original unchanged
      });

      nyTest('copyWith() should create copy with changed fields', () async {
        final original = RouteContext(
          routeName: '/test',
          queryParameters: {'a': '1'},
        );

        final modified = original.copyWith(queryParameters: {'b': '2'});

        expect(modified.routeName, '/test');
        expect(modified.queryParameters, {'b': '2'});
      });
    });

    nyGroup('data getter', () {
      nyTest('should return data from routeContext', () async {
        final guard = _TestNyRouteGuard();
        guard.setRouteContext(
          RouteContext(routeName: '/test', data: {'id': 123}),
        );

        expect(guard.data, {'id': 123});
      });

      nyTest('should return null when routeContext is null', () async {
        final guard = _TestNyRouteGuard();

        expect(guard.data, isNull);
      });
    });

    nyGroup('context getter', () {
      nyWidgetTest('should return context from routeContext', (tester) async {
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

        final guard = _TestNyRouteGuard();
        guard.setRouteContext(
          RouteContext(routeName: '/test', context: capturedContext),
        );

        expect(guard.context, same(capturedContext));
      });

      nyTest('should return null when routeContext is null', () async {
        final guard = _TestNyRouteGuard();

        expect(guard.context, isNull);
      });
    });

    nyGroup('queryParameters getter', () {
      nyTest('should return query parameters from routeContext', () async {
        final guard = _TestNyRouteGuard();
        guard.setRouteContext(
          RouteContext(
            routeName: '/test',
            queryParameters: {'sort': 'asc', 'page': '1'},
          ),
        );

        expect(guard.queryParameters, {'sort': 'asc', 'page': '1'});
      });

      nyTest('should return empty map when routeContext is null', () async {
        final guard = _TestNyRouteGuard();

        expect(guard.queryParameters, isEmpty);
      });
    });

    nyGroup('setData()', () {
      nyTest('should set modified data', () async {
        final guard = _TestNyRouteGuard();
        guard.setRouteContext(
          RouteContext(routeName: '/test', data: {'original': 'value'}),
        );

        guard.setData({'original': 'value', 'added': 'newValue'});

        expect(guard.hasModifiedData, isTrue);
        expect(guard.modifiedData, containsPair('original', 'value'));
        expect(guard.modifiedData, containsPair('added', 'newValue'));
      });
    });

    nyGroup('next()', () {
      nyTest('should return GuardResult.next', () async {
        final guard = _TestNyRouteGuard();

        expect(guard.next(), GuardResult.next);
      });
    });

    nyGroup('abort()', () {
      nyTest('should return GuardResult.handled', () async {
        final guard = _TestNyRouteGuard();

        expect(guard.abort(), GuardResult.handled);
      });
    });

    nyGroup('redirect()', () {
      nyTest(
        'should return GuardResult.handled and set redirectConfig',
        () async {
          final guard = _TestNyRouteGuard();
          guard.setRouteContext(RouteContext(routeName: '/protected'));

          final result = guard.redirect('/login');

          expect(result, GuardResult.handled);
          expect(guard.redirectConfig, isNotNull);
          expect(guard.redirectConfig!.path, '/login');
        },
      );

      nyTest('should use provided data if specified', () async {
        final guard = _TestNyRouteGuard();

        guard.redirect('/page', data: {'custom': 'data'});

        expect(guard.redirectConfig!.data, {'custom': 'data'});
      });

      nyTest('should include query parameters', () async {
        final guard = _TestNyRouteGuard();

        guard.redirect('/page', queryParameters: {'sort': 'desc'});

        expect(guard.redirectConfig!.queryParameters, {'sort': 'desc'});
      });

      nyTest('should set navigation type', () async {
        final guard = _TestNyRouteGuard();

        guard.redirect(
          '/page',
          navigationType: NavigationType.pushAndForgetAll,
        );

        expect(
          guard.redirectConfig!.navigationType,
          NavigationType.pushAndForgetAll,
        );
      });

      nyTest('should default to pushReplace navigation type', () async {
        final guard = _TestNyRouteGuard();

        guard.redirect('/page');

        expect(
          guard.redirectConfig!.navigationType,
          NavigationType.pushReplace,
        );
      });
    });

    nyGroup('onBefore lifecycle', () {
      nyTest('should return next by default', () async {
        final guard = _TestNyRouteGuard();
        final context = RouteContext(routeName: '/test');

        final result = await guard.onBefore(context);

        expect(result, GuardResult.next);
      });
    });

    nyGroup('onAfter lifecycle', () {
      nyTest('should complete without error by default', () async {
        final guard = _TestNyRouteGuard();
        final context = RouteContext(routeName: '/test');

        // Should not throw
        await guard.onAfter(context);
      });
    });

    nyGroup('setRouteContext()', () {
      nyTest('should reset state when called', () async {
        final guard = _TestNyRouteGuard();

        // Set some state
        guard.setRouteContext(RouteContext(routeName: '/first'));
        guard.redirect('/somewhere');
        guard.setData('modified');

        expect(guard.redirectConfig, isNotNull);
        expect(guard.hasModifiedData, isTrue);

        // Reset with new context
        guard.setRouteContext(RouteContext(routeName: '/second'));

        expect(guard.redirectConfig, isNull);
        expect(guard.hasModifiedData, isFalse);
        expect(guard.routeName, '/second');
      });
    });
  });

  nyGroup('PageRequest', () {
    nyGroup('constructor', () {
      nyTest('should create with no arguments', () async {
        final request = PageRequest();

        expect(request.context, isNull);
        expect(request.nyArgument, isNull);
        expect(request.queryParameters, isNull);
        expect(request.isRedirect, isFalse);
        expect(request.routeData, isNull);
      });

      nyTest('should create with all arguments', () async {
        final request = PageRequest(
          nyArgument: NyArgument('test'),
          queryParameters: {'key': 'value'},
        );

        expect(request.nyArgument!.data, 'test');
        expect(request.queryParameters, {'key': 'value'});
      });
    });

    nyGroup('data getter', () {
      nyTest('should return nyArgument data', () async {
        final request = PageRequest(nyArgument: NyArgument({'id': 42}));

        expect(request.data, {'id': 42});
      });

      nyTest('should return null when nyArgument is null', () async {
        final request = PageRequest();

        expect(request.data, isNull);
      });
    });

    nyGroup('redirect constructor', () {
      nyTest('should create redirect request', () async {
        final request = PageRequest.redirect('/target');

        expect(request.isRedirect, isTrue);
        expect(request.routeData, isNotNull);
        expect(request.routeData!.path, '/target');
      });

      nyTest('should include all redirect options', () async {
        final request = PageRequest.redirect(
          '/target',
          data: {'id': 1},
          queryParameters: {'page': '1'},
          navigationType: NavigationType.pushAndForgetAll,
          result: 'success',
        );

        expect(request.routeData!.data, {'id': 1});
        expect(request.routeData!.queryParameters, {'page': '1'});
        expect(
          request.routeData!.navigationType,
          NavigationType.pushAndForgetAll,
        );
        expect(request.routeData!.result, 'success');
      });
    });

    nyGroup('addData()', () {
      nyTest('should update nyArgument data', () async {
        final request = PageRequest(
          nyArgument: NyArgument({'original': 'value'}),
        );

        request.addData((data) => {...data, 'new': 'item'});

        expect(request.data, containsPair('original', 'value'));
        expect(request.data, containsPair('new', 'item'));
      });

      nyTest('should handle null nyArgument gracefully', () async {
        final request = PageRequest();

        // Should not throw
        request.addData((data) => {'new': 'value'});
      });
    });

    nyGroup('toRouteContext()', () {
      nyTest('should convert to RouteContext', () async {
        final request = PageRequest(
          nyArgument: NyArgument({'id': 1}),
          queryParameters: {'sort': 'asc'},
        );

        final context = request.toRouteContext('/test');

        expect(context.routeName, '/test');
        expect(context.data, {'id': 1});
        expect(context.queryParameters, {'sort': 'asc'});
      });
    });
  });

  nyGroup('RouteData', () {
    nyGroup('constructor', () {
      nyTest('should create with required path', () async {
        final routeData = RouteData('/home');

        expect(routeData.path, '/home');
        expect(routeData.navigationType, NavigationType.pushReplace);
      });

      nyTest('should create with all parameters', () async {
        final routeData = RouteData(
          '/target',
          data: {'id': 1},
          queryParameters: {'sort': 'asc'},
          navigationType: NavigationType.push,
          result: 'test',
        );

        expect(routeData.path, '/target');
        expect(routeData.data, {'id': 1});
        expect(routeData.queryParameters, {'sort': 'asc'});
        expect(routeData.navigationType, NavigationType.push);
        expect(routeData.result, 'test');
      });
    });

    nyGroup('fromRedirectConfig()', () {
      nyTest('should create RouteData from RedirectConfig', () async {
        final config = RedirectConfig(
          path: '/login',
          data: {'returnTo': '/profile'},
          queryParameters: {'ref': 'guard'},
          navigationType: NavigationType.pushReplace,
        );

        final routeData = RouteData.fromRedirectConfig(config);

        expect(routeData.path, '/login');
        expect(routeData.data, {'returnTo': '/profile'});
        expect(routeData.queryParameters, {'ref': 'guard'});
        expect(routeData.navigationType, NavigationType.pushReplace);
      });
    });

    nyGroup('properties', () {
      nyTest('should have nullable removeUntilPredicate', () async {
        final routeData = RouteData('/path');

        expect(routeData.removeUntilPredicate, isNull);
      });

      nyTest('should have nullable transitionType', () async {
        final routeData = RouteData('/path');

        expect(routeData.transitionType, isNull);
      });

      nyTest('should have nullable pageTransitionSettings', () async {
        final routeData = RouteData('/path');

        expect(routeData.pageTransitionSettings, isNull);
      });

      nyTest('should have nullable pageTransitionType', () async {
        final routeData = RouteData('/path');

        expect(routeData.pageTransitionType, isNull);
      });

      nyTest('should have nullable onPop callback', () async {
        final routeData = RouteData('/path');

        expect(routeData.onPop, isNull);
      });
    });
  });

  nyGroup('RedirectConfig', () {
    nyTest('should create with required path', () async {
      final config = RedirectConfig(path: '/login');

      expect(config.path, '/login');
      expect(config.navigationType, NavigationType.pushReplace);
    });

    nyTest('should create with all parameters', () async {
      final config = RedirectConfig(
        path: '/error',
        data: {'code': 403},
        queryParameters: {'reason': 'forbidden'},
        navigationType: NavigationType.pushAndForgetAll,
        result: 'error',
      );

      expect(config.path, '/error');
      expect(config.data, {'code': 403});
      expect(config.queryParameters, {'reason': 'forbidden'});
      expect(config.navigationType, NavigationType.pushAndForgetAll);
      expect(config.result, 'error');
    });
  });

  nyGroup('Guard implementation scenarios', () {
    nyTest('should allow guard to return next to continue', () async {
      final guard = _AllowAllGuard();
      final context = RouteContext(
        routeName: '/protected',
        data: {'user': 'authenticated'},
      );

      guard.setRouteContext(context);
      final result = await guard.onBefore(context);

      expect(result, GuardResult.next);
    });

    nyTest('should allow guard to redirect', () async {
      final guard = _RedirectGuard();
      final context = RouteContext(routeName: '/protected');

      guard.setRouteContext(context);
      final result = await guard.onBefore(context);

      expect(result, GuardResult.handled);
      expect(guard.redirectConfig, isNotNull);
      expect(guard.redirectConfig!.path, '/login');
    });

    nyTest('should allow guard to modify data', () async {
      final guard = _DataModifyingGuard();
      final context = RouteContext(
        routeName: '/test',
        data: {'original': true},
      );

      guard.setRouteContext(context);
      await guard.onBefore(context);

      expect(guard.hasModifiedData, isTrue);
      expect(guard.modifiedData, containsPair('original', true));
      expect(guard.modifiedData, containsPair('modified', true));
    });

    nyTest('should allow guard to abort without redirect', () async {
      final guard = _AbortGuard();
      final context = RouteContext(routeName: '/blocked');

      guard.setRouteContext(context);
      final result = await guard.onBefore(context);

      expect(result, GuardResult.handled);
      expect(guard.redirectConfig, isNull); // No redirect
    });
  });

  nyGroup('ParameterizedGuard', () {
    nyTest('should accept parameters', () async {
      final guard = _RoleGuard(['admin', 'moderator']);

      expect(guard.params, ['admin', 'moderator']);
    });

    nyTest('should use parameters in guard logic', () async {
      final adminGuard = _RoleGuard(['admin']);
      final context = RouteContext(
        routeName: '/admin',
        data: {'userRole': 'user'},
      );

      adminGuard.setRouteContext(context);
      final result = await adminGuard.onBefore(context);

      expect(result, GuardResult.handled); // Redirected
      expect(adminGuard.redirectConfig!.path, '/unauthorized');
    });
  });

  nyGroup('GuardStack', () {
    nyTest('should execute guards in order until handled', () async {
      final executionOrder = <String>[];
      final stack = GuardStack([
        _TrackingGuard('first', executionOrder),
        _TrackingGuard('second', executionOrder),
        _RedirectGuard(), // This will stop the chain
        _TrackingGuard('third', executionOrder),
      ]);

      final context = RouteContext(routeName: '/test');
      stack.setRouteContext(context);
      final result = await stack.onBefore(context);

      expect(result, GuardResult.handled);
      expect(executionOrder, ['first', 'second']);
      expect(executionOrder, isNot(contains('third')));
    });

    nyTest('should pass modified data between guards', () async {
      final stack = GuardStack([_DataModifyingGuard(), _DataCheckingGuard()]);

      final context = RouteContext(
        routeName: '/test',
        data: {'original': true},
      );
      stack.setRouteContext(context);
      await stack.onBefore(context);

      // DataCheckingGuard should have seen the modified data
      final checkingGuard = stack.guards[1] as _DataCheckingGuard;
      expect(checkingGuard.sawModifiedData, isTrue);
    });

    nyTest('should propagate redirect config', () async {
      final stack = GuardStack([_AllowAllGuard(), _RedirectGuard()]);

      final context = RouteContext(routeName: '/test');
      stack.setRouteContext(context);
      await stack.onBefore(context);

      expect(stack.redirectConfig, isNotNull);
      expect(stack.redirectConfig!.path, '/login');
    });
  });

  nyGroup('ConditionalGuard', () {
    nyTest('should apply guard when condition is true', () async {
      final guard = ConditionalGuard(
        condition: (context) => context.routeName.startsWith('/admin'),
        guard: _RedirectGuard(),
      );

      final context = RouteContext(routeName: '/admin/dashboard');
      guard.setRouteContext(context);
      final result = await guard.onBefore(context);

      expect(result, GuardResult.handled);
      expect(guard.redirectConfig!.path, '/login');
    });

    nyTest('should skip guard when condition is false', () async {
      final guard = ConditionalGuard(
        condition: (context) => context.routeName.startsWith('/admin'),
        guard: _RedirectGuard(),
      );

      final context = RouteContext(routeName: '/public/page');
      guard.setRouteContext(context);
      final result = await guard.onBefore(context);

      expect(result, GuardResult.next);
      expect(guard.redirectConfig, isNull);
    });
  });

  nyGroup('Backward compatibility', () {
    nyTest('NyRouteGuard onRequest should delegate to onBefore', () async {
      final guard = _NewStyleGuard();
      final request = PageRequest(
        nyArgument: NyArgument({'test': true}),
        queryParameters: {'page': '1'},
      );

      final result = await guard.onRequest(request);

      expect(result, isNotNull);
      expect(result!.isRedirect, isTrue);
      expect(result.routeData!.path, '/redirected');
    });
  });
}

class _BasicRouteGuard extends RouteGuard {}

class _TestNyRouteGuard extends NyRouteGuard {}

class _AllowAllGuard extends NyRouteGuard {
  @override
  Future<GuardResult> onBefore(RouteContext context) async {
    return next();
  }
}

class _RedirectGuard extends NyRouteGuard {
  @override
  Future<GuardResult> onBefore(RouteContext context) async {
    return redirect('/login');
  }
}

class _DataModifyingGuard extends NyRouteGuard {
  @override
  Future<GuardResult> onBefore(RouteContext context) async {
    final currentData = context.data as Map<String, dynamic>? ?? {};
    setData({...currentData, 'modified': true});
    return next();
  }
}

class _AbortGuard extends NyRouteGuard {
  @override
  Future<GuardResult> onBefore(RouteContext context) async {
    return abort();
  }
}

class _RoleGuard extends ParameterizedGuard<List<String>> {
  _RoleGuard(super.params);

  @override
  Future<GuardResult> onBefore(RouteContext context) async {
    final userRole = (context.data as Map<String, dynamic>?)?['userRole'];
    if (!params.contains(userRole)) {
      return redirect('/unauthorized');
    }
    return next();
  }
}

class _TrackingGuard extends NyRouteGuard {
  final String name;
  final List<String> executionOrder;

  _TrackingGuard(this.name, this.executionOrder);

  @override
  Future<GuardResult> onBefore(RouteContext context) async {
    executionOrder.add(name);
    return next();
  }
}

class _DataCheckingGuard extends NyRouteGuard {
  bool sawModifiedData = false;

  @override
  Future<GuardResult> onBefore(RouteContext context) async {
    final data = context.data as Map<String, dynamic>?;
    if (data != null && data['modified'] == true) {
      sawModifiedData = true;
    }
    return next();
  }
}

class _NewStyleGuard extends NyRouteGuard {
  @override
  Future<GuardResult> onBefore(RouteContext context) async {
    // This guard uses the new API
    return redirect('/redirected');
  }
}
