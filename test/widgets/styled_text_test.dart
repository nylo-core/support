import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

/// Helper to extract all [TextSpan] children from a [RichText] widget.
List<TextSpan> _extractSpans(WidgetTester tester) {
  final RichText richText = tester.widget<RichText>(find.byType(RichText));
  final root = richText.text as TextSpan;
  return root.children!.cast<TextSpan>();
}

void main() {
  NyTest.init();

  nyGroup('StyledText.template', () {
    nyGroup('basic placeholder (no colon)', () {
      testWidgets('renders placeholder text as display text', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: StyledText.template(
              "Hello {{name}}!",
              styles: {"name": TextStyle(fontWeight: FontWeight.bold)},
            ),
          ),
        );

        final List<TextSpan> spans = _extractSpans(tester);
        expect(spans[0].text, 'Hello ');
        expect(spans[1].text, 'name');
        expect(spans[1].style!.fontWeight, FontWeight.bold);
        expect(spans[2].text, '!');
      });
    });

    nyGroup('key:text syntax', () {
      testWidgets('renders display text from colon syntax', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: StyledText.template(
              "Hello {{name:World}}!",
              styles: {"name": TextStyle(fontWeight: FontWeight.bold)},
            ),
          ),
        );

        final List<TextSpan> spans = _extractSpans(tester);
        expect(spans[0].text, 'Hello ');
        expect(spans[1].text, 'World');
        expect(spans[1].style!.fontWeight, FontWeight.bold);
        expect(spans[2].text, '!');
      });

      testWidgets('uses key for style lookup, not display text', (
        tester,
      ) async {
        final blueStyle = TextStyle(color: Colors.blue);
        await tester.pumpWidget(
          MaterialApp(
            home: StyledText.template(
              "{{greet:Hola}}",
              styles: {"greet": blueStyle},
            ),
          ),
        );

        final List<TextSpan> spans = _extractSpans(tester);
        expect(spans[0].text, 'Hola');
        expect(spans[0].style!.color, Colors.blue);
      });

      testWidgets('display text can contain spaces', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: StyledText.template(
              "{{tos:Terms of Service}}",
              styles: {"tos": TextStyle(decoration: TextDecoration.underline)},
            ),
          ),
        );

        final List<TextSpan> spans = _extractSpans(tester);
        expect(spans[0].text, 'Terms of Service');
      });

      testWidgets('display text can contain colons', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: StyledText.template(
              "{{time:12:30 PM}}",
              styles: {"time": TextStyle(fontWeight: FontWeight.bold)},
            ),
          ),
        );

        final List<TextSpan> spans = _extractSpans(tester);
        expect(spans[0].text, '12:30 PM');
      });
    });

    nyGroup('key:text with pipe-separated styles', () {
      testWidgets('pipe keys match the key part before colon', (tester) async {
        final sharedStyle = TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        );
        await tester.pumpWidget(
          MaterialApp(
            home: StyledText.template(
              "Learn {{lang:Languages}}, {{read:Reading}} and {{speak:Speaking}}",
              styles: {"lang|read|speak": sharedStyle},
            ),
          ),
        );

        final List<TextSpan> spans = _extractSpans(tester);
        // "Learn "
        expect(spans[0].text, 'Learn ');
        // "Languages" styled
        expect(spans[1].text, 'Languages');
        expect(spans[1].style!.color, Colors.blue);
        // ", "
        expect(spans[2].text, ', ');
        // "Reading" styled
        expect(spans[3].text, 'Reading');
        expect(spans[3].style!.color, Colors.blue);
        // " and "
        expect(spans[4].text, ' and ');
        // "Speaking" styled
        expect(spans[5].text, 'Speaking');
        expect(spans[5].style!.color, Colors.blue);
      });
    });

    nyGroup('key:text with onTap', () {
      testWidgets('tap callback is looked up by key', (tester) async {
        bool tapped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: StyledText.template(
              "Click {{link:here}}",
              styles: {"link": TextStyle(color: Colors.blue)},
              onTap: {"link": () => tapped = true},
            ),
          ),
        );

        final List<TextSpan> spans = _extractSpans(tester);
        expect(spans[1].text, 'here');
        expect(spans[1].recognizer, isA<TapGestureRecognizer>());

        (spans[1].recognizer as TapGestureRecognizer).onTap!();
        expect(tapped, isTrue);
      });
    });

    nyGroup('wildcard * key', () {
      testWidgets('applies style to all placeholders', (tester) async {
        final wildcardStyle = TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        );
        await tester.pumpWidget(
          MaterialApp(
            home: StyledText.template(
              "Hello {{name}}, welcome to {{app}}!",
              styles: {"*": wildcardStyle},
            ),
          ),
        );

        final List<TextSpan> spans = _extractSpans(tester);
        expect(spans[0].text, 'Hello ');
        expect(spans[1].text, 'name');
        expect(spans[1].style!.color, Colors.blue);
        expect(spans[1].style!.fontWeight, FontWeight.bold);
        expect(spans[2].text, ', welcome to ');
        expect(spans[3].text, 'app');
        expect(spans[3].style!.color, Colors.blue);
        expect(spans[3].style!.fontWeight, FontWeight.bold);
        expect(spans[4].text, '!');
      });

      testWidgets('exact key overrides wildcard', (tester) async {
        final wildcardStyle = TextStyle(color: Colors.blue);
        final nameStyle = TextStyle(color: Colors.red);
        await tester.pumpWidget(
          MaterialApp(
            home: StyledText.template(
              "Hello {{name}}, welcome to {{app}}!",
              styles: {"*": wildcardStyle, "name": nameStyle},
            ),
          ),
        );

        final List<TextSpan> spans = _extractSpans(tester);
        expect(spans[1].text, 'name');
        expect(spans[1].style!.color, Colors.red);
        expect(spans[3].text, 'app');
        expect(spans[3].style!.color, Colors.blue);
      });

      testWidgets('pipe key overrides wildcard', (tester) async {
        final wildcardStyle = TextStyle(color: Colors.blue);
        final pipeStyle = TextStyle(color: Colors.green);
        await tester.pumpWidget(
          MaterialApp(
            home: StyledText.template(
              "{{a}}, {{b}}, {{c}}",
              styles: {"*": wildcardStyle, "a|b": pipeStyle},
            ),
          ),
        );

        final List<TextSpan> spans = _extractSpans(tester);
        expect(spans[0].text, 'a');
        expect(spans[0].style!.color, Colors.green);
        expect(spans[2].text, 'b');
        expect(spans[2].style!.color, Colors.green);
        expect(spans[4].text, 'c');
        expect(spans[4].style!.color, Colors.blue);
      });

      testWidgets('wildcard onTap applies to all placeholders', (tester) async {
        int tapCount = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: StyledText.template(
              "{{a}} and {{b}}",
              onTap: {"*": () => tapCount++},
            ),
          ),
        );

        final List<TextSpan> spans = _extractSpans(tester);
        expect(spans[0].recognizer, isA<TapGestureRecognizer>());
        expect(spans[2].recognizer, isA<TapGestureRecognizer>());

        (spans[0].recognizer as TapGestureRecognizer).onTap!();
        (spans[2].recognizer as TapGestureRecognizer).onTap!();
        expect(tapCount, 2);
      });
    });

    nyGroup('localization simulation', () {
      testWidgets('same keys render different display text per locale', (
        tester,
      ) async {
        final styles = {
          "lang|read": TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
          "app": TextStyle(color: Colors.green),
        };

        // English
        await tester.pumpWidget(
          MaterialApp(
            home: StyledText.template(
              "Learn {{lang:Languages}} and {{read:Reading}} in {{app:AppName}}",
              styles: styles,
            ),
          ),
        );

        List<TextSpan> spans = _extractSpans(tester);
        expect(spans[1].text, 'Languages');
        expect(spans[3].text, 'Reading');
        expect(spans[5].text, 'AppName');

        // Spanish — same keys, different display text
        await tester.pumpWidget(
          MaterialApp(
            home: StyledText.template(
              "Aprende {{lang:Idiomas}} y {{read:Lectura}} en {{app:AppName}}",
              styles: styles,
            ),
          ),
        );

        spans = _extractSpans(tester);
        expect(spans[1].text, 'Idiomas');
        expect(spans[1].style!.color, Colors.blue);
        expect(spans[3].text, 'Lectura');
        expect(spans[3].style!.color, Colors.blue);
        expect(spans[5].text, 'AppName');
        expect(spans[5].style!.color, Colors.green);
      });
    });

    nyGroup('recognizer lifecycle', () {
      testWidgets('recognizer count stays bounded across parent rebuilds', (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(home: _RebuildingStyledTextHost()),
        );

        final _RebuildingStyledTextHostState host = tester
            .state<_RebuildingStyledTextHostState>(
              find.byType(_RebuildingStyledTextHost),
            );
        expect(_recognizerCount(tester), 2);

        for (int i = 0; i < 20; i++) {
          host.rebuild();
          await tester.pump();
        }

        expect(host.buildCount, greaterThanOrEqualTo(21));
        expect(_recognizerCount(tester), 2);
      });

      testWidgets('tapping a placeholder still fires after rebuilds', (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(home: _RebuildingStyledTextHost()),
        );

        final _RebuildingStyledTextHostState host = tester
            .state<_RebuildingStyledTextHostState>(
              find.byType(_RebuildingStyledTextHost),
            );
        for (int i = 0; i < 20; i++) {
          host.rebuild();
          await tester.pump();
        }

        final List<TextSpan> spans = _extractSpans(tester);
        (spans[1].recognizer as TapGestureRecognizer).onTap!();
        (spans[3].recognizer as TapGestureRecognizer).onTap!();
        expect(host.termsTaps, 1);
        expect(host.privacyTaps, 1);
      });

      testWidgets('recognizers are rebuilt when the onTap map changes', (
        tester,
      ) async {
        int firstTaps = 0;
        int secondTaps = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: StyledText.template(
              "See {{terms}}",
              onTap: {"terms": () => firstTaps++},
            ),
          ),
        );
        expect(_recognizerCount(tester), 1);

        await tester.pumpWidget(
          MaterialApp(
            home: StyledText.template(
              "See {{terms}}",
              onTap: {"terms": () => secondTaps++},
            ),
          ),
        );
        expect(_recognizerCount(tester), 1);

        final List<TextSpan> spans = _extractSpans(tester);
        (spans[1].recognizer as TapGestureRecognizer).onTap!();
        expect(firstTaps, 0);
        expect(secondTaps, 1);
      });

      testWidgets('placeholders without onTap allocate no recognizers', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: StyledText.template(
              "Hello {{name}} and {{app}}",
              styles: {"*": TextStyle(color: Colors.blue)},
            ),
          ),
        );
        expect(_recognizerCount(tester), 0);
      });
    });
  });
}

/// Reads `debugRecognizerCount` from the private `_StyledTextState`.
int _recognizerCount(WidgetTester tester) {
  final dynamic state = tester.state(find.byType(StyledText));
  return state.debugRecognizerCount as int;
}

/// A parent that rebuilds a [StyledText.template] with a STABLE `onTap` map
/// (held in its own state) each time [rebuild] is called.
class _RebuildingStyledTextHost extends StatefulWidget {
  const _RebuildingStyledTextHost();

  @override
  State<_RebuildingStyledTextHost> createState() =>
      _RebuildingStyledTextHostState();
}

class _RebuildingStyledTextHostState extends State<_RebuildingStyledTextHost> {
  int buildCount = 0;
  int termsTaps = 0;
  int privacyTaps = 0;

  late final Map<String, VoidCallback> _links = {
    "terms": () => termsTaps++,
    "privacy": () => privacyTaps++,
  };

  void rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    buildCount++;
    return StyledText.template(
      "By continuing you accept the {{terms}} and {{privacy}}.",
      onTap: _links,
    );
  }
}
