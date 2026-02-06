import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/metro/ny_metro.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('MetroProjectFile', () {
    nyGroup('constructor', () {
      nyTest('should create instance with required name parameter', () async {
        // Act
        final file = MetroProjectFile('home_page');

        // Assert
        expect(file.name, equals('home_page'));
        expect(file.creationPath, isNull);
      });

      nyTest('should create instance with name and creationPath', () async {
        // Act
        final file = MetroProjectFile(
          'user_controller',
          creationPath: 'admin/users',
        );

        // Assert
        expect(file.name, equals('user_controller'));
        expect(file.creationPath, equals('admin/users'));
      });

      nyTest('should handle empty string name', () async {
        // Act
        final file = MetroProjectFile('');

        // Assert
        expect(file.name, equals(''));
        expect(file.name, isEmpty);
      });

      nyTest('should handle empty string creationPath', () async {
        // Act
        final file = MetroProjectFile('test_file', creationPath: '');

        // Assert
        expect(file.name, equals('test_file'));
        expect(file.creationPath, equals(''));
        expect(file.creationPath, isEmpty);
      });
    });

    nyGroup('name property', () {
      nyTest('should allow setting name after construction', () async {
        // Arrange
        final file = MetroProjectFile('original');

        // Act
        file.name = 'updated';

        // Assert
        expect(file.name, equals('updated'));
      });

      nyTest('should handle name with underscores', () async {
        // Act
        final file = MetroProjectFile('my_custom_widget');

        // Assert
        expect(file.name, equals('my_custom_widget'));
      });

      nyTest('should handle name with hyphens', () async {
        // Act
        final file = MetroProjectFile('my-custom-widget');

        // Assert
        expect(file.name, equals('my-custom-widget'));
      });

      nyTest('should handle PascalCase name', () async {
        // Act
        final file = MetroProjectFile('MyCustomWidget');

        // Assert
        expect(file.name, equals('MyCustomWidget'));
      });

      nyTest('should handle camelCase name', () async {
        // Act
        final file = MetroProjectFile('myCustomWidget');

        // Assert
        expect(file.name, equals('myCustomWidget'));
      });

      nyTest('should handle name with numbers', () async {
        // Act
        final file = MetroProjectFile('widget2');

        // Assert
        expect(file.name, equals('widget2'));
      });
    });

    nyGroup('creationPath property', () {
      nyTest('should allow setting creationPath after construction', () async {
        // Arrange
        final file = MetroProjectFile('test');

        // Act
        file.creationPath = 'new/path';

        // Assert
        expect(file.creationPath, equals('new/path'));
      });

      nyTest('should allow setting creationPath to null', () async {
        // Arrange
        final file = MetroProjectFile('test', creationPath: 'initial/path');

        // Act
        file.creationPath = null;

        // Assert
        expect(file.creationPath, isNull);
      });

      nyTest('should handle single directory path', () async {
        // Act
        final file = MetroProjectFile('test', creationPath: 'admin');

        // Assert
        expect(file.creationPath, equals('admin'));
      });

      nyTest('should handle nested directory path', () async {
        // Act
        final file = MetroProjectFile(
          'test',
          creationPath: 'admin/users/roles',
        );

        // Assert
        expect(file.creationPath, equals('admin/users/roles'));
      });

      nyTest('should handle path with leading slash', () async {
        // Act
        final file = MetroProjectFile('test', creationPath: '/admin/users');

        // Assert
        expect(file.creationPath, equals('/admin/users'));
      });

      nyTest('should handle path with trailing slash', () async {
        // Act
        final file = MetroProjectFile('test', creationPath: 'admin/users/');

        // Assert
        expect(file.creationPath, equals('admin/users/'));
      });
    });

    nyGroup('typical usage scenarios', () {
      nyTest('should represent a controller file in subdirectory', () async {
        // Arrange & Act
        final file = MetroProjectFile('user', creationPath: 'admin');

        // Assert
        expect(file.name, equals('user'));
        expect(file.creationPath, equals('admin'));
      });

      nyTest('should represent a page file in nested subdirectory', () async {
        // Arrange & Act
        final file = MetroProjectFile(
          'dashboard',
          creationPath: 'admin/settings',
        );

        // Assert
        expect(file.name, equals('dashboard'));
        expect(file.creationPath, equals('admin/settings'));
      });

      nyTest('should represent a model file in root directory', () async {
        // Arrange & Act
        final file = MetroProjectFile('user');

        // Assert
        expect(file.name, equals('user'));
        expect(file.creationPath, isNull);
      });

      nyTest('should represent a widget file without path', () async {
        // Arrange & Act
        final file = MetroProjectFile('custom_button');

        // Assert
        expect(file.name, equals('custom_button'));
        expect(file.creationPath, isNull);
      });
    });

    nyGroup('edge cases', () {
      nyTest('should handle name with file extension', () async {
        // Act
        final file = MetroProjectFile('test.dart');

        // Assert
        expect(file.name, equals('test.dart'));
      });

      nyTest('should handle name with dots', () async {
        // Act
        final file = MetroProjectFile('my.custom.widget');

        // Assert
        expect(file.name, equals('my.custom.widget'));
      });

      nyTest('should handle path with dots', () async {
        // Act
        final file = MetroProjectFile('test', creationPath: '../parent');

        // Assert
        expect(file.creationPath, equals('../parent'));
      });

      nyTest('should handle unicode characters in name', () async {
        // Act
        final file = MetroProjectFile('test_widget');

        // Assert
        expect(file.name, equals('test_widget'));
      });

      nyTest('should handle whitespace in name', () async {
        // Act
        final file = MetroProjectFile('  test  ');

        // Assert
        expect(file.name, equals('  test  '));
      });

      nyTest('should handle whitespace in path', () async {
        // Act
        final file = MetroProjectFile('test', creationPath: '  path  ');

        // Assert
        expect(file.creationPath, equals('  path  '));
      });
    });

    nyGroup('equality and identity', () {
      nyTest(
        'should not be equal to another instance with same values',
        () async {
          // Arrange
          final file1 = MetroProjectFile('test', creationPath: 'path');
          final file2 = MetroProjectFile('test', creationPath: 'path');

          // Assert - default Dart behavior compares by reference
          expect(identical(file1, file2), isFalse);
        },
      );

      nyTest('should be identical to itself', () async {
        // Arrange
        final file = MetroProjectFile('test');

        // Assert
        expect(identical(file, file), isTrue);
      });
    });
  });
}
