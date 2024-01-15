import 'dart:io';
import 'package:nylo_support/metro/constants/strings.dart';
import 'package:nylo_support/metro/metro_console.dart';
import 'package:nylo_support/metro/models/ny_command.dart';
import 'package:nylo_support/metro/models/ny_template.dart';
import 'package:recase/recase.dart';
import 'models/metro_project_file.dart';

class MetroService {
  /// Run a command from the terminal
  /// [menu] should contain the list of commands that can be run.
  static Future<void> runCommand(List<String> arguments,
      {required List<NyCommand?> allCommands, required String menu}) async {
    List<String> argumentsForAction = arguments.toList();

    if (argumentsForAction.isEmpty) {
      MetroConsole.writeInBlack(menu);
      return;
    }

    List<String> argumentSplit = arguments[0].split(":");

    if (argumentSplit.length == 0 || argumentSplit.length <= 1) {
      MetroConsole.writeInBlack('Invalid arguments ' + arguments.toString());
      exit(2);
    }

    String type = argumentSplit[0];
    String action = argumentSplit[1];

    NyCommand? nyCommand = allCommands.firstWhereOrNull(
        (command) => type == command?.category && command?.name == action);

    if (nyCommand == null) {
      MetroConsole.writeInBlack('Invalid arguments ' + arguments.toString());
      exit(1);
    }

    argumentsForAction.removeAt(0);

    await nyCommand.action!(argumentsForAction);
  }

  /// Creates a new Controller.
  static Future makeController(String className, String value,
      {String folderPath = controllersFolder,
      bool forceCreate = false,
      String? creationPath}) async {
    String name = className.replaceAll(RegExp(r'(_?controller)'), "");
    ReCase nameReCase = ReCase(name);

    // create missing directories in the project
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
        folderPath: folderPath,
        className: className,
        prefix: "controller",
        creationPath: creationPath);

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);

    String classImport =
        "import '/app/controllers/${creationPath != null ? '$creationPath/' : ''}${nameReCase.snakeCase}_controller.dart';";

    await MetroService.addToConfig(
        configName: "decoders",
        classImport: classImport,
        createTemplate: (file) {
          String controllerName = "${nameReCase.pascalCase}Controller";
          if (file.contains(controllerName)) {
            return "";
          }

          if (file.contains("final Map<Type, dynamic> controllers")) {
            RegExp reg =
                RegExp(r'final Map<Type, dynamic> controllers = \{([^}]*)\};');
            String temp = """
final Map<Type, dynamic> controllers = {${reg.allMatches(file).map((e) => e.group(1)).toList()[0]}
  $controllerName: () => $controllerName(),
};""";

            return file.replaceFirst(
              RegExp(r'final Map<Type, dynamic> controllers = \{([^}]*)\};'),
              temp,
            );
          }

          if (file.contains(
              "final Map<Type, BaseController Function()> controllers")) {
            RegExp reg = RegExp(
                r'final Map<Type, BaseController Function\(\)> controllers = \{([^}]*)\};');
            String temp = """
final Map<Type, BaseController Function\(\)> controllers = {${reg.allMatches(file).map((e) => e.group(1)).toList()[0]}
  $controllerName: () => $controllerName(),
};""";

            return file.replaceFirst(
              RegExp(
                  r'final Map<Type, BaseController Function\(\)> controllers = \{([^}]*)\};'),
              temp,
            );
          }

          RegExp reg = RegExp(
              r'final Map<Type, BaseController> controllers = \{([^}]*)\};');
          String temp = """
final Map<Type, BaseController> controllers = {${reg.allMatches(file).map((e) => e.group(1)).toList()[0]}
  $controllerName: $controllerName(),
};""";

          return file.replaceFirst(
            RegExp(
                r'final Map<Type, BaseController> controllers = \{([^}]*)\};'),
            temp,
          );
        });

    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen(
          '[Controller] ${nameReCase.snakeCase}_controller created 🎉');
    });
  }

  /// Finds the class name from a [className] from a String
  /// and returns a [MetroProjectFile] object.
  static MetroProjectFile createMetroProjectFile(String className,
      {Pattern prefix = ""}) {
    String name = className.replaceAll(prefix, "");
    String? creationPath;

    if (name.contains("/")) {
      List<String> pathSegments = Uri.parse(name).pathSegments.toList();
      name = pathSegments.removeLast();
      creationPath = pathSegments.join("/");
    }
    return MetroProjectFile(name, creationPath: creationPath);
  }

  /// Create directories from a [creationPath].
  static createDirectoriesFromCreationPath(
      String? creationPath, String folder) async {
    if (creationPath != null) {
      for (var segment in creationPath.split("/").toList()) {
        await MetroService.makeDirectory("$folder/$segment");
        folder += '/$segment';
      }
    }
  }

  /// Create a file path.
  static String createPathForDartFile(
      {required String folderPath,
      required String className,
      String? prefix,
      String? creationPath}) {
    if (prefix != null) {
      prefix = "_" + prefix;
    } else {
      prefix = "";
    }
    return '$folderPath/${creationPath != null ? '$creationPath/' : ''}${className.snakeCase}$prefix.dart';
  }

  /// Creates a new Page.
  static makePage(String className, String value,
      {String folderPath = pagesFolder,
      bool forceCreate = false,
      bool addToRoute = true,
      bool isInitialPage = false,
      bool isAuthPage = false,
      String? creationPath}) async {
    String name = className.replaceAll(RegExp(r'(_?page)'), "");

    // create missing directories in the project
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
        folderPath: folderPath,
        className: className,
        prefix: "page",
        creationPath: creationPath);

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen('[Page] ${name.snakeCase}_page created 🎉');
    });

    // add to router
    if (addToRoute == false) return;

    String classImport =
        "import '/resources/pages/${creationPath != null ? '$creationPath/' : ''}${name.snakeCase}_page.dart';";

    await addToRouter(
        classImport: classImport,
        createTemplate: (file) {
          String strAuthPage = "";
          if (isAuthPage) {
            strAuthPage = ", authPage: true";
          }
          String strInitialPage = "";
          if (isInitialPage) {
            strInitialPage = ", initialRoute: true";
          }

          String routeName =
              'router.route(${name.pascalCase}Page.path, (context) => ${name.pascalCase}Page()$strAuthPage$strInitialPage);';
          if (file.contains(routeName)) {
            return "";
          }
          RegExp reg =
              RegExp(r'appRouter\(\) => nyRoutes\(\(router\) {([^}]*)}\);');
          if (reg.allMatches(file).map((e) => e.group(1)).toList().isEmpty) {
            return "";
          }
          String temp =
              """appRouter() => nyRoutes((router) {${reg.allMatches(file).map((e) => e.group(1)).toList()[0]} router.route(${name.pascalCase}Page.path, (context) => ${name.pascalCase}Page()$strAuthPage$strInitialPage);
});""";

          return file.replaceFirst(
            RegExp(r'appRouter\(\) => nyRoutes\(\(router\) {([^}]*)}\);'),
            temp,
          );
        });
  }

  /// Adds a Theme to your config/theme.dart file.
  static addToTheme(String className) async {
    String name = className.replaceAll(RegExp(r'(_?theme)'), "");
    ReCase nameReCase = ReCase(name);

    String classesToAdd =
        """import '/resources/themes/styles/${nameReCase.snakeCase}_theme_colors.dart';
import '/resources/themes/${nameReCase.snakeCase}_theme.dart';""";

    String template = """BaseThemeConfig<ColorStyles>(
    id: '${nameReCase.snakeCase}_theme',
    description: "${nameReCase.titleCase} theme",
    theme: ${nameReCase.paramCase}Theme,
    colors: ${nameReCase.pascalCase}ThemeColors(),
  ),""";

    String filePath = "lib/config/theme.dart";
    String originalFile = await loadAsset(filePath);

    // create new file
    if (originalFile.contains(template)) {
      return "";
    }

    RegExp reg = RegExp(
        r'final List<BaseThemeConfig<ColorStyles>> appThemes = \[([^}]*)\];');
    if (reg.allMatches(originalFile).map((e) => e.group(1)).toList().isEmpty)
      return "";

    String temp =
        """final List<BaseThemeConfig<ColorStyles>> appThemes = [${reg.allMatches(originalFile).map((e) => e.group(1)).toList()[0]} $template
];""";

    String newFile = originalFile.replaceFirst(
      RegExp(
          r'final List<BaseThemeConfig<ColorStyles>> appThemes = \[([^}]*)\];'),
      temp,
    );

    // Add import
    newFile = classesToAdd + "\n" + newFile;

    // save new file
    final File file = File(filePath);
    await file.writeAsString(newFile);
  }

  /// Runs a process
  static runProcess(String command) async {
    List<String> commands = command.split(" ");

    final processArguments = commands.getRange(1, commands.length).toList();
    final process = await Process.start(commands.first, processArguments,
        runInShell: false);
    await stdout.addStream(process.stdout);
    await stderr.addStream(process.stderr);
  }

  /// Creates a new Model.
  static makeModel(String className, String value,
      {String folderPath = modelsFolder,
      bool forceCreate = false,
      bool addToConfig = true,
      bool? skipIfExist = false,
      String? creationPath}) async {
    String name = className.replaceAll(RegExp(r'(_?model)'), "");
    ReCase nameReCase = ReCase(name);

    // create missing directories in the project
    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
        folderPath: folderPath,
        className: className,
        creationPath: creationPath);

    if (skipIfExist == true) {
      if (await hasFile(filePath)) return;
    }
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen('[Model] ${nameReCase.snakeCase} created 🎉');
    });

    if (addToConfig == false) return;

    String classImport = makeImportPathModel(nameReCase.snakeCase,
        creationPath: creationPath ?? "");
    await MetroService.addToConfig(
        configName: "decoders",
        classImport: classImport,
        createTemplate: (file) {
          String modelName = nameReCase.pascalCase;
          if (file.contains(modelName)) {
            return "";
          }

          RegExp reg =
              RegExp(r'final Map<Type, dynamic> modelDecoders = \{([^}]*)\};');
          if (reg.allMatches(file).map((e) => e.group(1)).toList().isEmpty) {
            return file;
          }
          String template = """
final Map<Type, dynamic> modelDecoders = {${reg.allMatches(file).map((e) => e.group(1)).toList()[0]}
  List<$modelName>: (data) => List.from(data).map((json) => $modelName.fromJson(json)).toList(),

  $modelName: (data) => $modelName.fromJson(data),
};""";

          return file.replaceFirst(
              RegExp(r'final Map<Type, dynamic> modelDecoders = \{([^}]*)\};'),
              template);
        });
  }

  /// Creates a new Stateless Widget.
  static makeStatelessWidget(String className, String value,
      {String folderPath = widgetsFolder,
      bool forceCreate = false,
      String? creationPath}) async {
    String name = className.replaceAll(RegExp(r'(_?widget)'), "");
    ReCase nameReCase = ReCase(name);

    // create missing directories in the project
    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
        folderPath: folderPath,
        className: className,
        prefix: "widget",
        creationPath: creationPath);

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen(
          '[Stateless Widget] ${nameReCase.snakeCase} created 🎉');
    });
  }

  /// Creates a new config file.
  static makeConfig(String configName, String value,
      {String folderPath = configFolder,
      bool forceCreate = false,
      String? creationPath}) async {
    String name = configName.replaceAll(RegExp(r'(_?config)'), "");

    // create missing directories in the project
    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
        folderPath: folderPath,
        className: configName,
        creationPath: creationPath);

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen('[Config] ${name.snakeCase} created 🎉');
    });
  }

  /// Creates a new Stateful Widget.
  static makeStatefulWidget(String className, String value,
      {String folderPath = widgetsFolder,
      bool forceCreate = false,
      String? creationPath}) async {
    String name = className.replaceAll(RegExp(r'(_?widget)'), "");

    // create missing directories in the project
    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
        folderPath: folderPath,
        className: className,
        prefix: 'widget',
        creationPath: creationPath);

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen(
          '[Stateful Widget] ${name.snakeCase} created 🎉');
    });
  }

  /// Create a new Interceptor.
  static makeInterceptor(String className, String value,
      {String folderPath = networkingInterceptorsFolder,
      bool forceCreate = false,
      String? creationPath}) async {
    String name = className.replaceAll(RegExp(r'(_?interceptor)'), "");

    // create missing directories in the project
    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
        folderPath: folderPath,
        className: className,
        prefix: 'interceptor',
        creationPath: creationPath);

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen(
          '[Interceptor] ${name.snakeCase}_interceptor created 🎉');
    });
  }

  /// Creates a new Theme.
  static makeTheme(String className, String value,
      {String folderPath = themesFolder, bool forceCreate = false}) async {
    String name = className.replaceAll(RegExp(r'(_?theme)'), "");

    String filePath = '$folderPath/${name.snakeCase}_theme.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen('[Theme] ${name.snakeCase}_theme created 🎉');
    });
  }

  /// Creates a new Provider.
  static makeProvider(String className, String value,
      {String folderPath = providerFolder,
      bool forceCreate = false,
      bool addToConfig = true,
      String? creationPath}) async {
    String name = className.replaceAll(RegExp(r'(_?provider)'), "");

    String filePath = '$folderPath/${name.snakeCase}_provider.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen(
          '[Provider] ${name.snakeCase}_provider created 🎉');
    });

    if (addToConfig == false) return;

    String classImport = makeImportPathProviders(name.snakeCase,
        creationPath: creationPath ?? "");

    await MetroService.addToConfig(
        configName: "providers",
        classImport: classImport,
        createTemplate: (file) {
          String providerName = "${name.pascalCase}Provider";
          if (file.contains(providerName)) {
            return "";
          }

          RegExp reg =
              RegExp(r'final Map<Type, NyProvider> providers = \{([^}]*)\};');
          String template = """
final Map<Type, NyProvider> providers = {${reg.allMatches(file).map((e) => e.group(1)).toList()[0]}
  $providerName: $providerName(),
};""";

          return file.replaceFirst(
              RegExp(r'final Map<Type, NyProvider> providers = \{([^}]*)\};'),
              template);
        });
  }

  /// Creates a new Route Guard.
  static makeRouteGuard(String className, String value,
      {String folderPath = routeGuardsFolder, bool forceCreate = false}) async {
    String name = className.replaceAll(RegExp(r'(_?route_guard)'), "");

    String filePath = '$folderPath/${name.snakeCase}_route_guard.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen('[Route Guard] ${name.snakeCase} created 🎉');
    });
  }

  /// Creates a new Director.
  static makeDirectory(String folderPath) async =>
      await _makeDirectory(folderPath);

  /// Creates a new Event.
  static makeEvent(String className, String value,
      {String folderPath = eventsFolder,
      bool forceCreate = false,
      bool addToConfig = true}) async {
    String name = className.replaceAll(RegExp(r'(_?event)'), "");

    String filePath = '$folderPath/${name.snakeCase}_event.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen('[Event] ${name.snakeCase}_event created 🎉');
    });

    String classImport = makeImportPathEvent(name.snakeCase);
    await MetroService.addToConfig(
        configName: "events",
        classImport: classImport,
        createTemplate: (file) {
          String eventName = "${name.pascalCase}Event";
          if (file.contains(eventName)) {
            return "";
          }

          RegExp reg =
              RegExp(r'final Map<Type, NyEvent> events = \{([^}]*)\};');
          String template =
              """final Map<Type, NyEvent> events = {${reg.allMatches(file).map((e) => e.group(1)).toList()[0]}
  $eventName: $eventName(),
  };""";

          return file.replaceFirst(
              RegExp(r'final Map<Type, NyEvent> events = \{([^}]*)\};'),
              template);
        });
  }

  /// Creates a new API service.
  static makeApiService(String className, String value,
      {String folderPath = networkingFolder,
      bool forceCreate = false,
      bool addToConfig = true}) async {
    String name = className.replaceAll(RegExp(r'(_?api_service)'), "");

    String filePath = '$folderPath/${name.snakeCase}_api_service.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen(
          '[API Service] ${name.snakeCase}_api_service created 🎉');
    });

    if (addToConfig == false) return;

    String classImport = makeImportPathApiService(name.snakeCase);
    await MetroService.addToConfig(
        configName: "decoders",
        classImport: classImport,
        createTemplate: (file) {
          String apiServiceName = "${name.pascalCase}ApiService";
          if (file.contains(apiServiceName)) {
            return "";
          }

          if (file.contains("final Map<Type, dynamic> apiDecoders =")) {
            RegExp reg =
                RegExp(r'final Map<Type, dynamic> apiDecoders = \{([^}]*)\};');
            String temp = """
final Map<Type, dynamic> apiDecoders = {${reg.allMatches(file).map((e) => e.group(1)).toList()[0]}
  $apiServiceName: $apiServiceName(),
};""";

            return file.replaceFirst(
              RegExp(r'final Map<Type, dynamic> apiDecoders = \{([^}]*)\};'),
              temp,
            );
          }

          if (file.contains("final Map<Type, BaseApiService> apiDecoders =")) {
            RegExp reg = RegExp(
                r'final Map<Type, BaseApiService> apiDecoders = \{([^}]*)\};');
            String temp = """
final Map<Type, BaseApiService> apiDecoders = {${reg.allMatches(file).map((e) => e.group(1)).toList()[0]}
  $apiServiceName: $apiServiceName(),
};""";

            return file.replaceFirst(
              RegExp(
                  r'final Map<Type, BaseApiService> apiDecoders = \{([^}]*)\};'),
              temp,
            );
          }

          if (file.contains("final Map<Type, NyApiService> apiDecoders =")) {
            RegExp reg = RegExp(
                r'final Map<Type, NyApiService> apiDecoders = \{([^}]*)\};');
            String temp = """
final Map<Type, NyApiService> apiDecoders = {${reg.allMatches(file).map((e) => e.group(1)).toList()[0]}
  $apiServiceName: $apiServiceName(),
};""";

            return file.replaceFirst(
              RegExp(
                  r'final Map<Type, NyApiService> apiDecoders = \{([^}]*)\};'),
              temp,
            );
          }

          return file;
        });
  }

  /// Creates a new Stateful Widget.
  static makeThemeColors(String className, String value,
      {String folderPath = themeColorsFolder, bool forceCreate = false}) async {
    String filePath =
        '$folderPath/${className.toLowerCase()}_theme_colors.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  /// Check if a file exist by passing in a [path].
  static Future<bool> hasFile(path) async => await File(path).exists();

  /// Attempts to replace a file. Provide a [configName] to select which file to replace.
  /// Then you can use the callback [originalFile] to get the file and manipulate it.
  static addToConfig(
      {required String configName,
      required String classImport,
      required String Function(String originalFile) createTemplate}) async {
    // add it to the decoder config
    String filePath = "lib/config/$configName.dart";
    String originalFile = await loadAsset(filePath);

    // create new file
    String fileCreated = createTemplate(originalFile);
    if (fileCreated == "") {
      return;
    }

    // Add import
    fileCreated = classImport + "\n" + fileCreated;

    // save new file
    final File file = File(filePath);
    await file.writeAsString(fileCreated);
  }

  /// Attempts to replace a file. Provide a [routerName] to select which file to replace.
  /// Then you can use the callback [originalFile] to get the file and manipulate it.
  static addToRouter(
      {String routerName = "router",
      required String classImport,
      required String Function(String originalFile) createTemplate}) async {
    // add it to the decoder config
    String filePath = "lib/routes/$routerName.dart";
    String originalFile = await loadAsset(filePath);

    // create new file
    String fileCreated = createTemplate(originalFile);
    if (fileCreated == "") {
      return;
    }

    // Add import
    fileCreated = classImport + "\n" + fileCreated;

    // save new file
    final File file = File(filePath);
    RegExp regEx = RegExp(r'^([\s]+)?}\);([\n\s\S]+)?$');

    await file.writeAsString(fileCreated.replaceAll(regEx, '});'));
  }

  /// Load an asset from the project using an [assetPath].
  static Future<String> loadAsset(String assetPath) async {
    File file = new File(assetPath);
    if ((await file.exists()) == false) {
      return "";
    }
    return await file.readAsString();
  }

  /// Checks if the help flag is set.
  static hasHelpFlag(bool hasHelpFlag, String usage) {
    if (hasHelpFlag) {
      MetroConsole.writeInBlack(usage);
      exit(0);
    }
  }

  /// Checks that a command has [arguments].
  static checkArguments(List<String> arguments, String usage) {
    if (arguments.isEmpty) {
      MetroConsole.writeInBlack(usage);
      exit(1);
    }
  }

  /// Creates a new Slate using [templates].
  static createSlate(List<NyTemplate> templates, {bool? hasForceFlag}) async {
    String pubspecYaml = await MetroService.loadAsset('pubspec.yaml');
    for (var template in templates) {
      for (var pluginRequired in template.pluginsRequired) {
        if ((!pubspecYaml.contains(pluginRequired))) {
          MetroConsole.writeInRed(
              "Your project is missing the $pluginRequired package in your pubspec.yaml file.");
          MetroConsole.writeInGreen("Run 'flutter pub add $pluginRequired'");
          exit(1);
        }
      }
    }

    for (var template in templates) {
      switch (template.saveTo) {
        case controllersFolder:
          {
            await makeController(template.name, template.stub,
                forceCreate: (hasForceFlag ?? false));
            break;
          }
        case widgetsFolder:
          {
            await makeStatelessWidget(template.name, template.stub,
                forceCreate: (hasForceFlag ?? false));
            break;
          }
        case pagesFolder:
          {
            bool isAuthPage = false;
            if (template.options.containsKey('is_auth_page')) {
              isAuthPage = template.options['is_auth_page'];
            }
            bool isInitialPage = false;
            if (template.options.containsKey('is_initial_page')) {
              isInitialPage = template.options['is_initial_page'];
            }
            await makePage(template.name, template.stub,
                forceCreate: (hasForceFlag ?? false),
                addToRoute: true,
                isAuthPage: isAuthPage,
                isInitialPage: isInitialPage);
            break;
          }
        case modelsFolder:
          {
            await makeModel(template.name, template.stub,
                forceCreate: (hasForceFlag ?? false), addToConfig: true);
            break;
          }
        case themesFolder:
          {
            await makeTheme(template.name, template.stub,
                forceCreate: (hasForceFlag ?? false));
            break;
          }
        case providerFolder:
          {
            await makeProvider(template.name, template.stub,
                forceCreate: (hasForceFlag ?? false), addToConfig: true);
            break;
          }
        case eventsFolder:
          {
            await makeEvent(template.name, template.stub,
                forceCreate: (hasForceFlag ?? false), addToConfig: true);
            break;
          }
        case networkingFolder:
          {
            await makeApiService(template.name, template.stub,
                forceCreate: (hasForceFlag ?? false), addToConfig: true);
            break;
          }
        case themeColorsFolder:
          {
            await makeThemeColors(template.name, template.stub,
                forceCreate: (hasForceFlag ?? false));
            break;
          }
        default:
          {
            continue;
          }
      }
    }
  }
}

/// IterableExtension
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

/// Creates a new file from a [path] and [value].
_createNewFile(String path, String value, {Function()? onSuccess}) async {
  final File file = File(path);
  File fileCreated = await file.writeAsString(value);
  if (await fileCreated.exists()) {
    if (onSuccess == null) return;
    onSuccess();
  }
}

/// Creates a new directory from a [path] if it doesn't exist.
_makeDirectory(String path) async {
  Directory directory = Directory(path);
  if (!(await directory.exists())) {
    await directory.create();
  }
}

/// Checks if a file exists from a [path].
/// Use [shouldForceCreate] to override check.
_checkIfFileExists(path, {bool shouldForceCreate = false}) async {
  if (await File(path).exists() && shouldForceCreate == false) {
    MetroConsole.writeInRed('$path already exists');
    exit(1);
  }
}

/// Capitalize a String value.
/// Accepts an [input] and returns a [String].
String capitalize(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1);
}
