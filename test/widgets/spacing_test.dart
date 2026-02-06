import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

void main() {
  NyTest.init();

  nyGroup('Spacing', () {
    nyGroup('constructor', () {
      testWidgets('creates with width and height', (tester) async {
        const spacing = Spacing(width: 10, height: 20);

        await tester.pumpWidget(const MaterialApp(home: spacing));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, 10);
        expect(sizedBox.height, 20);
      });

      testWidgets('creates with null dimensions', (tester) async {
        const spacing = Spacing();

        await tester.pumpWidget(const MaterialApp(home: spacing));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, isNull);
        expect(sizedBox.height, isNull);
      });
    });

    nyGroup('vertical', () {
      testWidgets('creates vertical spacing', (tester) async {
        const spacing = Spacing.vertical(24);

        await tester.pumpWidget(const MaterialApp(home: spacing));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.height, 24);
        expect(sizedBox.width, isNull);
      });
    });

    nyGroup('horizontal', () {
      testWidgets('creates horizontal spacing', (tester) async {
        const spacing = Spacing.horizontal(16);

        await tester.pumpWidget(const MaterialApp(home: spacing));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, 16);
        expect(sizedBox.height, isNull);
      });
    });

    nyGroup('preset vertical sizes', () {
      testWidgets('zero creates no spacing', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: Spacing.zero));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.height, 0);
      });

      testWidgets('xs creates 4px spacing', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: Spacing.xs));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.height, 4);
      });

      testWidgets('sm creates 8px spacing', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: Spacing.sm));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.height, 8);
      });

      testWidgets('md creates 16px spacing', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: Spacing.md));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.height, 16);
      });

      testWidgets('lg creates 24px spacing', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: Spacing.lg));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.height, 24);
      });

      testWidgets('xl creates 32px spacing', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: Spacing.xl));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.height, 32);
      });
    });

    nyGroup('preset horizontal sizes', () {
      testWidgets('xsHorizontal creates 4px spacing', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: Spacing.xsHorizontal));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, 4);
      });

      testWidgets('smHorizontal creates 8px spacing', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: Spacing.smHorizontal));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, 8);
      });

      testWidgets('mdHorizontal creates 16px spacing', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: Spacing.mdHorizontal));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, 16);
      });

      testWidgets('lgHorizontal creates 24px spacing', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: Spacing.lgHorizontal));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, 24);
      });

      testWidgets('xlHorizontal creates 32px spacing', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: Spacing.xlHorizontal));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, 32);
      });
    });

    nyGroup('asSliver', () {
      testWidgets('returns SliverToBoxAdapter', (tester) async {
        const spacing = Spacing.vertical(16);

        await tester.pumpWidget(
          MaterialApp(home: CustomScrollView(slivers: [spacing.asSliver()])),
        );

        expect(find.byType(SliverToBoxAdapter), findsOneWidget);
        expect(find.byType(Spacing), findsOneWidget);
      });
    });

    nyGroup('integration', () {
      testWidgets('works in Column', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text('First'), Spacing.md, Text('Second')],
            ),
          ),
        );

        expect(find.text('First'), findsOneWidget);
        expect(find.text('Second'), findsOneWidget);
        expect(find.byType(Spacing), findsOneWidget);
      });

      testWidgets('works in Row', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text('Left'), Spacing.mdHorizontal, Text('Right')],
            ),
          ),
        );

        expect(find.text('Left'), findsOneWidget);
        expect(find.text('Right'), findsOneWidget);
        expect(find.byType(Spacing), findsOneWidget);
      });
    });
  });
}
