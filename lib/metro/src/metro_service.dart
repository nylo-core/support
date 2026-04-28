import 'dart:convert';
import 'dart:io';
import '/metro/ny_metro.dart';
import 'package:recase/recase.dart';

class MetroService {
  /// Run a command from the terminal
  /// [menu] should contain the list of commands that can be run.
  static Future<void> runCommand(
    List<String> arguments, {
    required List<NyCommand?> allCommands,
    required String menu,
  }) async {
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
      (command) => type == command?.category && command?.name == action,
    );

    if (nyCommand == null) {
      MetroConsole.writeInBlack('Invalid arguments $arguments');
      exit(1);
    }

    argumentsForAction.removeAt(0);
    await nyCommand.action!(argumentsForAction);
  }

  /// Creates a new Controller.
  static Future makeController(
    String className,
    String value, {
    String folderPath = controllersFolder,
    bool forceCreate = false,
    String? creationPath,
  }) async {
    String name = className.replaceAll(RegExp(r'(_?controller)'), "");
    ReCase nameReCase = ReCase(name);

    // create missing directories in the project
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
      folderPath: folderPath,
      className: className,
      prefix: "controller",
      creationPath: creationPath,
    );

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
          RegExp reg = RegExp(
            r'final Map<Type, dynamic> controllers = \{([^}]*)\};',
          );
          final match = _getFirstRegexMatch(reg, file);
          if (match == null) return file;
          String temp =
              """
final Map<Type, dynamic> controllers = {$match
  $controllerName: () => $controllerName(),
};""";

          return file.replaceFirst(reg, temp);
        }

        if (file.contains(
          "final Map<Type, BaseController Function()> controllers",
        )) {
          RegExp reg = RegExp(
            r'final Map<Type, BaseController Function\(\)> controllers = \{([^}]*)\};',
          );
          final match = _getFirstRegexMatch(reg, file);
          if (match == null) return file;
          String temp =
              """
final Map<Type, BaseController Function()> controllers = {$match
  $controllerName: () => $controllerName(),
};""";

          return file.replaceFirst(reg, temp);
        }

        RegExp reg = RegExp(
          r'final Map<Type, BaseController> controllers = \{([^}]*)\};',
        );
        final match = _getFirstRegexMatch(reg, file);
        if (match == null) return file;
        String temp =
            """
final Map<Type, BaseController> controllers = {$match
  $controllerName: $controllerName(),
};""";

        return file.replaceFirst(reg, temp);
      },
    );

    await _createNewFile(
      filePath,
      value,
      onSuccess: () {
        final linkText = '${nameReCase.snakeCase}_controller';
        final link = MetroConsole.hyperlink(linkText, filePath);
        MetroConsole.writeInGreen('[Controller] $link created 🎉');
      },
    );
  }

  /// Finds the class name from a [className] from a String
  /// and returns a [MetroProjectFile] object.
  static MetroProjectFile createMetroProjectFile(
    String className, {
    Pattern prefix = "",
  }) {
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
    String? creationPath,
    String folder,
  ) async {
    if (creationPath != null) {
      for (var segment in creationPath.split("/").toList()) {
        await MetroService.makeDirectory("$folder/$segment");
        folder += '/$segment';
      }
    }
  }

  /// Create a file path.
  static String createPathForDartFile({
    required String folderPath,
    required String className,
    String? prefix,
    String? creationPath,
  }) {
    if (prefix != null) {
      prefix = "_$prefix";
    } else {
      prefix = "";
    }
    return '$folderPath/${creationPath != null ? '$creationPath/' : ''}${className.snakeCase}$prefix.dart';
  }

  /// Creates a new Page.
  static Future<void> makePage(
    String className,
    String value, {
    String folderPath = pagesFolder,
    bool forceCreate = false,
    bool addToRoute = true,
    bool isInitialPage = false,
    bool isAuthPage = false,
    String? creationPath,
  }) async {
    String name = className.snakeCase.replaceAll(RegExp(r'(_?page)'), "");

    // create missing directories in the project
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
      folderPath: folderPath,
      className: name,
      prefix: "page",
      creationPath: creationPath,
    );

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(
      filePath,
      value,
      onSuccess: () {
        final linkText = '${name.snakeCase}_page';
        final link = MetroConsole.hyperlink(linkText, filePath);
        MetroConsole.writeInGreen('[Page] $link created 🎉');
      },
    );

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

        return file.replaceFirst(reg, "      $routeName\n});");
      },
    );
  }

  /// Creates a new Navigation Hub.
  static Future<void> makeNavigationHub(
    String className,
    String value, {
    String folderPath = pagesFolder,
    bool forceCreate = false,
    bool addToRoute = true,
    bool isInitialPage = false,
    bool isAuthPage = false,
    String? creationPath,
  }) async {
    String name = className.snakeCase.replaceAll(
      RegExp(r'(_?navigation_hub)'),
      "",
    );

    // create missing directories in the project
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
      folderPath: folderPath,
      className: name,
      prefix: "navigation_hub",
      creationPath: creationPath,
    );

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(
      filePath,
      value,
      onSuccess: () {
        final linkText = '${name.snakeCase}_navigation_hub';
        final link = MetroConsole.hyperlink(linkText, filePath);
        MetroConsole.writeInGreen('[Navigation Hub] $link created 🎉');
      },
    );

    // add to router
    if (addToRoute == false) return;

    String classImport =
        "import '/resources/pages/${creationPath != null ? '$creationPath/' : ''}${name.snakeCase}_navigation_hub.dart';";

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
            'router.add(${name.pascalCase}NavigationHub.path$strAuthPage$strInitialPage);';
        if (file.contains(routeName)) {
          return "";
        }

        RegExp reg = RegExp(r'\}\);(?![\s\S]*\}\);)');

        return file.replaceFirst(reg, "      $routeName\n});");
      },
    );
  }

  /// Runs a process
  static Future<int> runProcess(String command) async {
    List<String> commands = command.split(" ");

    final processArguments = commands.getRange(1, commands.length).toList();

    final process = await Process.start(
      commands.first,
      processArguments,
      runInShell: true,
    );

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
  static Future<void> addPackage(
    String package, {
    String? version,
    bool dev = false,
  }) async {
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
  static Future<void> addPackages(
    List<String> packages, {
    bool dev = false,
  }) async {
    String command = "dart pub add";
    if (dev) {
      command += " --dev";
    }
    command += " ${packages.join(" ")}";
    await runProcess(command);
  }

  /// Creates a new Model.
  static Future<void> makeModel(
    String className,
    String value, {
    String folderPath = modelsFolder,
    bool forceCreate = false,
    bool addToConfig = true,
    bool? skipIfExist = false,
    String? creationPath,
  }) async {
    String name = className.replaceAll(RegExp(r'(_?model)'), "");
    ReCase nameReCase = ReCase(name);

    // create missing directories in the project
    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
      folderPath: folderPath,
      className: name,
      creationPath: creationPath,
    );

    if (skipIfExist == true) {
      if (await hasFile(filePath)) return;
    }
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(
      filePath,
      value,
      onSuccess: () {
        final linkText = nameReCase.snakeCase;
        final link = MetroConsole.hyperlink(linkText, filePath);
        MetroConsole.writeInGreen('[Model] $link created 🎉');
      },
    );

    if (addToConfig == false) return;

    String classImport = makeImportPathModel(
      nameReCase.snakeCase,
      creationPath: creationPath ?? "",
    );

    await MetroService.addToConfig(
      configName: "decoders",
      classImport: classImport,
      createTemplate: (file) {
        String modelName = nameReCase.pascalCase;

        RegExp reg = RegExp(
          r'final Map<Type, dynamic> modelDecoders = \{([^}]*)\};',
        );
        final match = _getFirstRegexMatch(reg, file);
        if (match == null) {
          return file;
        }
        String template =
            """
final Map<Type, dynamic> modelDecoders = {$match
  List<$modelName>: (data) => List.from(data).map((json) => $modelName.fromJson(json)).toList(),

  $modelName: (data) => $modelName.fromJson(data),
};""";

        return file.replaceFirst(reg, template);
      },
    );
  }

  /// Creates a new Stateless Widget.
  static Future<void> makeStatelessWidget(
    String className,
    String value, {
    String folderPath = widgetsFolder,
    bool forceCreate = false,
    String? creationPath,
  }) async {
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
      creationPath: creationPath,
    );

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(
      filePath,
      value,
      onSuccess: () {
        final linkText = nameReCase.snakeCase;
        final link = MetroConsole.hyperlink(linkText, filePath);
        MetroConsole.writeInGreen('[Stateless Widget] $link created 🎉');
      },
    );
  }

  /// Creates a new config file.
  static Future<void> makeConfig(
    String configName,
    String value, {
    String folderPath = configFolder,
    bool forceCreate = false,
    String? creationPath,
  }) async {
    String name = configName.replaceAll(RegExp(r'(_?config)'), "");

    // create missing directories in the project
    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
      folderPath: folderPath,
      className: name,
      creationPath: creationPath,
    );

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(
      filePath,
      value,
      onSuccess: () {
        final linkText = name.snakeCase;
        final link = MetroConsole.hyperlink(linkText, filePath);
        MetroConsole.writeInGreen('[Config] $link created 🎉');
      },
    );
  }

  /// Creates a new command file.
  static Future<void> makeCommand(
    String commandName,
    String value, {
    String folderPath = commandsFolder,
    bool forceCreate = false,
    String? creationPath,
    String? category,
  }) async {
    String name = commandName.replaceAll(RegExp(r'(_?command)'), "");
    ReCase nameReCase = ReCase(name);

    // create missing directories in the project
    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // Check commands.json file exists
    String customCommandsFilePath = "$folderPath/commands.json";
    if (!await hasFile(customCommandsFilePath)) {
      await _createNewFile(customCommandsFilePath, "[]");
    }

    // create file path
    String filePath = createPathForDartFile(
      folderPath: folderPath,
      className: name,
      creationPath: creationPath,
    );
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(
      filePath,
      value,
      onSuccess: () async {
        final linkText = name.snakeCase;
        final link = MetroConsole.hyperlink(linkText, filePath);
        MetroConsole.writeInGreen('[Command] $link created 🎉');
      },
    );

    // Add to commands.json
    String commandJson = jsonEncode({
      "name": nameReCase.snakeCase,
      "category": category ?? "app",
      "script": "${nameReCase.snakeCase}.dart",
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
      String formattedJson = const JsonEncoder.withIndent(
        '  ',
      ).convert(jsonDecode(updatedCommands));

      await file.writeAsString(formattedJson);
    } catch (e) {
      MetroConsole.writeInRed(
        '[Command] ${name.snakeCase} failed to create command: $e',
      );
      return;
    }
  }

  /// Creates a new Stateful Widget.
  static Future<void> makeStatefulWidget(
    String className,
    String value, {
    String folderPath = widgetsFolder,
    bool forceCreate = false,
    String? creationPath,
  }) async {
    String name = className.replaceAll(RegExp(r'(_?widget)'), "");

    // create missing directories in the project
    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
      folderPath: folderPath,
      className: name,
      prefix: 'widget',
      creationPath: creationPath,
    );

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(
      filePath,
      value,
      onSuccess: () {
        final linkText = name.snakeCase;
        final link = MetroConsole.hyperlink(linkText, filePath);
        MetroConsole.writeInGreen('[Stateful Widget] $link created 🎉');
      },
    );
  }

  /// Creates a new Journey Widget.
  static Future<void> makeJourneyWidget(
    String className,
    String value, {
    String folderPath = widgetsFolder,
    bool forceCreate = false,
    String? creationPath,
  }) async {
    String name = className.replaceAll(RegExp(r'(_?widget)'), "");

    // create missing directories in the project
    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
      folderPath: folderPath,
      className: name,
      prefix: 'widget',
      creationPath: creationPath,
    );

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(
      filePath,
      value,
      onSuccess: () {
        final linkText = name.snakeCase;
        final link = MetroConsole.hyperlink(linkText, filePath);
        MetroConsole.writeInGreen('[Journey Widget] $link created 🎉');
      },
    );
  }

  /// Creates a new State Managed Widget.
  static Future<void> makeStateManagedWidget(
    String className,
    String value, {
    String folderPath = widgetsFolder,
    bool forceCreate = false,
    String? creationPath,
  }) async {
    String name = className.replaceAll(RegExp(r'(_?widget)'), "");

    // create missing directories in the project
    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
      folderPath: folderPath,
      className: name,
      prefix: 'widget',
      creationPath: creationPath,
    );

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(
      filePath,
      value,
      onSuccess: () {
        final linkText = name.snakeCase;
        final link = MetroConsole.hyperlink(linkText, filePath);
        MetroConsole.writeInGreen('[State Managed Widget] $link created 🎉');
      },
    );
  }

  /// Create a new Interceptor.
  static Future<void> makeInterceptor(
    String className,
    String value, {
    String folderPath = networkingInterceptorsFolder,
    bool forceCreate = false,
    String? creationPath,
  }) async {
    String name = className.replaceAll(RegExp(r'(_?interceptor)'), "");

    // create missing directories in the project
    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    // create file path
    String filePath = createPathForDartFile(
      folderPath: folderPath,
      className: name,
      prefix: 'interceptor',
      creationPath: creationPath,
    );

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(
      filePath,
      value,
      onSuccess: () {
        final linkText = '${name.snakeCase}_interceptor';
        final link = MetroConsole.hyperlink(linkText, filePath);
        MetroConsole.writeInGreen('[Interceptor] $link created 🎉');
      },
    );
  }

  /// Creates a new Provider.
  static Future<void> makeProvider(
    String className,
    String value, {
    String folderPath = providerFolder,
    bool forceCreate = false,
    bool addToConfig = true,
    String? creationPath,
  }) async {
    String name = className.replaceAll(RegExp(r'(_?provider)'), "");

    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    String filePath = createPathForDartFile(
      folderPath: folderPath,
      className: name,
      prefix: "provider",
      creationPath: creationPath,
    );

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(
      filePath,
      value,
      onSuccess: () {
        final linkText = '${name.snakeCase}_provider';
        final link = MetroConsole.hyperlink(linkText, filePath);
        MetroConsole.writeInGreen('[Provider] $link created 🎉');
      },
    );

    if (addToConfig == false) return;

    String classImport = makeImportPathProviders(
      name.snakeCase,
      creationPath: creationPath ?? "",
    );

    await MetroService.addToConfig(
      configName: "providers",
      classImport: classImport,
      createTemplate: (file) {
        String providerName = "${name.pascalCase}Provider";

        RegExp reg = RegExp(
          r'final Map<Type, NyProvider> providers = \{([^}]*)\};',
        );
        final match = _getFirstRegexMatch(reg, file);
        if (match == null) return file;
        String template =
            """
final Map<Type, NyProvider> providers = {$match
  $providerName: $providerName(),
};""";

        return file.replaceFirst(reg, template);
      },
    );
  }

  /// Creates a new Route Guard.
  static Future<void> makeRouteGuard(
    String className,
    String value, {
    String folderPath = routeGuardsFolder,
    bool forceCreate = false,
    String? creationPath,
  }) async {
    String name = className.replaceAll(RegExp(r'(_?route_guard)'), "");

    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    String filePath = createPathForDartFile(
      folderPath: folderPath,
      className: name,
      prefix: "route_guard",
      creationPath: creationPath,
    );

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(
      filePath,
      value,
      onSuccess: () {
        final linkText = name.snakeCase;
        final link = MetroConsole.hyperlink(linkText, filePath);
        MetroConsole.writeInGreen('[Route Guard] $link created 🎉');
      },
    );
  }

  /// Creates a new Form.
  static Future<void> makeForm(
    String className,
    String value, {
    String folderPath = formsFolder,
    bool forceCreate = false,
    String? creationPath,
  }) async {
    String name = className.replaceAll(RegExp(r'(_?form)'), "");

    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    String filePath = createPathForDartFile(
      folderPath: folderPath,
      className: name,
      prefix: "form",
      creationPath: creationPath,
    );

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(
      filePath,
      value,
      onSuccess: () {
        final linkText = name.snakeCase;
        final link = MetroConsole.hyperlink(linkText, filePath);
        MetroConsole.writeInGreen('[Form] $link created 🎉');
      },
    );
  }

  /// Creates a new Director.
  static Future makeDirectory(String folderPath) async =>
      await _makeDirectory(folderPath);

  /// Creates a new Event.
  static Future<void> makeEvent(
    String className,
    String value, {
    String folderPath = eventsFolder,
    bool forceCreate = false,
    bool addToConfig = true,
    String? creationPath,
  }) async {
    String name = className.replaceAll(RegExp(r'(_?event)'), "");

    await _makeDirectory(folderPath);
    await createDirectoriesFromCreationPath(creationPath, folderPath);

    String filePath = createPathForDartFile(
      folderPath: folderPath,
      className: name,
      prefix: "event",
      creationPath: creationPath,
    );

    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(
      filePath,
      value,
      onSuccess: () {
        final linkText = '${name.snakeCase}_event';
        final link = MetroConsole.hyperlink(linkText, filePath);
        MetroConsole.writeInGreen('[Event] $link created 🎉');
      },
    );

    String classImport = makeImportPathEvent(
      name.snakeCase,
      creationPath: creationPath ?? "",
    );
    await MetroService.addToConfig(
      configName: "events",
      classImport: classImport,
      createTemplate: (file) {
        String eventName = "${name.pascalCase}Event";

        RegExp reg = RegExp(r'final Map<Type, NyEvent> events = \{([^}]*)\};');
        final match = _getFirstRegexMatch(reg, file);
        if (match == null) return file;
        String template =
            """final Map<Type, NyEvent> events = {$match
  $eventName: $eventName(),
  };""";

        return file.replaceFirst(reg, template);
      },
    );
  }

  /// Creates a new API service.
  static Future<void> makeApiService(
    String className,
    String value, {
    String folderPath = networkingFolder,
    bool forceCreate = false,
    bool addToConfig = true,
  }) async {
    String name = className.replaceAll(RegExp(r'(_?api_service)'), "");

    String filePath = '$folderPath/${name.snakeCase}_api_service.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(
      filePath,
      value,
      onSuccess: () {
        final linkText = '${name.snakeCase}_api_service';
        final link = MetroConsole.hyperlink(linkText, filePath);
        MetroConsole.writeInGreen('[API Service] $link created 🎉');
      },
    );

    if (addToConfig == false) return;

    String classImport = makeImportPathApiService(name.snakeCase);
    await MetroService.addToConfig(
      configName: "decoders",
      classImport: classImport,
      createTemplate: (file) {
        String apiServiceName = "${name.pascalCase}ApiService";

        if (file.contains("final Map<Type, dynamic> apiDecoders =")) {
          RegExp reg = RegExp(
            r'final Map<Type, dynamic> apiDecoders = \{([^}]*)\};',
          );
          final match = _getFirstRegexMatch(reg, file);
          if (match == null) return file;
          String temp =
              """
final Map<Type, dynamic> apiDecoders = {$match
  $apiServiceName: $apiServiceName(),
};""";

          return file.replaceFirst(reg, temp);
        }

        if (file.contains("final Map<Type, BaseApiService> apiDecoders =")) {
          RegExp reg = RegExp(
            r'final Map<Type, BaseApiService> apiDecoders = \{([^}]*)\};',
          );
          final match = _getFirstRegexMatch(reg, file);
          if (match == null) return file;
          String temp =
              """
final Map<Type, BaseApiService> apiDecoders = {$match
  $apiServiceName: $apiServiceName(),
};""";

          return file.replaceFirst(reg, temp);
        }

        if (file.contains("final Map<Type, NyApiService> apiDecoders =")) {
          RegExp reg = RegExp(
            r'final Map<Type, NyApiService> apiDecoders = \{([^}]*)\};',
          );
          final match = _getFirstRegexMatch(reg, file);
          if (match == null) return file;
          String temp =
              """
final Map<Type, NyApiService> apiDecoders = {$match
  $apiServiceName: $apiServiceName(),
};""";

          return file.replaceFirst(reg, temp);
        }

        return file;
      },
    );
  }

  /// Check if a file exist by passing in a [path].
  static Future<bool> hasFile(String path) async => await File(path).exists();

  /// Attempts to replace a file. Provide a [configName] to select which file to replace.
  /// Then you can use the callback [originalFile] to get the file and manipulate it.
  static Future<void> addToConfig({
    required String configName,
    required String classImport,
    required String Function(String originalFile) createTemplate,
  }) async {
    // add it to the decoder config
    String filePath = "lib/bootstrap/$configName.dart";
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
  static Future<void> addToRouter({
    String routerName = "router",
    required String classImport,
    required String Function(String originalFile) createTemplate,
  }) async {
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
  static Future<void> createSlate(
    List<NyTemplate> templates, {
    bool? hasForceFlag,
  }) async {
    String pubspecYaml = await MetroService.loadAsset('pubspec.yaml');
    for (var template in templates) {
      for (var pluginRequired in template.pluginsRequired) {
        if ((!pubspecYaml.contains(pluginRequired))) {
          MetroConsole.writeInRed(
            "Your project is missing the $pluginRequired package in your pubspec.yaml file.",
          );
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
            await makeController(
              templateName,
              template.stub,
              forceCreate: (hasForceFlag ?? false),
            );
            break;
          }
        case widgetsFolder:
          {
            await makeStatelessWidget(
              templateName,
              template.stub,
              forceCreate: (hasForceFlag ?? false),
            );
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
            await makePage(
              templateName,
              template.stub,
              forceCreate: (hasForceFlag ?? false),
              addToRoute: true,
              isAuthPage: isAuthPage,
              isInitialPage: isInitialPage,
            );
            break;
          }
        case modelsFolder:
          {
            await makeModel(
              templateName,
              template.stub,
              forceCreate: (hasForceFlag ?? false),
              addToConfig: true,
            );
            break;
          }
        case providerFolder:
          {
            if (templateName.contains("_provider")) {
              templateName = templateName.replaceAll("_provider", "");
            }
            await makeProvider(
              templateName,
              template.stub,
              forceCreate: (hasForceFlag ?? false),
              addToConfig: true,
            );
            break;
          }
        case eventsFolder:
          {
            if (templateName.contains("_event")) {
              templateName = templateName.replaceAll("_event", "");
            }
            await makeEvent(
              templateName,
              template.stub,
              forceCreate: (hasForceFlag ?? false),
              addToConfig: true,
            );
            break;
          }
        case networkingFolder:
          {
            if (templateName.contains("_api_service")) {
              templateName = templateName.replaceAll("_api_service", "");
            }
            await makeApiService(
              templateName,
              template.stub,
              forceCreate: (hasForceFlag ?? false),
              addToConfig: true,
            );
            break;
          }
        case formsFolder:
          {
            if (templateName.contains("_form")) {
              templateName = templateName.replaceAll("_form", "");
            }
            await makeForm(
              templateName,
              template.stub,
              forceCreate: (hasForceFlag ?? false),
            );
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
            await makeCommand(
              templateName,
              template.stub,
              forceCreate: (hasForceFlag ?? false),
              category: category,
            );
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
  static Future<List<NyCommand>> discoverCommands(
    List<dynamic> commandConfigs,
  ) async {
    // // Remove any duplicate commands from commandConfigs
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
      assert(
        config['name'] != null,
        'Command "name" is required in commands.json',
      );
      assert(
        config['script'] != null,
        'Command "script" is required in commands.json',
      );
      return NyCommand(
        name: config['name'],
        category: config.containsKey('category') ? config['category'] : "app",
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

  /// Discovers custom commands from a JSON file.
  static Future<List<NyCommand>> discoverCustomCommands() async {
    try {
      final configFile = File('lib/app/commands/commands.json');
      if (await configFile.exists()) {
        final jsonStr = await configFile.readAsString();
        final List<dynamic> commandConfigs = jsonDecode(jsonStr);
        return discoverCommands(commandConfigs);
      }
    } catch (e) {
      MetroConsole.writeInRed(
        'Error loading custom commands: $e\n\nMake sure to create a commands.json file in the lib/app/commands directory.',
      );
    }
    return [];
  }

  /// Executes a command script.
  static Future<void> _executeCommandScript(
    String scriptPath,
    List<String> args,
  ) async {
    final script = File('lib/app/commands/$scriptPath');
    if (await script.exists()) {
      await runProcess('dart run ${script.path} ${args.join(' ')}');
    } else {
      MetroConsole.writeInRed('Command script not found: $scriptPath');
    }
  }

  /// Safely gets the first capture group from regex matches.
  /// Returns null if no matches found.
  static String? _getFirstRegexMatch(RegExp regex, String content) {
    final matches = regex.allMatches(content).toList();
    if (matches.isEmpty) return null;
    return matches.first.group(1);
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
Future<void> _createNewFile(
  String path,
  String value, {
  Function()? onSuccess,
}) async {
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
    await directory.create(recursive: true);
  }
}

/// Checks if a file exists from a [path].
/// Use [shouldForceCreate] to override check.
Future<void> _checkIfFileExists(
  String path, {
  bool shouldForceCreate = false,
}) async {
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
