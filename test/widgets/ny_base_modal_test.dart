import 'package:material_ui/material_ui.dart';
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

  group('NyBaseModal.show content sizing', () {
    const Key contentKey = Key('content');
    const Key actionKey = Key('action');
    const Size screen = Size(400, 800);

    /// Opens a modal with [child] (which must carry [contentKey]) and an
    /// action below it, on an 800px-tall screen.
    Future<void> openModal(
      WidgetTester tester, {
      required Widget child,
      double? height,
      bool isScrollControlled = false,
      Widget? header,
    }) async {
      tester.view.physicalSize = screen;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => NyBaseModal.show(
                context,
                child: child,
                height: height,
                isScrollControlled: isScrollControlled,
                header: header,
                actionsColumn: const [SizedBox(key: actionKey, height: 40)],
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    double contentHeight(WidgetTester tester) =>
        tester.getSize(find.byKey(contentKey)).height;

    void expectActionOnScreen(WidgetTester tester) {
      expect(
        tester.getBottomLeft(find.byKey(actionKey)).dy,
        lessThanOrEqualTo(screen.height),
      );
    }

    /// Fifty 20px rows: 1000px, taller than any modal on the test screen.
    List<Widget> longRows() =>
        List.generate(50, (i) => SizedBox(height: 20, child: Text('Row $i')));

    for (final bool scrollControlled in [false, true]) {
      for (final double? height in [null, 600]) {
        final String config =
            '(isScrollControlled: $scrollControlled, height: $height)';

        testWidgets('a short Column keeps its natural height $config', (
          tester,
        ) async {
          await openModal(
            tester,
            isScrollControlled: scrollControlled,
            height: height,
            child: const Column(
              key: contentKey,
              children: [SizedBox(height: 20), SizedBox(height: 20)],
            ),
          );
          expect(tester.takeException(), isNull);
          expect(contentHeight(tester), 40);
          // The actions sit right under the content, not at the bottom of a
          // fixed-height modal.
          expect(
            tester.getTopLeft(find.byKey(actionKey)).dy,
            tester.getBottomLeft(find.byKey(contentKey)).dy + 16,
          );
        });

        testWidgets('a Center keeps its natural height $config', (
          tester,
        ) async {
          await openModal(
            tester,
            isScrollControlled: scrollControlled,
            height: height,
            child: const Center(
              key: contentKey,
              child: SizedBox(height: 20, width: 20),
            ),
          );
          expect(tester.takeException(), isNull);
          expect(contentHeight(tester), 20);
        });

        testWidgets('long content scrolls instead of overflowing $config', (
          tester,
        ) async {
          await openModal(
            tester,
            isScrollControlled: scrollControlled,
            height: height,
            child: Column(key: contentKey, children: longRows()),
          );
          expect(tester.takeException(), isNull);
          expectActionOnScreen(tester);

          final double top = tester.getTopLeft(find.byKey(contentKey)).dy;
          await tester.drag(find.text('Row 5'), const Offset(0, -200));
          await tester.pumpAndSettle();
          expect(tester.getTopLeft(find.byKey(contentKey)).dy, lessThan(top));
        });

        testWidgets('a short SingleChildScrollView keeps its height $config', (
          tester,
        ) async {
          await openModal(
            tester,
            isScrollControlled: scrollControlled,
            height: height,
            child: const SingleChildScrollView(
              key: contentKey,
              child: SizedBox(height: 20),
            ),
          );
          expect(tester.takeException(), isNull);
          expect(contentHeight(tester), 20);
        });
      }
    }

    testWidgets('a long SingleChildScrollView child scrolls by itself', (
      tester,
    ) async {
      // The scrollable modal example from the docs (issue #314).
      await openModal(
        tester,
        isScrollControlled: true,
        height: screen.height * 0.9,
        header: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Terms of Service'),
        ),
        child: SingleChildScrollView(
          key: contentKey,
          child: Column(children: longRows()),
        ),
      );
      expect(tester.takeException(), isNull);
      expectActionOnScreen(tester);
      // No scroll view is added around the child, so its own scroll view
      // is the only one in the modal.
      expect(
        find.descendant(
          of: find.byType(NyModalLayout),
          matching: find.byType(Scrollable),
        ),
        findsOneWidget,
      );

      final ScrollPosition position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      await tester.drag(find.text('Row 5'), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(position.pixels, greaterThan(0));
    });

    testWidgets('a ListView child without shrinkWrap lays out', (tester) async {
      await openModal(
        tester,
        child: ListView(key: contentKey, children: longRows()),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Row 0'), findsOneWidget);
      expectActionOnScreen(tester);
    });
  });
}
