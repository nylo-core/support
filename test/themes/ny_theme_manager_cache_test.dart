import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/themes/src/base_theme_config.dart';
import 'package:nylo_support/themes/src/ny_theme_manager.dart';

class _Colors {
  final Color primary;
  const _Colors(this.primary);
}

BaseThemeConfig<_Colors> _theme(String id, NyThemeType type) =>
    BaseThemeConfig<_Colors>(
      id: id,
      theme: (c) =>
          (type == NyThemeType.dark ? ThemeData.dark() : ThemeData.light())
              .copyWith(primaryColor: c.primary),
      colors: _Colors(type == NyThemeType.dark ? Colors.purple : Colors.blue),
      type: type,
    );

void main() {
  NyTest.init();

  nySetUp(() {
    NyMockChannels.clearSecureStorage();
  });

  nyGroup('NyThemeManager currentTheme cache', () {
    nyTest('returns the identical instance on repeated reads', () async {
      final NyThemeManager manager = NyThemeManager.instance;
      manager.registerThemes([
        _theme('light', NyThemeType.light),
        _theme('dark', NyThemeType.dark),
      ], initialThemeId: 'light');

      final BaseThemeConfig<dynamic>? first = manager.currentTheme;
      final BaseThemeConfig<dynamic>? second = manager.currentTheme;

      expect(first, isNotNull);
      expect(identical(first, second), isTrue);
      expect(first!.id, 'light');
      expect(manager.isDark, isFalse);
    });

    nyTest('is invalidated by setTheme', () async {
      final NyThemeManager manager = NyThemeManager.instance;
      manager.registerThemes([
        _theme('light', NyThemeType.light),
        _theme('dark', NyThemeType.dark),
      ], initialThemeId: 'light');

      final BaseThemeConfig<dynamic>? before = manager.currentTheme;
      expect(before!.id, 'light');
      expect(manager.themeData!.brightness, Brightness.light);
      expect(manager.colorStyles<_Colors>().primary, Colors.blue);

      await manager.setTheme('dark');

      final BaseThemeConfig<dynamic>? after = manager.currentTheme;
      expect(after!.id, 'dark');
      expect(identical(before, after), isFalse);
      expect(manager.isDark, isTrue);
      expect(manager.themeData!.brightness, Brightness.dark);
      expect(manager.colorStyles<_Colors>().primary, Colors.purple);
      // Stable again after the switch.
      expect(identical(after, manager.currentTheme), isTrue);
    });

    nyTest('is invalidated by registerThemes', () async {
      final NyThemeManager manager = NyThemeManager.instance;
      manager.registerThemes([
        _theme('light', NyThemeType.light),
      ], initialThemeId: 'light');
      final BaseThemeConfig<dynamic>? before = manager.currentTheme;
      expect(before!.id, 'light');

      // Re-register with a new instance under the same id: the cache must
      // not hand back the stale config from the previous registration.
      manager.registerThemes([
        _theme('light', NyThemeType.light),
        _theme('dark', NyThemeType.dark),
      ], initialThemeId: 'light');
      final BaseThemeConfig<dynamic>? after = manager.currentTheme;

      expect(after!.id, 'light');
      expect(identical(before, after), isFalse);
      expect(manager.themes.contains(after), isTrue);
    });

    nyTest('is invalidated by setFollowSystemTheme', () async {
      final NyThemeManager manager = NyThemeManager.instance;
      manager.registerThemes([
        _theme('light', NyThemeType.light),
        _theme('dark', NyThemeType.dark),
      ], initialThemeId: 'dark');
      expect(manager.currentTheme!.id, 'dark');

      // Test binding reports light platform brightness by default.
      await manager.setFollowSystemTheme(true);

      expect(manager.currentTheme!.id, 'light');
      expect(manager.isDark, isFalse);
    });

    nyTest('is cleared by dispose', () async {
      final NyThemeManager manager = NyThemeManager.instance;
      manager.registerThemes([
        _theme('light', NyThemeType.light),
      ], initialThemeId: 'light');
      expect(manager.currentTheme, isNotNull);

      manager.dispose();

      expect(manager.currentThemeId, isEmpty);
      expect(manager.currentTheme, isNull);
      expect(manager.isDark, isFalse);
    });
  });
}
