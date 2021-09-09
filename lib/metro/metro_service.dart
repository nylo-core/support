import 'dart:io';

import 'package:nylo_support/metro/metro_console.dart';

import 'constants/strings.dart';

class MetroService {
  static makeController(String className, String value,
      {String folderPath = controllerFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}_controller.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  static makePage(String className, String value,
      {String folderPath = pageFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}_page.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  static makeModel(String className, String value,
      {String folderPath = modelFolder,
      bool storable = false,
      bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  static makeStatelessWidget(String className, String value,
      {String folderPath = widgetFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}_widget.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }

  static makeStatefulWidget(String className, String value,
      {String folderPath = widgetFolder, bool forceCreate = false}) async {
    String filePath = '$folderPath/${className.toLowerCase()}_widget.dart';

    await _makeDirectory(folderPath);
    await _checkIfFileExists(filePath, shouldForceCreate: forceCreate);
    await _createNewFile(filePath, value);
  }
}

_createNewFile(String path, String value) async {
  final File filePage = File(path);
  await filePage.writeAsString(value);
}

_makeDirectory(String path) async {
  final File dirFolder = File(path);
  if (!(await dirFolder.exists())) {
    await Directory(path).create();
  }
}

_checkIfFileExists(path, {bool shouldForceCreate = false}) async {
  if (await File(path).exists() && shouldForceCreate == false) {
    MetroConsole.writeInRed('$path already exists');
    exit(1);
  }
}

String capitalize(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1);
}
