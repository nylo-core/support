import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/screenshot/ny_screenshot.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

void main() {
  testWidgets('NyApp.materialApp puts the screenshot boundary outside the '
      'app\'s builder', (WidgetTester tester) async {
    await tester.pumpWidget(
      NyApp.materialApp(
        home: const Text('Home'),
        builder: (BuildContext context, Widget? child) => Banner(
          message: 'beta',
          location: BannerLocation.topEnd,
          child: child!,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(Screenshot.rootKey),
        matching: find.byType(Banner),
      ),
      findsOneWidget,
    );
    expect(find.text('Home'), findsOneWidget);
    expect(Screenshot.overlayKey.currentState, isNotNull);
  });
}
