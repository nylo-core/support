import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/live/ny_live.dart';
import 'package:nylo_support/localization/ny_localization.dart';
import 'package:nylo_support/screenshot/ny_screenshot.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/themes/src/ny_theme_manager.dart';
import 'package:nylo_support/themes/src/ny_theme_storage.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

import 'lang_assets.dart';

class _CounterPage extends StatefulWidget {
  const _CounterPage();

  @override
  State<_CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<_CounterPage> {
  int count = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        Text('greeting'.tr()),
        Text('Count $count'),
        TextButton(
          onPressed: () => setState(() => count++),
          child: const Text('Add'),
        ),
      ],
    ),
  );
}

void main() {
  NyTest.init();

  setUp(() async {
    rootBundle.clear();
    mockLangAssets();
    NyMockChannels.clearSecureStorage();
    await NyLocalization.instance.init(languageCode: 'en');
    NyThemeManager.instance.registerThemes<Object?>([
      testTheme('light', Brightness.light),
      testTheme('dark', Brightness.dark),
    ]);
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(NyApp.materialApp(home: const _CounterPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pump();
  }

  testWidgets('shows another locale in place and puts it back', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Hello'), findsOneWidget);

    final Future<void> Function() restore = (await tester.runAsync(
      () => ScreenshotLook.show(locale: 'es'),
    ))!;
    await tester.pump();

    expect(find.text('Hola'), findsOneWidget);
    expect(find.text('Count 1'), findsOneWidget);
    expect(
      Localizations.localeOf(tester.element(find.text('Hola'))),
      const Locale('es'),
    );

    await tester.runAsync(restore);
    await tester.pump();

    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Count 1'), findsOneWidget);
    expect(NyLocalization.instance.languageCode, 'en');
  });

  testWidgets('names the language file when a locale has none', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    final Object? error = await tester.runAsync<Object?>(() async {
      try {
        await ScreenshotLook.show(locale: 'ja');
        return null;
      } catch (e) {
        return e;
      }
    });

    expect(
      error,
      isA<StateError>().having(
        (StateError e) => e.message,
        'message',
        'Couldn\'t switch to "ja". Check that lang/ja.json exists and is '
            'listed in your assets.',
      ),
    );
    expect(NyLocalization.instance.languageCode, 'en');
  });

  testWidgets('shows another theme without saving it', (
    WidgetTester tester,
  ) async {
    await NyThemeManager.instance.setTheme('light');
    await NyThemeManager.instance.setFollowSystemTheme(true);
    await pumpApp(tester);
    final String? saved = await tester.runAsync<String?>(
      () => NyThemeStorage().readThemeId(),
    );

    final Future<void> Function() restore = (await tester.runAsync(
      () => ScreenshotLook.show(theme: 'dark'),
    ))!;
    await tester.pumpAndSettle();

    expect(NyThemeManager.instance.currentThemeId, 'dark');
    expect(NyThemeManager.instance.followSystemTheme, isTrue);
    expect(
      await tester.runAsync<String?>(() => NyThemeStorage().readThemeId()),
      saved,
    );
    expect(find.text('Count 1'), findsOneWidget);

    await tester.runAsync(restore);
    await tester.pumpAndSettle();

    expect(NyThemeManager.instance.currentThemeId, 'light');
  });

  testWidgets('names the registered themes when one is missing', (
    WidgetTester tester,
  ) async {
    await expectLater(
      ScreenshotLook.show(theme: 'sepia'),
      throwsA(
        isA<StateError>().having(
          (StateError e) => e.message,
          'message',
          'No theme with id "sepia". Registered themes: light, dark.',
        ),
      ),
    );
  });

  testWidgets('lists the bundled language files', (WidgetTester tester) async {
    expect(await tester.runAsync(ScreenshotLook.bundledLocales), ['en', 'es']);
    expect(ScreenshotLook.themeIds, ['light', 'dark']);
  });

  testWidgets('status lists the locales and themes', (
    WidgetTester tester,
  ) async {
    NyLive.debugBuildOverride = true;
    addTearDown(() => NyLive.debugBuildOverride = null);

    final Map status =
        (await tester.runAsync(() => NyLive.dispatch('status')))! as Map;

    expect(status['locales'], ['en', 'es']);
    expect(status['themes'], ['light', 'dark']);
  });

  testWidgets('theme.set with save false leaves the saved theme alone', (
    WidgetTester tester,
  ) async {
    NyLive.debugBuildOverride = true;
    addTearDown(() => NyLive.debugBuildOverride = null);
    await NyThemeManager.instance.setTheme('light');
    await NyThemeManager.instance.setFollowSystemTheme(true);

    await tester.runAsync(
      () => NyLive.dispatch('theme.set', {'id': 'dark', 'save': false}),
    );

    expect(NyThemeManager.instance.currentThemeId, 'dark');
    expect(NyThemeManager.instance.followSystemTheme, isTrue);
  });

  testWidgets('screenshot.capture names a missing language file', (
    WidgetTester tester,
  ) async {
    NyLive.debugBuildOverride = true;
    addTearDown(() => NyLive.debugBuildOverride = null);
    await pumpApp(tester);

    final Object? error = await tester.runAsync<Object?>(() async {
      try {
        await NyLive.dispatch('screenshot.capture', {'locale': 'ja'});
        return null;
      } catch (e) {
        return e;
      }
    });

    expect(
      error,
      isA<LiveException>().having(
        (LiveException e) => e.message,
        'message',
        'Couldn\'t switch to "ja". Check that lang/ja.json exists and is '
            'listed in your assets.',
      ),
    );
  });

  testWidgets('playbooks.run checks the matrix', (WidgetTester tester) async {
    NyLive.debugBuildOverride = true;
    addTearDown(() => NyLive.debugBuildOverride = null);

    await expectLater(
      NyLive.dispatch('playbooks.run', {
        'names': ['any'],
        'matrix': {'locale': 3},
      }),
      throwsA(
        isA<LiveException>().having(
          (LiveException e) => e.message,
          'message',
          '"matrix" must be an object with an optional "locale" and "theme".',
        ),
      ),
    );
  });
}
