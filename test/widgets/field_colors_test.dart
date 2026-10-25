import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/helpers/src/backpack.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

const Color _accent = Color(0xFF4D9FFF);

ThemeData _dark({List<ThemeExtension<dynamic>> extensions = const []}) =>
    ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(primary: _accent),
      extensions: extensions,
    );

Widget _app(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? _dark(),
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: child,
    ),
  ),
);

void main() {
  NyTest.init();

  setUp(() {
    if (!Backpack.instance.isNyloInitialized()) {
      Backpack.instance.save("nylo", Nylo());
    }
    Backpack.instance.save("event_bus", EventBus(maxHistoryLength: 10));
  });

  group('NyFieldColors', () {
    testWidgets('follows the theme\'s brightness and primary color', (
      tester,
    ) async {
      late NyFieldColors colors;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (BuildContext context) {
              colors = NyFieldColors.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(colors.fill, const Color(0xFF1E1E1E));
      expect(colors.text, const Color(0xFFF2F2F2));
      expect(colors.accent, _accent);
    });

    testWidgets('a theme extension chooses them', (tester) async {
      final NyFieldColors custom = NyFieldColors.fromTheme(
        Brightness.dark,
        accent: _accent,
      ).copyWith(fill: const Color(0xFF102030));
      late NyFieldColors colors;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (BuildContext context) {
              colors = NyFieldColors.of(context);
              return const SizedBox();
            },
          ),
          theme: _dark(extensions: [custom]),
        ),
      );

      expect(colors.fill, const Color(0xFF102030));
    });

    test('lerps between two sets', () {
      final NyFieldColors light = NyFieldColors.fromTheme(
        Brightness.light,
        accent: _accent,
      );
      final NyFieldColors dark = NyFieldColors.fromTheme(
        Brightness.dark,
        accent: _accent,
      );
      expect(light.lerp(dark, 1).fill, dark.fill);
      expect(light.lerp(dark, 0).fill, light.fill);
    });
  });

  group('text fields in a dark theme', () {
    testWidgets('read: dark fill, light text, the label above', (tester) async {
      final Field field = Field.text('Name', value: 'Anthony');
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      final TextField input = tester.widget<TextField>(find.byType(TextField));
      expect(input.decoration!.fillColor, const Color(0xFF1E1E1E));
      expect(input.decoration!.labelText, isNull);
      expect(input.style!.color, const Color(0xFFF2F2F2));

      final Text label = tester.widget<Text>(find.text('Name'));
      expect(label.style!.color, const Color(0xFFD4D4D4));
      expect(
        tester.getBottomLeft(find.text('Name')).dy,
        lessThan(tester.getTopLeft(find.byType(TextField)).dy),
      );
    });

    testWidgets('the accent outlines the focused field', (tester) async {
      final Field field = Field.text('Name');
      await tester.pumpWidget(_app(field.widget!));

      final OutlineInputBorder focused =
          tester
                  .widget<TextField>(find.byType(TextField))
                  .decoration!
                  .focusedBorder!
              as OutlineInputBorder;
      expect(focused.borderSide.color, _accent);
    });

    testWidgets('the cursor is the accent', (tester) async {
      final Field field = Field.password('Password');
      await tester.pumpWidget(_app(field.widget!));

      expect(
        tester.widget<TextField>(find.byType(TextField)).cursorColor,
        _accent,
      );
    });

    testWidgets('FieldLabelPosition.floating keeps the label inside', (
      tester,
    ) async {
      final Field field = Field.text(
        'Name',
        style: FieldStyleTextField(labelPosition: FieldLabelPosition.floating),
      );
      await tester.pumpWidget(_app(field.widget!));

      expect(
        tester.widget<TextField>(find.byType(TextField)).decoration!.labelText,
        'Name',
      );
    });

    testWidgets('a field\'s own background color still wins', (tester) async {
      final Field field = Field.text(
        'Name',
        style: FieldStyleTextField(backgroundColor: const Color(0xFF332211)),
      );
      await tester.pumpWidget(_app(field.widget!));

      expect(
        tester.widget<TextField>(find.byType(TextField)).decoration!.fillColor,
        const Color(0xFF332211),
      );
    });
  });

  group('a dark theme whose onSurface is black', () {
    // The boilerplate's dark ColorScheme sets onSurface to black, which
    // Flutter uses for list row text and a field's counter.
    final ThemeData blackOnSurface = ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _accent,
        onSurface: Colors.black,
      ),
    );

    Color drawn(WidgetTester tester, String text) => tester
        .widget<RichText>(
          find.descendant(of: find.text(text), matching: find.byType(RichText)),
        )
        .text
        .style!
        .color!;

    testWidgets('a switch\'s title and subtitle still read', (tester) async {
      final Field field = Field.switchBox(
        'Updates',
        style: FieldStyleSwitchBox(subtitle: const Text('Once a month')),
      );
      await tester.pumpWidget(_app(field.widget!, theme: blackOnSurface));

      expect(drawn(tester, 'Updates'), const Color(0xFFF2F2F2));
      expect(drawn(tester, 'Once a month'), const Color(0xFF8C8C8C));
    });

    testWidgets('a checkbox\'s own title still reads', (tester) async {
      final Field field = Field.checkbox(
        'Terms',
        style: FieldStyleCheckbox(title: const Text('I agree')),
      );
      await tester.pumpWidget(_app(field.widget!, theme: blackOnSurface));

      expect(drawn(tester, 'I agree'), const Color(0xFFF2F2F2));
    });

    testWidgets('a text field\'s counter still reads', (tester) async {
      final Field field = Field.textArea(
        'Bio',
        value: 'Hi',
        style: FieldStyleTextField(maxLength: 160),
      );
      await tester.pumpWidget(_app(field.widget!, theme: blackOnSurface));

      expect(
        tester
            .widget<TextField>(find.byType(TextField))
            .decoration!
            .counterStyle!
            .color,
        const Color(0xFF8C8C8C),
      );
    });
  });

  group('choice fields in a dark theme', () {
    testWidgets('a checked checkbox is filled with the accent', (tester) async {
      final Field field = Field.checkbox('Agree', value: true);
      await tester.pumpWidget(_app(field.widget!));

      final CheckboxListTile tile = tester.widget<CheckboxListTile>(
        find.byType(CheckboxListTile),
      );
      expect(tile.fillColor!.resolve({WidgetState.selected}), _accent);
      expect(tile.checkColor, isNot(Colors.black));
    });

    testWidgets('a switch that is on uses the accent', (tester) async {
      final Field field = Field.switchBox('Updates', value: true);
      await tester.pumpWidget(_app(field.widget!));

      final SwitchListTile tile = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(tile.activeTrackColor, _accent);
      expect(tile.activeThumbColor, isNot(Colors.black));
    });

    testWidgets('radio options sit in one card, marked with the accent', (
      tester,
    ) async {
      final Field field = Field.radio(
        'Plan',
        value: 'pro',
        options: FormCollection.from({'free': 'Free', 'pro': 'Pro'}),
      );
      await tester.pumpWidget(_app(field.widget!));

      final RadioListTile<dynamic> tile = tester
          .widgetList<RadioListTile<dynamic>>(
            find.byType(RadioListTile<dynamic>),
          )
          .first;
      expect(tile.activeColor, _accent);
      expect(
        find.ancestor(
          of: find.byType(RadioListTile<dynamic>).first,
          matching: find.byWidgetPredicate(
            (Widget w) =>
                w is Container &&
                w.decoration is BoxDecoration &&
                (w.decoration as BoxDecoration).color ==
                    const Color(0xFF1E1E1E),
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a slider uses the accent, not the theme\'s primaryColor', (
      tester,
    ) async {
      final Field field = Field.slider('Goal');
      await tester.pumpWidget(
        _app(
          field.widget!,
          theme: _dark().copyWith(primaryColor: Colors.white),
        ),
      );

      expect(
        SliderTheme.of(tester.element(find.byType(Slider))).activeTrackColor,
        _accent,
      );
    });
  });
}
