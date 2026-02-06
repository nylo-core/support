import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/router/src/errors/route_not_found.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('RouteNotFoundError', () {
    nyTest('should store name', () async {
      final error = RouteNotFoundError(name: '/missing');
      expect(error.name, '/missing');
    });

    nyTest('should be an Error', () async {
      final error = RouteNotFoundError(name: '/test');
      expect(error, isA<Error>());
    });

    nyTest('toString should include route name', () async {
      final error = RouteNotFoundError(name: '/dashboard');
      final str = error.toString();
      expect(str, contains('/dashboard'));
      expect(str, contains('not found'));
    });

    nyTest('toString should mention registration', () async {
      final error = RouteNotFoundError(name: '/settings');
      expect(error.toString(), contains('registered'));
    });

    nyTest('should handle empty name', () async {
      final error = RouteNotFoundError(name: '');
      expect(error.name, '');
      expect(error.toString(), contains("''"));
    });

    nyTest('should handle route with params', () async {
      final error = RouteNotFoundError(name: '/user/123/profile');
      expect(error.name, '/user/123/profile');
      expect(error.toString(), contains('/user/123/profile'));
    });
  });
}
