import 'dart:io';
import 'package:nylo_support/metro/constants/strings.dart';
import 'package:nylo_support/metro/metro_console.dart';

class MetroService {
  /// Creates a new Controller.
  static Future makeController(String className, String value,
      {String folderPath = controllerFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}_controller.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  /// Creates a new Page.
  static makePage(String className, String value,
      {String folderPath = pageFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}_page.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  /// Creates a new Model.
  static makeModel(String className, String value,
      {String folderPath = modelFolder,
      bool storable = false,
      bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  /// Creates a new Stateless Widget.
  static makeStatelessWidget(String className, String value,
      {String folderPath = widgetFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}_widget.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  /// Creates a new Stateful Widget.
  static makeStatefulWidget(String className, String value,
      {String folderPath = widgetFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}_widget.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  /// Creates a new Stateful Widget.
  static makeTheme(String className, String value,
      {String folderPath = themeFolder, bool forceCreate = false}) async {
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
