import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/helpers/src/backpack.dart';
import 'package:nylo_support/localization/ny_localization.dart';
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
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  NyTest.init();

  setUp(() {
    _initNylo();
  });

  tearDown(() {
    NyLocalization.instance.setValuesForTesting(values: {});
  });

  nyGroup('InputField labels', () {
    testWidgets(
      'password and email fields are labelled in English by default',
      (tester) async {
        await tester.pumpWidget(
          _app(
            Column(
              children: [
                InputField.password(controller: TextEditingController()),
                InputField.emailAddress(
                  controller: TextEditingController(),
                  autoFocus: false,
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Email Address'), findsOneWidget);
      },
    );

    testWidgets('labelText is translated', (tester) async {
      NyLocalization.instance.setValuesForTesting(
        values: {
          'auth': {'email': 'Correo'},
        },
      );

      await tester.pumpWidget(
        _app(
          InputField(
            controller: TextEditingController(),
            labelText: 'auth.email',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Correo'), findsOneWidget);
      expect(find.text('auth.email'), findsNothing);
    });

    testWidgets('validation messages name the translated label', (
      tester,
    ) async {
      NyLocalization.instance.setValuesForTesting(
        values: {
          'auth': {'email': 'Correo'},
        },
      );

      await tester.pumpWidget(
        _app(
          InputField(
            controller: TextEditingController(),
            labelText: 'auth.email',
            formValidator: FormValidator.email(),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'not-an-email');
      // validateOnFocusChange defaults to true: errors show once focus leaves
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      expect(
        find.text('The Correo must be a valid email address.'),
        findsOneWidget,
      );
    });
  });
}
