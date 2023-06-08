import 'dart:io';
import 'package:nylo_support/metro/constants/strings.dart';
import 'package:nylo_support/metro/metro_console.dart';
import 'package:nylo_support/metro/models/ny_command.dart';
import 'package:nylo_support/metro/models/ny_template.dart';
import 'package:recase/recase.dart';

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
      {String folderPath = controllersFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}_controller.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  /// Creates a new Page.
  static makePage(String className, String value,
      {String folderPath = pagesFolder,
      bool forceCreate = false,
      String? pathWithinFolder}) async {
    String filePath =
        '$folderPath/${pathWithinFolder != null ? '$pathWithinFolder/' : ''}${className.toLowerCase()}_page.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  /// Creates a new Model.
  static makeModel(String className, String value,
      {String folderPath = modelsFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  /// Creates a new Stateless Widget.
  static makeStatelessWidget(String className, String value,
      {String folderPath = widgetsFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}_widget.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  /// Creates a new Stateful Widget.
  static makeStatefulWidget(String className, String value,
      {String folderPath = widgetsFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}_widget.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  /// Creates a new Theme.
  static makeTheme(String className, String value,
      {String folderPath = themesFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}_theme.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  /// Creates a new Provider.
  static makeProvider(String className, String value,
      {String folderPath = providerFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}_provider.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  /// Creates a new Route Guard.
  static makeRouteGuard(String className, String value,
      {String folderPath = routeGuardsFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}_route_guard.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  /// Creates a new Director.
  static makeDirectory(String folderPath) async =>
      await _makeDirectory(folderPath);

  /// Creates a new Event.
  static makeEvent(String className, String value,
      {String folderPath = eventsFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}_event.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  /// Creates a new API service.
  static makeApiService(String className, String value,
      {String folderPath = networkingFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}_api_service.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
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
            await makePage(template.name, template.stub,
                forceCreate: (hasForceFlag ?? false));

            String className = template.name;

            String? creationPath;
            if (className.contains("/")) {
              List<String> pathSegments =
                  Uri.parse(className).pathSegments.toList();
              className = pathSegments.removeLast();
              String folder = pagesFolder;

              for (var segment in pathSegments) {
                await MetroService.makeDirectory("$folder/$segment");
                folder += '/$segment';
              }
              creationPath = pathSegments.join("/");
            }

            String classImport =
                "import '/resources/pages/${creationPath != null ? '$creationPath/' : ''}${className.toLowerCase()}_page.dart';";

            ReCase classReCase = ReCase(className);

            await addToRouter(
                classImport: classImport,
                createTemplate: (file) {
                  String routeName =
                      'router.route("/${classReCase.pathCase}", (context) => ${classReCase.pascalCase}Page());';
                  if (file.contains(routeName)) {
                    return "";
                  }
                  RegExp reg = RegExp(
                      r'appRouter\(\) => nyRoutes\(\(router\) {([^}]*)}\);');
                  if (reg
                      .allMatches(file)
                      .map((e) => e.group(1))
                      .toList()
                      .isEmpty) {
                    return "";
                  }
                  String temp = """
appRouter() => nyRoutes((router) {${reg.allMatches(file).map((e) => e.group(1)).toList()[0]}
  router.route("/${classReCase.paramCase}", (context) => ${classReCase.pascalCase}Page());
});
  """;

                  return file.replaceFirst(
                    RegExp(
                        r'appRouter\(\) => nyRoutes\(\(router\) {([^}]*)\n}\);'),
                    temp,
                  );
                });
            break;
          }
        case modelsFolder:
          {
            await makeModel(template.name, template.stub,
                forceCreate: (hasForceFlag ?? false));

            ReCase classReCase = ReCase(template.name);

            String classImport = makeImportPathModel(classReCase.snakeCase);
            await MetroService.addToConfig(
                configName: "decoders",
                classImport: classImport,
                createTemplate: (file) {
                  String modelName = classReCase.pascalCase;
                  if (file.contains(modelName)) {
                    return "";
                  }

                  RegExp reg = RegExp(
                      r'final Map<Type, dynamic> modelDecoders = {([^};]*)};');
                  String template = """
final Map<Type, dynamic> modelDecoders = {${reg.allMatches(file).map((e) => e.group(1)).toList()[0]}
  List<$modelName>: (data) => List.from(data).map((json) => $modelName.fromJson(json)).toList(),

  $modelName: (data) => $modelName.fromJson(data),
};""";

                  return file.replaceFirst(
                      RegExp(
                          r'final Map<Type, dynamic> modelDecoders = {([^};]*)};'),
                      template);
                });
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
                forceCreate: (hasForceFlag ?? false));
            break;
          }
        case eventsFolder:
          {
            await makeEvent(template.name, template.stub,
                forceCreate: (hasForceFlag ?? false));
            break;
          }
        case networkingFolder:
          {
            await makeApiService(template.name, template.stub,
                forceCreate: (hasForceFlag ?? false));
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
      MetroConsole.writeInGreen('${template.name} created 🎉');
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
_createNewFile(String path, String value) async {
  final File file = File(path);
  await file.writeAsString(value);
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
