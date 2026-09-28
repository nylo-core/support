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
  });

  nyGroup('Field.chips in dark mode', () {
    testWidgets('shows which chips are selected, with labels that read', (
      tester,
    ) async {
      /// Every chip was painted the dark surface, so selected ones looked
      /// unselected, and the default black labels vanished.
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final Field field = Field.chips(
        "Features",
        value: ["garden"],
        options: FormCollection.from({
          "garden": "Garden",
          "parking": "Parking",
        }),
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      ChoiceChip chip(String label) => tester.widget<ChoiceChip>(
        find.ancestor(of: find.text(label), matching: find.byType(ChoiceChip)),
      );
      Color background(String label) =>
          chip(label).color!.resolve(<WidgetState>{})!;
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
}
