import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/helpers/src/backpack.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

/// Helper to initialize Nylo for widget tests that use NyState.
void _initNylo() {
  if (!Backpack.instance.isNyloInitialized()) {
    Backpack.instance.save("nylo", Nylo());
  }
  Backpack.instance.save("event_bus", EventBus(maxHistoryLength: 10));
}

Widget _app(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

/// Contrast ratio between two colours (WCAG).
double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  return la > lb ? (la + 0.05) / (lb + 0.05) : (lb + 0.05) / (la + 0.05);
}

void main() {
  NyTest.init();

  setUp(() {
    _initNylo();
  });

  nyGroup('Field.date', () {
    testWidgets('shows nothing until a date is chosen', (tester) async {
      /// It used to show today while its value stayed null, so the form
      /// submitted nothing for the date on screen.
      final Field field = Field.date("Moved in");
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      expect(find.text(today), findsNothing);
      expect(field.value, isNull);
      expect(find.text("Moved In"), findsOneWidget);
    });

    testWidgets('shows the date it was given', (tester) async {
      final Field field = Field.date("Moved in", value: "2026-09-27");
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      expect(find.text("2026-09-27"), findsOneWidget);
    });

    testWidgets('shows a date set after it opened', (tester) async {
      /// setValue reached a field that had no handler for it, so the form's
      /// value changed while the screen kept the old date.
      final Field field = Field.date("Moved in", value: "2026-09-27");
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      field.setValue(DateTime(2026, 10, 1));
      await tester.pumpAndSettle();

      expect(find.text("2026-10-01"), findsOneWidget);
      expect(find.text("2026-09-27"), findsNothing);
      expect(field.value, DateTime(2026, 10, 1));
    });

    testWidgets('clears what it shows', (tester) async {
      final Field field = Field.date("Moved in", value: "2026-09-27");
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      field.clear();
      await tester.pumpAndSettle();

      expect(find.text("2026-09-27"), findsNothing);
      expect(field.value, isNull);
    });

    testWidgets('keeps its label under a style with its own decoration', (
      tester,
    ) async {
      /// A style's decoration replaced the default one, label and all.
      final Field field = Field.date(
        "Moved in",
        style: FieldStyleDateTimePicker(
          decoration: const InputDecoration(filled: true),
        ),
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      expect(find.text("Moved In"), findsOneWidget);
    });

    testWidgets('leaves a decoration that has its own label or hint alone', (
      tester,
    ) async {
      final Field labelled = Field.date(
        "Moved in",
        style: FieldStyleDateTimePicker(
          decoration: const InputDecoration(labelText: "Move-in date"),
        ),
      );
      final Field hinted = Field.date(
        "Moved out",
        style: FieldStyleDateTimePicker(
          decoration: const InputDecoration(hintText: "Not yet"),
        ),
      );
      await tester.pumpWidget(
        _app(Column(children: [labelled.widget!, hinted.widget!])),
      );
      await tester.pumpAndSettle();

      expect(find.text("Move-in date"), findsOneWidget);
      expect(find.text("Moved In"), findsNothing);
      expect(find.text("Moved Out"), findsNothing);
    });
  });

  nyGroup('Field.picker', () {
    testWidgets('grows to fit its choice at double text size', (tester) async {
      /// A fixed 50pt box overflowed once a choice (name and value) was
      /// shown at larger text sizes, or when the choice ran to two lines.
      tester.view.physicalSize = const Size(960, 2000);
      tester.view.devicePixelRatio = 3.0;
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final Field field = Field.picker(
        "Category",
        value: "heating",
        options: FormCollection.from({
          "heating":
              "Heating and hot water, including the boiler and radiators",
        }),
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.textContaining("Heating and hot water"), findsOneWidget);
    });

    testWidgets('is still at least containerHeight tall', (tester) async {
      final Field field = Field.picker(
        "Category",
        options: FormCollection.from({"plumbing": "Plumbing"}),
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      final Size size = tester.getSize(find.byType(NyFormPicker));
      expect(size.height, greaterThanOrEqualTo(50));
    });

    /// #308: the picker lays out like the text fields beside it.
    testWidgets('shows a prefixIcon', (tester) async {
      final Field field = Field.picker(
        "Reason",
        options: FormCollection.from({"billing": "Billing"}),
        style: FieldStylePicker(prefixIcon: const Icon(Icons.phone)),
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.phone), findsOneWidget);
    });

    testWidgets('shows its label and choice at 16pt', (tester) async {
      final Field field = Field.picker(
        "Reason",
        value: "billing",
        options: FormCollection.from({"billing": "Billing"}),
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      final Text choice = tester.widget<Text>(find.text("Billing"));
      expect(choice.style?.fontSize, 16);
      final InputDecorator decorator = tester.widget<InputDecorator>(
        find.byType(InputDecorator),
      );
      expect(decorator.decoration.hintStyle?.fontSize, 16);
    });

    testWidgets('shows its name above, and a placeholder until chosen', (
      tester,
    ) async {
      final Field field = Field.picker(
        "Reason",
        options: FormCollection.from({"billing": "Billing"}),
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      InputDecorator decorator() =>
          tester.widget<InputDecorator>(find.byType(InputDecorator));
      expect(decorator().isEmpty, isTrue);
      expect(find.text("Reason"), findsOneWidget);
      expect(decorator().decoration.hintText, "Select Reason");

      field.setValue("billing");
      await tester.pumpAndSettle();

      expect(decorator().isEmpty, isFalse);
      expect(find.text("Reason"), findsOneWidget);
      expect(find.text("Billing"), findsOneWidget);
    });

    testWidgets('keeps the dropdown icon at the end once chosen', (
      tester,
    ) async {
      final Field field = Field.picker(
        "Reason",
        value: "billing",
        options: FormCollection.from({"billing": "Billing"}),
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      final Rect picker = tester.getRect(find.byType(NyFormPicker));
      final Rect icon = tester.getRect(find.byIcon(Icons.arrow_drop_down));
      expect(picker.right - icon.right, lessThan(24));
    });

    testWidgets('keeps its label and icons under a custom decoration', (
      tester,
    ) async {
      final Field field = Field.picker(
        "Reason",
        options: FormCollection.from({"billing": "Billing"}),
        style: FieldStylePicker(
          decoration: const InputDecoration(filled: true),
          prefixIcon: const Icon(Icons.phone),
        ),
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      expect(find.text("Select Reason"), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });
  });

  nyGroup('Field.chips in dark mode', () {
    testWidgets('shows which chips are selected, with labels that read', (
      tester,
    ) async {
      /// Every chip was painted the dark surface, so selected ones looked
      /// unselected, and the default black labels vanished.
      final Field field = Field.chips(
        "Features",
        value: ["garden"],
        options: FormCollection.from({
          "garden": "Garden",
          "parking": "Parking",
        }),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(body: field.widget!),
        ),
      );
      await tester.pumpAndSettle();

      ChoiceChip chip(String label) => tester.widget<ChoiceChip>(
        find.ancestor(of: find.text(label), matching: find.byType(ChoiceChip)),
      );
      // An unselected chip is see-through, so its text sits on the page.
      Color background(String label) {
        final Color color = chip(label).color!.resolve(<WidgetState>{})!;
        return color.a == 0 ? ThemeData.dark().scaffoldBackgroundColor : color;
      }

      Color text(String label) =>
          tester.widget<Text>(find.text(label)).style!.color!;

      expect(background("Garden"), isNot(background("Parking")));
      expect(
        _contrast(text("Garden"), background("Garden")),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(text("Parking"), background("Parking")),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(chip("Garden").checkmarkColor!, background("Garden")),
        greaterThanOrEqualTo(4.5),
      );
    });

    testWidgets('light mode keeps the style as given', (tester) async {
      final Field field = Field.chips(
        "Features",
        value: ["garden"],
        options: FormCollection.from({"garden": "Garden"}),
        style: FieldStyleChip(
          selectedTextStyle: const TextStyle(color: Color(0xFFFFCC00)),
        ),
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(find.text("Garden")).style!.color,
        const Color(0xFFFFCC00),
      );
    });
  });

  nyGroup('Password toggle', () {
    testWidgets('is a labelled button at least 48pt square', (tester) async {
      /// A bare GestureDetector round a 24pt icon: no label for screen
      /// readers, no keyboard focus, and a small target.
      final SemanticsHandle semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(InputField.password(controller: TextEditingController())),
      );
      await tester.pumpAndSettle();

      final Finder toggle = find.byTooltip("Show password");
      expect(toggle, findsOneWidget);
      final Size size = tester.getSize(
        find.ancestor(of: toggle, matching: find.byType(IconButton)),
      );
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      // Screen readers announce it as a button called "Show password".
      expect(
        tester.getSemantics(
          find.ancestor(of: toggle, matching: find.byType(IconButton)),
        ),
        isSemantics(
          tooltip: "Show password",
          isButton: true,
          isFocusable: true,
          hasTapAction: true,
        ),
      );

      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.byTooltip("Hide password"), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText,
        isFalse,
      );
      semantics.dispose();
    });
  });

  nyGroup('Field.picker bottom sheet', () {
    testWidgets('builds only the visible rows of a long list', (tester) async {
      /// It used to build and lay out every option (and divider) eagerly in
      /// the sheet's first frame, a visible stutter for ~250-item pickers.
      final Map<String, String> options = {
        for (int i = 0; i < 300; i++) 'c$i': 'Country $i',
      };
      final Field field = Field.picker(
        "Country",
        options: FormCollection.from(options),
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NyFormPicker));
      await tester.pumpAndSettle();

      final int tiles = find.byType(ListTile).evaluate().length;
      expect(tiles, greaterThan(0));
      expect(tiles, lessThan(100));
      expect(find.text('Country 0'), findsOneWidget);
      expect(find.text('Country 299'), findsNothing);

      await tester.tap(find.text('Country 3'));
      await tester.pumpAndSettle();

      expect(field.value, 'c3');
      expect(find.byType(ListTile), findsNothing);
      expect(find.text('Country 3'), findsOneWidget);
    });

    testWidgets('scrolls to the last option and selects it', (tester) async {
      final Field field = Field.picker(
        "Country",
        options: FormCollection.from({
          for (int i = 0; i < 300; i++) 'c$i': 'Country $i',
        }),
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NyFormPicker));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Country 299'),
        400,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Country 299'));
      await tester.pumpAndSettle();

      expect(field.value, 'c299');
    });

    testWidgets('Clear empties the value so notEmpty fails again', (
      tester,
    ) async {
      // https://github.com/nylo-core/nylo/issues/311
      final List<dynamic> changes = [];
      final Field field = Field.picker(
        "Reason",
        validator: FormValidator.notEmpty(),
        options: FormCollection.fromArray(['Info', 'Other']),
        onChanged: changes.add,
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NyFormPicker));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Info'));
      await tester.pumpAndSettle();
      expect(field.validate()?.isValid, isTrue);

      await tester.tap(find.byType(NyFormPicker));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(field.value, isNull);
      expect(field.validate()?.isValid, isFalse);
      expect(changes, ['Info', null]);
    });
  });
}
