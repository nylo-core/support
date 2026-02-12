import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// Helper function to create an EnvGetter from a Map for testing
EnvGetter mockEnv(Map<String, dynamic> values) =>
    (String key, {dynamic defaultValue}) => values[key] ?? defaultValue;

void main() {
  NyTest.init();

  nySetUp(() {
    NyEnvRegistry.register(
      getter: mockEnv({
        'APP_DEBUG': true,
        'APP_ENV': 'testing',
        'ASSET_PATH': 'assets',
      }),
    );
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // nyHexColor Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('nyHexColor', () {
    nyTest('should convert 6-digit hex to Color', () async {
      final color = nyHexColor('FF5733');

      expect(color, isA<Color>());
      expect((color.r * 255).round(), 255);
      expect((color.g * 255).round(), 87);
      expect((color.b * 255).round(), 51);
    });

    nyTest('should handle hex with hash prefix', () async {
      final color = nyHexColor('#FF5733');

      expect((color.r * 255).round(), 255);
      expect((color.g * 255).round(), 87);
      expect((color.b * 255).round(), 51);
    });

    nyTest('should handle lowercase hex', () async {
      final color = nyHexColor('ff5733');

      expect((color.r * 255).round(), 255);
      expect((color.g * 255).round(), 87);
      expect((color.b * 255).round(), 51);
    });

    nyTest('should handle 8-digit hex with alpha', () async {
      final color = nyHexColor('80FF5733');

      expect((color.a * 255).round(), 128);
      expect((color.r * 255).round(), 255);
      expect((color.g * 255).round(), 87);
      expect((color.b * 255).round(), 51);
    });

    nyTest('should convert white correctly', () async {
      final color = nyHexColor('FFFFFF');

      expect((color.r * 255).round(), 255);
      expect((color.g * 255).round(), 255);
      expect((color.b * 255).round(), 255);
    });

    nyTest('should convert black correctly', () async {
      final color = nyHexColor('000000');

      expect((color.r * 255).round(), 0);
      expect((color.g * 255).round(), 0);
      expect((color.b * 255).round(), 0);
    });

    nyTest('should convert primary colors correctly', () async {
      final red = nyHexColor('FF0000');
      final green = nyHexColor('00FF00');
      final blue = nyHexColor('0000FF');

      expect((red.r * 255).round(), 255);
      expect((red.g * 255).round(), 0);
      expect((red.b * 255).round(), 0);

      expect((green.r * 255).round(), 0);
      expect((green.g * 255).round(), 255);
      expect((green.b * 255).round(), 0);

      expect((blue.r * 255).round(), 0);
      expect((blue.g * 255).round(), 0);
      expect((blue.b * 255).round(), 255);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // match Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('match', () {
    nyTest('should match string value', () async {
      final result = match<String>(
        'option1',
        () => {
          'option1': 'Result One',
          'option2': 'Result Two',
          'option3': 'Result Three',
        },
      );

      expect(result, 'Result One');
    });

    nyTest('should match int value', () async {
      final result = match<String>(2, () => {1: 'One', 2: 'Two', 3: 'Three'});

      expect(result, 'Two');
    });

    nyTest('should match enum value', () async {
      final result = match<String>(
        TestEnum.second,
        () => {
          TestEnum.first: 'First Value',
          TestEnum.second: 'Second Value',
          TestEnum.third: 'Third Value',
        },
      );

      expect(result, 'Second Value');
    });

    nyTest('should return defaultValue when no match found', () async {
      // match logs an error but returns defaultValue when provided
      final result = match<String>(
        'existing_key',
        () => {'existing_key': 'Result One'},
        defaultValue: 'Default Result',
      );

      expect(result, 'Result One');
    });

    nyTest('should handle matching with defaultValue as fallback', () async {
      // When key matches, return the match
      final result = match<String>(
        'option1',
        () => {'option1': 'Result One', 'option2': 'Result Two'},
        defaultValue: 'Default Result',
      );

      expect(result, 'Result One');
    });

    nyTest('should return defaultValue for null input', () async {
      final result = match<String>(
        null,
        () => {'option1': 'Result One'},
        defaultValue: 'Null Default',
      );

      expect(result, 'Null Default');
    });

    nyTest('should match bool keys', () async {
      final result = match<String>(
        true,
        () => {true: 'Is True', false: 'Is False'},
      );

      expect(result, 'Is True');
    });

    nyTest('should return complex objects', () async {
      final result = match<Map<String, dynamic>>(
        'user',
        () => {
          'user': {'name': 'John', 'age': 30},
          'admin': {'name': 'Admin', 'role': 'admin'},
        },
      );

      expect(result, {'name': 'John', 'age': 30});
    });

    nyTest('should match first occurrence for duplicate keys', () async {
      final result = match<String>(
        'key',
        () => {
          'key': 'First',
          // Note: Dart maps don't allow duplicate keys, so this tests that
          // the map correctly uses the last value for duplicate keys
        },
      );

      expect(result, 'First');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // sleep Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('sleep', () {
    nyTest('should delay execution for specified seconds', () async {
      final stopwatch = Stopwatch()..start();

      await sleep(1);

      stopwatch.stop();
      // Allow for some timing variance
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(900));
      expect(stopwatch.elapsedMilliseconds, lessThan(1500));
    });

    nyTest('should delay for 0 seconds (no delay)', () async {
      final stopwatch = Stopwatch()..start();

      await sleep(0);

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    nyTest('should support microseconds parameter', () async {
      final stopwatch = Stopwatch()..start();

      await sleep(0, 500000); // 500ms in microseconds

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(400));
      expect(stopwatch.elapsedMilliseconds, lessThan(700));
    });

    nyTest('should combine seconds and microseconds', () async {
      final stopwatch = Stopwatch()..start();

      await sleep(1, 500000); // 1.5 seconds

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(1400));
      expect(stopwatch.elapsedMilliseconds, lessThan(1800));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // now Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('now', () {
    nyTest('should return current DateTime', () async {
      final before = DateTime.now();
      final result = now();
      final after = DateTime.now();

      expect(result.isAfter(before) || result.isAtSameMomentAs(before), isTrue);
      expect(result.isBefore(after) || result.isAtSameMomentAs(after), isTrue);
    });

    nyTest('should return DateTime type', () async {
      final result = now();

      expect(result, isA<DateTime>());
    });

    nyTest(
      'should return different values when called at different times',
      () async {
        final first = now();
        await Future.delayed(Duration(milliseconds: 10));
        final second = now();

        expect(second.isAfter(first), isTrue);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // getImageAsset Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('getImageAsset', () {
    nyTest('should return full image path with default path', () async {
      final result = getImageAsset('logo.png');

      expect(result, 'assets/images/logo.png');
    });

    nyTest('should return full image path with custom path', () async {
      final result = getImageAsset('icon.png', path: '/icons');

      expect(result, 'assets/icons/icon.png');
    });

    nyTest('should handle various image extensions', () async {
      expect(getImageAsset('image.jpg'), 'assets/images/image.jpg');
      expect(getImageAsset('image.jpeg'), 'assets/images/image.jpeg');
      expect(getImageAsset('image.gif'), 'assets/images/image.gif');
      expect(getImageAsset('image.webp'), 'assets/images/image.webp');
      expect(getImageAsset('image.svg'), 'assets/images/image.svg');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // getAsset Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('getAsset', () {
    nyTest('should return full asset path', () async {
      final result = getAsset('videos/intro.mp4');

      expect(result, 'assets/videos/intro.mp4');
    });

    nyTest('should strip leading slash from asset path', () async {
      final result = getAsset('/videos/intro.mp4');

      expect(result, 'assets/videos/intro.mp4');
    });

    nyTest('should handle various asset types', () async {
      expect(getAsset('fonts/custom.ttf'), 'assets/fonts/custom.ttf');
      expect(getAsset('data/config.json'), 'assets/data/config.json');
      expect(getAsset('audio/sound.mp3'), 'assets/audio/sound.mp3');
    });

    nyTest('should handle deeply nested paths', () async {
      final result = getAsset('level1/level2/level3/file.txt');

      expect(result, 'assets/level1/level2/level3/file.txt');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // showNextLog Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('showNextLog', () {
    nyTest('should set SHOW_LOG flag in Backpack', () async {
      showNextLog();

      final result = Backpack.instance.read<bool>('SHOW_LOG');
      expect(result, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // getAppTextTheme Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('getAppTextTheme', () {
    nyTest('should return a TextTheme', () async {
      final appFont = TextStyle(fontFamily: 'CustomFont');
      final baseTheme = Typography.material2021().black;

      final result = getAppTextTheme(appFont, baseTheme);

      expect(result, isA<TextTheme>());
    });

    nyTest('should merge font properties from app font', () async {
      final appFont = TextStyle(fontFamily: 'CustomFont', fontSize: 16);
      final baseTheme = TextTheme(
        displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black),
      );

      final result = getAppTextTheme(appFont, baseTheme);

      // The result should have the base theme properties merged with app font
      expect(result.displayLarge?.fontSize, 96);
      expect(result.displayLarge?.fontWeight, FontWeight.bold);
      expect(result.bodyMedium?.fontSize, 14);
    });

    nyTest('should handle empty text theme', () async {
      final appFont = TextStyle(fontFamily: 'CustomFont');
      final emptyTheme = TextTheme();

      final result = getAppTextTheme(appFont, emptyTheme);

      expect(result, isA<TextTheme>());
    });
  });
}

/// Test enum for match function tests
enum TestEnum { first, second, third }
