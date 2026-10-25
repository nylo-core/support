import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '/localization/ny_localization.dart';
import '/themes/ny_themes.dart';
import '/widgets/src/ny_app.dart';

/// Shows the app in another locale or theme for a screenshot, without
/// restarting it, and puts it back afterwards.
///
/// The page, its state and the navigation stack stay where they are, so a
/// playbook can photograph one screen in every language it ships.
abstract final class ScreenshotLook {
  /// Shows [locale] (a language code like `es`) and [theme] (a theme id),
  /// and returns a function that puts back the ones shown before. A null
  /// argument keeps the current one.
  ///
  /// Throws a [StateError] when the locale has no language file or no theme
  /// has that id. Nothing is saved, so the user's own choices are kept.
  static Future<Future<void> Function()> show({
    String? locale,
    String? theme,
  }) async {
    final NyLocalization localization = NyLocalization.instance;
    final NyThemeManager themes = NyThemeManager.instance;
    final Locale localeBefore = localization.locale;
    final String themeBefore = themes.currentThemeId;
    final bool changeLocale =
        locale != null && locale != localeBefore.languageCode;
    final bool changeTheme = theme != null && theme != themeBefore;

    if (changeTheme && themes.getThemeById(theme) == null) {
      final List<String> ids = themeIds;
      throw StateError(
        ids.isEmpty
            ? 'No themes are registered.'
            : 'No theme with id "$theme". Registered themes: '
                  '${ids.join(', ')}.',
      );
    }
    if (changeLocale) {
      final String file =
          '${localization.assetsDirectory ?? 'lang/'}$locale.json';
      if (!await _exists(file)) {
        throw StateError(
          'Couldn\'t switch to "$locale". Check that $file exists and is '
          'listed in your assets.',
        );
      }
      await localization.setLocale(locale: Locale(locale));
      NyApp.refreshLocale();
    }
    if (changeTheme) themes.showTheme(theme);

    return () async {
      if (changeTheme && themeBefore.isNotEmpty) themes.showTheme(themeBefore);
      if (changeLocale) {
        await localization.setLocale(locale: localeBefore);
        NyApp.refreshLocale();
      }
    };
  }

  static Future<bool> _exists(String asset) async {
    try {
      await rootBundle.loadString(asset);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// The language codes of the language files bundled with the app, e.g.
  /// `[en, es]`, sorted.
  static Future<List<String>> bundledLocales() async {
    final String folder = NyLocalization.instance.assetsDirectory ?? 'lang/';
    final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(
      rootBundle,
    );
    return [
      for (final String asset in manifest.listAssets())
        if (asset.startsWith(folder) &&
            asset.endsWith('.json') &&
            !asset.substring(folder.length).contains('/'))
          asset.substring(folder.length, asset.length - '.json'.length),
    ]..sort();
  }

  /// The ids of the registered themes.
  static List<String> get themeIds => [
    for (final BaseThemeConfig<dynamic> config
        in NyThemeManager.instance.themes)
      config.id,
  ];
}
