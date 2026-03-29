import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/metro/src/metro_service.dart';
import 'package:nylo_support/metro/src/constants/strings.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('MetroService.createMetroProjectFile', () {
    nyTest('should create from simple class name', () async {
      final projectFile = MetroService.createMetroProjectFile('UserController');
      expect(projectFile.name, 'UserController');
      expect(projectFile.creationPath, isNull);
    });

    nyTest('should strip prefix', () async {
      final projectFile = MetroService.createMetroProjectFile(
        'user_controller',
        prefix: '_controller',
      );
      expect(projectFile.name, 'user');
    });

    nyTest('should extract creation path from slashes', () async {
      final projectFile = MetroService.createMetroProjectFile(
        'admin/UserController',
      );
      expect(projectFile.name, 'UserController');
      expect(projectFile.creationPath, 'admin');
    });

    nyTest('should handle deep creation path', () async {
      final projectFile = MetroService.createMetroProjectFile(
        'admin/settings/UserController',
      );
      expect(projectFile.name, 'UserController');
      expect(projectFile.creationPath, 'admin/settings');
    });
  });

  nyGroup('MetroService.createPathForDartFile', () {
    nyTest('should create path with prefix', () async {
      final path = MetroService.createPathForDartFile(
        folderPath: 'lib/app/controllers',
        className: 'home',
        prefix: 'controller',
      );
      expect(path, 'lib/app/controllers/home_controller.dart');
    });

    nyTest('should create path without prefix', () async {
      final path = MetroService.createPathForDartFile(
        folderPath: 'lib/app/models',
        className: 'user',
      );
      expect(path, 'lib/app/models/user.dart');
    });

    nyTest('should create path with creation path', () async {
      final path = MetroService.createPathForDartFile(
        folderPath: 'lib/app/controllers',
        className: 'home',
        prefix: 'controller',
        creationPath: 'admin',
      );
      expect(path, 'lib/app/controllers/admin/home_controller.dart');
    });

    nyTest('should handle PascalCase class name', () async {
      final path = MetroService.createPathForDartFile(
        folderPath: 'lib/app/models',
        className: 'UserProfile',
      );
      expect(path, 'lib/app/models/user_profile.dart');
    });
  });

  nyGroup('MetroService.discoverCommands', () {
    nyTest('should return empty list for empty input', () async {
      final commands = await MetroService.discoverCommands([]);
      expect(commands, isEmpty);
    });

    nyTest('should create commands from config', () async {
      final commands = await MetroService.discoverCommands([
        {'name': 'test', 'script': 'test.dart', 'category': 'app'},
      ]);
      expect(commands, hasLength(1));
      expect(commands.first.name, 'test');
      expect(commands.first.category, 'app');
    });

    nyTest('should remove duplicate commands', () async {
      final commands = await MetroService.discoverCommands([
        {'name': 'test', 'script': 'test.dart', 'category': 'app'},
        {'name': 'test', 'script': 'test.dart', 'category': 'app'},
      ]);
      expect(commands, hasLength(1));
    });

    nyTest('should sort commands by category', () async {
      final commands = await MetroService.discoverCommands([
        {'name': 'zeta', 'script': 'z.dart', 'category': 'z'},
        {'name': 'alpha', 'script': 'a.dart', 'category': 'a'},
      ]);
      expect(commands.first.category, 'a');
      expect(commands.last.category, 'z');
    });

    nyTest('should sort by name within same category', () async {
      final commands = await MetroService.discoverCommands([
        {'name': 'zeta', 'script': 'z.dart', 'category': 'app'},
        {'name': 'alpha', 'script': 'a.dart', 'category': 'app'},
      ]);
      expect(commands.first.name, 'alpha');
      expect(commands.last.name, 'zeta');
    });

    nyTest('should default category to app', () async {
      final commands = await MetroService.discoverCommands([
        {'name': 'test', 'script': 'test.dart'},
      ]);
      expect(commands.first.category, 'app');
    });
  });

  nyGroup('capitalize', () {
    nyTest('should capitalize first letter', () async {
      expect(capitalize('hello'), 'Hello');
    });

    nyTest('should handle empty string', () async {
      expect(capitalize(''), '');
    });

    nyTest('should handle already capitalized', () async {
      expect(capitalize('Hello'), 'Hello');
    });

    nyTest('should handle single character', () async {
      expect(capitalize('a'), 'A');
    });
  });

  nyGroup('IterableExtension.firstWhereOrNull', () {
    nyTest('should return matching element', () async {
      final result = [1, 2, 3].firstWhereOrNull((e) => e == 2);
      expect(result, 2);
    });

    nyTest('should return null when no match', () async {
      final result = [1, 2, 3].firstWhereOrNull((e) => e == 99);
      expect(result, isNull);
    });

    nyTest('should return first match', () async {
      final result = [1, 2, 2, 3].firstWhereOrNull((e) => e == 2);
      expect(result, 2);
    });

    nyTest('should handle empty list', () async {
      final result = <int>[].firstWhereOrNull((e) => e == 1);
      expect(result, isNull);
    });
  });

  nyGroup('Metro constants', () {
    nyTest('folder paths should be correct', () async {
      expect(controllersFolder, 'lib/app/controllers');
      expect(widgetsFolder, 'lib/resources/widgets');
      expect(pagesFolder, 'lib/resources/pages');
      expect(modelsFolder, 'lib/app/models');
      expect(themesFolder, 'lib/resources/themes');
      expect(providerFolder, 'lib/app/providers');
      expect(formsFolder, 'lib/app/forms');
      expect(eventsFolder, 'lib/app/events');
      expect(networkingFolder, 'lib/app/networking');
      expect(bootstrapFolder, 'lib/bootstrap');
      expect(configFolder, 'lib/config');
      expect(commandsFolder, 'lib/app/commands');
      expect(themeColorsFolder, 'lib/resources/themes/styles');
      expect(routeGuardsFolder, 'lib/routes/guards');
      expect(langFolder, 'lang');
    });

    nyTest('flag names should be correct', () async {
      expect(fileOption, 'file');
      expect(helpFlag, 'help');
      expect(forceFlag, 'force');
      expect(controllerFlag, 'controller');
      expect(modelFlag, 'model');
      expect(jsonFlag, 'json');
      expect(urlFlag, 'url');
      expect(authPageFlag, 'auth');
      expect(initialPageFlag, 'initial');
    });

    nyTest('yaml path should be correct', () async {
      expect(yamlPath, 'pubspec.yaml');
    });
  });

  nyGroup('Import path generators', () {
    nyTest('makeImportPathModel should generate correct path', () async {
      expect(makeImportPathModel('user'), "import '/app/models/user.dart';");
    });

    nyTest('makeImportPathModel with creation path', () async {
      expect(
        makeImportPathModel('user', creationPath: 'admin'),
        "import '/app/models/admin/user.dart';",
      );
    });

    nyTest('makeImportPathApiService should generate correct path', () async {
      expect(
        makeImportPathApiService('user'),
        "import '/app/networking/user_api_service.dart';",
      );
    });

    nyTest('makeImportPathEvent should generate correct path', () async {
      expect(
        makeImportPathEvent('login'),
        "import '/app/events/login_event.dart';",
      );
    });

    nyTest('makeImportPathEvent with creation path', () async {
      expect(
        makeImportPathEvent('login', creationPath: 'auth'),
        "import '/app/events/auth/login_event.dart';",
      );
    });

    nyTest('makeImportPathProviders should generate correct path', () async {
      expect(
        makeImportPathProviders('auth'),
        "import '/app/providers/auth_provider.dart';",
      );
    });

    nyTest('makeImportPathProviders with creation path', () async {
      expect(
        makeImportPathProviders('auth', creationPath: 'services'),
        "import '/app/providers/services/auth_provider.dart';",
      );
    });
  });
}
