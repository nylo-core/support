import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

/// Helper to extract all [TextSpan] children from a [RichText] widget.
List<TextSpan> _extractSpans(WidgetTester tester) {
  final richText = tester.widget<RichText>(find.byType(RichText));
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

        final spans = _extractSpans(tester);
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

        final spans = _extractSpans(tester);
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

        final spans = _extractSpans(tester);
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

        final spans = _extractSpans(tester);
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

        final spans = _extractSpans(tester);
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

        final spans = _extractSpans(tester);
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

        final spans = _extractSpans(tester);
        expect(spans[1].text, 'here');
        expect(spans[1].recognizer, isA<TapGestureRecognizer>());

        (spans[1].recognizer as TapGestureRecognizer).onTap!();
        expect(tapped, isTrue);
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

        var spans = _extractSpans(tester);
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
  });
}
