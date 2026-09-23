import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/localization/ny_localization.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

/// A bottom navigation hub whose tab titles are translated.
class TranslatedTabsHub extends NyStatefulWidget {
  TranslatedTabsHub({super.key})
    : super(child: () => _TranslatedTabsHubState());
}

class _TranslatedTabsHubState extends NavigationHub<TranslatedTabsHub> {
  _TranslatedTabsHubState()
    : super(
        () => {
          0: NavigationTab.tab(
            title: "saved".tr(),
            page: const Text('saved page'),
            icon: const Icon(Icons.bookmark),
          ),
          1: NavigationTab.tab(
            title: "settings".tr(),
            page: const Text('settings page'),
            icon: const Icon(Icons.settings),
          ),
        },
      );

  @override
  NavigationHubLayout? layout(BuildContext context) =>
      NavigationHubLayout.bottomNav();
}

/// The `lang/` files the tests load, keyed by asset path.
const Map<String, Map<String, String>> _languageFiles = {
  'lang/en.json': {'saved': 'Saved', 'settings': 'Settings'},
  'lang/es.json': {'saved': 'Guardados', 'settings': 'Ajustes'},
};

/// Helper to initialize Nylo for widget tests that use NyPage.
void _initNylo() {
  NyEnvRegistry.register(
    getter: (String key, {dynamic defaultValue}) => defaultValue,
    containsKey: (String key) => false,
  );
  if (!Backpack.instance.isNyloInitialized()) {
    Backpack.instance.save("nylo", Nylo());
  }
  // Fresh EventBus per test so state events do not leak between tests.
  Backpack.instance.save("event_bus", EventBus(maxHistoryLength: 10));
}

/// Serves [_languageFiles] to `rootBundle`.
void _mockLanguageFiles() {
  // rootBundle caches each file's Future, and a Future made inside one
  // test's fake async zone never completes in the next test.
  rootBundle.clear();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        final String key = utf8.decode(
          message!.buffer.asUint8List(
            message.offsetInBytes,
            message.lengthInBytes,
          ),
        );
        final Map<String, String>? values = _languageFiles[key];
        if (values == null) return null;
        return ByteData.sublistView(utf8.encode(jsonEncode(values)));
      });
}

Widget _app(Locale locale, Widget home) => MaterialApp(
  locale: locale,
  supportedLocales: const [Locale('en'), Locale('es')],
  localizationsDelegates: NyLocalization.instance.delegates,
  home: home,
);

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  NyTest.init();

  setUp(() {
    _initNylo();
    _mockLanguageFiles();
  });

  nyGroup('NavigationHub tab titles', () {
    nyWidgetTest('follow a language change', (tester) async {
      await NyLocalization.instance.init(languageCode: 'en');
      final hub = TranslatedTabsHub();
      await tester.pumpWidget(_app(const Locale('en'), hub));
      await _settle(tester);
      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      await NyLocalization.instance.setLocale(locale: const Locale('es'));
      await tester.pumpWidget(_app(const Locale('es'), hub));
      await _settle(tester);

      expect(find.text('Guardados'), findsOneWidget);
      expect(find.text('Ajustes'), findsOneWidget);
      expect(find.text('Saved'), findsNothing);
    });

    nyWidgetTest('keep the selected tab when the language changes', (
      tester,
    ) async {
      await NyLocalization.instance.init(languageCode: 'en');
      final hub = TranslatedTabsHub();
      await tester.pumpWidget(_app(const Locale('en'), hub));
      await _settle(tester);
      await tester.tap(find.text('Settings'));
      await _settle(tester);

      await NyLocalization.instance.setLocale(locale: const Locale('es'));
      await tester.pumpWidget(_app(const Locale('es'), hub));
      await _settle(tester);

      final bar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bar.currentIndex, 1);
    });
  });
}
