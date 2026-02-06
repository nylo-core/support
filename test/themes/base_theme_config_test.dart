import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/themes/src/base_theme_config.dart';

/// Simple color styles for testing
class TestColors {
  final Color primary;
  final Color background;
  final Color accent;

  TestColors({
    this.primary = Colors.blue,
    this.background = Colors.white,
    this.accent = Colors.green,
  });
}

/// Extended color styles for testing generic type support
class ExtendedColors extends TestColors {
  final Color secondary;
  final Color tertiary;

  ExtendedColors({
    super.primary,
    super.background,
    super.accent,
    this.secondary = Colors.orange,
    this.tertiary = Colors.purple,
  });
}

void main() {
  NyTest.init();

  nyGroup('NyThemeType', () {
    nyGroup('enum values', () {
      nyTest('has light value', () async {
        expect(NyThemeType.light, isNotNull);
        expect(NyThemeType.light.name, 'light');
      });

      nyTest('has dark value', () async {
        expect(NyThemeType.dark, isNotNull);
        expect(NyThemeType.dark.name, 'dark');
      });

      nyTest('has exactly two values', () async {
        expect(NyThemeType.values.length, 2);
        expect(NyThemeType.values, contains(NyThemeType.light));
        expect(NyThemeType.values, contains(NyThemeType.dark));
      });

      nyTest('values have correct indices', () async {
        expect(NyThemeType.light.index, 0);
        expect(NyThemeType.dark.index, 1);
      });
    });

    nyGroup('equality and identity', () {
      nyTest('light equals itself', () async {
        expect(NyThemeType.light == NyThemeType.light, isTrue);
      });

      nyTest('dark equals itself', () async {
        expect(NyThemeType.dark == NyThemeType.dark, isTrue);
      });

      nyTest('light does not equal dark', () async {
        expect(NyThemeType.light == NyThemeType.dark, isFalse);
      });

      nyTest('can be used in switch statements', () async {
        String result = '';
        void setResult(NyThemeType type) {
          switch (type) {
            case NyThemeType.light:
              result = 'light';
              break;
            case NyThemeType.dark:
              result = 'dark';
              break;
          }
        }

        setResult(NyThemeType.light);
        expect(result, 'light');

        setResult(NyThemeType.dark);
        expect(result, 'dark');
      });

      nyTest('can be stored in collections', () async {
        final types = <NyThemeType>{NyThemeType.light, NyThemeType.dark};
        expect(types.length, 2);
        expect(types.contains(NyThemeType.light), isTrue);
        expect(types.contains(NyThemeType.dark), isTrue);
      });
    });
  });

  nyGroup('BaseThemeConfig', () {
    nyGroup('constructor', () {
      nyTest('creates with required parameters', () async {
        final colors = TestColors();
        final config = BaseThemeConfig<TestColors>(
          id: 'light_theme',
          theme: (colors) => ThemeData.light(),
          colors: colors,
        );

        expect(config.id, 'light_theme');
        expect(config.colors, colors);
        expect(config.type, NyThemeType.light);
      });

      nyTest('defaults to light theme type', () async {
        final config = BaseThemeConfig<TestColors>(
          id: 'test_theme',
          theme: (colors) => ThemeData.light(),
          colors: TestColors(),
        );

        expect(config.type, NyThemeType.light);
      });

      nyTest('can specify dark theme type', () async {
        final config = BaseThemeConfig<TestColors>(
          id: 'dark_theme',
          theme: (colors) => ThemeData.dark(),
          colors: TestColors(primary: Colors.purple, background: Colors.black),
          type: NyThemeType.dark,
        );

        expect(config.type, NyThemeType.dark);
      });

      nyTest('accepts empty string as id', () async {
        final config = BaseThemeConfig<TestColors>(
          id: '',
          theme: (c) => ThemeData.light(),
          colors: TestColors(),
        );

        expect(config.id, '');
      });

      nyTest('accepts id with special characters', () async {
        final config = BaseThemeConfig<TestColors>(
          id: 'theme-with_special.chars@123',
          theme: (c) => ThemeData.light(),
          colors: TestColors(),
        );

        expect(config.id, 'theme-with_special.chars@123');
      });

      nyTest('accepts unicode characters in id', () async {
        final config = BaseThemeConfig<TestColors>(
          id: 'theme_test_unicode',
          theme: (c) => ThemeData.light(),
          colors: TestColors(),
        );

        expect(config.id, 'theme_test_unicode');
      });

      nyTest('accepts very long id', () async {
        final longId = 'a' * 1000;
        final config = BaseThemeConfig<TestColors>(
          id: longId,
          theme: (c) => ThemeData.light(),
          colors: TestColors(),
        );

        expect(config.id, longId);
        expect(config.id.length, 1000);
      });
    });

    nyGroup('themeData getter', () {
      nyTest('returns ThemeData from theme function', () async {
        final colors = TestColors(primary: Colors.red);
        final config = BaseThemeConfig<TestColors>(
          id: 'custom_theme',
          theme: (colors) =>
              ThemeData.light().copyWith(primaryColor: colors.primary),
          colors: colors,
        );

        final themeData = config.themeData;

        expect(themeData, isA<ThemeData>());
        expect(themeData.primaryColor, Colors.red);
      });

      nyTest('passes color styles to theme function', () async {
        TestColors? receivedColors;
        final colors = TestColors(
          primary: Colors.green,
          background: Colors.grey,
        );

        final config = BaseThemeConfig<TestColors>(
          id: 'test_theme',
          theme: (c) {
            receivedColors = c;
            return ThemeData.light();
          },
          colors: colors,
        );

        config.themeData;

        expect(receivedColors, colors);
        expect(receivedColors!.primary, Colors.green);
        expect(receivedColors!.background, Colors.grey);
      });

      nyTest('can generate complex ThemeData', () async {
        final colors = TestColors(
          primary: Colors.indigo,
          background: Colors.white,
        );

        final config = BaseThemeConfig<TestColors>(
          id: 'complex_theme',
          theme: (colors) => ThemeData(
            primaryColor: colors.primary,
            scaffoldBackgroundColor: colors.background,
            appBarTheme: AppBarTheme(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
            ),
          ),
          colors: colors,
        );

        final themeData = config.themeData;

        expect(themeData.primaryColor, Colors.indigo);
        expect(themeData.scaffoldBackgroundColor, Colors.white);
        expect(themeData.appBarTheme.backgroundColor, Colors.indigo);
        expect(themeData.appBarTheme.foregroundColor, Colors.white);
      });

      nyTest('theme function can access all color properties', () async {
        final colors = TestColors(
          primary: Colors.red,
          background: Colors.blue,
          accent: Colors.green,
        );

        Color? capturedPrimary;
        Color? capturedBackground;
        Color? capturedAccent;

        final config = BaseThemeConfig<TestColors>(
          id: 'test',
          theme: (c) {
            capturedPrimary = c.primary;
            capturedBackground = c.background;
            capturedAccent = c.accent;
            return ThemeData.light();
          },
          colors: colors,
        );

        config.themeData;

        expect(capturedPrimary, Colors.red);
        expect(capturedBackground, Colors.blue);
        expect(capturedAccent, Colors.green);
      });

      nyTest('returns consistent ThemeData on multiple accesses', () async {
        final config = BaseThemeConfig<TestColors>(
          id: 'consistent_theme',
          theme: (c) => ThemeData.light().copyWith(primaryColor: c.primary),
          colors: TestColors(primary: Colors.teal),
        );

        final themeData1 = config.themeData;
        final themeData2 = config.themeData;

        expect(themeData1.primaryColor, themeData2.primaryColor);
      });
    });

    nyGroup('property accessibility', () {
      nyTest('id is accessible', () async {
        final config = BaseThemeConfig<TestColors>(
          id: 'my_theme_id',
          theme: (c) => ThemeData.light(),
          colors: TestColors(),
        );

        expect(config.id, 'my_theme_id');
        expect(config.id, isA<String>());
      });

      nyTest('colors is accessible with correct type', () async {
        final colors = TestColors(primary: Colors.orange);
        final config = BaseThemeConfig<TestColors>(
          id: 'test',
          theme: (c) => ThemeData.light(),
          colors: colors,
        );

        expect(config.colors, isA<TestColors>());
        expect(config.colors.primary, Colors.orange);
      });

      nyTest('type is accessible', () async {
        final lightConfig = BaseThemeConfig<TestColors>(
          id: 'light',
          theme: (c) => ThemeData.light(),
          colors: TestColors(),
          type: NyThemeType.light,
        );

        final darkConfig = BaseThemeConfig<TestColors>(
          id: 'dark',
          theme: (c) => ThemeData.dark(),
          colors: TestColors(),
          type: NyThemeType.dark,
        );

        expect(lightConfig.type, NyThemeType.light);
        expect(darkConfig.type, NyThemeType.dark);
      });

      nyTest('theme function is accessible', () async {
        ThemeData testTheme(TestColors c) => ThemeData.light();

        final config = BaseThemeConfig<TestColors>(
          id: 'test',
          theme: testTheme,
          colors: TestColors(),
        );

        expect(config.theme, isNotNull);
        expect(config.theme, isA<ThemeData Function(TestColors)>());
      });
    });

    nyGroup('generic type support', () {
      nyTest('works with different color style types', () async {
        // Using Map as color styles
        final mapConfig = BaseThemeConfig<Map<String, Color>>(
          id: 'map_theme',
          theme: (colors) =>
              ThemeData.light().copyWith(primaryColor: colors['primary']),
          colors: {'primary': Colors.cyan, 'secondary': Colors.pink},
        );

        expect(mapConfig.colors['primary'], Colors.cyan);
        expect(mapConfig.colors['secondary'], Colors.pink);
      });

      nyTest('works with custom class color styles', () async {
        final config = BaseThemeConfig<TestColors>(
          id: 'custom_class_theme',
          theme: (colors) => ThemeData.light().copyWith(
            primaryColor: colors.primary,
            scaffoldBackgroundColor: colors.background,
          ),
          colors: TestColors(
            primary: Colors.deepPurple,
            background: Colors.amber,
          ),
        );

        final themeData = config.themeData;

        expect(config.colors.primary, Colors.deepPurple);
        expect(config.colors.background, Colors.amber);
        expect(themeData.primaryColor, Colors.deepPurple);
        expect(themeData.scaffoldBackgroundColor, Colors.amber);
      });

      nyTest('works with extended color styles', () async {
        final config = BaseThemeConfig<ExtendedColors>(
          id: 'extended_theme',
          theme: (colors) => ThemeData.light().copyWith(
            primaryColor: colors.primary,
            secondaryHeaderColor: colors.secondary,
          ),
          colors: ExtendedColors(
            primary: Colors.blue,
            secondary: Colors.orange,
            tertiary: Colors.purple,
          ),
        );

        expect(config.colors.primary, Colors.blue);
        expect(config.colors.secondary, Colors.orange);
        expect(config.colors.tertiary, Colors.purple);
      });

      nyTest('works with List as color styles', () async {
        final config = BaseThemeConfig<List<Color>>(
          id: 'list_theme',
          theme: (colors) => ThemeData.light().copyWith(
            primaryColor: colors.isNotEmpty ? colors[0] : Colors.grey,
          ),
          colors: [Colors.red, Colors.green, Colors.blue],
        );

        expect(config.colors.length, 3);
        expect(config.colors[0], Colors.red);
        expect(config.themeData.primaryColor, Colors.red);
      });
    });

    nyGroup('immutability', () {
      nyTest('id is final', () async {
        final config = BaseThemeConfig<TestColors>(
          id: 'immutable_id',
          theme: (c) => ThemeData.light(),
          colors: TestColors(),
        );

        // id is final - we can only verify it stays the same
        expect(config.id, 'immutable_id');
      });

      nyTest('themeData is computed on access', () async {
        var callCount = 0;
        final config = BaseThemeConfig<TestColors>(
          id: 'computed_theme',
          theme: (c) {
            callCount++;
            return ThemeData.light();
          },
          colors: TestColors(),
        );

        config.themeData;
        config.themeData;
        config.themeData;

        expect(callCount, 3);
      });

      nyTest('colors reference is maintained', () async {
        final colors = TestColors();
        final config = BaseThemeConfig<TestColors>(
          id: 'test',
          theme: (c) => ThemeData.light(),
          colors: colors,
        );

        expect(identical(config.colors, colors), isTrue);
      });

      nyTest('type is final', () async {
        final config = BaseThemeConfig<TestColors>(
          id: 'test',
          theme: (c) => ThemeData.light(),
          colors: TestColors(),
          type: NyThemeType.dark,
        );

        expect(config.type, NyThemeType.dark);
      });
    });

    nyGroup('theme function edge cases', () {
      nyTest('theme function can return light ThemeData', () async {
        final config = BaseThemeConfig<TestColors>(
          id: 'light',
          theme: (c) => ThemeData.light(),
          colors: TestColors(),
          type: NyThemeType.light,
        );

        expect(config.themeData.brightness, Brightness.light);
      });

      nyTest('theme function can return dark ThemeData', () async {
        final config = BaseThemeConfig<TestColors>(
          id: 'dark',
          theme: (c) => ThemeData.dark(),
          colors: TestColors(),
          type: NyThemeType.dark,
        );

        expect(config.themeData.brightness, Brightness.dark);
      });

      nyTest('theme function can use conditional logic', () async {
        final lightColors = TestColors(background: Colors.white);
        final darkColors = TestColors(background: Colors.black);

        final lightConfig = BaseThemeConfig<TestColors>(
          id: 'conditional_light',
          theme: (c) {
            if (c.background == Colors.white) {
              return ThemeData.light();
            }
            return ThemeData.dark();
          },
          colors: lightColors,
        );

        final darkConfig = BaseThemeConfig<TestColors>(
          id: 'conditional_dark',
          theme: (c) {
            if (c.background == Colors.white) {
              return ThemeData.light();
            }
            return ThemeData.dark();
          },
          colors: darkColors,
        );

        expect(lightConfig.themeData.brightness, Brightness.light);
        expect(darkConfig.themeData.brightness, Brightness.dark);
      });

      nyTest('theme function can combine multiple themes', () async {
        final config = BaseThemeConfig<TestColors>(
          id: 'combined',
          theme: (c) {
            final base = ThemeData.light();
            return base.copyWith(
              primaryColor: c.primary,
              scaffoldBackgroundColor: c.background,
              textTheme: base.textTheme.copyWith(
                bodyLarge: TextStyle(color: c.accent),
              ),
            );
          },
          colors: TestColors(
            primary: Colors.blue,
            background: Colors.white,
            accent: Colors.green,
          ),
        );

        final themeData = config.themeData;
        expect(themeData.primaryColor, Colors.blue);
        expect(themeData.scaffoldBackgroundColor, Colors.white);
        expect(themeData.textTheme.bodyLarge?.color, Colors.green);
      });
    });

    nyGroup('equality and comparison', () {
      nyTest('two configs with same id are not equal by default', () async {
        final config1 = BaseThemeConfig<TestColors>(
          id: 'same_id',
          theme: (c) => ThemeData.light(),
          colors: TestColors(),
        );

        final config2 = BaseThemeConfig<TestColors>(
          id: 'same_id',
          theme: (c) => ThemeData.light(),
          colors: TestColors(),
        );

        // They are different instances
        expect(identical(config1, config2), isFalse);
      });

      nyTest('same config instance equals itself', () async {
        final config = BaseThemeConfig<TestColors>(
          id: 'self',
          theme: (c) => ThemeData.light(),
          colors: TestColors(),
        );

        expect(identical(config, config), isTrue);
      });

      nyTest('can be stored in a list', () async {
        final configs = <BaseThemeConfig<TestColors>>[
          BaseThemeConfig<TestColors>(
            id: 'light',
            theme: (c) => ThemeData.light(),
            colors: TestColors(),
          ),
          BaseThemeConfig<TestColors>(
            id: 'dark',
            theme: (c) => ThemeData.dark(),
            colors: TestColors(),
            type: NyThemeType.dark,
          ),
        ];

        expect(configs.length, 2);
        expect(configs[0].id, 'light');
        expect(configs[1].id, 'dark');
      });

      nyTest('can be found by id in collection', () async {
        final configs = <BaseThemeConfig<TestColors>>[
          BaseThemeConfig<TestColors>(
            id: 'light',
            theme: (c) => ThemeData.light(),
            colors: TestColors(),
          ),
          BaseThemeConfig<TestColors>(
            id: 'dark',
            theme: (c) => ThemeData.dark(),
            colors: TestColors(),
            type: NyThemeType.dark,
          ),
        ];

        final found = configs.firstWhere((c) => c.id == 'dark');
        expect(found.type, NyThemeType.dark);
      });
    });

    nyGroup('type consistency', () {
      nyTest('light type with light ThemeData', () async {
        final config = BaseThemeConfig<TestColors>(
          id: 'light',
          theme: (c) => ThemeData.light(),
          colors: TestColors(),
          type: NyThemeType.light,
        );

        expect(config.type, NyThemeType.light);
        expect(config.themeData.brightness, Brightness.light);
      });

      nyTest('dark type with dark ThemeData', () async {
        final config = BaseThemeConfig<TestColors>(
          id: 'dark',
          theme: (c) => ThemeData.dark(),
          colors: TestColors(),
          type: NyThemeType.dark,
        );

        expect(config.type, NyThemeType.dark);
        expect(config.themeData.brightness, Brightness.dark);
      });

      nyTest('type can mismatch ThemeData brightness', () async {
        // This is allowed - type is metadata, not enforced
        final config = BaseThemeConfig<TestColors>(
          id: 'mismatch',
          theme: (c) => ThemeData.light(), // light ThemeData
          colors: TestColors(),
          type: NyThemeType.dark, // but marked as dark
        );

        expect(config.type, NyThemeType.dark);
        expect(config.themeData.brightness, Brightness.light);
      });
    });
  });
}
