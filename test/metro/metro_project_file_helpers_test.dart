import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/metro/src/metro_service.dart';

void main() {
  group('MetroService', () {
    group('createMetroProjectFile()', () {
      test('creates MetroProjectFile from simple class name', () {
        final result = MetroService.createMetroProjectFile('UserController');

        expect(result.name, equals('UserController'));
        expect(result.creationPath, isNull);
      });

      test('removes prefix from class name', () {
        final result = MetroService.createMetroProjectFile(
          'UserController',
          prefix: 'Controller',
        );

        expect(result.name, equals('User'));
      });

      test('extracts creation path from name with slashes', () {
        final result = MetroService.createMetroProjectFile(
          'admin/users/UserController',
        );

        expect(result.name, equals('UserController'));
        expect(result.creationPath, equals('admin/users'));
      });

      test('handles single level path', () {
        final result = MetroService.createMetroProjectFile(
          'auth/LoginController',
        );

        expect(result.name, equals('LoginController'));
        expect(result.creationPath, equals('auth'));
      });

      test('handles prefix with path', () {
        final result = MetroService.createMetroProjectFile(
          'admin/UserController',
          prefix: 'Controller',
        );

        expect(result.name, equals('User'));
        expect(result.creationPath, equals('admin'));
      });
    });

    group('createPathForDartFile()', () {
      test('creates basic file path', () {
        final path = MetroService.createPathForDartFile(
          folderPath: 'lib/app/controllers',
          className: 'user',
        );

        expect(path, equals('lib/app/controllers/user.dart'));
      });

      test('adds prefix when provided', () {
        final path = MetroService.createPathForDartFile(
          folderPath: 'lib/app/controllers',
          className: 'user',
          prefix: 'controller',
        );

        expect(path, equals('lib/app/controllers/user_controller.dart'));
      });

      test('includes creation path when provided', () {
        final path = MetroService.createPathForDartFile(
          folderPath: 'lib/app/controllers',
          className: 'user',
          creationPath: 'admin',
        );

        expect(path, equals('lib/app/controllers/admin/user.dart'));
      });

      test('includes both prefix and creation path', () {
        final path = MetroService.createPathForDartFile(
          folderPath: 'lib/app/controllers',
          className: 'user',
          prefix: 'controller',
          creationPath: 'admin',
        );

        expect(path, equals('lib/app/controllers/admin/user_controller.dart'));
      });

      test('converts class name to snake_case', () {
        final path = MetroService.createPathForDartFile(
          folderPath: 'lib/app/models',
          className: 'UserProfile',
        );

        expect(path, equals('lib/app/models/user_profile.dart'));
      });
    });
  });

  group('IterableExtension', () {
    group('firstWhereOrNull()', () {
      test('returns first matching element', () {
        final list = [1, 2, 3, 4, 5];
        final result = list.firstWhereOrNull((e) => e > 3);

        expect(result, equals(4));
      });

      test('returns null when no element matches', () {
        final list = [1, 2, 3];
        final result = list.firstWhereOrNull((e) => e > 10);

        expect(result, isNull);
      });

      test('returns null for empty list', () {
        final list = <int>[];
        final result = list.firstWhereOrNull((e) => e > 0);

        expect(result, isNull);
      });

      test('returns first element when all match', () {
        final list = [5, 6, 7, 8];
        final result = list.firstWhereOrNull((e) => e > 4);

        expect(result, equals(5));
      });

      test('works with nullable types', () {
        final list = ['a', null, 'b'];
        final result = list.firstWhereOrNull((e) => e == null);

        expect(result, isNull);
      });
    });
  });

  group('capitalize()', () {
    test('capitalizes first character', () {
      expect(capitalize('hello'), equals('Hello'));
    });

    test('handles already capitalized string', () {
      expect(capitalize('Hello'), equals('Hello'));
    });

    test('handles single character', () {
      expect(capitalize('a'), equals('A'));
    });

    test('handles empty string', () {
      expect(capitalize(''), equals(''));
    });

    test('preserves rest of string', () {
      expect(capitalize('hELLO'), equals('HELLO'));
    });
  });
}
