import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:core';
import 'package:nylo_support/widgets/ny_state.dart';

class NyLangSwitcher extends StatefulWidget {
  NyLangSwitcher({Key? key}) : super(key: key);

  static String state = "ny_lang_switcher";

  @override
  createState() => _NyLangSwitcherState();
}

class _NyLangSwitcherState extends NyState<NyLangSwitcher> {
  String selectedLanguage = 'English';

  // List of colors for the dropdown
  List<String> languages = [];

  _NyLangSwitcherState() {
    stateName = NyLangSwitcher.state;
  }

  @override
  init() async {
    super.init();
    await getLanguageList();
    languages.sort();
  }

  String getLanguageCode({required String language}) {
    switch (language.toLowerCase()) {
      case 'afrikaans':
        return 'af';
      case 'amharic':
        return 'am';
      case 'arabic':
        return 'ar';
      case 'assamese':
        return 'as';
      case 'azerbaijani':
        return 'az';
      case 'belarusian':
        return 'be';
      case 'bulgarian':
        return 'bg';
      case 'bengali':
        return 'bn';
      case 'bosnian':
        return 'bs';
      case 'catalan':
        return 'ca';
      case 'czech':
        return 'cs';
      case 'welsh':
        return 'cy';
      case 'danish':
        return 'da';
      case 'german':
        return 'de';
      case 'greek':
        return 'el';
      case 'english':
        return 'en';
      case 'spanish':
        return 'es';
      case 'estonian':
        return 'et';
      case 'basque':
        return 'eu';
      case 'persian':
        return 'fa';
      case 'finnish':
        return 'fi';
      case 'filipino':
        return 'fil';
      case 'french':
        return 'fr';
      case 'galician':
        return 'gl';
      case 'swiss':
        return 'gsw';
      case 'gujarati':
        return 'gu';
      case 'hebrew':
        return 'he';
      case 'hindi':
        return 'hi';
      case 'croatian':
        return 'hr';
      case 'hungarian':
        return 'hu';
      case 'armenian':
        return 'hy';
      case 'indonesian':
        return 'id';
      case 'icelandic':
        return 'is';
      case 'italian':
        return 'it';
      case 'japanese':
        return 'ja';
      case 'georgian':
        return 'ka';
      case 'kazakh':
        return 'kk';
      case 'khmer':
        return 'km';
      case 'kannada':
        return 'kn';
      case 'korean':
        return 'ko';
      case 'kirghiz':
        return 'ky';
      case 'lao':
        return 'lo';
      case 'lithuanian':
        return 'lt';
      case 'latvian':
        return 'lv';
      case 'macedonian':
        return 'mk';
      case 'malayalam':
        return 'ml';
      case 'mongolian':
        return 'mn';
      case 'marathi':
        return 'mr';
      case 'malay':
        return 'ms';
      case 'burmese':
        return 'my';
      case 'norwegian':
        return 'nb';
      case 'nepali':
        return 'ne';
      case 'dutch':
        return 'nl';
      case 'oriya':
        return 'or';
      case 'panjabi':
        return 'pa';
      case 'polish':
        return 'pl';
      case 'pushto':
        return 'ps';
      case 'portuguese':
        return 'pt';
      case 'romanian':
        return 'ro';
      case 'russian':
        return 'ru';
      case 'sinhala':
        return 'si';
      case 'slovak':
        return 'sk';
      case 'slovenian':
        return 'sl';
      case 'albanian':
        return 'sq';
      case 'serbian':
        return 'sr';
      case 'swedish':
        return 'sv';
      case 'swahili':
        return 'sw';
      case 'tamil':
        return 'ta';
      case 'telugu':
        return 'te';
      case 'thai':
        return 'th';
      case 'tagalog':
        return 'tl';
      case 'turkish':
        return 'tr';
      case 'ukrainian':
        return 'uk';
      case 'urdu':
        return 'ur';
      case 'uzbek':
        return 'uz';
      case 'vietnamese':
        return 'vi';
      case 'chinese':
        return 'zh';
      case 'zulu':
        return 'zu';
      default:
        return 'Unknown Language';
    }
  }

  String fullLanguageName({required String code}) {
    switch (code) {
      case 'af':
        return 'Afrikaans';
      case 'am':
        return 'Amharic';
      case 'ar':
        return 'Arabic';
      case 'as':
        return 'Assamese';
      case 'az':
        return 'Azerbaijani';
      case 'be':
        return 'Belarusian';
      case 'bg':
        return 'Bulgarian';
      case 'bn':
        return 'Bengali';
      case 'bs':
        return 'Bosnian';
      case 'ca':
        return 'Catalan';
      case 'cs':
        return 'Czech';
      case 'cy':
        return 'Welsh';
      case 'da':
        return 'Danish';
      case 'de':
        return 'German';
      case 'el':
        return 'Greek';
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'et':
        return 'Estonian';
      case 'eu':
        return 'Basque';
      case 'fa':
        return 'Persian';
      case 'fi':
        return 'Finnish';
      case 'fil':
        return 'Filipino';
      case 'fr':
        return 'French';
      case 'gl':
        return 'Galician';
      case 'gsw':
        return 'Swiss';
      case 'gu':
        return 'Gujarati';
      case 'he':
        return 'Hebrew';
      case 'hi':
        return 'Hindi';
      case 'hr':
        return 'Croatian';
      case 'hu':
        return 'Hungarian';
      case 'hy':
        return 'Armenian';
      case 'id':
        return 'Indonesian';
      case 'is':
        return 'Icelandic';
      case 'it':
        return 'Italian';
      case 'ja':
        return 'Japanese';
      case 'ka':
        return 'Georgian';
      case 'kk':
        return 'Kazakh';
      case 'km':
        return 'Khmer';
      case 'kn':
        return 'Kannada';
      case 'ko':
        return 'Korean';
      case 'ky':
        return 'Kirghiz';
      case 'lo':
        return 'Lao';
      case 'lt':
        return 'Lithuanian';
      case 'lv':
        return 'Latvian';
      case 'mk':
        return 'Macedonian';
      case 'ml':
        return 'Malayalam';
      case 'mn':
        return 'Mongolian';
      case 'mr':
        return 'Marathi';
      case 'ms':
        return 'Malay';
      case 'my':
        return 'Burmese';
      case 'nb':
        return 'Norwegian';
      case 'ne':
        return 'Nepali';
      case 'nl':
        return 'Dutch';
      case 'no':
        return 'Norwegian';
      case 'or':
        return 'Oriya';
      case 'pa':
        return 'Panjabi';
      case 'pl':
        return 'Polish';
      case 'ps':
        return 'Pushto';
      case 'pt':
        return 'Portuguese';
      case 'ro':
        return 'Romanian';
      case 'ru':
        return 'Russian';
      case 'si':
        return 'Sinhala';
      case 'sk':
        return 'Slovak';
      case 'sl':
        return 'Slovenian';
      case 'sq':
        return 'Albanian';
      case 'sr':
        return 'Serbian';
      case 'sv':
        return 'Swedish';
      case 'sw':
        return 'Swahili';
      case 'ta':
        return 'Tamil';
      case 'te':
        return 'Telugu';
      case 'th':
        return 'Thai';
      case 'tl':
        return 'Tagalog';
      case 'tr':
        return 'Turkish';
      case 'uk':
        return 'Ukrainian';
      case 'ur':
        return 'Urdu';
      case 'uz':
        return 'Uzbek';
      case 'vi':
        return 'Vietnamese';
      case 'zh':
        return 'Chinese';
      case 'zu':
        return 'Zulu';
      default:
        return 'Unknown Language';
    }
  }

  getLanguageList() async {
    String langPath = 'lang';

    try {
      final fileCount = json
          .decode(await rootBundle.loadString('AssetManifest.json'))
          .keys
          .where((String key) => key.contains(langPath))
          .toList();
      int _numberOfChapters = fileCount.length;
      for (int i = 0; i < _numberOfChapters; i++) {
        RegExp regex = RegExp(r'lang/(.*).json');
        Match? match = regex.firstMatch(fileCount[i] ?? "");

        if (match != null) {
          String? extractedString = match.group(1);

          //languages.add(fullLanguageName(code: extractedString ?? ""));
          languages.add(fullLanguageName(code: extractedString ?? ""));

        } else {}
      }
    } on Exception catch (e) {

    }
  }

  @override
  stateUpdated(dynamic data) async {
    // e.g. to update this state from another class
    // updateState(NyLangSwitcher.state, data: "example payload");
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedLanguage,
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.black),

      onChanged: (String? newValue) async {
        String lanCode = getLanguageCode(language: newValue!);
        await changeLanguage(lanCode);

        setState(() {
          selectedLanguage = newValue;
        });
      },
      items: languages.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class LanguageModel{
  final String name;
  final String code;
  final String flag;
  const LanguageModel({required this.name, required this.code, required this.flag});

}