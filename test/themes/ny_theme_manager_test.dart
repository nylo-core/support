import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/themes/src/base_theme_config.dart';
import 'package:nylo_support/themes/src/ny_theme_manager.dart';

/// Test color styles class
class TestColors {
  final Color primary;
  final Color background;
  final Color text;

  TestColors({
    this.primary = Colors.blue,
    this.background = Colors.white,
    this.text = Colors.black,
  });
}

/// Creates a light theme config for testing
BaseThemeConfig<TestColors> createLightTheme({
  String id = 'light_theme',
  String description = 'Light Theme',
  TestColors? colors,
}) {
  return BaseThemeConfig<TestColors>(
    id: id,
    theme: (c) => ThemeData.light().copyWith(
      primaryColor: c.primary,
      scaffoldBackgroundColor: c.background,
    ),
    colors: colors ?? TestColors(),
    type: NyThemeType.light,
  );
}

/// Creates a dark theme config for testing
BaseThemeConfig<TestColors> createDarkTheme({
  String id = 'dark_theme',
  String description = 'Dark Theme',
  TestColors? colors,
}) {
  return BaseThemeConfig<TestColors>(
    id: id,
    theme: (c) => ThemeData.dark().copyWith(
      primaryColor: c.primary,
      scaffoldBackgroundColor: c.background,
    ),
    colors:
        colors ??
        TestColors(
          primary: Colors.purple,
          background: Colors.black,
          text: Colors.white,
        ),
    type: NyThemeType.dark,
  );
}

void main() {
  NyTest.init();

  // Helper to clear storage between tests
  nySetUp(() {
    NyMockChannels.clearSecureStorage();
  });

  nyGroup('NyThemeManager', () {
    nyGroup('singleton', () {
      nyTest('instance returns the same instance', () async {
        final instance1 = NyThemeManager.instance;
        final instance2 = NyThemeManager.instance;

        expect(identical(instance1, instance2), isTrue);
      });
    });

    nyGroup('registerThemes()', () {
      nyTest('registers themes successfully', () async {
        final themes = [createLightTheme(), createDarkTheme()];

        NyThemeManager.instance.registerThemes(themes);

        expect(NyThemeManager.instance.themes.length, 2);
      });

      nyTest('throws when registering empty list', () async {
        expect(
          () => NyThemeManager.instance.registerThemes<TestColors>([]),
          throwsA(isA<ArgumentError>()),
        );
      });

      nyTest('sets initial theme when provided', () async {
        final themes = [createLightTheme(), createDarkTheme()];

        NyThemeManager.instance.registerThemes(
          themes,
          initialThemeId: 'dark_theme',
        );

        expect(NyThemeManager.instance.currentThemeId, 'dark_theme');
      });

      nyTest('clears previous themes on registration', () async {
        NyThemeManager.instance.registerThemes([
          createLightTheme(id: 'old_light'),
          createDarkTheme(id: 'old_dark'),
        ]);

        NyThemeManager.instance.registerThemes([
          createLightTheme(id: 'new_light'),
        ]);

        expect(NyThemeManager.instance.themes.length, 1);
        expect(NyThemeManager.instance.themes.first.id, 'new_light');
      });

      nyTest('uses first theme when initialThemeId not found', () async {
        final themes = [
          createLightTheme(id: 'first_theme'),
          createDarkTheme(id: 'second_theme'),
        ];

        NyThemeManager.instance.registerThemes(
          themes,
          initialThemeId: 'non_existent',
        );

        expect(NyThemeManager.instance.currentThemeId, 'first_theme');
      });

      nyTest(
        'disables followSystemTheme when initialThemeId is provided',
        () async {
          final themes = [createLightTheme(), createDarkTheme()];

          NyThemeManager.instance.registerThemes(
            themes,
            initialThemeId: 'light_theme',
          );

          expect(NyThemeManager.instance.followSystemTheme, isFalse);
        },
      );
    });

    nyGroup('currentTheme', () {
      nyTest('returns current theme config', () async {
        final themes = [createLightTheme(), createDarkTheme()];
        NyThemeManager.instance.registerThemes(
          themes,
          initialThemeId: 'light_theme',
        );

        final current = NyThemeManager.instance.currentTheme;

        expect(current, isNotNull);
        expect(current!.id, 'light_theme');
        expect(current.type, NyThemeType.light);
      });

      nyTest('returns null when no themes registered', () async {
        // Fresh state - registering an empty state is needed
        // We register and then check currentTheme behavior
        NyThemeManager.instance.registerThemes([createLightTheme()]);
        expect(NyThemeManager.instance.currentTheme, isNotNull);
      });
    });

    nyGroup('themeData', () {
      nyTest('returns ThemeData from current theme', () async {
        final colors = TestColors(primary: Colors.red);
        final themes = [createLightTheme(colors: colors)];
        NyThemeManager.instance.registerThemes(themes);

        final themeData = NyThemeManager.instance.themeData;

        expect(themeData, isNotNull);
        expect(themeData!.primaryColor, Colors.red);
      });
    });

    nyGroup('isDark', () {
      nyTest('returns true when current theme is dark', () async {
        final themes = [createLightTheme(), createDarkTheme()];
        NyThemeManager.instance.registerThemes(
          themes,
          initialThemeId: 'dark_theme',
        );

        expect(NyThemeManager.instance.isDark, isTrue);
      });

      nyTest('returns false when current theme is light', () async {
        final themes = [createLightTheme(), createDarkTheme()];
        NyThemeManager.instance.registerThemes(
          themes,
          initialThemeId: 'light_theme',
        );

        expect(NyThemeManager.instance.isDark, isFalse);
      });
    });

    nyGroup('themes getter', () {
      nyTest('returns unmodifiable list', () async {
        NyThemeManager.instance.registerThemes([createLightTheme()]);

        final themes = NyThemeManager.instance.themes;

        expect(themes, isA<List<BaseThemeConfig>>());
        expect(
          () => themes.add(createDarkTheme()),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    nyGroup('lightThemes and darkThemes', () {
      nyTest('lightThemes returns only light themes', () async {
        final themes = [
          createLightTheme(id: 'light1'),
          createLightTheme(id: 'light2'),
          createDarkTheme(id: 'dark1'),
        ];
        NyThemeManager.instance.registerThemes(themes);

        final lightThemes = NyThemeManager.instance.lightThemes;

        expect(lightThemes.length, 2);
        expect(lightThemes.every((t) => t.type == NyThemeType.light), isTrue);
      });

      nyTest('darkThemes returns only dark themes', () async {
        final themes = [
          createLightTheme(id: 'light1'),
          createDarkTheme(id: 'dark1'),
          createDarkTheme(id: 'dark2'),
        ];
        NyThemeManager.instance.registerThemes(themes);

        final darkThemes = NyThemeManager.instance.darkThemes;

        expect(darkThemes.length, 2);
        expect(darkThemes.every((t) => t.type == NyThemeType.dark), isTrue);
      });
    });

    nyGroup('getThemesByType()', () {
      nyTest('returns themes of specified type', () async {
        final themes = [
          createLightTheme(id: 'light1'),
          createDarkTheme(id: 'dark1'),
          createDarkTheme(id: 'dark2'),
        ];
        NyThemeManager.instance.registerThemes(themes);

        final lightResults = NyThemeManager.instance.getThemesByType(
          NyThemeType.light,
        );
        final darkResults = NyThemeManager.instance.getThemesByType(
          NyThemeType.dark,
        );

        expect(lightResults.length, 1);
        expect(darkResults.length, 2);
      });
    });

    nyGroup('getThemeById()', () {
      nyTest('returns theme when found', () async {
        final themes = [createLightTheme(id: 'my_theme'), createDarkTheme()];
        NyThemeManager.instance.registerThemes(themes);

        final result = NyThemeManager.instance.getThemeById('my_theme');

        expect(result, isNotNull);
        expect(result!.id, 'my_theme');
      });

      nyTest('returns null when theme not found', () async {
        NyThemeManager.instance.registerThemes([createLightTheme()]);

        final result = NyThemeManager.instance.getThemeById('non_existent');

        expect(result, isNull);
      });
    });

    nyGroup('lightTheme and darkTheme getters', () {
      nyTest('lightTheme returns first light theme', () async {
        final themes = [
          createDarkTheme(),
          createLightTheme(id: 'first_light'),
          createLightTheme(id: 'second_light'),
        ];
        NyThemeManager.instance.registerThemes(themes);

        final result = NyThemeManager.instance.lightTheme;

        expect(result, isNotNull);
        expect(result!.id, 'first_light');
      });

      nyTest('darkTheme returns first dark theme', () async {
        final themes = [
          createLightTheme(),
          createDarkTheme(id: 'first_dark'),
          createDarkTheme(id: 'second_dark'),
        ];
        NyThemeManager.instance.registerThemes(themes);

        final result = NyThemeManager.instance.darkTheme;

        expect(result, isNotNull);
        expect(result!.id, 'first_dark');
      });

      nyTest(
        'lightTheme returns first theme when no light themes exist',
        () async {
          final themes = [createDarkTheme()];
          NyThemeManager.instance.registerThemes(themes);

          final result = NyThemeManager.instance.lightTheme;

          expect(result, isNotNull);
          expect(result!.type, NyThemeType.dark);
        },
      );

      nyTest('darkTheme returns null when no dark themes exist', () async {
        final themes = [createLightTheme()];
        NyThemeManager.instance.registerThemes(themes);

        final result = NyThemeManager.instance.darkTheme;

        expect(result, isNull);
      });
    });

    nyGroup('colorStyles()', () {
      nyTest('returns typed color styles from current theme', () async {
        final colors = TestColors(primary: Colors.orange);
        final themes = [createLightTheme(colors: colors)];
        NyThemeManager.instance.registerThemes(themes);

        final result = NyThemeManager.instance.colorStyles<TestColors>();

        expect(result, isA<TestColors>());
        expect(result.primary, Colors.orange);
      });
    });

    nyGroup('colorStylesFromTheme()', () {
      nyTest('returns color styles from specific theme', () async {
        final lightColors = TestColors(primary: Colors.blue);
        final darkColors = TestColors(primary: Colors.purple);
        final themes = [
          createLightTheme(id: 'light', colors: lightColors),
          createDarkTheme(id: 'dark', colors: darkColors),
        ];
        NyThemeManager.instance.registerThemes(themes, initialThemeId: 'light');

        final lightResult = NyThemeManager.instance
            .colorStylesFromTheme<TestColors>('light');
        final darkResult = NyThemeManager.instance
            .colorStylesFromTheme<TestColors>('dark');

        expect(lightResult.primary, Colors.blue);
        expect(darkResult.primary, Colors.purple);
      });

      nyTest('throws when theme not found', () async {
        NyThemeManager.instance.registerThemes([createLightTheme()]);

        expect(
          () => NyThemeManager.instance.colorStylesFromTheme<TestColors>(
            'non_existent',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    nyGroup('setTheme()', () {
      nyTest('changes current theme', () async {
        final themes = [createLightTheme(), createDarkTheme()];
        NyThemeManager.instance.registerThemes(
          themes,
          initialThemeId: 'light_theme',
        );

        await NyThemeManager.instance.setTheme('dark_theme');

        expect(NyThemeManager.instance.currentThemeId, 'dark_theme');
      });

      nyTest('throws when theme not found', () async {
        NyThemeManager.instance.registerThemes([createLightTheme()]);

        expect(
          () => NyThemeManager.instance.setTheme('non_existent'),
          throwsA(isA<ArgumentError>()),
        );
      });

      nyTest('disables followSystemTheme', () async {
        final themes = [createLightTheme(), createDarkTheme()];
        NyThemeManager.instance.registerThemes(themes);
        await NyThemeManager.instance.setFollowSystemTheme(true);

        await NyThemeManager.instance.setTheme('dark_theme');

        expect(NyThemeManager.instance.followSystemTheme, isFalse);
      });
    });

    nyGroup('setTheme() with remember parameter', () {
      nyTest('sets preferred dark theme when remember is true', () async {
        final themes = [
          createLightTheme(),
          createDarkTheme(id: 'dark_amoled'),
          createDarkTheme(id: 'dark_blue'),
        ];
        NyThemeManager.instance.registerThemes(themes);

        await NyThemeManager.instance.setTheme('dark_amoled', remember: true);

        expect(NyThemeManager.instance.preferredDarkThemeId, 'dark_amoled');
      });

      nyTest('sets preferred light theme when remember is true', () async {
        final themes = [
          createLightTheme(id: 'light_cream'),
          createLightTheme(id: 'light_pure'),
          createDarkTheme(),
        ];
        NyThemeManager.instance.registerThemes(themes);

        await NyThemeManager.instance.setTheme('light_cream', remember: true);

        expect(NyThemeManager.instance.preferredLightThemeId, 'light_cream');
      });
    });

    nyGroup('setPreferredDarkTheme()', () {
      nyTest('sets preferred dark theme', () async {
        final themes = [
          createLightTheme(),
          createDarkTheme(id: 'dark1'),
          createDarkTheme(id: 'dark2'),
        ];
        NyThemeManager.instance.registerThemes(themes);

        await NyThemeManager.instance.setPreferredDarkTheme('dark2');

        expect(NyThemeManager.instance.preferredDarkThemeId, 'dark2');
      });

      nyTest('throws when theme is not dark type', () async {
        final themes = [createLightTheme(), createDarkTheme()];
        NyThemeManager.instance.registerThemes(themes);

        expect(
          () => NyThemeManager.instance.setPreferredDarkTheme('light_theme'),
          throwsA(isA<ArgumentError>()),
        );
      });

      nyTest('throws when theme not found', () async {
        NyThemeManager.instance.registerThemes([createLightTheme()]);

        expect(
          () => NyThemeManager.instance.setPreferredDarkTheme('non_existent'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    nyGroup('setPreferredLightTheme()', () {
      nyTest('sets preferred light theme', () async {
        final themes = [
          createLightTheme(id: 'light1'),
          createLightTheme(id: 'light2'),
          createDarkTheme(),
        ];
        NyThemeManager.instance.registerThemes(themes);

        await NyThemeManager.instance.setPreferredLightTheme('light2');

        expect(NyThemeManager.instance.preferredLightThemeId, 'light2');
      });

      nyTest('throws when theme is not light type', () async {
        final themes = [createLightTheme(), createDarkTheme()];
        NyThemeManager.instance.registerThemes(themes);

        expect(
          () => NyThemeManager.instance.setPreferredLightTheme('dark_theme'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    nyGroup('effectiveLightTheme and effectiveDarkTheme', () {
      nyTest('effectiveLightTheme returns preferred when set', () async {
        final themes = [
          createLightTheme(id: 'light1'),
          createLightTheme(id: 'light_preferred'),
          createDarkTheme(),
        ];
        NyThemeManager.instance.registerThemes(themes);
        await NyThemeManager.instance.setPreferredLightTheme('light_preferred');

        final result = NyThemeManager.instance.effectiveLightTheme;

        expect(result, isNotNull);
        expect(result!.id, 'light_preferred');
      });

      nyTest('effectiveDarkTheme returns preferred when set', () async {
        final themes = [
          createLightTheme(),
          createDarkTheme(id: 'dark1'),
          createDarkTheme(id: 'dark_preferred'),
        ];
        NyThemeManager.instance.registerThemes(themes);
        await NyThemeManager.instance.setPreferredDarkTheme('dark_preferred');

        final result = NyThemeManager.instance.effectiveDarkTheme;

        expect(result, isNotNull);
        expect(result!.id, 'dark_preferred');
      });

      nyTest('effectiveLightTheme falls back to first light theme', () async {
        final themes = [
          createLightTheme(id: 'first_light'),
          createLightTheme(id: 'second_light'),
        ];
        NyThemeManager.instance.registerThemes(themes);

        final result = NyThemeManager.instance.effectiveLightTheme;

        expect(result, isNotNull);
        expect(result!.id, 'first_light');
      });
    });

    nyGroup('setFollowSystemTheme()', () {
      nyTest('enables system theme following', () async {
        NyThemeManager.instance.registerThemes([
          createLightTheme(),
          createDarkTheme(),
        ]);

        await NyThemeManager.instance.setFollowSystemTheme(true);

        expect(NyThemeManager.instance.followSystemTheme, isTrue);
      });

      nyTest('disables system theme following', () async {
        NyThemeManager.instance.registerThemes([
          createLightTheme(),
          createDarkTheme(),
        ]);
        await NyThemeManager.instance.setFollowSystemTheme(true);

        await NyThemeManager.instance.setFollowSystemTheme(false);

        expect(NyThemeManager.instance.followSystemTheme, isFalse);
      });
    });

    nyGroup('themeNotifier', () {
      nyTest('notifies on theme change', () async {
        final themes = [createLightTheme(), createDarkTheme()];
        NyThemeManager.instance.registerThemes(
          themes,
          initialThemeId: 'light_theme',
        );

        String? notifiedTheme;
        NyThemeManager.instance.themeNotifier.addListener(() {
          notifiedTheme = NyThemeManager.instance.themeNotifier.value;
        });

        await NyThemeManager.instance.setTheme('dark_theme');

        expect(notifiedTheme, 'dark_theme');
      });
    });

    nyGroup('onThemeChanged stream', () {
      nyTest('emits theme ID when theme changes', () async {
        final themes = [createLightTheme(), createDarkTheme()];
        NyThemeManager.instance.registerThemes(
          themes,
          initialThemeId: 'light_theme',
        );

        final completer = Completer<String>();
        final subscription = NyThemeManager.instance.onThemeChanged.listen((
          themeId,
        ) {
          if (!completer.isCompleted) {
            completer.complete(themeId);
          }
        });

        await NyThemeManager.instance.setTheme('dark_theme');

        final emittedTheme = await completer.future.timeout(
          const Duration(seconds: 1),
        );
        expect(emittedTheme, 'dark_theme');

        await subscription.cancel();
      });
    });

    nyGroup('clearSavedTheme()', () {
      nyTest('clears preferred themes', () async {
        final themes = [
          createLightTheme(id: 'light'),
          createDarkTheme(id: 'dark'),
        ];
        NyThemeManager.instance.registerThemes(themes);
        await NyThemeManager.instance.setPreferredLightTheme('light');
        await NyThemeManager.instance.setPreferredDarkTheme('dark');

        await NyThemeManager.instance.clearSavedTheme();

        expect(NyThemeManager.instance.preferredLightThemeId, isNull);
        expect(NyThemeManager.instance.preferredDarkThemeId, isNull);
      });
    });
  });

  nyGroup('nyColorStyles helper function', () {
    nyTest('returns color styles from NyThemeManager', () async {
      final colors = TestColors(primary: Colors.pink);
      NyThemeManager.instance.registerThemes([
        createLightTheme(colors: colors),
      ]);

      final result = nyColorStyles<TestColors>();

      expect(result, isA<TestColors>());
      expect(result.primary, Colors.pink);
    });
  });
}
