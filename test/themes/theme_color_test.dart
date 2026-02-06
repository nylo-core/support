import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/themes/src/theme_color.dart';

/// Test implementation of ThemeColor
class TestThemeColor extends ThemeColor {
  @override
  GeneralColors get general => const GeneralColors(
    background: Colors.white,
    content: Colors.black,
    primaryAccent: Colors.blue,
    surface: Color(0xFFF5F5F5),
    surfaceContent: Color(0xFF212121),
  );

  @override
  AppBarColors get appBar =>
      const AppBarColors(background: Colors.blue, content: Colors.white);

  @override
  BottomTabBarColors get bottomTabBar => const BottomTabBarColors(
    background: Colors.white,
    iconSelected: Colors.blue,
    iconUnselected: Colors.grey,
    labelSelected: Colors.blue,
    labelUnselected: Colors.grey,
  );
}

void main() {
  NyTest.init();

  nyGroup('ThemeColor', () {
    nyGroup('abstract class implementation', () {
      nyTest('can be implemented with all required color groups', () async {
        final theme = TestThemeColor();

        expect(theme.general, isA<GeneralColors>());
        expect(theme.appBar, isA<AppBarColors>());
        expect(theme.bottomTabBar, isA<BottomTabBarColors>());
      });

      nyTest('general colors are accessible', () async {
        final theme = TestThemeColor();

        expect(theme.general.background, Colors.white);
        expect(theme.general.content, Colors.black);
        expect(theme.general.primaryAccent, Colors.blue);
        expect(theme.general.surface, const Color(0xFFF5F5F5));
        expect(theme.general.surfaceContent, const Color(0xFF212121));
      });

      nyTest('app bar colors are accessible', () async {
        final theme = TestThemeColor();

        expect(theme.appBar.background, Colors.blue);
        expect(theme.appBar.content, Colors.white);
      });

      nyTest('bottom tab bar colors are accessible', () async {
        final theme = TestThemeColor();

        expect(theme.bottomTabBar.background, Colors.white);
        expect(theme.bottomTabBar.iconSelected, Colors.blue);
        expect(theme.bottomTabBar.iconUnselected, Colors.grey);
        expect(theme.bottomTabBar.labelSelected, Colors.blue);
        expect(theme.bottomTabBar.labelUnselected, Colors.grey);
      });
    });
  });

  nyGroup('GeneralColors', () {
    nyTest('can be constructed with const', () async {
      const colors = GeneralColors(
        background: Colors.white,
        content: Colors.black,
        primaryAccent: Colors.blue,
        surface: Colors.grey,
        surfaceContent: Colors.black87,
      );

      expect(colors.background, Colors.white);
      expect(colors.content, Colors.black);
    });

    nyTest('copyWith creates new instance with replaced values', () async {
      const original = GeneralColors(
        background: Colors.white,
        content: Colors.black,
        primaryAccent: Colors.blue,
        surface: Colors.grey,
        surfaceContent: Colors.black87,
      );

      final modified = original.copyWith(background: Colors.red);

      expect(modified.background, Colors.red);
      expect(modified.content, Colors.black);
      expect(modified.primaryAccent, Colors.blue);
    });

    nyTest('copyWith preserves original values when not specified', () async {
      const original = GeneralColors(
        background: Colors.white,
        content: Colors.black,
        primaryAccent: Colors.blue,
        surface: Colors.grey,
        surfaceContent: Colors.black87,
      );

      final modified = original.copyWith();

      expect(modified.background, original.background);
      expect(modified.content, original.content);
      expect(modified.primaryAccent, original.primaryAccent);
      expect(modified.surface, original.surface);
      expect(modified.surfaceContent, original.surfaceContent);
    });
  });

  nyGroup('AppBarColors', () {
    nyTest('can be constructed with const', () async {
      const colors = AppBarColors(
        background: Colors.blue,
        content: Colors.white,
      );

      expect(colors.background, Colors.blue);
      expect(colors.content, Colors.white);
    });

    nyTest('copyWith creates new instance with replaced values', () async {
      const original = AppBarColors(
        background: Colors.blue,
        content: Colors.white,
      );

      final modified = original.copyWith(background: Colors.green);

      expect(modified.background, Colors.green);
      expect(modified.content, Colors.white);
    });
  });

  nyGroup('BottomTabBarColors', () {
    nyTest('can be constructed with const', () async {
      const colors = BottomTabBarColors(
        background: Colors.white,
        iconSelected: Colors.blue,
        iconUnselected: Colors.grey,
        labelSelected: Colors.blue,
        labelUnselected: Colors.grey,
      );

      expect(colors.background, Colors.white);
      expect(colors.iconSelected, Colors.blue);
    });

    nyTest('copyWith creates new instance with replaced values', () async {
      const original = BottomTabBarColors(
        background: Colors.white,
        iconSelected: Colors.blue,
        iconUnselected: Colors.grey,
        labelSelected: Colors.blue,
        labelUnselected: Colors.grey,
      );

      final modified = original.copyWith(
        iconSelected: Colors.green,
        labelSelected: Colors.green,
      );

      expect(modified.background, Colors.white);
      expect(modified.iconSelected, Colors.green);
      expect(modified.iconUnselected, Colors.grey);
      expect(modified.labelSelected, Colors.green);
      expect(modified.labelUnselected, Colors.grey);
    });
  });
}
