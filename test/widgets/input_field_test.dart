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

  nyGroup('InputField inline validation', () {
    const String tooShort = 'The Code must be at least 5 characters long.';

    Future<void> focusAndType(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.pumpAndSettle();
    }

    testWidgets('shows the error while typing and clears it once valid', (
      tester,
    ) async {
      int validatorCalls = 0;
      await tester.pumpWidget(
        _app(
          InputField(
            controller: TextEditingController(),
            labelText: 'Code',
            validateOnFocusChange: false,
            validate: (validator, data) {
              validatorCalls++;
              validator.minLength(5);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(tooShort), findsNothing);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      await focusAndType(tester, 'a');
      expect(find.text(tooShort), findsOneWidget);
      expect(validatorCalls, greaterThan(0));

      await focusAndType(tester, 'abcde');
      expect(find.text(tooShort), findsNothing);
    });

    testWidgets('does not rebuild while the error text is unchanged', (
      tester,
    ) async {
      /// Before: every keystroke ran setState and re-ran the validator in
      /// view(). Now the validator runs per keystroke but the field only
      /// rebuilds when the shown error changes.
      int validatorCalls = 0;
      await tester.pumpWidget(
        _app(
          InputField(
            controller: TextEditingController(),
            labelText: 'Code',
            validateOnFocusChange: false,
            onChanged: (_) {},
            validate: (validator, data) {
              validatorCalls++;
              validator.minLength(5);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      await focusAndType(tester, 'a');
      expect(find.text(tooShort), findsOneWidget);

      final int buildsWithError = InputField.debugBuildCount;
      final int callsWithError = validatorCalls;

      await focusAndType(tester, 'ab');
      await focusAndType(tester, 'abc');
      await focusAndType(tester, 'abcd');

      // Validation still runs on each keystroke...
      expect(validatorCalls, callsWithError + 3);
      // ...but the same error text does not rebuild the field.
      expect(InputField.debugBuildCount, buildsWithError);
      expect(find.text(tooShort), findsOneWidget);

      // Becoming valid changes the error text, so exactly one rebuild.
      await focusAndType(tester, 'abcde');
      expect(find.text(tooShort), findsNothing);
      expect(InputField.debugBuildCount, buildsWithError + 1);
    });

    testWidgets('validateOnFocusChange waits for focus to leave', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          InputField(
            controller: TextEditingController(),
            labelText: 'Code',
            validateOnFocusChange: true,
            validate: (validator, data) => validator.minLength(5),
          ),
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      await focusAndType(tester, 'abc');
      expect(find.text(tooShort), findsNothing);

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(find.text(tooShort), findsOneWidget);
    });

    testWidgets('masked fields hand onChanged the unmasked value', (
      tester,
    ) async {
      String? received;
      await tester.pumpWidget(
        _app(
          InputField(
            controller: TextEditingController(),
            labelText: 'Phone',
            mask: '###-###',
            maskMatch: r'[0-9]',
            onChanged: (value) => received = value,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pumpAndSettle();

      expect(received, '123456');
      expect(find.text('123-456'), findsOneWidget);
    });

    testWidgets('toggling the password eye still rebuilds', (tester) async {
      await tester.pumpWidget(
        _app(
          InputField.password(
            controller: TextEditingController(),
            passwordViewable: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);
    });
  });

  nyGroup('InputField focus node ownership', () {
    const String tooShort = 'The Password must be at least 8 characters long.';

    testWidgets('Field.password with the default style validates inline', (
      tester,
    ) async {
      /// The default FieldStyleTextField used to ship its own FocusNode, so
      /// the InputField listened to a node that never gained focus and
      /// inline errors never appeared for password/email fields.
      final Field field = Field.password(
        "password",
        validator: FormValidator.notEmpty().minLength(8),
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      expect(find.text(tooShort), findsOneWidget);
    });

    testWidgets('a caller-supplied focusNode still drives validation', (
      tester,
    ) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      final Field field = Field.text(
        "password",
        validator: FormValidator.notEmpty().minLength(8),
        style: FieldStyleTextField(focusNode: node),
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      node.requestFocus();
      await tester.pumpAndSettle();
      expect(node.hasFocus, isTrue);

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pumpAndSettle();
      node.unfocus();
      await tester.pumpAndSettle();

      expect(find.text(tooShort), findsOneWidget);
    });

    testWidgets('swapping the focusNode moves the listener', (tester) async {
      final FocusNode first = FocusNode();
      final FocusNode second = FocusNode();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      final TextEditingController controller = TextEditingController();

      Widget build(FocusNode node) => _app(
        InputField(
          controller: controller,
          labelText: 'Code',
          focusNode: node,
          validate: (validator, data) => validator.minLength(5),
        ),
      );

      await tester.pumpWidget(build(first));
      await tester.pumpWidget(build(second));
      await tester.pumpAndSettle();

      second.requestFocus();
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pumpAndSettle();
      second.unfocus();
      await tester.pumpAndSettle();

      expect(
        find.text('The Code must be at least 5 characters long.'),
        findsOneWidget,
      );
    });
  });
}
