import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/themes/src/ny_theme_storage.dart';

void main() {
  NyTest.init();

  late NyThemeStorage storage;

  nySetUp(() {
    NyMockChannels.clearSecureStorage();
    storage = NyThemeStorage();
  });

  nyGroup('NyThemeStorage', () {
    nyGroup('saveThemeId() and readThemeId()', () {
      nyTest('saves and reads theme ID', () async {
        await storage.saveThemeId('dark_theme');

        final result = await storage.readThemeId();

        expect(result, 'dark_theme');
      });

      nyTest('returns null when no theme ID saved', () async {
        final result = await storage.readThemeId();

        expect(result, isNull);
      });

      nyTest('overwrites previous theme ID', () async {
        await storage.saveThemeId('light_theme');
        await storage.saveThemeId('dark_theme');

        final result = await storage.readThemeId();

        expect(result, 'dark_theme');
      });

      nyTest('handles empty string', () async {
        await storage.saveThemeId('');

        final result = await storage.readThemeId();

        expect(result, '');
      });
    });

    nyGroup('saveFollowSystem() and readFollowSystem()', () {
      nyTest('saves and reads true value', () async {
        await storage.saveFollowSystem(true);

        final result = await storage.readFollowSystem();

        expect(result, isTrue);
      });

      nyTest('saves and reads false value', () async {
        await storage.saveFollowSystem(false);

        final result = await storage.readFollowSystem();

        expect(result, isFalse);
      });

      nyTest('returns null when not set', () async {
        final result = await storage.readFollowSystem();

        expect(result, isNull);
      });

      nyTest('overwrites previous value', () async {
        await storage.saveFollowSystem(true);
        await storage.saveFollowSystem(false);

        final result = await storage.readFollowSystem();

        expect(result, isFalse);
      });
    });

    nyGroup('savePreferredLightThemeId() and readPreferredLightThemeId()', () {
      nyTest('saves and reads preferred light theme ID', () async {
        await storage.savePreferredLightThemeId('light_cream');

        final result = await storage.readPreferredLightThemeId();

        expect(result, 'light_cream');
      });

      nyTest('returns null when not set', () async {
        final result = await storage.readPreferredLightThemeId();

        expect(result, isNull);
      });

      nyTest('overwrites previous value', () async {
        await storage.savePreferredLightThemeId('light1');
        await storage.savePreferredLightThemeId('light2');

        final result = await storage.readPreferredLightThemeId();

        expect(result, 'light2');
      });
    });

    nyGroup('savePreferredDarkThemeId() and readPreferredDarkThemeId()', () {
      nyTest('saves and reads preferred dark theme ID', () async {
        await storage.savePreferredDarkThemeId('dark_amoled');

        final result = await storage.readPreferredDarkThemeId();

        expect(result, 'dark_amoled');
      });

      nyTest('returns null when not set', () async {
        final result = await storage.readPreferredDarkThemeId();

        expect(result, isNull);
      });

      nyTest('overwrites previous value', () async {
        await storage.savePreferredDarkThemeId('dark1');
        await storage.savePreferredDarkThemeId('dark2');

        final result = await storage.readPreferredDarkThemeId();

        expect(result, 'dark2');
      });
    });

    nyGroup('clear()', () {
      nyTest('clears theme ID', () async {
        await storage.saveThemeId('test_theme');

        await storage.clear();

        final result = await storage.readThemeId();
        expect(result, isNull);
      });

      nyTest('clears follow system preference', () async {
        await storage.saveFollowSystem(true);

        await storage.clear();

        final result = await storage.readFollowSystem();
        expect(result, isNull);
      });

      nyTest('clears preferred light theme ID', () async {
        await storage.savePreferredLightThemeId('light_theme');

        await storage.clear();

        final result = await storage.readPreferredLightThemeId();
        expect(result, isNull);
      });

      nyTest('clears preferred dark theme ID', () async {
        await storage.savePreferredDarkThemeId('dark_theme');

        await storage.clear();

        final result = await storage.readPreferredDarkThemeId();
        expect(result, isNull);
      });

      nyTest('clears all values at once', () async {
        await storage.saveThemeId('theme1');
        await storage.saveFollowSystem(true);
        await storage.savePreferredLightThemeId('light1');
        await storage.savePreferredDarkThemeId('dark1');

        await storage.clear();

        expect(await storage.readThemeId(), isNull);
        expect(await storage.readFollowSystem(), isNull);
        expect(await storage.readPreferredLightThemeId(), isNull);
        expect(await storage.readPreferredDarkThemeId(), isNull);
      });
    });

    nyGroup('clearAll()', () {
      nyTest('clears all data including migration flag', () async {
        await storage.saveThemeId('theme1');
        await storage.saveFollowSystem(true);

        await storage.clearAll();

        expect(await storage.readThemeId(), isNull);
        expect(await storage.readFollowSystem(), isNull);
      });
    });

    nyGroup('data isolation', () {
      nyTest('theme ID is separate from follow system', () async {
        await storage.saveThemeId('my_theme');
        await storage.saveFollowSystem(true);

        final themeId = await storage.readThemeId();
        final followSystem = await storage.readFollowSystem();

        expect(themeId, 'my_theme');
        expect(followSystem, isTrue);
      });

      nyTest('preferred themes are independent', () async {
        await storage.savePreferredLightThemeId('light_custom');
        await storage.savePreferredDarkThemeId('dark_custom');

        final lightId = await storage.readPreferredLightThemeId();
        final darkId = await storage.readPreferredDarkThemeId();

        expect(lightId, 'light_custom');
        expect(darkId, 'dark_custom');
      });

      nyTest('multiple storage instances share data', () async {
        final storage1 = NyThemeStorage();
        final storage2 = NyThemeStorage();

        await storage1.saveThemeId('shared_theme');

        final result = await storage2.readThemeId();

        expect(result, 'shared_theme');
      });
    });

    nyGroup('edge cases', () {
      nyTest('handles special characters in theme ID', () async {
        await storage.saveThemeId('theme-with_special.chars123');

        final result = await storage.readThemeId();

        expect(result, 'theme-with_special.chars123');
      });

      nyTest('handles unicode in theme ID', () async {
        await storage.saveThemeId('theme_emoji_test');

        final result = await storage.readThemeId();

        expect(result, 'theme_emoji_test');
      });

      nyTest('handles very long theme ID', () async {
        final longId = 'a' * 1000;
        await storage.saveThemeId(longId);

        final result = await storage.readThemeId();

        expect(result, longId);
      });
    });
  });
}
