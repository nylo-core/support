import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/themes/src/base_theme_config.dart';
import 'package:nylo_support/themes/src/ny_theme_manager.dart';
import 'package:nylo_support/themes/src/ny_theme_provider.dart';

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

  nySetUp(() {
    NyMockChannels.clearSecureStorage();
    // Register default themes for widget tests
    NyThemeManager.instance.registerThemes([
      createLightTheme(),
      createDarkTheme(),
    ], initialThemeId: 'light_theme');
  });

  nyGroup('NyThemeProvider', () {
    nyGroup('constructor', () {
      nyWidgetTest('creates with required child', (tester) async {
        await tester.pumpWidget(
          NyThemeProvider(
            child: MaterialApp(home: Scaffold(body: Container())),
          ),
        );

        expect(find.byType(NyThemeProvider), findsOneWidget);
      });

      nyWidgetTest('accepts custom duration', (tester) async {
        await tester.pumpWidget(
          NyThemeProvider(
            duration: const Duration(milliseconds: 500),
            child: MaterialApp(home: Scaffold(body: Container())),
          ),
        );

        expect(find.byType(NyThemeProvider), findsOneWidget);
      });

      nyWidgetTest('accepts custom curve', (tester) async {
        await tester.pumpWidget(
          NyThemeProvider(
            curve: Curves.bounceOut,
            child: MaterialApp(home: Scaffold(body: Container())),
          ),
        );

        expect(find.byType(NyThemeProvider), findsOneWidget);
      });
    });

    nyGroup('of()', () {
      nyWidgetTest('returns NyThemeManager instance', (tester) async {
        NyThemeManager? capturedManager;

        await tester.pumpWidget(
          NyThemeProvider(
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  capturedManager = NyThemeProvider.of(context);
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(capturedManager, isNotNull);
        expect(capturedManager, NyThemeManager.instance);
      });
    });

    nyGroup('colorStyles()', () {
      nyWidgetTest('returns typed color styles', (tester) async {
        final colors = TestColors(primary: Colors.red);
        NyThemeManager.instance.registerThemes([
          createLightTheme(colors: colors),
        ]);

        TestColors? capturedColors;

        await tester.pumpWidget(
          NyThemeProvider(
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  capturedColors = NyThemeProvider.colorStyles<TestColors>(
                    context,
                  );
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(capturedColors, isNotNull);
        expect(capturedColors!.primary, Colors.red);
      });
    });

    nyGroup('isDark()', () {
      nyWidgetTest('returns false when light theme is active', (tester) async {
        NyThemeManager.instance.registerThemes([
          createLightTheme(),
          createDarkTheme(),
        ], initialThemeId: 'light_theme');

        bool? isDark;

        await tester.pumpWidget(
          NyThemeProvider(
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  isDark = NyThemeProvider.isDark(context);
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(isDark, isFalse);
      });

      nyWidgetTest('returns true when dark theme is active', (tester) async {
        NyThemeManager.instance.registerThemes([
          createLightTheme(),
          createDarkTheme(),
        ], initialThemeId: 'dark_theme');

        bool? isDark;

        await tester.pumpWidget(
          NyThemeProvider(
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  isDark = NyThemeProvider.isDark(context);
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(isDark, isTrue);
      });
    });

    nyGroup('currentThemeId()', () {
      nyWidgetTest('returns current theme ID', (tester) async {
        NyThemeManager.instance.registerThemes([
          createLightTheme(id: 'my_light'),
          createDarkTheme(),
        ], initialThemeId: 'my_light');

        String? themeId;

        await tester.pumpWidget(
          NyThemeProvider(
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  themeId = NyThemeProvider.currentThemeId(context);
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(themeId, 'my_light');
      });
    });

    nyGroup('currentTheme()', () {
      nyWidgetTest('returns current theme config', (tester) async {
        NyThemeManager.instance.registerThemes([
          createLightTheme(id: 'test_theme'),
        ], initialThemeId: 'test_theme');

        BaseThemeConfig? theme;

        await tester.pumpWidget(
          NyThemeProvider(
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  theme = NyThemeProvider.currentTheme(context);
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(theme, isNotNull);
        expect(theme!.id, 'test_theme');
      });
    });

    nyGroup('build()', () {
      nyWidgetTest('returns child without wrapper when no theme set', (
        tester,
      ) async {
        // This test is to ensure the provider handles edge cases gracefully
        NyThemeManager.instance.registerThemes([createLightTheme()]);

        await tester.pumpWidget(
          NyThemeProvider(
            child: MaterialApp(home: Scaffold(body: Text('Test'))),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
      });
    });
  });

  nyGroup('NyThemeBuilder', () {
    nyGroup('constructor', () {
      nyWidgetTest('creates with required builder', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: NyThemeBuilder(builder: (context, themeData) => Container()),
          ),
        );

        expect(find.byType(NyThemeBuilder), findsOneWidget);
      });
    });

    nyGroup('build()', () {
      nyWidgetTest('passes ThemeData to builder', (tester) async {
        ThemeData? receivedThemeData;

        await tester.pumpWidget(
          MaterialApp(
            home: NyThemeBuilder(
              builder: (context, themeData) {
                receivedThemeData = themeData;
                return Container();
              },
            ),
          ),
        );

        expect(receivedThemeData, isNotNull);
        expect(receivedThemeData, isA<ThemeData>());
      });

      nyWidgetTest('rebuilds when theme changes', (tester) async {
        var buildCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: NyThemeBuilder(
              builder: (context, themeData) {
                buildCount++;
                return Container();
              },
            ),
          ),
        );

        final initialCount = buildCount;

        await NyThemeManager.instance.setTheme('dark_theme');
        await tester.pump();

        expect(buildCount, greaterThan(initialCount));
      });

      nyWidgetTest('reflects new ThemeData after theme change', (tester) async {
        final lightColors = TestColors(primary: Colors.blue);
        final darkColors = TestColors(primary: Colors.purple);

        NyThemeManager.instance.registerThemes([
          createLightTheme(colors: lightColors),
          createDarkTheme(colors: darkColors),
        ], initialThemeId: 'light_theme');

        Color? capturedPrimaryColor;

        await tester.pumpWidget(
          MaterialApp(
            home: NyThemeBuilder(
              builder: (context, themeData) {
                capturedPrimaryColor = themeData?.primaryColor;
                return Container();
              },
            ),
          ),
        );

        expect(capturedPrimaryColor, Colors.blue);

        await NyThemeManager.instance.setTheme('dark_theme');
        await tester.pump();

        expect(capturedPrimaryColor, Colors.purple);
      });
    });
  });

  nyGroup('NyColorStyleBuilder', () {
    nyGroup('constructor', () {
      nyWidgetTest('creates with required builder', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: NyColorStyleBuilder<TestColors>(
              builder: (context, colors) => Container(),
            ),
          ),
        );

        expect(find.byType(NyColorStyleBuilder<TestColors>), findsOneWidget);
      });
    });

    nyGroup('build()', () {
      nyWidgetTest('passes typed color styles to builder', (tester) async {
        final colors = TestColors(primary: Colors.orange);
        NyThemeManager.instance.registerThemes([
          createLightTheme(colors: colors),
        ]);

        TestColors? receivedColors;

        await tester.pumpWidget(
          MaterialApp(
            home: NyColorStyleBuilder<TestColors>(
              builder: (context, colors) {
                receivedColors = colors;
                return Container();
              },
            ),
          ),
        );

        expect(receivedColors, isNotNull);
        expect(receivedColors!.primary, Colors.orange);
      });

      nyWidgetTest('rebuilds when theme changes', (tester) async {
        var buildCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: NyColorStyleBuilder<TestColors>(
              builder: (context, colors) {
                buildCount++;
                return Container();
              },
            ),
          ),
        );

        final initialCount = buildCount;

        await NyThemeManager.instance.setTheme('dark_theme');
        await tester.pump();

        expect(buildCount, greaterThan(initialCount));
      });

      nyWidgetTest('reflects new color styles after theme change', (
        tester,
      ) async {
        final lightColors = TestColors(primary: Colors.green);
        final darkColors = TestColors(primary: Colors.red);

        NyThemeManager.instance.registerThemes([
          createLightTheme(colors: lightColors),
          createDarkTheme(colors: darkColors),
        ], initialThemeId: 'light_theme');

        Color? capturedPrimary;

        await tester.pumpWidget(
          MaterialApp(
            home: NyColorStyleBuilder<TestColors>(
              builder: (context, colors) {
                capturedPrimary = colors.primary;
                return Container();
              },
            ),
          ),
        );

        expect(capturedPrimary, Colors.green);

        await NyThemeManager.instance.setTheme('dark_theme');
        await tester.pump();

        expect(capturedPrimary, Colors.red);
      });

      nyWidgetTest('can be used to style widgets', (tester) async {
        final colors = TestColors(
          primary: Colors.cyan,
          background: Colors.grey,
        );
        NyThemeManager.instance.registerThemes([
          createLightTheme(colors: colors),
        ]);

        await tester.pumpWidget(
          MaterialApp(
            home: NyColorStyleBuilder<TestColors>(
              builder: (context, colors) {
                return Container(
                  color: colors.background,
                  child: Text(
                    'Styled Text',
                    style: TextStyle(color: colors.primary),
                  ),
                );
              },
            ),
          ),
        );

        expect(find.text('Styled Text'), findsOneWidget);
      });
    });
  });
}
