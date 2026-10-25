import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

const Color _accent = Color(0xFF0045A0);

class _ProfileForm extends NyFormWidget {
  const _ProfileForm({this.style});

  final FormFieldStyle? style;

  @override
  FormFieldStyle? get fieldStyle => style;

  @override
  List<dynamic> fields() => [
    Field.text("Name"),
    Field.email("Email"),
    Field.password("Password"),
    Field.checkbox("Agree"),
    Field.text("Nickname"),
  ];
}

class _HiddenFieldForm extends NyFormWidget {
  const _HiddenFieldForm();

  @override
  FormFieldStyle? get fieldStyle => const FormFieldStyle.grouped();

  @override
  List<dynamic> fields() => [
    Field.text("Phone"),
    Field.text("phone_code", value: "+44", hidden: true),
    Field.text("Budget"),
  ];
}

Widget _app(Widget child) => MaterialApp(
  theme: ThemeData(colorScheme: const ColorScheme.light(primary: _accent)),
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: child,
    ),
  ),
);

InputDecoration _decoration(WidgetTester tester, [int index = 0]) => tester
    .widgetList<TextField>(find.byType(TextField))
    .elementAt(index)
    .decoration!;

void main() {
  NyTest.init();

  late Nylo nylo;
  setUp(() {
    NyEnvRegistry.register(
      getter: (String key, {dynamic defaultValue}) => defaultValue,
      containsKey: (String key) => false,
    );
    nylo = Nylo();
    Backpack.instance.save("nylo", nylo);
    Backpack.instance.save("event_bus", EventBus(maxHistoryLength: 10));
  });

  group('FormFieldStyle', () {
    testWidgets('fields are filled by default', (tester) async {
      await tester.pumpWidget(_app(Field.text("Name").widget!));

      final InputDecoration decoration = _decoration(tester);
      expect(decoration.filled, isTrue);
      expect(decoration.enabledBorder, isA<OutlineInputBorder>());
    });

    testWidgets('outlined draws a clear box with an accent focus border', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          FormFieldStyleScope(
            style: const FormFieldStyle.outlined(),
            child: Field.text("Name").widget!,
          ),
        ),
      );

      final InputDecoration decoration = _decoration(tester);
      expect(decoration.filled, isFalse);
      final OutlineInputBorder enabled =
          decoration.enabledBorder! as OutlineInputBorder;
      expect(enabled.borderRadius, const BorderRadius.all(Radius.circular(10)));
      final OutlineInputBorder focused =
          decoration.focusedBorder! as OutlineInputBorder;
      expect(focused.borderSide.color, _accent);
      expect(focused.borderSide.width, 2);
    });

    testWidgets('underlined draws only a line under the field', (tester) async {
      await tester.pumpWidget(
        _app(
          FormFieldStyleScope(
            style: const FormFieldStyle.underlined(),
            child: Field.text("Name").widget!,
          ),
        ),
      );

      final InputDecoration decoration = _decoration(tester);
      expect(decoration.filled, isFalse);
      expect(decoration.enabledBorder, isA<UnderlineInputBorder>());
      expect(decoration.focusedBorder, isA<UnderlineInputBorder>());
    });

    testWidgets('a grouped field sits beside its label, without its icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          FormFieldStyleScope(
            style: const FormFieldStyle.grouped(),
            child: Field.email("Email").widget!,
          ),
        ),
      );

      final Rect label = tester.getRect(find.text("Email"));
      final Rect input = tester.getRect(find.byType(TextField));
      expect(label.right, lessThanOrEqualTo(input.left));
      expect(label.top, lessThan(input.bottom));
      expect(find.byIcon(Icons.email_outlined), findsNothing);
      expect(_decoration(tester).enabledBorder, InputBorder.none);
    });

    testWidgets('the app\'s style applies without a scope', (tester) async {
      nylo.addFormFieldStyle(const FormFieldStyle.underlined());

      await tester.pumpWidget(_app(Field.text("Name").widget!));

      expect(_decoration(tester).enabledBorder, isA<UnderlineInputBorder>());
    });

    testWidgets('a field\'s own label position wins over the style', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          FormFieldStyleScope(
            style: const FormFieldStyle.outlined(),
            child: Field.text(
              "Name",
              style: FieldStyleTextField(
                labelPosition: FieldLabelPosition.floating,
              ),
            ).widget!,
          ),
        ),
      );

      expect(_decoration(tester).labelText, "Name");
    });

    testWidgets('an underlined radio group has no card', (tester) async {
      await tester.pumpWidget(
        _app(
          FormFieldStyleScope(
            style: const FormFieldStyle.underlined(),
            child: Field.radio(
              "Plan",
              options: FormCollection.from({"a": "A", "b": "B"}),
            ).widget!,
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (Widget w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).borderRadius != null,
        ),
        findsNothing,
      );
    });

    testWidgets('a grouped picker shows its choice beside its name', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          FormFieldStyleScope(
            style: const FormFieldStyle.grouped(),
            child: Field.picker(
              "Country",
              value: "uk",
              options: FormCollection.from({"uk": "United Kingdom"}),
            ).widget!,
          ),
        ),
      );

      expect(
        tester.getRect(find.text("Country")).right,
        lessThanOrEqualTo(tester.getRect(find.text("United Kingdom")).left),
      );
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });
  });

  group('design details', () {
    testWidgets('a radio option shows its description under its label', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Field.radio(
            "Plan",
            value: "pro",
            options: FormCollection.from([
              {"value": "pro", "label": "Pro", "description": "\$9 a month"},
            ]),
          ).widget!,
        ),
      );

      expect(find.text("\$9 a month"), findsOneWidget);
      expect(
        tester.getTopLeft(find.text("\$9 a month")).dy,
        greaterThan(tester.getTopLeft(find.text("Pro")).dy),
      );
      expect(
        FormCollection.from([
          {"value": "pro", "label": "Pro", "description": "\$9 a month"},
        ]).first.description,
        "\$9 a month",
      );
    });

    testWidgets('a radio subtitleStyle colors the description', (tester) async {
      await tester.pumpWidget(
        _app(
          Field.radio(
            "Plan",
            value: "pro",
            options: FormCollection.from([
              {"value": "pro", "label": "Pro", "description": "\$9 a month"},
            ]),
            style: FieldStyleRadio(
              subtitleStyle: const TextStyle(color: Color(0xFF0F766E)),
            ),
          ).widget!,
        ),
      );

      final Text description = tester.widget<Text>(find.text("\$9 a month"));
      expect(description.style?.color, const Color(0xFF0F766E));
      expect(description.style?.fontSize, 13);
    });

    testWidgets('chips show their name above them', (tester) async {
      await tester.pumpWidget(
        _app(
          Field.chips(
            "Interests",
            options: FormCollection.from({"a": "Forms"}),
          ).widget!,
        ),
      );

      expect(
        tester.getBottomLeft(find.text("Interests")).dy,
        lessThan(tester.getTopLeft(find.text("Forms")).dy),
      );
    });

    testWidgets('Field.mask shows its prefixIcon', (tester) async {
      await tester.pumpWidget(
        _app(
          Field.mask(
            "Phone",
            mask: "#### ######",
            prefixIcon: const Icon(Icons.phone),
            style: FieldStyleTextField(keyboardType: TextInputType.phone),
          ).widget!,
        ),
      );

      expect(find.byIcon(Icons.phone), findsOneWidget);
    });

    testWidgets('a currency can show its symbol beside the amount', (
      tester,
    ) async {
      final Field field = Field.currency(
        "Budget",
        currency: "usd",
        value: "1200",
        separateSymbol: true,
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      final String text = tester
          .widget<TextField>(find.byType(TextField))
          .controller!
          .text;
      expect(text, isNot(contains("\$")));
      expect(find.text("\$"), findsOneWidget);
      expect(
        tester.getRect(find.text("\$")).right,
        lessThanOrEqualTo(tester.getRect(find.byType(EditableText)).left),
      );
    });

    testWidgets('a trailing symbol sits after the amount', (tester) async {
      await tester.pumpWidget(
        _app(
          Field.currency(
            "Budget",
            currency: "eur",
            value: "50",
            separateSymbol: true,
          ).widget!,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getRect(find.text("€")).left,
        greaterThanOrEqualTo(tester.getRect(find.byType(EditableText)).right),
      );
    });

    testWidgets('a date field takes a prefix icon', (tester) async {
      await tester.pumpWidget(
        _app(
          Field.date(
            "Birthday",
            style: FieldStyleDateTimePicker(
              prefixIcon: const Icon(Icons.calendar_today_outlined),
            ),
          ).widget!,
        ),
      );

      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
    });

    testWidgets('a slider and a range slider line their tracks up', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              Field.slider("Goal", value: 50).widget!,
              Field.rangeSlider(
                "Range",
                value: const RangeValues(0, 100),
              ).widget!,
            ],
          ),
        ),
      );

      // Both use the same track, so they start at the same place.
      final Element slider = tester.element(find.byType(Slider));
      final Element range = tester.element(find.byType(RangeSlider));
      final RenderBox sliderBox = slider.renderObject! as RenderBox;
      final RenderBox rangeBox = range.renderObject! as RenderBox;
      Rect track(Element element, RenderBox box, bool isRange) {
        final SliderThemeData theme = SliderTheme.of(element);
        return isRange
            ? theme.rangeTrackShape!.getPreferredRect(
                parentBox: box,
                sliderTheme: theme,
              )
            : theme.trackShape!.getPreferredRect(
                parentBox: box,
                sliderTheme: theme,
              );
      }

      expect(
        sliderBox.localToGlobal(track(slider, sliderBox, false).topLeft).dx,
        rangeBox.localToGlobal(track(range, rangeBox, true).topLeft).dx,
      );
      // And they start in line with the label, as in the design.
      expect(
        sliderBox.localToGlobal(track(slider, sliderBox, false).topLeft).dx,
        tester.getTopLeft(find.text("Goal")).dx,
      );
    });

    testWidgets('a slider shows its value beside its name', (tester) async {
      await tester.pumpWidget(
        _app(
          Field.slider(
            "Daily goal",
            value: 30,
            style: FieldStyleSlider(
              max: 120,
              valueFormatter: (double value) => "${value.round()} min",
            ),
          ).widget!,
        ),
      );

      final Rect name = tester.getRect(find.text("Daily Goal"));
      final Rect value = tester.getRect(find.text("30 min"));
      expect((name.center.dy - value.center.dy).abs(), lessThan(4));
      expect(value.left, greaterThanOrEqualTo(name.right));
      expect(
        tester.getTopLeft(find.byType(Slider)).dy,
        greaterThan(value.bottom),
      );
    });
  });

  group('grouped rows', () {
    Widget grouped(Widget child) => _app(
      FormFieldStyleScope(
        style: const FormFieldStyle.grouped(),
        child: FormFieldGroup(children: [child]),
      ),
    );

    Rect row(WidgetTester tester) =>
        tester.getRect(find.byType(FormFieldGroupRow));

    testWidgets('a short label sits a fixed gap from its field', (
      tester,
    ) async {
      await tester.pumpWidget(grouped(Field.text("Bio").widget!));

      final Rect label = tester.getRect(find.text("Bio"));
      final Rect input = tester.getRect(find.byType(TextField));
      expect(input.left - label.right, 16);
    });

    testWidgets('a label that wraps keeps the inset under it', (tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        grouped(Field.text("budget", label: "Monthly budget").widget!),
      );

      final Rect label = tester.getRect(find.text("Monthly budget"));
      expect(label.height, greaterThan(30), reason: 'the label wraps');
      expect(label.top - row(tester).top, 15);
      expect(row(tester).bottom - label.bottom, 15);
    });

    testWidgets('a counter keeps the inset under it', (tester) async {
      await tester.pumpWidget(
        grouped(
          Field.textArea(
            "Bio",
            value: "Hello",
            style: FieldStyleTextField(maxLength: 160),
          ).widget!,
        ),
      );

      final Rect counter = tester.getRect(find.text("5/160"));
      expect(row(tester).bottom - counter.bottom, 15);
    });

    testWidgets('a currency symbol sits where the value starts', (
      tester,
    ) async {
      await tester.pumpWidget(
        grouped(
          Field.currency(
            "budget",
            label: "Budget",
            currency: "usd",
            value: "1200",
            separateSymbol: true,
          ).widget!,
        ),
      );

      final Rect label = tester.getRect(find.text("Budget"));
      final Rect symbol = tester.getRect(find.text("\$"));
      expect(symbol.left - label.right, 16);
    });

    testWidgets('a text field keeps a prefix that isn\'t a plain icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        grouped(
          Field.mask(
            "Phone",
            mask: "#### ######",
            prefixIcon: TextButton(onPressed: () {}, child: const Text("+44")),
          ).widget!,
        ),
      );

      expect(find.text("+44"), findsOneWidget);
    });

    testWidgets('a picker keeps a prefix that isn\'t a plain icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        grouped(
          Field.picker(
            "Country",
            options: FormCollection.from({"uk": "United Kingdom"}),
            style: FieldStylePicker(prefixIcon: const Text("UK")),
          ).widget!,
        ),
      );

      expect(find.text("UK"), findsOneWidget);
    });

    testWidgets('a picker and date picker leave out a plain icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        grouped(
          Column(
            children: [
              Field.picker(
                "Country",
                options: FormCollection.from({"uk": "United Kingdom"}),
                style: FieldStylePicker(prefixIcon: const Icon(Icons.public)),
              ).widget!,
              Field.date(
                "Birthday",
                style: FieldStyleDateTimePicker(
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                ),
              ).widget!,
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.public), findsNothing);
      expect(find.byIcon(Icons.calendar_today_outlined), findsNothing);
    });

    for (final TextDirection direction in TextDirection.values) {
      testWidgets('a picker\'s arrow ends on the row\'s inset ($direction)', (
        tester,
      ) async {
        await tester.pumpWidget(
          grouped(
            Directionality(
              textDirection: direction,
              child: Field.picker(
                "Country",
                value: "ca",
                options: FormCollection.from({"ca": "Canada"}),
              ).widget!,
            ),
          ),
        );

        // The glyph has 8pt of empty space on its outer side, which may
        // spill into the row's 16pt inset.
        final Rect arrow = tester.getRect(
          find.byIcon(Icons.chevron_right_rounded),
        );
        final Rect row = tester.getRect(find.byType(FormFieldGroupRow));
        expect(arrow.width, 24);
        if (direction == TextDirection.ltr) {
          expect(row.right - arrow.right, 8);
        } else {
          expect(arrow.left - row.left, 8);
        }
      });
    }

    testWidgets('a hidden field leaves the card whole', (tester) async {
      await tester.pumpWidget(_app(const _HiddenFieldForm()));
      await tester.pumpAndSettle();

      expect(find.byType(FormFieldGroup), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
      expect(find.text("Phone"), findsOneWidget);
      expect(find.text("Budget"), findsOneWidget);
    });
  });

  group('cards', () {
    // The border goes over the rows, so a tinted row can't cover its curve.
    final Finder borderOnTop = find.byWidgetPredicate(
      (Widget w) =>
          w is Container &&
          (w.foregroundDecoration as BoxDecoration?)?.border != null &&
          (w.decoration as BoxDecoration?)?.border == null,
    );

    for (final FormFieldStyle look in const [
      FormFieldStyle.outlined(),
      FormFieldStyle.grouped(),
    ]) {
      testWidgets('a radio card draws its border over its options '
          '(${look.look.name})', (tester) async {
        await tester.pumpWidget(
          _app(
            FormFieldStyleScope(
              style: look,
              child: Field.radio(
                "Plan",
                value: "starter",
                options: FormCollection.from({"starter": "Starter"}),
              ).widget!,
            ),
          ),
        );

        expect(
          find.ancestor(
            of: find.byType(RadioListTile<dynamic>),
            matching: borderOnTop,
          ),
          findsOneWidget,
        );
      });
    }

    testWidgets('a grouped card draws its border over its rows', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          FormFieldGroup(
            children: [
              Field.switchBox("Email updates", label: "Email updates").widget!,
            ],
          ),
        ),
      );

      expect(
        find.ancestor(of: find.byType(Switch), matching: borderOnTop),
        findsOneWidget,
      );
    });
  });

  group('NyFormWidget.fieldStyle', () {
    testWidgets('a grouped form puts fields that follow each other in a card', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const _ProfileForm(style: FormFieldStyle.grouped())),
      );
      await tester.pumpAndSettle();

      // Name, Email and Password share a card; the checkbox breaks the run,
      // and Nickname gets its own.
      expect(find.byType(FormFieldGroup), findsNWidgets(2));
      Finder inGroup(String text) => find.descendant(
        of: find.byType(FormFieldGroup).first,
        matching: find.text(text),
      );
      expect(inGroup("Name"), findsOneWidget);
      expect(inGroup("Email"), findsOneWidget);
      expect(inGroup("Password"), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(FormFieldGroup),
          matching: find.byType(CheckboxListTile),
        ),
        findsNothing,
      );
    });

    testWidgets('a form\'s style wins over the app\'s', (tester) async {
      nylo.addFormFieldStyle(const FormFieldStyle.underlined());

      await tester.pumpWidget(
        _app(const _ProfileForm(style: FormFieldStyle.outlined())),
      );
      await tester.pumpAndSettle();

      expect(_decoration(tester).enabledBorder, isA<OutlineInputBorder>());
      expect(_decoration(tester).filled, isFalse);
    });

    testWidgets('Nylo.configure takes the app\'s style', (tester) async {
      await nylo.configure(formFieldStyle: const FormFieldStyle.outlined());

      expect(nylo.formFieldStyle, const FormFieldStyle.outlined());
    });
  });
}
