import 'package:collection/collection.dart';
import '/helpers/ny_helpers.dart';

import '/local_storage/ny_local_storage.dart';
import '/localization/ny_localization.dart';
import '/widgets/ny_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// [LanguageSwitcher] is a widget that allows you to switch languages in your app.
/// You can use it in the [AppBar] or as a bottom sheet modal using the [showBottomModal] method.
/// Example:
/// ```dart
/// LanguageSwitcher()
/// // or
/// LanguageSwitcher.showBottomModal(context);
/// ```
/// You can also use the [LanguageSwitcher.currentLanguage] method to get the current language.
/// Example:
/// ```dart
/// Map<String, dynamic>? lang = await LanguageSwitcher.currentLanguage();
/// ```
/// You can also use the [LanguageSwitcher.storeLanguage] method to store the language.
/// Example:
/// ```dart
/// LanguageSwitcher.storeLanguage(object: {"en": "English"});
/// ```
class LanguageSwitcher extends StatefulWidget {
  const LanguageSwitcher({
    super.key,
    this.icon,
    this.iconEnabledColor,
    this.dropdownBgColor,
    this.onLanguageChange,
    this.hint,
    this.itemHeight = kMinInteractiveDimension,
    this.dropdownBuilder,
    this.dropdownAlignment = AlignmentDirectional.centerStart,
    this.dropdownOnTap,
    this.padding,
    this.onTap,
    this.borderRadius,
    this.iconSize = 24,
    this.elevation = 8,
    this.langPath = 'lang',
    this.textStyle,
  });

  final Widget? icon;
  final Widget? hint;
  final double itemHeight;
  final Widget Function(Map<String, dynamic> language)? dropdownBuilder;
  final Function()? dropdownOnTap;
  final AlignmentGeometry dropdownAlignment;
  final Color? dropdownBgColor;
  final String langPath;
  final TextStyle? textStyle;
  final double iconSize;
  final Function()? onTap;
  final BorderRadius? borderRadius;
  final Color? iconEnabledColor;
  final int elevation;
  final EdgeInsetsGeometry? padding;
  final Function(Map<String, dynamic> language)? onLanguageChange;

  static String state = "ny_lang_switcher";

  /// Get the current language
  static Future<Map<String, dynamic>?> currentLanguage({String? key}) async {
    key ??= state;
    return await NyStorage.readJson(key);
  }

  /// Store the language in the storage
  static Future storeLanguage({String? key, Map<String, dynamic>? object}) {
    key ??= state;
    return NyStorage.saveJson(key, object);
  }

  /// Clear the language from the storage
  static Future clearLanguage({String? key}) {
    key ??= state;
    return NyStorage.delete(key);
  }

  /// Map of locale codes to flag emojis
  static const Map<String, String> _localeFlags = {
    'en': '\u{1F1FA}\u{1F1F8}',
    'en_US': '\u{1F1FA}\u{1F1F8}',
    'en_GB': '\u{1F1EC}\u{1F1E7}',
    'en_AU': '\u{1F1E6}\u{1F1FA}',
    'en_CA': '\u{1F1E8}\u{1F1E6}',
    'es': '\u{1F1EA}\u{1F1F8}',
    'es_ES': '\u{1F1EA}\u{1F1F8}',
    'es_MX': '\u{1F1F2}\u{1F1FD}',
    'fr': '\u{1F1EB}\u{1F1F7}',
    'fr_FR': '\u{1F1EB}\u{1F1F7}',
    'fr_CA': '\u{1F1E8}\u{1F1E6}',
    'de': '\u{1F1E9}\u{1F1EA}',
    'de_DE': '\u{1F1E9}\u{1F1EA}',
    'it': '\u{1F1EE}\u{1F1F9}',
    'it_IT': '\u{1F1EE}\u{1F1F9}',
    'pt': '\u{1F1F5}\u{1F1F9}',
    'pt_PT': '\u{1F1F5}\u{1F1F9}',
    'pt_BR': '\u{1F1E7}\u{1F1F7}',
    'nl': '\u{1F1F3}\u{1F1F1}',
    'nl_NL': '\u{1F1F3}\u{1F1F1}',
    'ru': '\u{1F1F7}\u{1F1FA}',
    'ru_RU': '\u{1F1F7}\u{1F1FA}',
    'zh': '\u{1F1E8}\u{1F1F3}',
    'zh_CN': '\u{1F1E8}\u{1F1F3}',
    'zh_TW': '\u{1F1F9}\u{1F1FC}',
    'zh_HK': '\u{1F1ED}\u{1F1F0}',
    'ja': '\u{1F1EF}\u{1F1F5}',
    'ja_JP': '\u{1F1EF}\u{1F1F5}',
    'ko': '\u{1F1F0}\u{1F1F7}',
    'ko_KR': '\u{1F1F0}\u{1F1F7}',
    'ar': '\u{1F1F8}\u{1F1E6}',
    'hi': '\u{1F1EE}\u{1F1F3}',
    'hi_IN': '\u{1F1EE}\u{1F1F3}',
    'tr': '\u{1F1F9}\u{1F1F7}',
    'tr_TR': '\u{1F1F9}\u{1F1F7}',
    'pl': '\u{1F1F5}\u{1F1F1}',
    'pl_PL': '\u{1F1F5}\u{1F1F1}',
    'uk': '\u{1F1FA}\u{1F1E6}',
    'uk_UA': '\u{1F1FA}\u{1F1E6}',
    'vi': '\u{1F1FB}\u{1F1F3}',
    'vi_VN': '\u{1F1FB}\u{1F1F3}',
    'th': '\u{1F1F9}\u{1F1ED}',
    'th_TH': '\u{1F1F9}\u{1F1ED}',
    'id': '\u{1F1EE}\u{1F1E9}',
    'id_ID': '\u{1F1EE}\u{1F1E9}',
    'ms': '\u{1F1F2}\u{1F1FE}',
    'ms_MY': '\u{1F1F2}\u{1F1FE}',
    'sv': '\u{1F1F8}\u{1F1EA}',
    'sv_SE': '\u{1F1F8}\u{1F1EA}',
    'da': '\u{1F1E9}\u{1F1F0}',
    'da_DK': '\u{1F1E9}\u{1F1F0}',
    'no': '\u{1F1F3}\u{1F1F4}',
    'no_NO': '\u{1F1F3}\u{1F1F4}',
    'fi': '\u{1F1EB}\u{1F1EE}',
    'fi_FI': '\u{1F1EB}\u{1F1EE}',
    'el': '\u{1F1EC}\u{1F1F7}',
    'el_GR': '\u{1F1EC}\u{1F1F7}',
    'he': '\u{1F1EE}\u{1F1F1}',
    'he_IL': '\u{1F1EE}\u{1F1F1}',
    'cs': '\u{1F1E8}\u{1F1FF}',
    'cs_CZ': '\u{1F1E8}\u{1F1FF}',
    'ro': '\u{1F1F7}\u{1F1F4}',
    'ro_RO': '\u{1F1F7}\u{1F1F4}',
    'hu': '\u{1F1ED}\u{1F1FA}',
    'hu_HU': '\u{1F1ED}\u{1F1FA}',
    'sk': '\u{1F1F8}\u{1F1F0}',
    'sk_SK': '\u{1F1F8}\u{1F1F0}',
    'bg': '\u{1F1E7}\u{1F1EC}',
    'bg_BG': '\u{1F1E7}\u{1F1EC}',
    'hr': '\u{1F1ED}\u{1F1F7}',
    'hr_HR': '\u{1F1ED}\u{1F1F7}',
    'sr': '\u{1F1F7}\u{1F1F8}',
    'sr_RS': '\u{1F1F7}\u{1F1F8}',
    'sl': '\u{1F1F8}\u{1F1EE}',
    'sl_SI': '\u{1F1F8}\u{1F1EE}',
    'et': '\u{1F1EA}\u{1F1EA}',
    'et_EE': '\u{1F1EA}\u{1F1EA}',
    'lv': '\u{1F1F1}\u{1F1FB}',
    'lv_LV': '\u{1F1F1}\u{1F1FB}',
    'lt': '\u{1F1F1}\u{1F1F9}',
    'lt_LT': '\u{1F1F1}\u{1F1F9}',
    'bn': '\u{1F1E7}\u{1F1E9}',
    'bn_BD': '\u{1F1E7}\u{1F1E9}',
    'ta': '\u{1F1EE}\u{1F1F3}',
    'ta_IN': '\u{1F1EE}\u{1F1F3}',
    'te': '\u{1F1EE}\u{1F1F3}',
    'te_IN': '\u{1F1EE}\u{1F1F3}',
    'mr': '\u{1F1EE}\u{1F1F3}',
    'mr_IN': '\u{1F1EE}\u{1F1F3}',
    'gu': '\u{1F1EE}\u{1F1F3}',
    'gu_IN': '\u{1F1EE}\u{1F1F3}',
    'kn': '\u{1F1EE}\u{1F1F3}',
    'kn_IN': '\u{1F1EE}\u{1F1F3}',
    'ml': '\u{1F1EE}\u{1F1F3}',
    'ml_IN': '\u{1F1EE}\u{1F1F3}',
    'pa': '\u{1F1EE}\u{1F1F3}',
    'pa_IN': '\u{1F1EE}\u{1F1F3}',
    'fa': '\u{1F1EE}\u{1F1F7}',
    'fa_IR': '\u{1F1EE}\u{1F1F7}',
    'ur': '\u{1F1F5}\u{1F1F0}',
    'ur_PK': '\u{1F1F5}\u{1F1F0}',
    'sw': '\u{1F1F0}\u{1F1EA}',
    'sw_KE': '\u{1F1F0}\u{1F1EA}',
    'af': '\u{1F1FF}\u{1F1E6}',
    'af_ZA': '\u{1F1FF}\u{1F1E6}',
    'fil': '\u{1F1F5}\u{1F1ED}',
    'tl': '\u{1F1F5}\u{1F1ED}',
    'tl_PH': '\u{1F1F5}\u{1F1ED}',
    'ca': '\u{1F1EA}\u{1F1F8}',
    'ca_ES': '\u{1F1EA}\u{1F1F8}',
    'eu': '\u{1F1EA}\u{1F1F8}',
    'eu_ES': '\u{1F1EA}\u{1F1F8}',
    'gl': '\u{1F1EA}\u{1F1F8}',
    'gl_ES': '\u{1F1EA}\u{1F1F8}',
  };

  /// Get flag emoji for a locale code
  static String getFlagEmoji(String localeCode) {
    // Try exact match first
    if (_localeFlags.containsKey(localeCode)) {
      return _localeFlags[localeCode]!;
    }
    // Try base language code (e.g., 'en' from 'en_US')
    final baseCode = localeCode.split('_').first;
    if (_localeFlags.containsKey(baseCode)) {
      return _localeFlags[baseCode]!;
    }
    // Default globe emoji
    return '\u{1F310}';
  }

  /// Show a bottom modal to switch languages
  static Future<void> showBottomModal(
    BuildContext context, {
    double? height,
    Color? backgroundColor,
    Color? handleColor,
    Color? selectedColor,
    TextStyle? titleStyle,
    TextStyle? languageTextStyle,
    BorderRadius? borderRadius,
  }) async {
    // Capture navigator state before async operations
    final navigator = Navigator.of(context);

    List<Map<String, String>> list = await getLanguageList();
    Map<String, dynamic>? currentLang = await currentLanguage();

    if (!context.mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        final effectiveBackgroundColor =
            backgroundColor ??
            (isDark ? const Color(0xFF1C1C1E) : Colors.white);
        final effectiveHandleColor =
            handleColor ??
            (isDark ? Colors.grey.shade600 : Colors.grey.shade300);
        final effectiveSelectedColor =
            selectedColor ??
            (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7));
        final effectiveBorderRadius =
            borderRadius ??
            const BorderRadius.vertical(top: Radius.circular(20));

        return Container(
          constraints: BoxConstraints(maxHeight: height ?? screenHeight * 0.6),
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: effectiveBorderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: effectiveHandleColor,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Text(
                    "nylo.language_switcher.title".tr(),
                    style:
                        titleStyle ??
                        TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                          letterSpacing: -0.5,
                        ),
                  ),
                ),
                // Divider
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
                // Language list
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final meta = list[index];
                      final data = meta.entries.firstOrNull;
                      if (data == null) return const SizedBox.shrink();

                      final isSelected =
                          currentLang != null &&
                          currentLang.entries.isNotEmpty &&
                          data.key == currentLang.entries.first.key;

                      final flagEmoji = getFlagEmoji(data.key);

                      return _LanguageListItem(
                        languageName: data.value,
                        localeCode: data.key,
                        flagEmoji: flagEmoji,
                        isSelected: isSelected,
                        selectedColor: effectiveSelectedColor,
                        textStyle: languageTextStyle,
                        isDark: isDark,
                        onTap: () async {
                          await NyLocalization.instance.setLanguage(
                            modalContext,
                            language: data.key,
                          );

                          // store the language
                          await storeLanguage(object: {data.key: data.value});

                          updateState(
                            state,
                            data: {"action": "refresh-page", "data": {}},
                          );
                          navigator.pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Map of locale codes to language names
  static const Map<String, String> _languageData = {
    "af": "Afrikaans",
    "af_NA": "Afrikaans (Namibia)",
    "af_ZA": "Afrikaans (South Africa)",
    "ak": "Akan",
    "ak_GH": "Akan (Ghana)",
    "sq": "Albanian",
    "sq_AL": "Albanian (Albania)",
    "sq_XK": "Albanian (Kosovo)",
    "sq_MK": "Albanian (Macedonia)",
    "am": "Amharic",
    "am_ET": "Amharic (Ethiopia)",
    "ar": "Arabic",
    "ar_DZ": "Arabic (Algeria)",
    "ar_BH": "Arabic (Bahrain)",
    "ar_TD": "Arabic (Chad)",
    "ar_KM": "Arabic (Comoros)",
    "ar_DJ": "Arabic (Djibouti)",
    "ar_EG": "Arabic (Egypt)",
    "ar_ER": "Arabic (Eritrea)",
    "ar_IQ": "Arabic (Iraq)",
    "ar_IL": "Arabic (Israel)",
    "ar_JO": "Arabic (Jordan)",
    "ar_KW": "Arabic (Kuwait)",
    "ar_LB": "Arabic (Lebanon)",
    "ar_LY": "Arabic (Libya)",
    "ar_MR": "Arabic (Mauritania)",
    "ar_MA": "Arabic (Morocco)",
    "ar_OM": "Arabic (Oman)",
    "ar_PS": "Arabic (Palestinian Territories)",
    "ar_QA": "Arabic (Qatar)",
    "ar_SA": "Arabic (Saudi Arabia)",
    "ar_SO": "Arabic (Somalia)",
    "ar_SS": "Arabic (South Sudan)",
    "ar_SD": "Arabic (Sudan)",
    "ar_SY": "Arabic (Syria)",
    "ar_TN": "Arabic (Tunisia)",
    "ar_AE": "Arabic (United Arab Emirates)",
    "ar_EH": "Arabic (Western Sahara)",
    "ar_YE": "Arabic (Yemen)",
    "hy": "Armenian",
    "hy_AM": "Armenian (Armenia)",
    "as": "Assamese",
    "as_IN": "Assamese (India)",
    "az": "Azerbaijani",
    "az_AZ": "Azerbaijani (Azerbaijan)",
    "az_Cyrl_AZ": "Azerbaijani (Cyrillic, Azerbaijan)",
    "az_Cyrl": "Azerbaijani (Cyrillic)",
    "az_Latn_AZ": "Azerbaijani (Latin, Azerbaijan)",
    "az_Latn": "Azerbaijani (Latin)",
    "bm": "Bambara",
    "bm_Latn_ML": "Bambara (Latin, Mali)",
    "bm_Latn": "Bambara (Latin)",
    "eu": "Basque",
    "eu_ES": "Basque (Spain)",
    "be": "Belarusian",
    "be_BY": "Belarusian (Belarus)",
    "bn": "Bengali",
    "bn_BD": "Bengali (Bangladesh)",
    "bn_IN": "Bengali (India)",
    "bs": "Bosnian",
    "bs_BA": "Bosnian (Bosnia & Herzegovina)",
    "bs_Cyrl_BA": "Bosnian (Cyrillic, Bosnia & Herzegovina)",
    "bs_Cyrl": "Bosnian (Cyrillic)",
    "bs_Latn_BA": "Bosnian (Latin, Bosnia & Herzegovina)",
    "bs_Latn": "Bosnian (Latin)",
    "br": "Breton",
    "br_FR": "Breton (France)",
    "bg": "Bulgarian",
    "bg_BG": "Bulgarian (Bulgaria)",
    "my": "Burmese",
    "my_MM": "Burmese (Myanmar (Burma))",
    "ca": "Catalan",
    "ca_AD": "Catalan (Andorra)",
    "ca_FR": "Catalan (France)",
    "ca_IT": "Catalan (Italy)",
    "ca_ES": "Catalan (Spain)",
    "zh": "Chinese",
    "zh_CN": "Chinese (China)",
    "zh_HK": "Chinese (Hong Kong SAR China)",
    "zh_MO": "Chinese (Macau SAR China)",
    "zh_Hans_CN": "Chinese (Simplified, China)",
    "zh_Hans_HK": "Chinese (Simplified, Hong Kong SAR China)",
    "zh_Hans_MO": "Chinese (Simplified, Macau SAR China)",
    "zh_Hans_SG": "Chinese (Simplified, Singapore)",
    "zh_Hans": "Chinese (Simplified)",
    "zh_SG": "Chinese (Singapore)",
    "zh_TW": "Chinese (Taiwan)",
    "zh_Hant_HK": "Chinese (Traditional, Hong Kong SAR China)",
    "zh_Hant_MO": "Chinese (Traditional, Macau SAR China)",
    "zh_Hant_TW": "Chinese (Traditional, Taiwan)",
    "zh_Hant": "Chinese (Traditional)",
    "kw": "Cornish",
    "kw_GB": "Cornish (United Kingdom)",
    "hr": "Croatian",
    "hr_BA": "Croatian (Bosnia & Herzegovina)",
    "hr_HR": "Croatian (Croatia)",
    "cs": "Czech",
    "cs_CZ": "Czech (Czech Republic)",
    "da": "Danish",
    "da_DK": "Danish (Denmark)",
    "da_GL": "Danish (Greenland)",
    "nl": "Dutch",
    "nl_AW": "Dutch (Aruba)",
    "nl_BE": "Dutch (Belgium)",
    "nl_BQ": "Dutch (Caribbean Netherlands)",
    "nl_CW": "Dutch (Cura\u00e7ao)",
    "nl_NL": "Dutch (Netherlands)",
    "nl_SX": "Dutch (Sint Maarten)",
    "nl_SR": "Dutch (Suriname)",
    "dz": "Dzongkha",
    "dz_BT": "Dzongkha (Bhutan)",
    "en": "English",
    "en_AS": "English (American Samoa)",
    "en_AI": "English (Anguilla)",
    "en_AG": "English (Antigua & Barbuda)",
    "en_AU": "English (Australia)",
    "en_BS": "English (Bahamas)",
    "en_BB": "English (Barbados)",
    "en_BE": "English (Belgium)",
    "en_BZ": "English (Belize)",
    "en_BM": "English (Bermuda)",
    "en_BW": "English (Botswana)",
    "en_IO": "English (British Indian Ocean Territory)",
    "en_VG": "English (British Virgin Islands)",
    "en_CM": "English (Cameroon)",
    "en_CA": "English (Canada)",
    "en_KY": "English (Cayman Islands)",
    "en_CX": "English (Christmas Island)",
    "en_CC": "English (Cocos (Keeling) Islands)",
    "en_CK": "English (Cook Islands)",
    "en_DG": "English (Diego Garcia)",
    "en_DM": "English (Dominica)",
    "en_ER": "English (Eritrea)",
    "en_FK": "English (Falkland Islands)",
    "en_FJ": "English (Fiji)",
    "en_GM": "English (Gambia)",
    "en_GH": "English (Ghana)",
    "en_GI": "English (Gibraltar)",
    "en_GD": "English (Grenada)",
    "en_GU": "English (Guam)",
    "en_GG": "English (Guernsey)",
    "en_GY": "English (Guyana)",
    "en_HK": "English (Hong Kong SAR China)",
    "en_IN": "English (India)",
    "en_IE": "English (Ireland)",
    "en_IM": "English (Isle of Man)",
    "en_JM": "English (Jamaica)",
    "en_JE": "English (Jersey)",
    "en_KE": "English (Kenya)",
    "en_KI": "English (Kiribati)",
    "en_LS": "English (Lesotho)",
    "en_LR": "English (Liberia)",
    "en_MO": "English (Macau SAR China)",
    "en_MG": "English (Madagascar)",
    "en_MW": "English (Malawi)",
    "en_MY": "English (Malaysia)",
    "en_MT": "English (Malta)",
    "en_MH": "English (Marshall Islands)",
    "en_MU": "English (Mauritius)",
    "en_FM": "English (Micronesia)",
    "en_MS": "English (Montserrat)",
    "en_NA": "English (Namibia)",
    "en_NR": "English (Nauru)",
    "en_NZ": "English (New Zealand)",
    "en_NG": "English (Nigeria)",
    "en_NU": "English (Niue)",
    "en_NF": "English (Norfolk Island)",
    "en_MP": "English (Northern Mariana Islands)",
    "en_PK": "English (Pakistan)",
    "en_PW": "English (Palau)",
    "en_PG": "English (Papua New Guinea)",
    "en_PH": "English (Philippines)",
    "en_PN": "English (Pitcairn Islands)",
    "en_PR": "English (Puerto Rico)",
    "en_RW": "English (Rwanda)",
    "en_WS": "English (Samoa)",
    "en_SC": "English (Seychelles)",
    "en_SL": "English (Sierra Leone)",
    "en_SG": "English (Singapore)",
    "en_SX": "English (Sint Maarten)",
    "en_SB": "English (Solomon Islands)",
    "en_ZA": "English (South Africa)",
    "en_SS": "English (South Sudan)",
    "en_SH": "English (St. Helena)",
    "en_KN": "English (St. Kitts & Nevis)",
    "en_LC": "English (St. Lucia)",
    "en_VC": "English (St. Vincent & Grenadines)",
    "en_SD": "English (Sudan)",
    "en_SZ": "English (Swaziland)",
    "en_TZ": "English (Tanzania)",
    "en_TK": "English (Tokelau)",
    "en_TO": "English (Tonga)",
    "en_TT": "English (Trinidad & Tobago)",
    "en_TC": "English (Turks & Caicos Islands)",
    "en_TV": "English (Tuvalu)",
    "en_UM": "English (U.S. Outlying Islands)",
    "en_VI": "English (U.S. Virgin Islands)",
    "en_UG": "English (Uganda)",
    "en_GB": "English (United Kingdom)",
    "en_US": "English (United States)",
    "en_VU": "English (Vanuatu)",
    "en_ZM": "English (Zambia)",
    "en_ZW": "English (Zimbabwe)",
    "eo": "Esperanto",
    "et": "Estonian",
    "et_EE": "Estonian (Estonia)",
    "ee": "Ewe",
    "ee_GH": "Ewe (Ghana)",
    "ee_TG": "Ewe (Togo)",
    "fo": "Faroese",
    "fo_FO": "Faroese (Faroe Islands)",
    "fi": "Finnish",
    "fi_FI": "Finnish (Finland)",
    "fr": "French",
    "fr_DZ": "French (Algeria)",
    "fr_BE": "French (Belgium)",
    "fr_BJ": "French (Benin)",
    "fr_BF": "French (Burkina Faso)",
    "fr_BI": "French (Burundi)",
    "fr_CM": "French (Cameroon)",
    "fr_CA": "French (Canada)",
    "fr_CF": "French (Central African Republic)",
    "fr_TD": "French (Chad)",
    "fr_KM": "French (Comoros)",
    "fr_CG": "French (Congo - Brazzaville)",
    "fr_CD": "French (Congo - Kinshasa)",
    "fr_CI": "French (C\u00f4te d\u2019Ivoire)",
    "fr_DJ": "French (Djibouti)",
    "fr_GQ": "French (Equatorial Guinea)",
    "fr_FR": "French (France)",
    "fr_GF": "French (French Guiana)",
    "fr_PF": "French (French Polynesia)",
    "fr_GA": "French (Gabon)",
    "fr_GP": "French (Guadeloupe)",
    "fr_GN": "French (Guinea)",
    "fr_HT": "French (Haiti)",
    "fr_LU": "French (Luxembourg)",
    "fr_MG": "French (Madagascar)",
    "fr_ML": "French (Mali)",
    "fr_MQ": "French (Martinique)",
    "fr_MR": "French (Mauritania)",
    "fr_MU": "French (Mauritius)",
    "fr_YT": "French (Mayotte)",
    "fr_MC": "French (Monaco)",
    "fr_MA": "French (Morocco)",
    "fr_NC": "French (New Caledonia)",
    "fr_NE": "French (Niger)",
    "fr_RE": "French (R\u00e9union)",
    "fr_RW": "French (Rwanda)",
    "fr_SN": "French (Senegal)",
    "fr_SC": "French (Seychelles)",
    "fr_BL": "French (St. Barth\u00e9lemy)",
    "fr_MF": "French (St. Martin)",
    "fr_PM": "French (St. Pierre & Miquelon)",
    "fr_CH": "French (Switzerland)",
    "fr_SY": "French (Syria)",
    "fr_TG": "French (Togo)",
    "fr_TN": "French (Tunisia)",
    "fr_VU": "French (Vanuatu)",
    "fr_WF": "French (Wallis & Futuna)",
    "ff": "Fulah",
    "ff_CM": "Fulah (Cameroon)",
    "ff_GN": "Fulah (Guinea)",
    "ff_MR": "Fulah (Mauritania)",
    "ff_SN": "Fulah (Senegal)",
    "gl": "Galician",
    "gl_ES": "Galician (Spain)",
    "lg": "Ganda",
    "lg_UG": "Ganda (Uganda)",
    "ka": "Georgian",
    "ka_GE": "Georgian (Georgia)",
    "de": "German",
    "de_AT": "German (Austria)",
    "de_BE": "German (Belgium)",
    "de_DE": "German (Germany)",
    "de_LI": "German (Liechtenstein)",
    "de_LU": "German (Luxembourg)",
    "de_CH": "German (Switzerland)",
    "el": "Greek",
    "el_CY": "Greek (Cyprus)",
    "el_GR": "Greek (Greece)",
    "gu": "Gujarati",
    "gu_IN": "Gujarati (India)",
    "ha": "Hausa",
    "ha_GH": "Hausa (Ghana)",
    "ha_Latn_GH": "Hausa (Latin, Ghana)",
    "ha_Latn_NE": "Hausa (Latin, Niger)",
    "ha_Latn_NG": "Hausa (Latin, Nigeria)",
    "ha_Latn": "Hausa (Latin)",
    "ha_NE": "Hausa (Niger)",
    "ha_NG": "Hausa (Nigeria)",
    "he": "Hebrew",
    "he_IL": "Hebrew (Israel)",
    "hi": "Hindi",
    "hi_IN": "Hindi (India)",
    "hu": "Hungarian",
    "hu_HU": "Hungarian (Hungary)",
    "is": "Icelandic",
    "is_IS": "Icelandic (Iceland)",
    "ig": "Igbo",
    "ig_NG": "Igbo (Nigeria)",
    "id": "Indonesian",
    "id_ID": "Indonesian (Indonesia)",
    "ga": "Irish",
    "ga_IE": "Irish (Ireland)",
    "it": "Italian",
    "it_IT": "Italian (Italy)",
    "it_SM": "Italian (San Marino)",
    "it_CH": "Italian (Switzerland)",
    "ja": "Japanese",
    "ja_JP": "Japanese (Japan)",
    "kl": "Kalaallisut",
    "kl_GL": "Kalaallisut (Greenland)",
    "kn": "Kannada",
    "kn_IN": "Kannada (India)",
    "ks": "Kashmiri",
    "ks_Arab_IN": "Kashmiri (Arabic, India)",
    "ks_Arab": "Kashmiri (Arabic)",
    "ks_IN": "Kashmiri (India)",
    "kk": "Kazakh",
    "kk_Cyrl_KZ": "Kazakh (Cyrillic, Kazakhstan)",
    "kk_Cyrl": "Kazakh (Cyrillic)",
    "kk_KZ": "Kazakh (Kazakhstan)",
    "km": "Khmer",
    "km_KH": "Khmer (Cambodia)",
    "ki": "Kikuyu",
    "ki_KE": "Kikuyu (Kenya)",
    "rw": "Kinyarwanda",
    "rw_RW": "Kinyarwanda (Rwanda)",
    "ko": "Korean",
    "ko_KP": "Korean (North Korea)",
    "ko_KR": "Korean (South Korea)",
    "ky": "Kyrgyz",
    "ky_Cyrl_KG": "Kyrgyz (Cyrillic, Kyrgyzstan)",
    "ky_Cyrl": "Kyrgyz (Cyrillic)",
    "ky_KG": "Kyrgyz (Kyrgyzstan)",
    "lo": "Lao",
    "lo_LA": "Lao (Laos)",
    "lv": "Latvian",
    "lv_LV": "Latvian (Latvia)",
    "ln": "Lingala",
    "ln_AO": "Lingala (Angola)",
    "ln_CF": "Lingala (Central African Republic)",
    "ln_CG": "Lingala (Congo - Brazzaville)",
    "ln_CD": "Lingala (Congo - Kinshasa)",
    "lt": "Lithuanian",
    "lt_LT": "Lithuanian (Lithuania)",
    "lu": "Luba-Katanga",
    "lu_CD": "Luba-Katanga (Congo - Kinshasa)",
    "lb": "Luxembourgish",
    "lb_LU": "Luxembourgish (Luxembourg)",
    "mk": "Macedonian",
    "mk_MK": "Macedonian (Macedonia)",
    "mg": "Malagasy",
    "mg_MG": "Malagasy (Madagascar)",
    "ms": "Malay",
    "ms_BN": "Malay (Brunei)",
    "ms_Latn_BN": "Malay (Latin, Brunei)",
    "ms_Latn_MY": "Malay (Latin, Malaysia)",
    "ms_Latn_SG": "Malay (Latin, Singapore)",
    "ms_Latn": "Malay (Latin)",
    "ms_MY": "Malay (Malaysia)",
    "ms_SG": "Malay (Singapore)",
    "ml": "Malayalam",
    "ml_IN": "Malayalam (India)",
    "mt": "Maltese",
    "mt_MT": "Maltese (Malta)",
    "gv": "Manx",
    "gv_IM": "Manx (Isle of Man)",
    "mr": "Marathi",
    "mr_IN": "Marathi (India)",
    "mn": "Mongolian",
    "mn_Cyrl_MN": "Mongolian (Cyrillic, Mongolia)",
    "mn_Cyrl": "Mongolian (Cyrillic)",
    "mn_MN": "Mongolian (Mongolia)",
    "ne": "Nepali",
    "ne_IN": "Nepali (India)",
    "ne_NP": "Nepali (Nepal)",
    "nd": "North Ndebele",
    "nd_ZW": "North Ndebele (Zimbabwe)",
    "se": "Northern Sami",
    "se_FI": "Northern Sami (Finland)",
    "se_NO": "Northern Sami (Norway)",
    "se_SE": "Northern Sami (Sweden)",
    "no": "Norwegian",
    "no_NO": "Norwegian (Norway)",
    "nb": "Norwegian Bokm\u00e5l",
    "nb_NO": "Norwegian Bokm\u00e5l (Norway)",
    "nb_SJ": "Norwegian Bokm\u00e5l (Svalbard & Jan Mayen)",
    "nn": "Norwegian Nynorsk",
    "nn_NO": "Norwegian Nynorsk (Norway)",
    "or": "Oriya",
    "or_IN": "Oriya (India)",
    "om": "Oromo",
    "om_ET": "Oromo (Ethiopia)",
    "om_KE": "Oromo (Kenya)",
    "os": "Ossetic",
    "os_GE": "Ossetic (Georgia)",
    "os_RU": "Ossetic (Russia)",
    "ps": "Pashto",
    "ps_AF": "Pashto (Afghanistan)",
    "fa": "Persian",
    "fa_AF": "Persian (Afghanistan)",
    "fa_IR": "Persian (Iran)",
    "pl": "Polish",
    "pl_PL": "Polish (Poland)",
    "pt": "Portuguese",
    "pt_AO": "Portuguese (Angola)",
    "pt_BR": "Portuguese (Brazil)",
    "pt_CV": "Portuguese (Cape Verde)",
    "pt_GW": "Portuguese (Guinea-Bissau)",
    "pt_MO": "Portuguese (Macau SAR China)",
    "pt_MZ": "Portuguese (Mozambique)",
    "pt_PT": "Portuguese (Portugal)",
    "pt_ST": "Portuguese (S\u00e3o Tom\u00e9 & Pr\u00edncipe)",
    "pt_TL": "Portuguese (Timor-Leste)",
    "pa": "Punjabi",
    "pa_Arab_PK": "Punjabi (Arabic, Pakistan)",
    "pa_Arab": "Punjabi (Arabic)",
    "pa_Guru_IN": "Punjabi (Gurmukhi, India)",
    "pa_Guru": "Punjabi (Gurmukhi)",
    "pa_IN": "Punjabi (India)",
    "pa_PK": "Punjabi (Pakistan)",
    "qu": "Quechua",
    "qu_BO": "Quechua (Bolivia)",
    "qu_EC": "Quechua (Ecuador)",
    "qu_PE": "Quechua (Peru)",
    "ro": "Romanian",
    "ro_MD": "Romanian (Moldova)",
    "ro_RO": "Romanian (Romania)",
    "rm": "Romansh",
    "rm_CH": "Romansh (Switzerland)",
    "rn": "Rundi",
    "rn_BI": "Rundi (Burundi)",
    "ru": "Russian",
    "ru_BY": "Russian (Belarus)",
    "ru_KZ": "Russian (Kazakhstan)",
    "ru_KG": "Russian (Kyrgyzstan)",
    "ru_MD": "Russian (Moldova)",
    "ru_RU": "Russian (Russia)",
    "ru_UA": "Russian (Ukraine)",
    "sg": "Sango",
    "sg_CF": "Sango (Central African Republic)",
    "gd": "Scottish Gaelic",
    "gd_GB": "Scottish Gaelic (United Kingdom)",
    "sr": "Serbian",
    "sr_BA": "Serbian (Bosnia & Herzegovina)",
    "sr_Cyrl_BA": "Serbian (Cyrillic, Bosnia & Herzegovina)",
    "sr_Cyrl_XK": "Serbian (Cyrillic, Kosovo)",
    "sr_Cyrl_ME": "Serbian (Cyrillic, Montenegro)",
    "sr_Cyrl_RS": "Serbian (Cyrillic, Serbia)",
    "sr_Cyrl": "Serbian (Cyrillic)",
    "sr_XK": "Serbian (Kosovo)",
    "sr_Latn_BA": "Serbian (Latin, Bosnia & Herzegovina)",
    "sr_Latn_XK": "Serbian (Latin, Kosovo)",
    "sr_Latn_ME": "Serbian (Latin, Montenegro)",
    "sr_Latn_RS": "Serbian (Latin, Serbia)",
    "sr_Latn": "Serbian (Latin)",
    "sr_ME": "Serbian (Montenegro)",
    "sr_RS": "Serbian (Serbia)",
    "sh": "Serbo-Croatian",
    "sh_BA": "Serbo-Croatian (Bosnia & Herzegovina)",
    "sn": "Shona",
    "sn_ZW": "Shona (Zimbabwe)",
    "ii": "Sichuan Yi",
    "ii_CN": "Sichuan Yi (China)",
    "si": "Sinhala",
    "si_LK": "Sinhala (Sri Lanka)",
    "sk": "Slovak",
    "sk_SK": "Slovak (Slovakia)",
    "sl": "Slovenian",
    "sl_SI": "Slovenian (Slovenia)",
    "so": "Somali",
    "so_DJ": "Somali (Djibouti)",
    "so_ET": "Somali (Ethiopia)",
    "so_KE": "Somali (Kenya)",
    "so_SO": "Somali (Somalia)",
    "es": "Spanish",
    "es_AR": "Spanish (Argentina)",
    "es_BO": "Spanish (Bolivia)",
    "es_IC": "Spanish (Canary Islands)",
    "es_EA": "Spanish (Ceuta & Melilla)",
    "es_CL": "Spanish (Chile)",
    "es_CO": "Spanish (Colombia)",
    "es_CR": "Spanish (Costa Rica)",
    "es_CU": "Spanish (Cuba)",
    "es_DO": "Spanish (Dominican Republic)",
    "es_EC": "Spanish (Ecuador)",
    "es_SV": "Spanish (El Salvador)",
    "es_GQ": "Spanish (Equatorial Guinea)",
    "es_GT": "Spanish (Guatemala)",
    "es_HN": "Spanish (Honduras)",
    "es_MX": "Spanish (Mexico)",
    "es_NI": "Spanish (Nicaragua)",
    "es_PA": "Spanish (Panama)",
    "es_PY": "Spanish (Paraguay)",
    "es_PE": "Spanish (Peru)",
    "es_PH": "Spanish (Philippines)",
    "es_PR": "Spanish (Puerto Rico)",
    "es_ES": "Spanish (Spain)",
    "es_US": "Spanish (United States)",
    "es_UY": "Spanish (Uruguay)",
    "es_VE": "Spanish (Venezuela)",
    "sw": "Swahili",
    "sw_KE": "Swahili (Kenya)",
    "sw_TZ": "Swahili (Tanzania)",
    "sw_UG": "Swahili (Uganda)",
    "sv": "Swedish",
    "sv_AX": "Swedish (\u00c5land Islands)",
    "sv_FI": "Swedish (Finland)",
    "sv_SE": "Swedish (Sweden)",
    "tl": "Tagalog",
    "tl_PH": "Tagalog (Philippines)",
    "ta": "Tamil",
    "ta_IN": "Tamil (India)",
    "ta_MY": "Tamil (Malaysia)",
    "ta_SG": "Tamil (Singapore)",
    "ta_LK": "Tamil (Sri Lanka)",
    "te": "Telugu",
    "te_IN": "Telugu (India)",
    "th": "Thai",
    "th_TH": "Thai (Thailand)",
    "bo": "Tibetan",
    "bo_CN": "Tibetan (China)",
    "bo_IN": "Tibetan (India)",
    "ti": "Tigrinya",
    "ti_ER": "Tigrinya (Eritrea)",
    "ti_ET": "Tigrinya (Ethiopia)",
    "to": "Tongan",
    "to_TO": "Tongan (Tonga)",
    "tr": "Turkish",
    "tr_CY": "Turkish (Cyprus)",
    "tr_TR": "Turkish (Turkey)",
    "uk": "Ukrainian",
    "uk_UA": "Ukrainian (Ukraine)",
    "ur": "Urdu",
    "ur_IN": "Urdu (India)",
    "ur_PK": "Urdu (Pakistan)",
    "ug": "Uyghur",
    "ug_Arab_CN": "Uyghur (Arabic, China)",
    "ug_Arab": "Uyghur (Arabic)",
    "ug_CN": "Uyghur (China)",
    "uz": "Uzbek",
    "uz_AF": "Uzbek (Afghanistan)",
    "uz_Arab_AF": "Uzbek (Arabic, Afghanistan)",
    "uz_Arab": "Uzbek (Arabic)",
    "uz_Cyrl_UZ": "Uzbek (Cyrillic, Uzbekistan)",
    "uz_Cyrl": "Uzbek (Cyrillic)",
    "uz_Latn_UZ": "Uzbek (Latin, Uzbekistan)",
    "uz_Latn": "Uzbek (Latin)",
    "uz_UZ": "Uzbek (Uzbekistan)",
    "vi": "Vietnamese",
    "vi_VN": "Vietnamese (Vietnam)",
    "cy": "Welsh",
    "cy_GB": "Welsh (United Kingdom)",
    "fy": "Western Frisian",
    "fy_NL": "Western Frisian (Netherlands)",
    "yi": "Yiddish",
    "yo": "Yoruba",
    "yo_BJ": "Yoruba (Benin)",
    "yo_NG": "Yoruba (Nigeria)",
    "zu": "Zulu",
    "zu_ZA": "Zulu (South Africa)",
  };

  /// Get the language data
  static Map<String, String>? getLanguageData(String localeCode) {
    final data = _languageData.entries.firstWhereOrNull(
      (element) => element.key == localeCode,
    );
    if (data == null) {
      return null;
    }
    return {data.key: data.value};
  }

  /// Get language list
  static Future<List<Map<String, String>>> getLanguageList({
    String langPath = 'lang',
  }) async {
    List<Map<String, String>> list = [];
    try {
      final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      List<String> langFiles = assetManifest
          .listAssets()
          .where((String key) => key.contains("lang"))
          .toList();

      for (var langFile in langFiles) {
        RegExp regex = RegExp(langPath + r'/(.*).json');
        Match? match = regex.firstMatch(langFile);

        if (match == null) continue;

        String? extractedString = match.group(1);
        if (extractedString == null) continue;

        Map<String, String>? langData = getLanguageData(extractedString);
        if (langData == null) continue;

        list.add(langData);
      }
    } on Exception catch (e) {
      NyLogger.debug(e.toString());
    }
    return list;
  }

  @override
  createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends NyState<LanguageSwitcher> {
  Map<String, dynamic>? selectedLanguage;
  List<Map<String, String>> languages = [];

  _LanguageSwitcherState() {
    stateName = LanguageSwitcher.state;
  }

  @override
  get init => () async {
    languages = await LanguageSwitcher.getLanguageList();
    selectedLanguage = await LanguageSwitcher.currentLanguage();
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedLang = selectedLanguage?.entries.firstOrNull?.key ?? "en";
    final selectedName =
        selectedLanguage?.entries.firstOrNull?.value ??
        LanguageSwitcher.getLanguageData(selectedLang)?.values.first ??
        "English";
    final flagEmoji = LanguageSwitcher.getFlagEmoji(selectedLang);

    // If custom dropdownBuilder is provided, use the traditional dropdown
    if (widget.dropdownBuilder != null) {
      return _buildTraditionalDropdown(context, isDark, selectedLang);
    }

    // Modern styled popup menu
    return PopupMenuButton<String>(
      onSelected: _onChange,
      onOpened: widget.onTap,
      elevation: widget.elevation.toDouble(),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
      ),
      color:
          widget.dropdownBgColor ??
          (isDark ? const Color(0xFF2C2C2E) : Colors.white),
      constraints: BoxConstraints(
        maxHeight: widget.itemHeight * 6,
        minWidth: 200,
      ),
      itemBuilder: (context) => languages.map((Map<String, String> value) {
        final item = value.entries.firstOrNull;
        if (item == null) {
          return const PopupMenuItem<String>(
            value: '',
            height: 0,
            child: SizedBox.shrink(),
          );
        }
        final itemFlag = LanguageSwitcher.getFlagEmoji(item.key);
        final isSelected = item.key == selectedLang;

        return PopupMenuItem<String>(
          value: item.key,
          height: widget.itemHeight,
          onTap: widget.dropdownOnTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                // Flag container
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(itemFlag, style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                // Language name
                Expanded(
                  child: Text(
                    item.value,
                    style:
                        widget.textStyle ??
                        TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: -0.2,
                        ),
                  ),
                ),
                // Selected indicator
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF34C759),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
      child: Container(
        padding:
            widget.padding ??
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey.shade800.withValues(alpha: 0.5)
              : Colors.grey.shade100,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Flag
            Text(flagEmoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            // Language name
            Text(
              selectedName,
              style:
                  widget.textStyle ??
                  TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -0.2,
                  ),
            ),
            const SizedBox(width: 6),
            // Dropdown icon
            widget.icon ??
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: widget.iconSize,
                  color:
                      widget.iconEnabledColor ??
                      (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
          ],
        ),
      ),
    );
  }

  /// Build traditional dropdown for custom dropdownBuilder
  Widget _buildTraditionalDropdown(
    BuildContext context,
    bool isDark,
    String selectedLang,
  ) {
    return DropdownButton<String>(
      value: selectedLang,
      iconSize: widget.iconSize,
      hint: widget.hint,
      elevation: widget.elevation,
      itemHeight: widget.itemHeight,
      style:
          widget.textStyle ??
          TextStyle(
            color: NyColor(
              light: Colors.black,
              dark: Colors.white,
            ).toColor(context),
          ),
      onChanged: _onChange,
      icon: widget.icon,
      borderRadius: widget.borderRadius,
      onTap: widget.onTap,
      dropdownColor: widget.dropdownBgColor,
      padding: widget.padding,
      underline: const SizedBox.shrink(),
      items: languages.map<DropdownMenuItem<String>>((
        Map<String, String> value,
      ) {
        final item = value.entries.firstOrNull;
        if (item == null) {
          return const DropdownMenuItem<String>(value: '', child: SizedBox());
        }
        Widget child = widget.dropdownBuilder!({
          "locale": item.key,
          "name": item.value,
          "flag": LanguageSwitcher.getFlagEmoji(item.key),
        });
        return DropdownMenuItem<String>(
          value: item.key,
          onTap: widget.dropdownOnTap,
          alignment: widget.dropdownAlignment,
          child: child,
        );
      }).toList(),
    );
  }

  /// On change event for the dropdown
  Future<void> _onChange(String? newLanguageCode) async {
    if (newLanguageCode == null) {
      return;
    }

    selectedLanguage = LanguageSwitcher.getLanguageData(newLanguageCode);
    if (selectedLanguage == null) {
      return;
    }

    // change the language
    await changeLanguage(selectedLanguage!.entries.first.key);

    // store the language
    await LanguageSwitcher.storeLanguage(object: selectedLanguage);

    if (widget.onLanguageChange != null) {
      widget.onLanguageChange!(selectedLanguage!);
    }

    if (mounted) {
      setState(() {});
    }
  }
}

/// A styled list item for the language selection modal
class _LanguageListItem extends StatefulWidget {
  const _LanguageListItem({
    required this.languageName,
    required this.localeCode,
    required this.flagEmoji,
    required this.isSelected,
    required this.selectedColor,
    required this.isDark,
    required this.onTap,
    this.textStyle,
  });

  final String languageName;
  final String localeCode;
  final String flagEmoji;
  final bool isSelected;
  final Color selectedColor;
  final bool isDark;
  final VoidCallback onTap;
  final TextStyle? textStyle;

  @override
  State<_LanguageListItem> createState() => _LanguageListItemState();
}

class _LanguageListItemState extends State<_LanguageListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.selectedColor
                : (_isPressed
                      ? widget.selectedColor.withValues(alpha: 0.5)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
            border: widget.isSelected
                ? Border.all(
                    color: widget.isDark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Flag emoji
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    widget.flagEmoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Language name and code
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.languageName,
                      style:
                          widget.textStyle ??
                          TextStyle(
                            fontSize: 16,
                            fontWeight: widget.isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: widget.isDark ? Colors.white : Colors.black,
                            letterSpacing: -0.3,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.localeCode.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: widget.isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Checkmark for selected
              AnimatedOpacity(
                opacity: widget.isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedScale(
                  scale: widget.isSelected ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? const Color(0xFF34C759)
                          : const Color(0xFF34C759),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
