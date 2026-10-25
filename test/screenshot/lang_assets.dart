import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/screenshot/ny_screenshot.dart';
import 'package:nylo_support/themes/src/base_theme_config.dart';

const Map<String, String> _langFiles = {
  'lang/en.json': '{"greeting": "Hello"}',
  'lang/es.json': '{"greeting": "Hola"}',
};

/// Serves [_langFiles] and an asset manifest listing them.
void mockLangAssets() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        final String key = utf8.decode(message!.buffer.asUint8List());
        if (key == 'AssetManifest.bin') {
          return const StandardMessageCodec().encodeMessage({
            for (final String path in [
              ..._langFiles.keys,
              'lang/notes/readme.json',
              'assets/images/logo.png',
            ])
              path: <Object?>[],
          });
        }
        final String? body = _langFiles[key];
        return body == null
            ? null
            : ByteData.sublistView(Uint8List.fromList(utf8.encode(body)));
      });
}

/// Loads the language files, the asset manifest, and [missing] language
/// files that don't exist, so rootBundle answers from its cache later.
Future<void> warmLangAssets([List<String> missing = const []]) async {
  for (final String file in [
    ..._langFiles.keys,
    for (final String code in missing) 'lang/$code.json',
  ]) {
    try {
      await rootBundle.loadString(file);
    } catch (_) {
      // Cached as missing.
    }
  }
  await ScreenshotLook.bundledLocales();
}

/// A theme with no colors, called [id].
BaseThemeConfig<Object?> testTheme(String id, Brightness brightness) =>
    BaseThemeConfig<Object?>(
      id: id,
      theme: (_) => ThemeData(brightness: brightness),
      colors: null,
      type: brightness == Brightness.dark
          ? NyThemeType.dark
          : NyThemeType.light,
    );
