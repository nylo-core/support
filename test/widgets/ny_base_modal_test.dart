import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

/// Opens a modal with [NyBaseModal.show] and returns the color of its
/// content area.
Future<Color?> _contentColor(
  WidgetTester tester, {
  Color? backgroundColor,
  Color? modalBackgroundColor,
  Widget? header,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => NyBaseModal.show(
            context,
            child: const Text('Modal content'),
            backgroundColor: backgroundColor,
            modalBackgroundColor: modalBackgroundColor,
            header: header,
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();

  final Container container = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(NyModalLayout),
          matching: find.byType(Container),
        )
        .first,
  );
  return (container.decoration as BoxDecoration).color;
}

void main() {
  NyTest.init();

  group('NyBaseModal.show background colors', () {
    testWidgets('content is white by default', (tester) async {
      expect(await _contentColor(tester), Colors.white);
    });

    testWidgets('backgroundColor colors the content area', (tester) async {
      expect(
        await _contentColor(tester, backgroundColor: Colors.green),
        Colors.green,
      );
      final BottomSheet sheet = tester.widget<BottomSheet>(
        find.byType(BottomSheet),
      );
      expect(sheet.backgroundColor, Colors.green);
    });

    testWidgets('modalBackgroundColor overrides backgroundColor', (
      tester,
    ) async {
      expect(
        await _contentColor(
          tester,
          backgroundColor: Colors.green,
          modalBackgroundColor: Colors.red,
        ),
        Colors.red,
      );
      final BottomSheet sheet = tester.widget<BottomSheet>(
        find.byType(BottomSheet),
      );
      expect(sheet.backgroundColor, Colors.green);
    });

    testWidgets('content stays white under a header with no colors set', (
      tester,
    ) async {
      expect(
        await _contentColor(tester, header: const Text('Header')),
        Colors.white,
      );
      final BottomSheet sheet = tester.widget<BottomSheet>(
        find.byType(BottomSheet),
      );
      expect(sheet.backgroundColor, Colors.transparent);
    });
  });
}
