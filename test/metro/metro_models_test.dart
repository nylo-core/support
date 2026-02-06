import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/metro/src/models/metro_project_file.dart';
import 'package:nylo_support/metro/src/models/ny_command.dart';
import 'package:nylo_support/metro/src/models/ny_template.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  // ===========================================================================
  // MetroProjectFile tests
  // ===========================================================================

  nyGroup('MetroProjectFile', () {
    nyTest('should store name', () async {
      final file = MetroProjectFile('UserController');
      expect(file.name, 'UserController');
    });

    nyTest('should have null creationPath by default', () async {
      final file = MetroProjectFile('Model');
      expect(file.creationPath, isNull);
    });

    nyTest('should accept creationPath', () async {
      final file = MetroProjectFile('Model', creationPath: 'admin/settings');
      expect(file.name, 'Model');
      expect(file.creationPath, 'admin/settings');
    });

    nyTest('name should be mutable', () async {
      final file = MetroProjectFile('Old');
      file.name = 'New';
      expect(file.name, 'New');
    });

    nyTest('creationPath should be mutable', () async {
      final file = MetroProjectFile('Model');
      file.creationPath = 'some/path';
      expect(file.creationPath, 'some/path');
    });
  });

  // ===========================================================================
  // NyCommand tests
  // ===========================================================================

  nyGroup('NyCommand', () {
    nyTest('should create with default null values', () async {
      final cmd = NyCommand();
      expect(cmd.name, isNull);
      expect(cmd.category, isNull);
      expect(cmd.action, isNull);
    });

    nyTest('should store name and category', () async {
      final cmd = NyCommand(name: 'make:model', category: 'app');
      expect(cmd.name, 'make:model');
      expect(cmd.category, 'app');
    });

    nyTest('should accept action function', () async {
      bool called = false;
      final cmd = NyCommand(action: () => called = true);
      cmd.action!();
      expect(called, isTrue);
    });
  });

  // ===========================================================================
  // NyTemplate tests
  // ===========================================================================

  nyGroup('NyTemplate', () {
    nyTest('should create with required fields', () async {
      final template = NyTemplate(
        name: 'controller',
        saveTo: 'lib/app/controllers',
        pluginsRequired: ['nylo_framework'],
        stub: 'class {{className}} {}',
      );
      expect(template.name, 'controller');
      expect(template.saveTo, 'lib/app/controllers');
      expect(template.pluginsRequired, ['nylo_framework']);
      expect(template.stub, 'class {{className}} {}');
    });

    nyTest('should default options to empty map', () async {
      final template = NyTemplate(
        name: 'test',
        saveTo: 'test/',
        pluginsRequired: [],
        stub: '',
      );
      expect(template.options, isEmpty);
    });

    nyTest('should accept custom options', () async {
      final template = NyTemplate(
        name: 'test',
        saveTo: 'test/',
        pluginsRequired: [],
        stub: '',
        options: {'force': true, 'verbose': false},
      );
      expect(template.options['force'], isTrue);
      expect(template.options['verbose'], isFalse);
    });

    nyTest('should store multiple plugins', () async {
      final template = NyTemplate(
        name: 'test',
        saveTo: 'test/',
        pluginsRequired: ['plugin_a', 'plugin_b', 'plugin_c'],
        stub: '',
      );
      expect(template.pluginsRequired, hasLength(3));
    });
  });
}
