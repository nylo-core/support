import 'dart:io';
import 'package:nylo_support/metro/constants/strings.dart';
import 'package:nylo_support/metro/metro_console.dart';

class MetroService {
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
      {String folderPath = pagesFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}_page.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  /// Creates a new Model.
  static makeModel(String className, String value,
      {String folderPath = modelsFolder,
      bool storable = false,
      bool forceCreate = false}) async {
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

  /// Creates a new Stateful Widget.
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

  /// Creates a new Director.
  static makeDirectory(String folderPath) async => await _makeDirectory(folderPath);

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
  static hasFile(path) async {
    return await File(path).exists();
  }

  /// Attempts to replace a file. Provide a [configName] to select which file to replace.
  /// Then you can use the callback [originalFile] to get the file and manipulate it.
  static addToConfig({required String configName, required String classImport, required String Function(String originalFile) createTemplate}) async {

    // add it to the decoder config
    String filePath = "lib/config/$configName.dart";
    String originalFile = await loadAsset(filePath);

    // create new file
    String fileCreated = createTemplate(originalFile);
    if (fileCreated == "") {return;}

    // Add import
    fileCreated = classImport + "\n" + fileCreated;

    // save new file
    final File file = File(filePath);
    await file.writeAsString(fileCreated);
  }

  /// Load an asset from the project using an [assetPath].
  static Future<String> loadAsset(String assetPath) async {
    File file = new File(assetPath);
    if ((await file.exists()) == false) {
      return "";
    }
    return await file.readAsString();
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
