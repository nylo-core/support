import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/metro/ny_metro.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NyCommand', () {
    nyGroup('constructor', () {
      nyTest('should create instance with all parameters', () async {
        // Arrange
        actionFn(List<String> args) async => 'executed';

        // Act
        final command = NyCommand(
          name: 'test_command',
          category: 'test_category',
          action: actionFn,
        );

        // Assert
        expect(command.name, equals('test_command'));
        expect(command.category, equals('test_category'));
        expect(command.action, equals(actionFn));
      });

      nyTest('should create instance with default null values', () async {
        // Act
        final command = NyCommand();

        // Assert
        expect(command.name, isNull);
        expect(command.category, isNull);
        expect(command.action, isNull);
      });

      nyTest('should create instance with only name', () async {
        // Act
        final command = NyCommand(name: 'only_name');

        // Assert
        expect(command.name, equals('only_name'));
        expect(command.category, isNull);
        expect(command.action, isNull);
      });

      nyTest('should create instance with only category', () async {
        // Act
        final command = NyCommand(category: 'only_category');

        // Assert
        expect(command.name, isNull);
        expect(command.category, equals('only_category'));
        expect(command.action, isNull);
      });

      nyTest('should create instance with only action', () async {
        // Arrange
        actionFn(List<String> args) async => args;

        // Act
        final command = NyCommand(action: actionFn);

        // Assert
        expect(command.name, isNull);
        expect(command.category, isNull);
        expect(command.action, equals(actionFn));
      });
    });

    nyGroup('package and description', () {
      nyTest('default to null for project commands', () async {
        final command = NyCommand(name: 'deploy', category: 'app');

        expect(command.package, isNull);
        expect(command.description, isNull);
        expect(command.isFromPackage, isFalse);
      });

      nyTest('are kept for package commands', () async {
        final command = NyCommand(
          name: 'create',
          category: 'demo',
          package: 'demo_package',
          description: 'Create a new record',
        );

        expect(command.package, equals('demo_package'));
        expect(command.description, equals('Create a new record'));
        expect(command.isFromPackage, isTrue);
      });
    });

    nyGroup('fullName', () {
      nyTest('joins category and name with a colon', () async {
        expect(
          NyCommand(name: 'create', category: 'demo').fullName,
          equals('demo:create'),
        );
      });

      nyTest('tolerates missing parts', () async {
        expect(NyCommand().fullName, equals(':'));
        expect(NyCommand(name: 'create').fullName, equals(':create'));
      });
    });

    nyGroup('name property', () {
      nyTest('should allow setting name after construction', () async {
        // Arrange
        final command = NyCommand();

        // Act
        command.name = 'updated_name';

        // Assert
        expect(command.name, equals('updated_name'));
      });

      nyTest('should allow setting name to null', () async {
        // Arrange
        final command = NyCommand(name: 'initial_name');

        // Act
        command.name = null;

        // Assert
        expect(command.name, isNull);
      });

      nyTest('should handle empty string name', () async {
        // Act
        final command = NyCommand(name: '');

        // Assert
        expect(command.name, equals(''));
        expect(command.name, isEmpty);
      });

      nyTest('should handle name with special characters', () async {
        // Act
        final command = NyCommand(name: 'make:controller');

        // Assert
        expect(command.name, equals('make:controller'));
      });

      nyTest('should handle name with spaces', () async {
        // Act
        final command = NyCommand(name: 'create new file');

        // Assert
        expect(command.name, equals('create new file'));
      });
    });

    nyGroup('category property', () {
      nyTest('should allow setting category after construction', () async {
        // Arrange
        final command = NyCommand();

        // Act
        command.category = 'updated_category';

        // Assert
        expect(command.category, equals('updated_category'));
      });

      nyTest('should allow setting category to null', () async {
        // Arrange
        final command = NyCommand(category: 'initial_category');

        // Act
        command.category = null;

        // Assert
        expect(command.category, isNull);
      });

      nyTest('should handle empty string category', () async {
        // Act
        final command = NyCommand(category: '');

        // Assert
        expect(command.category, equals(''));
        expect(command.category, isEmpty);
      });

      nyTest('should handle typical category values', () async {
        // Test common category names
        final categories = ['make', 'app', 'db', 'route', 'slate'];

        for (final cat in categories) {
          final command = NyCommand(category: cat);
          expect(command.category, equals(cat));
        }
      });
    });

    nyGroup('action property', () {
      nyTest('should allow setting action after construction', () async {
        // Arrange
        final command = NyCommand();
        newAction(List<String> args) async => 'new_action';

        // Act
        command.action = newAction;

        // Assert
        expect(command.action, isNotNull);
        expect(command.action, equals(newAction));
      });

      nyTest('should allow setting action to null', () async {
        // Arrange
        actionFn(List<String> args) async => 'test';
        final command = NyCommand(action: actionFn);

        // Act
        command.action = null;

        // Assert
        expect(command.action, isNull);
      });

      nyTest('should execute action with arguments', () async {
        // Arrange
        List<String>? capturedArgs;
        actionFn(List<String> args) {
          capturedArgs = args;
          return 'executed';
        }

        final command = NyCommand(action: actionFn);

        // Act
        final result = command.action!(['arg1', 'arg2']);

        // Assert
        expect(result, equals('executed'));
        expect(capturedArgs, equals(['arg1', 'arg2']));
      });

      nyTest('should execute action with empty arguments', () async {
        // Arrange
        List<String>? capturedArgs;
        actionFn(List<String> args) {
          capturedArgs = args;
        }

        final command = NyCommand(action: actionFn);

        // Act
        command.action!(<String>[]);

        // Assert
        expect(capturedArgs, isEmpty);
      });

      nyTest('should handle async action', () async {
        // Arrange
        asyncAction(List<String> args) async {
          await Future.delayed(Duration(milliseconds: 10));
          return 'async_result';
        }

        final command = NyCommand(action: asyncAction);

        // Act
        final result = await command.action!(<String>['test']);

        // Assert
        expect(result, equals('async_result'));
      });
    });

    nyGroup('equality and identity', () {
      nyTest(
        'should not be equal to another instance with same values',
        () async {
          // Arrange
          actionFn(List<String> args) async => null;

          final command1 = NyCommand(
            name: 'test',
            category: 'cat',
            action: actionFn,
          );
          final command2 = NyCommand(
            name: 'test',
            category: 'cat',
            action: actionFn,
          );

          // Assert - by default Dart objects are compared by reference
          expect(identical(command1, command2), isFalse);
        },
      );

      nyTest('should be identical to itself', () async {
        // Arrange
        final command = NyCommand(name: 'test');

        // Assert
        expect(identical(command, command), isTrue);
      });
    });

    nyGroup('realistic usage scenarios', () {
      nyTest('should work as typical metro make:controller command', () async {
        // Arrange
        String? createdController;
        makeControllerAction(List<String> args) {
          if (args.isNotEmpty) {
            createdController = args[0];
          }
        }

        final command = NyCommand(
          name: 'controller',
          category: 'make',
          action: makeControllerAction,
        );

        // Act
        command.action!(['HomeController']);

        // Assert
        expect(command.category, equals('make'));
        expect(command.name, equals('controller'));
        expect(createdController, equals('HomeController'));
      });

      nyTest('should work as typical metro app:init command', () async {
        // Arrange
        bool initialized = false;
        initAction(List<String> args) async {
          initialized = true;
          return {'success': true};
        }

        final command = NyCommand(
          name: 'init',
          category: 'app',
          action: initAction,
        );

        // Act
        final result = await command.action!(<String>[]);

        // Assert
        expect(initialized, isTrue);
        expect(result, equals({'success': true}));
      });

      nyTest('should handle command with multiple arguments', () async {
        // Arrange
        Map<String, String>? capturedOptions;
        commandAction(List<String> args) {
          capturedOptions = {};
          for (var arg in args) {
            if (arg.startsWith('--')) {
              final parts = arg.substring(2).split('=');
              if (parts.length == 2) {
                capturedOptions![parts[0]] = parts[1];
              }
            }
          }
        }

        final command = NyCommand(
          name: 'generate',
          category: 'app',
          action: commandAction,
        );

        // Act
        command.action!([
          '--name=TestWidget',
          '--type=stateless',
          '--force=true',
        ]);

        // Assert
        expect(capturedOptions, isNotNull);
        expect(capturedOptions!['name'], equals('TestWidget'));
        expect(capturedOptions!['type'], equals('stateless'));
        expect(capturedOptions!['force'], equals('true'));
      });
    });
  });
}
