import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

class _SpacedForm extends NyFormWidget {
  const _SpacedForm({super.mainAxisSpacing, super.crossAxisSpacing});

  @override
  List<dynamic> fields() => [
    Field.text("First"),
    Field.text("Second"),
    [Field.text("Left"), Field.text("Right")],
  ];
}

Widget _app(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

Rect _rect(WidgetTester tester, int index) =>
    tester.getRect(find.byType(TextField).at(index));

void main() {
  NyTest.init();

  setUp(() {
    NyEnvRegistry.register(
      getter: (String key, {dynamic defaultValue}) => defaultValue,
      containsKey: (String key) => false,
    );
    Backpack.instance.save("nylo", Nylo());
    Backpack.instance.save("event_bus", EventBus(maxHistoryLength: 10));
  });

  Future<double> verticalGap(WidgetTester tester, _SpacedForm form) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app(form));
    await tester.pumpAndSettle();
    return _rect(tester, 1).top - _rect(tester, 0).top;
  }

  Future<double> rowGap(WidgetTester tester, _SpacedForm form) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app(form));
    await tester.pumpAndSettle();
    return _rect(tester, 3).left - _rect(tester, 2).right;
  }

  group('NyFormWidget spacing', () {
    testWidgets('mainAxisSpacing sets the vertical gap between fields', (
      tester,
    ) async {
      final double narrow = await verticalGap(
        tester,
        const _SpacedForm(mainAxisSpacing: 10),
      );
      final double wide = await verticalGap(
        tester,
        const _SpacedForm(mainAxisSpacing: 40),
      );

      expect(wide - narrow, moreOrLessEquals(30));
    });

    testWidgets('crossAxisSpacing sets the gap between fields in a row', (
      tester,
    ) async {
      final double narrow = await rowGap(
        tester,
        const _SpacedForm(crossAxisSpacing: 10),
      );
      final double wide = await rowGap(
        tester,
        const _SpacedForm(crossAxisSpacing: 40),
      );

      expect(wide - narrow, moreOrLessEquals(30));
    });

    testWidgets('crossAxisSpacing leaves the vertical gap as it is', (
      tester,
    ) async {
      final double before = await verticalGap(tester, const _SpacedForm());
      final double after = await verticalGap(
        tester,
        const _SpacedForm(crossAxisSpacing: 40),
      );

      expect(after, moreOrLessEquals(before));
    });
  });
}
