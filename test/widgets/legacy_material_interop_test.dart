import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nylo_support/alerts/ny_alerts.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

/// Widgets from pull_to_refresh_flutter3 and flutter_styled_toast still use
/// `package:flutter/material.dart`, which a `package:material_ui` app does
/// not provide a theme or localizations for.
void main() {
  NyTest.init();

  setUp(() {
    if (!Backpack.instance.isNyloInitialized()) {
      Backpack.instance.save('nylo', Nylo());
    }
    Backpack.instance.save('event_bus', EventBus(maxHistoryLength: 10));
  });

  Widget app(Widget home) => MaterialApp(
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: home,
  );

  testWidgets('a MaterialClassicHeader builds and refreshes', (tester) async {
    bool refreshed = false;

    await tester.pumpWidget(
      app(
        Scaffold(
          body: Pullable.materialClassicHeader(
            onRefresh: () async => refreshed = true,
            child: ListView(
              children: List<Widget>.generate(
                30,
                (int i) => SizedBox(height: 40, child: Text('row $i')),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.fling(find.text('row 0'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(refreshed, isTrue);
  });

  testWidgets('a CollectionView with a MaterialClassicHeader builds', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        Scaffold(
          body: CollectionView<int>.pullable(
            headerStyle: 'MaterialClassicHeader',
            data: (int page) async => List<int>.generate(30, (int i) => i),
            builder: (BuildContext context, CollectionItem<int> item) =>
                SizedBox(height: 40, child: Text('item ${item.data}')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.fling(find.text('item 0'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  group('toasts', () {
    setUp(() {
      NyEnvRegistry.register(
        getter: (String key, {dynamic defaultValue}) => defaultValue,
        containsKey: (String key) => false,
      );
      ToastNotificationRegistry.instance.clear();
    });

    tearDown(ToastNotificationRegistry.instance.clear);

    testWidgets('toast content gets a Material for ink and text style', (
      tester,
    ) async {
      bool tapped = false;
      ToastNotificationRegistry.instance.register(
        'ink',
        (ToastMeta meta, void Function(ToastMeta) updateMeta) => InkWell(
          onTap: () => tapped = true,
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Text('tap me'),
          ),
        ),
      );

      await tester.pumpWidget(
        app(
          Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () => showToastNotification(context, id: 'ink'),
              child: const Text('show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      await tester.tap(find.text('tap me'));
      expect(tapped, isTrue);

      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    });
  });
}
