import 'dart:convert';
import 'dart:io';
import '/metro/constants/strings.dart';
import '/metro/metro_console.dart';
import '/metro/models/ny_command.dart';
import '/metro/models/ny_template.dart';
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

    if (argumentSplit.isEmpty || argumentSplit.length <= 1) {
      MetroConsole.writeInBlack('Invalid arguments $arguments');
      exit(2);
    }

    String type = argumentSplit[0];
    String action = argumentSplit[1];

    NyCommand? nyCommand = allCommands.firstWhereOrNull(
        (command) => type == command?.category && command?.name == action);

    if (nyCommand == null) {
      MetroConsole.writeInBlack('Invalid arguments $arguments');
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
final Map<Type, BaseController Function()> controllers = {${reg.allMatches(file).map((e) => e.group(1)).toList()[0]}
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
  static Future<void> createDirectoriesFromCreationPath(
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
      prefix = "_$prefix";
    } else {
      prefix = "";
    }
    return '$folderPath/${creationPath != null ? '$creationPath/' : ''}${className.snakeCase}$prefix.dart';
  }

  /// Creates a new Page.
  static Future<void> makePage(String className, String value,
      {String folderPath = pagesFolder,
      bool forceCreate = false,
      bool addToRoute = true,
      bool isInitialPage = false,
      bool isAuthPage = false,
      String? creationPath}) async {
    String name = className.snakeCase.replaceAll(RegExp(r'(_?page)'), "");

    // create missing directories in the project
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
        folderPath: folderPath,
        className: name,
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
            strAuthPage = ", authenticatedRoute: true";
          }
          String strInitialPage = "";
          if (isInitialPage) {
            strInitialPage = ", initialRoute: true";
          }

          String routeName =
              'router.add(${name.pascalCase}Page.path$strAuthPage$strInitialPage);';
          if (file.contains(routeName)) {
            return "";
          }

          RegExp reg = RegExp(r'\}\);(?![\s\S]*\}\);)');

          return file.replaceFirst(reg, "  $routeName\n});");
        });
  }

  /// Creates a new Navigation Hub.
  static Future<void> makeNavigationHub(String className, String value,
      {String folderPath = pagesFolder,
      bool forceCreate = false,
      bool addToRoute = true,
      bool isInitialPage = false,
      bool isAuthPage = false,
      String? creationPath}) async {
    String name =
        className.snakeCase.replaceAll(RegExp(r'(_?navigation_hub)'), "");

    // create missing directories in the project
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
        folderPath: folderPath,
        className: name,
        prefix: "navigation_hub",
        creationPath: creationPath);

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen(
          '[Navigation Hub] ${name.snakeCase}_navigation_hub created 🎉');
    });

    // add to router
    if (addToRoute == false) return;

    String classImport =
        "import '/resources/pages/${creationPath != null ? '$creationPath/' : ''}${name.snakeCase}_navigation_hub.dart';";

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
              'router.add(${name.pascalCase}NavigationHub.path$strAuthPage$strInitialPage);';
          if (file.contains(routeName)) {
            return "";
          }

          RegExp reg = RegExp(r'\}\);(?![\s\S]*\}\);)');

          return file.replaceFirst(reg, "  $routeName\n});");
        });
  }

  /// Adds a Theme to your config/theme.dart file.
  static Future<void> addToTheme(String className) async {
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
      return;
    }

    RegExp reg = RegExp(
        r'final List<BaseThemeConfig<ColorStyles>> appThemes = \[([^}]*)\];');
    if (reg.allMatches(originalFile).map((e) => e.group(1)).toList().isEmpty) {
      return;
    }

    String temp =
        """final List<BaseThemeConfig<ColorStyles>> appThemes = [${reg.allMatches(originalFile).map((e) => e.group(1)).toList()[0]} $template
];""";

    String newFile = originalFile.replaceFirst(
      RegExp(
          r'final List<BaseThemeConfig<ColorStyles>> appThemes = \[([^}]*)\];'),
      temp,
    );

    // Add import
    newFile = "$classesToAdd\n$newFile";

    // save new file
    final File file = File(filePath);
    await file.writeAsString(newFile);
  }

  /// Runs a process
  static Future<int> runProcess(String command) async {
    List<String> commands = command.split(" ");

    final processArguments = commands.getRange(1, commands.length).toList();

    final process =
        await Process.start(commands.first, processArguments, runInShell: true);

    // Connect all streams
    process.stdout.pipe(stdout);
    process.stderr.pipe(stderr);
    stdin.pipe(process.stdin); // This pipes stdin to the child process

    final exitCode = await process.exitCode;

    if (exitCode != 0) {
      MetroConsole.writeInRed("Error: $exitCode");
    }

    return exitCode;
  }

  /// Add a package to your pubspec.yaml file.
  static Future<void> addPackage(String package,
      {String? version, bool dev = false}) async {
    String command = "dart pub add";
    if (dev) {
      command += " --dev";
    }
    command += " $package";
    if (version != null) {
      command += ":$version";
    }
    await runProcess(command);
  }

  /// Add a packages to your pubspec.yaml file.
  static Future<void> addPackages(List<String> packages,
      {bool dev = false}) async {
    String command = "dart pub add";
    if (dev) {
      command += " --dev";
    }
    command += " ${packages.join(" ")}";
    await runProcess(command);
  }

  /// Creates a new Model.
  static Future<void> makeModel(String className, String value,
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
        folderPath: folderPath, className: name, creationPath: creationPath);

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
  static Future<void> makeStatelessWidget(String className, String value,
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
        className: name,
        prefix: "widget",
        creationPath: creationPath);

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen(
          '[Stateless Widget] ${nameReCase.snakeCase} created 🎉');
    });
  }

  /// Creates a new config file.
  static Future<void> makeConfig(String configName, String value,
      {String folderPath = configFolder,
      bool forceCreate = false,
      String? creationPath}) async {
    String name = configName.replaceAll(RegExp(r'(_?config)'), "");

    // create missing directories in the project
    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
        folderPath: folderPath, className: name, creationPath: creationPath);

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen('[Config] ${name.snakeCase} created 🎉');
    });
  }

  /// Creates a new command file.
  static Future<void> makeCommand(String commandName, String value,
      {String folderPath = commandsFolder,
      bool forceCreate = false,
      String? creationPath,
      String? category}) async {
    String name = commandName.replaceAll(RegExp(r'(_?command)'), "");
    ReCase nameReCase = ReCase(name);

    // create missing directories in the project
    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // Check custom_commands.json file exists
    String customCommandsFilePath = "$folderPath/custom_commands.json";
    if (!await hasFile(customCommandsFilePath)) {
      await _createNewFile(customCommandsFilePath, "[]");
    }

    // create file path
    String filePath = createPathForDartFile(
        folderPath: folderPath, className: name, creationPath: creationPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () async {
      MetroConsole.writeInGreen('[Command] ${name.snakeCase} created 🎉');
    });

    // Add to custom_commands.json
    String commandJson = jsonEncode({
      "name": nameReCase.snakeCase,
      "category": category ?? "app",
      "script": "${nameReCase.snakeCase}.dart"
    });

    try {
      File file = File(customCommandsFilePath);

      String customCommandsFile = await loadAsset(customCommandsFilePath);

      List<dynamic> commands = jsonDecode(customCommandsFile);
      if (!commands.any((command) => command["name"] == nameReCase.snakeCase)) {
        commands.add(jsonDecode(commandJson));
      }
      String updatedCommands = jsonEncode(commands);

      // format json file
      String formattedJson = const JsonEncoder.withIndent('  ')
          .convert(jsonDecode(updatedCommands));

      await file.writeAsString(formattedJson);
    } catch (e) {
      MetroConsole.writeInRed(
          '[Command] ${name.snakeCase} failed to create command: $e');
      return;
    }
  }

  /// Creates a new Stateful Widget.
  static Future<void> makeStatefulWidget(String className, String value,
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
        className: name,
        prefix: 'widget',
        creationPath: creationPath);

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen(
          '[Stateful Widget] ${name.snakeCase} created 🎉');
    });
  }

  /// Creates a new Journey Widget.
  static Future<void> makeJourneyWidget(String className, String value,
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
        className: name,
        prefix: 'widget',
        creationPath: creationPath);

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen(
          '[Journey Widget] ${name.snakeCase} created 🎉');
    });
  }

  /// Creates a new State Managed Widget.
  static Future<void> makeStateManagedWidget(String className, String value,
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
        className: name,
        prefix: 'widget',
        creationPath: creationPath);

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen(
          '[State Managed Widget] ${name.snakeCase} created 🎉');
    });
  }

  /// Create a new Interceptor.
  static Future<void> makeInterceptor(String className, String value,
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
        className: name,
        prefix: 'interceptor',
        creationPath: creationPath);

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen(
          '[Interceptor] ${name.snakeCase}_interceptor created 🎉');
    });
  }

  /// Creates a new Theme.
  static Future<void> makeTheme(String className, String value,
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
  static Future<void> makeProvider(String className, String value,
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
  static Future<void> makeRouteGuard(String className, String value,
      {String folderPath = routeGuardsFolder, bool forceCreate = false}) async {
    String name = className.replaceAll(RegExp(r'(_?route_guard)'), "");

    String filePath = '$folderPath/${name.snakeCase}_route_guard.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen('[Route Guard] ${name.snakeCase} created 🎉');
    });
  }

  /// Creates a new Form.
  static Future<void> makeForm(String className, String value,
      {String folderPath = formsFolder, bool forceCreate = false}) async {
    String name = className.replaceAll(RegExp(r'(_?form)'), "");

    String filePath = '$folderPath/${name.snakeCase}_form.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value, onSuccess: () {
      MetroConsole.writeInGreen('[Form] ${name.snakeCase} created 🎉');
    });
  }

  /// Creates a new Director.
  static Future makeDirectory(String folderPath) async =>
      await _makeDirectory(folderPath);

  /// Creates a new Event.
  static Future<void> makeEvent(String className, String value,
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
  static Future<void> makeApiService(String className, String value,
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
  static Future<void> makeThemeColors(String className, String value,
      {String folderPath = themeColorsFolder, bool forceCreate = false}) async {
    String filePath =
        '$folderPath/${className.toLowerCase()}_theme_colors.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  /// Check if a file exist by passing in a [path].
  static Future<bool> hasFile(String path) async => await File(path).exists();

  /// Attempts to replace a file. Provide a [configName] to select which file to replace.
  /// Then you can use the callback [originalFile] to get the file and manipulate it.
  static Future<void> addToConfig(
      {required String configName,
      required String classImport,
      required String Function(String originalFile) createTemplate}) async {
    // add it to the decoder config
    String filePath = "lib/config/$configName.dart";
    String originalFile = await loadAsset(filePath);

    if (originalFile.contains(classImport)) {
      return;
    }

    // create new file
    String fileCreated = createTemplate(originalFile);
    if (fileCreated == "") {
      return;
    }

    // Add import
    fileCreated = "$classImport\n$fileCreated";

    // save new file
    final File file = File(filePath);
    await file.writeAsString(fileCreated);
  }

  /// Attempts to replace a file. Provide a [routerName] to select which file to replace.
  /// Then you can use the callback [originalFile] to get the file and manipulate it.
  static Future<void> addToRouter(
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
    fileCreated = "$classImport\n$fileCreated";

    // save new file
    final File file = File(filePath);
    RegExp regEx = RegExp(r'^([\s]+)?}\);([\n\s\S]+)?$');

    await file.writeAsString(fileCreated.replaceAll(regEx, '});'));
  }

  /// Load an asset from the project using an [assetPath].
  static Future<String> loadAsset(String assetPath) async {
    File file = File(assetPath);
    if ((await file.exists()) == false) {
      return "";
    }
    return await file.readAsString();
  }

  /// Checks if the help flag is set.
  static void hasHelpFlag(bool hasHelpFlag, String usage) {
    if (hasHelpFlag) {
      MetroConsole.writeInBlack(usage);
      exit(0);
    }
  }

  /// Checks that a command has [arguments].
  static void checkArguments(List<String> arguments, String usage) {
    if (arguments.isEmpty) {
      MetroConsole.writeInBlack(usage);
      exit(1);
    }
  }

  /// Creates a new Slate using [templates].
  static Future<void> createSlate(List<NyTemplate> templates,
      {bool? hasForceFlag}) async {
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
      String templateName = template.name;
      switch (template.saveTo) {
        case controllersFolder:
          {
            if (templateName.contains("_controller")) {
              templateName = templateName.replaceAll("_controller", "");
            }
            await makeController(templateName, template.stub,
                forceCreate: (hasForceFlag ?? false));
            break;
          }
        case widgetsFolder:
          {
            await makeStatelessWidget(templateName, template.stub,
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
            if (templateName.contains("_page")) {
              templateName = templateName.replaceAll("_page", "");
            }
            await makePage(templateName, template.stub,
                forceCreate: (hasForceFlag ?? false),
                addToRoute: true,
                isAuthPage: isAuthPage,
                isInitialPage: isInitialPage);
            break;
          }
        case modelsFolder:
          {
            await makeModel(templateName, template.stub,
                forceCreate: (hasForceFlag ?? false), addToConfig: true);
            break;
          }
        case themesFolder:
          {
            if (templateName.contains("_theme")) {
              templateName = templateName.replaceAll("_theme", "");
            }
            await makeTheme(templateName, template.stub,
                forceCreate: (hasForceFlag ?? false));
            break;
          }
        case providerFolder:
          {
            if (templateName.contains("_provider")) {
              templateName = templateName.replaceAll("_provider", "");
            }
            await makeProvider(templateName, template.stub,
                forceCreate: (hasForceFlag ?? false), addToConfig: true);
            break;
          }
        case eventsFolder:
          {
            if (templateName.contains("_event")) {
              templateName = templateName.replaceAll("_event", "");
            }
            await makeEvent(templateName, template.stub,
                forceCreate: (hasForceFlag ?? false), addToConfig: true);
            break;
          }
        case networkingFolder:
          {
            if (templateName.contains("_api_service")) {
              templateName = templateName.replaceAll("_api_service", "");
            }
            await makeApiService(templateName, template.stub,
                forceCreate: (hasForceFlag ?? false), addToConfig: true);
            break;
          }
        case themeColorsFolder:
          {
            if (templateName.contains("_theme_colors")) {
              templateName = templateName.replaceAll("_theme_colors", "");
            }
            await makeThemeColors(templateName, template.stub,
                forceCreate: (hasForceFlag ?? false));
            break;
          }
        case formsFolder:
          {
            if (templateName.contains("_form")) {
              templateName = templateName.replaceAll("_form", "");
            }
            await makeForm(templateName, template.stub,
                forceCreate: (hasForceFlag ?? false));
            break;
          }
        case commandsFolder:
          {
            if (templateName.contains("_command")) {
              templateName = templateName.replaceAll("_command", "");
            }
            String category = 'app';
            if (template.options.containsKey('category')) {
              category = template.options['category'];
            }
            await makeCommand(templateName, template.stub,
                forceCreate: (hasForceFlag ?? false), category: category);
            break;
          }
        default:
          {
            continue;
          }
      }
    }
  }

  /// Discovers custom commands from a JSON file.
  static Future<List<NyCommand>> discoverCustomCommands() async {
    try {
      final configFile = File('lib/app/commands/custom_commands.json');
      if (await configFile.exists()) {
        final jsonStr = await configFile.readAsString();
        final List<dynamic> commandConfigs = jsonDecode(jsonStr);

        // Remove any duplicate commands from commandConfigs
        final Set<String> commandNames = {};
        commandConfigs.removeWhere((config) {
          final name = config['name'];
          if (commandNames.contains(name)) {
            return true; // Remove duplicate
          } else {
            commandNames.add(name);
            return false; // Keep unique
          }
        });

        // List of commands
        List<NyCommand> allCommands = commandConfigs.map<NyCommand>((config) {
          assert(config['name'] != null,
              'Command "name" is required in custom_commands.json');
          assert(config['script'] != null,
              'Command "script" is required in custom_commands.json');
          return NyCommand(
            name: config['name'],
            category:
                config.containsKey('category') ? config['category'] : "app",
            action: (args) => _executeCommandScript(config['script'], args),
          );
        }).toList();

        // Sort commands by category
        allCommands.sort((a, b) {
          if (a.category == b.category) {
            return (a.name ?? "").compareTo(b.name ?? "");
          }
          return (a.category ?? "").compareTo(b.category ?? "");
        });

        return allCommands;
      }
    } catch (e) {
      MetroConsole.writeInRed(
          'Error loading custom commands: $e\n\nMake sure to create a custom_commands.json file in the lib/app/commands directory.');
    }
    return [];
  }

  /// Executes a command script.
  static Future<void> _executeCommandScript(
      String scriptPath, List<String> args) async {
    final script = File('lib/app/commands/$scriptPath');
    if (await script.exists()) {
      await runProcess('dart run ${script.path} ${args.join(' ')}');
    } else {
      MetroConsole.writeInRed('Command script not found: $scriptPath');
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
Future<void> _createNewFile(String path, String value,
    {Function()? onSuccess}) async {
  final File file = File(path);
  File fileCreated = await file.writeAsString(value);
  if (await fileCreated.exists()) {
    if (onSuccess == null) return;
    onSuccess();
  }
}

/// Creates a new directory from a [path] if it doesn't exist.
Future<void> _makeDirectory(String path) async {
  Directory directory = Directory(path);
  if (!(await directory.exists())) {
    await directory.create();
  }
}

/// Checks if a file exists from a [path].
/// Use [shouldForceCreate] to override check.
Future<void> _checkIfFileExists(String path,
    {bool shouldForceCreate = false}) async {
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
