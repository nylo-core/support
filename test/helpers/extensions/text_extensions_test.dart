import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/src/extensions.dart';
import 'package:nylo_support/widgets/src/text_tr.dart';

const Color _lightTitle = Color(0xFF111111);
const Color _darkTitle = Color(0xFFEEEEEE);

ThemeData _theme(Brightness brightness, Color title) => ThemeData(
  brightness: brightness,
  textTheme: TextTheme(
    titleLarge: TextStyle(fontSize: 30, color: title),
    bodySmall: const TextStyle(fontSize: 11),
  ),
);

final ThemeData _light = _theme(Brightness.light, _lightTitle);
final ThemeData _dark = _theme(Brightness.dark, _darkTitle);

/// The style [text] is drawn in.
TextStyle _drawn(WidgetTester tester, String text) => tester
    .widget<RichText>(
      find.descendant(of: find.text(text), matching: find.byType(RichText)),
    )
    .text
    .style!;

/// Shows [text] in [theme], once MaterialApp has animated to it.
Future<void> _show(WidgetTester tester, Widget text, ThemeData theme) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(body: Center(child: text)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('text style helpers', () {
    testWidgets('follow a change of theme without being rebuilt', (
      tester,
    ) async {
      // Made once, like text a page built before the theme changed.
      final Text title = const Text('Hello').titleLarge();

      await _show(tester, title, _light);
      expect(_drawn(tester, 'Hello').color, _lightTitle);

      await _show(tester, title, _dark);
      expect(_drawn(tester, 'Hello').color, _darkTitle);
      expect(_drawn(tester, 'Hello').fontSize, 30);
    });

    testWidgets('keep the theme\'s style through a chain', (tester) async {
      final Text title = const Text(
        'Hello',
      ).titleLarge().fontWeightBold().alignCenter();

      await _show(tester, title, _dark);

      final TextStyle drawn = _drawn(tester, 'Hello');
      expect(drawn.color, _darkTitle);
      expect(drawn.fontSize, 30);
      expect(drawn.fontWeight, FontWeight.bold);
      expect(
        tester.widget<Text>(find.text('Hello')).textAlign,
        TextAlign.center,
      );
    });

    testWidgets('a color given to the helper wins in every theme', (
      tester,
    ) async {
      final Text title = const Text('Hello').titleLarge(color: Colors.red);

      await _show(tester, title, _light);
      expect(_drawn(tester, 'Hello').color, Colors.red);
      await _show(tester, title, _dark);
      expect(_drawn(tester, 'Hello').color, Colors.red);
    });

    testWidgets('a style set before the helper is kept', (tester) async {
      final Text title = const Text('Hello').fontWeightBold().titleLarge();

      await _show(tester, title, _dark);

      expect(_drawn(tester, 'Hello').fontWeight, FontWeight.bold);
      expect(_drawn(tester, 'Hello').fontSize, 30);
    });

    testWidgets('a later helper replaces the theme\'s style', (tester) async {
      final Text text = const Text('Hello').titleLarge().bodySmall();

      await _show(tester, text, _dark);

      expect(_drawn(tester, 'Hello').fontSize, 11);
    });

    testWidgets('is one Text to finders', (tester) async {
      await _show(tester, const Text('Hello').titleLarge(), _light);

      expect(find.text('Hello'), findsOneWidget);
      expect(find.byWidgetPredicate((Widget w) => w is Text), findsOneWidget);
    });

    testWidgets('keep rich text through a chain', (tester) async {
      final Text title = const Text.rich(
        TextSpan(
          text: 'Hello ',
          children: [
            TextSpan(
              text: 'world',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ).titleLarge().fontWeightBold();

      await _show(tester, title, _light);
      expect(_drawn(tester, 'Hello world').color, _lightTitle);

      await _show(tester, title, _dark);
      final TextStyle drawn = _drawn(tester, 'Hello world');
      expect(drawn.color, _darkTitle);
      expect(drawn.fontWeight, FontWeight.bold);

      final RichText richText = tester.widget<RichText>(
        find.descendant(
          of: find.text('Hello world'),
          matching: find.byType(RichText),
        ),
      );
      expect(richText.text.toPlainText(), 'Hello world');
      final TextSpan hello =
          (richText.text as TextSpan).children!.single as TextSpan;
      expect(hello.children!.last.style?.fontStyle, FontStyle.italic);
    });

    testWidgets('keep textHeightBehavior and selectionColor through a chain', (
      tester,
    ) async {
      const TextHeightBehavior heightBehavior = TextHeightBehavior(
        applyHeightToFirstAscent: false,
      );
      final Text title = const Text(
        'Hello',
        textHeightBehavior: heightBehavior,
        selectionColor: Colors.green,
      ).titleLarge().alignCenter();

      await _show(tester, title, _light);

      final Text shown = tester.widget<Text>(find.text('Hello'));
      expect(shown.textHeightBehavior, heightBehavior);
      expect(shown.selectionColor, Colors.green);
    });
  });

  group('TextTr', () {
    testWidgets('a named style follows a change of theme', (tester) async {
      final Widget title = TextTr.titleLarge('Hello');

      await _show(tester, title, _light);
      expect(_drawn(tester, 'Hello').color, _lightTitle);

      await _show(tester, title, _dark);
      expect(_drawn(tester, 'Hello').color, _darkTitle);
    });
  });
}
