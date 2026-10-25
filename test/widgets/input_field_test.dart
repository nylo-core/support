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

  nyGroup('InputField multi-line prefix icon', () {
    /// The rendered icon: with [PrefixIconAlignment.top] the decorator also
    /// holds an invisible copy, which is not hit-testable.
    Finder visibleIcon(IconData icon) => find.byIcon(icon).hitTestable();

    Rect iconRectWithin(WidgetTester tester, IconData icon, Finder field) {
      return tester.getRect(visibleIcon(icon)).shift(-tester.getTopLeft(field));
    }

    testWidgets('a textarea floats its label in line with single-line fields', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              InputField(
                controller: TextEditingController(text: 'Anthony'),
                labelText: 'Name',
                prefixIcon: const Icon(Icons.person),
              ),
              InputField(
                controller: TextEditingController(text: 'Hello'),
                labelText: 'Bio',
                maxLines: 5,
                minLines: 3,
                prefixIcon: const Icon(Icons.notes),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.text('Bio')).dx,
        tester.getTopLeft(find.text('Name')).dx,
      );
    });

    testWidgets('a textarea without a prefix icon keeps its label on top', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(InputField(controller: TextEditingController(), maxLines: 5)),
      );

      final TextField field = tester.widget(find.byType(TextField));
      expect(field.decoration!.alignLabelWithHint, isTrue);
    });

    testWidgets('an explicit alignLabelWithHint is kept', (tester) async {
      await tester.pumpWidget(
        _app(
          InputField(
            controller: TextEditingController(),
            maxLines: 5,
            prefixIcon: const Icon(Icons.notes),
            decoration: const InputDecoration(alignLabelWithHint: true),
          ),
        ),
      );

      final TextField field = tester.widget(find.byType(TextField));
      expect(field.decoration!.alignLabelWithHint, isTrue);
    });

    testWidgets('the prefix icon is centered by default', (tester) async {
      await tester.pumpWidget(
        _app(
          InputField(
            controller: TextEditingController(),
            maxLines: 5,
            minLines: 5,
            prefixIcon: const Icon(Icons.notes),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getCenter(visibleIcon(Icons.notes)).dy,
        tester.getCenter(find.byType(TextField)).dy,
      );
    });

    testWidgets(
      'PrefixIconAlignment.top places the icon where a single-line field does',
      (tester) async {
        await tester.pumpWidget(
          _app(
            InputField(
              controller: TextEditingController(),
              labelText: 'Name',
              prefixIcon: const Icon(Icons.notes),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final Rect singleLine = iconRectWithin(
          tester,
          Icons.notes,
          find.byType(TextField),
        );

        await tester.pumpWidget(
          _app(
            InputField(
              key: UniqueKey(),
              controller: TextEditingController(),
              labelText: 'Bio',
              maxLines: 5,
              minLines: 5,
              prefixIcon: const Icon(Icons.notes),
              prefixIconAlignment: PrefixIconAlignment.top,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          tester.getSize(find.byType(TextField)).height,
          greaterThan(singleLine.height * 2),
        );
        expect(
          iconRectWithin(tester, Icons.notes, find.byType(TextField)),
          singleLine,
        );
      },
    );

    testWidgets('PrefixIconAlignment.top keeps the themed icon color', (
      tester,
    ) async {
      Color? iconColor() => tester
          .widget<RichText>(
            find.descendant(
              of: visibleIcon(Icons.notes),
              matching: find.byType(RichText),
            ),
          )
          .text
          .style
          ?.color;

      await tester.pumpWidget(
        _app(
          InputField(
            controller: TextEditingController(),
            prefixIcon: const Icon(Icons.notes),
            decoration: const InputDecoration(prefixIconColor: Colors.teal),
          ),
        ),
      );
      final Color? singleLine = iconColor();

      await tester.pumpWidget(
        _app(
          InputField(
            key: UniqueKey(),
            controller: TextEditingController(),
            maxLines: 5,
            prefixIcon: const Icon(Icons.notes),
            prefixIconAlignment: PrefixIconAlignment.top,
            decoration: const InputDecoration(prefixIconColor: Colors.teal),
          ),
        ),
      );

      expect(singleLine, isNotNull);
      expect(iconColor(), singleLine);
    });

    testWidgets('PrefixIconAlignment.top keeps the floating label aligned', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              InputField(
                controller: TextEditingController(text: 'Anthony'),
                labelText: 'Name',
                prefixIcon: const Icon(Icons.person),
              ),
              InputField(
                controller: TextEditingController(text: 'Hello'),
                labelText: 'Bio',
                maxLines: 5,
                prefixIcon: const Icon(Icons.notes),
                prefixIconAlignment: PrefixIconAlignment.top,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.text('Bio')).dx,
        tester.getTopLeft(find.text('Name')).dx,
      );
    });

    testWidgets('PrefixIconAlignment.top sits at the start edge in RTL', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Directionality(
            textDirection: TextDirection.rtl,
            child: InputField(
              controller: TextEditingController(),
              maxLines: 5,
              prefixIcon: const Icon(Icons.notes),
              prefixIconAlignment: PrefixIconAlignment.top,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getTopRight(visibleIcon(Icons.notes)).dx,
        tester.getTopRight(find.byType(TextField)).dx,
      );
    });

    testWidgets('tapping a top-aligned icon focuses the field', (tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpWidget(
        _app(
          InputField(
            controller: TextEditingController(),
            focusNode: node,
            maxLines: 5,
            prefixIcon: const Icon(Icons.notes),
            prefixIconAlignment: PrefixIconAlignment.top,
          ),
        ),
      );
      await tester.tap(visibleIcon(Icons.notes));
      await tester.pumpAndSettle();

      expect(node.hasFocus, isTrue);
    });

    testWidgets('PrefixIconAlignment.top leaves single-line fields alone', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          InputField(
            controller: TextEditingController(),
            prefixIcon: const Icon(Icons.notes),
            prefixIconAlignment: PrefixIconAlignment.top,
          ),
        ),
      );

      expect(find.byIcon(Icons.notes), findsOneWidget);
    });

    testWidgets('Field.textArea takes prefixIconAlignment from its style', (
      tester,
    ) async {
      final Field field = Field.textArea(
        "bio",
        label: "Bio",
        style: FieldStyleTextField(
          maxLines: 5,
          minLines: 5,
          prefixIcon: const Icon(Icons.notes),
          prefixIconAlignment: PrefixIconAlignment.top,
        ),
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      final InputField input = tester.widget(find.byType(InputField));
      expect(input.prefixIconAlignment, PrefixIconAlignment.top);
      expect(
        tester.getTopLeft(visibleIcon(Icons.notes)).dy,
        lessThan(tester.getCenter(find.byType(TextField)).dy - 24),
      );
    });
  });

  nyGroup('InputField multi-line label beside a top-aligned prefix icon', () {
    /// The label as drawn: the textarea's own label is kept, transparent,
    /// under the one that shows.
    Finder shownLabel(String text) => find.byWidgetPredicate(
      (widget) =>
          widget is RichText &&
          widget.text.toPlainText() == text &&
          widget.text.style?.color != Colors.transparent,
    );

    Offset labelWithin(WidgetTester tester, String text, Finder field) {
      return tester.getTopLeft(shownLabel(text)) - tester.getTopLeft(field);
    }

    /// Shows [error] under the field, as a failed validation does.
    DecoratorTextField failing(String error) => DecoratorTextField(
      decoration: (_, decoration) => decoration.copyWith(errorText: error),
    );

    Widget textarea({
      Key? key,
      String text = '',
      InputDecoration? decoration,
      DecoratorTextField? decorator,
      FocusNode? focusNode,
    }) {
      return InputField(
        key: key,
        controller: TextEditingController(text: text),
        focusNode: focusNode,
        labelText: 'Bio',
        labelPosition: FieldLabelPosition.floating,
        maxLines: 5,
        minLines: 5,
        prefixIcon: const Icon(Icons.notes),
        prefixIconAlignment: PrefixIconAlignment.top,
        decoration: decoration,
        decorator: decorator,
      );
    }

    testWidgets('the label rests where a single-line field rests it', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          InputField(
            controller: TextEditingController(),
            labelText: 'Bio',
            labelPosition: FieldLabelPosition.floating,
            prefixIcon: const Icon(Icons.notes),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final Offset singleLine = labelWithin(
        tester,
        'Bio',
        find.byType(TextField),
      );

      await tester.pumpWidget(_app(textarea(key: UniqueKey())));
      await tester.pumpAndSettle();

      expect(shownLabel('Bio'), findsOneWidget);
      expect(
        labelWithin(tester, 'Bio', find.byType(TextField)),
        offsetMoreOrLessEquals(singleLine),
      );
    });

    testWidgets('the label floats where a single-line field floats it', (
      tester,
    ) async {
      final Key name = UniqueKey();
      final Key bio = UniqueKey();
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              InputField(
                key: name,
                controller: TextEditingController(text: 'Anthony'),
                labelText: 'Name',
                labelPosition: FieldLabelPosition.floating,
                prefixIcon: const Icon(Icons.person),
              ),
              textarea(key: bio, text: 'Hello'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      Finder field(Key key) => find.descendant(
        of: find.byKey(key),
        matching: find.byType(TextField),
      );
      expect(
        labelWithin(tester, 'Bio', field(bio)),
        offsetMoreOrLessEquals(labelWithin(tester, 'Name', field(name))),
      );
    });

    testWidgets('the label floats on focus and rests again when left empty', (
      tester,
    ) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(_app(textarea(focusNode: node)));
      await tester.pumpAndSettle();
      final Offset resting = tester.getTopLeft(shownLabel('Bio'));

      node.requestFocus();
      await tester.pump();
      expect(
        tester.getTopLeft(shownLabel('Bio')),
        offsetMoreOrLessEquals(resting),
      );
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(shownLabel('Bio')).dy, lessThan(resting.dy));

      node.unfocus();
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(shownLabel('Bio')),
        offsetMoreOrLessEquals(resting),
      );
    });

    testWidgets('find.text finds the label and error once', (tester) async {
      await tester.pumpWidget(_app(textarea(decorator: failing('Needed'))));
      await tester.pumpAndSettle();

      expect(find.text('Bio'), findsOneWidget);
      expect(find.text('Needed'), findsOneWidget);
    });

    testWidgets('a state-aware labelStyle sees the error', (tester) async {
      final TextStyle labelStyle = WidgetStateTextStyle.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.error) ? Colors.red : Colors.blue,
        ),
      );
      Color? labelColor() =>
          tester.widget<RichText>(shownLabel('Bio')).text.style?.color;

      await tester.pumpWidget(
        _app(textarea(decoration: InputDecoration(labelStyle: labelStyle))),
      );
      await tester.pumpAndSettle();
      expect(labelColor(), Colors.blue);

      await tester.pumpWidget(
        _app(
          textarea(
            key: UniqueKey(),
            decoration: InputDecoration(labelStyle: labelStyle),
            decorator: failing('Needed'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(labelColor(), Colors.red);
    });

    testWidgets('alignLabelWithHint: true keeps a single label', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          textarea(decoration: const InputDecoration(alignLabelWithHint: true)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bio', findRichText: true), findsOneWidget);
      expect(shownLabel('Bio'), findsOneWidget);
    });
  });

  nyGroup('InputField multi-line suffix icon', () {
    Finder visibleIcon(IconData icon) => find.byIcon(icon).hitTestable();

    Rect iconRectWithin(WidgetTester tester, IconData icon, Finder field) {
      return tester.getRect(visibleIcon(icon)).shift(-tester.getTopLeft(field));
    }

    testWidgets('the suffix icon is centered by default', (tester) async {
      await tester.pumpWidget(
        _app(
          InputField(
            controller: TextEditingController(),
            maxLines: 5,
            minLines: 5,
            suffixIcon: const Icon(Icons.send),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getCenter(visibleIcon(Icons.send)).dy,
        tester.getCenter(find.byType(TextField)).dy,
      );
    });

    testWidgets(
      'SuffixIconAlignment.top places the icon where a single-line field does',
      (tester) async {
        await tester.pumpWidget(
          _app(
            InputField(
              controller: TextEditingController(),
              labelText: 'Name',
              suffixIcon: const Icon(Icons.send),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final Rect singleLine = iconRectWithin(
          tester,
          Icons.send,
          find.byType(TextField),
        );

        await tester.pumpWidget(
          _app(
            InputField(
              key: UniqueKey(),
              controller: TextEditingController(),
              labelText: 'Message',
              maxLines: 5,
              minLines: 5,
              suffixIcon: const Icon(Icons.send),
              suffixIconAlignment: SuffixIconAlignment.top,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          iconRectWithin(tester, Icons.send, find.byType(TextField)),
          singleLine,
        );
      },
    );

    testWidgets('top-aligned prefix and suffix icons share the first line', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          InputField(
            controller: TextEditingController(),
            labelText: 'Message',
            maxLines: 5,
            minLines: 5,
            prefixIcon: const Icon(Icons.notes),
            prefixIconAlignment: PrefixIconAlignment.top,
            suffixIcon: const Icon(Icons.send),
            suffixIconAlignment: SuffixIconAlignment.top,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getCenter(visibleIcon(Icons.send)).dy,
        tester.getCenter(visibleIcon(Icons.notes)).dy,
      );
    });

    testWidgets('a top-aligned suffix button still takes taps', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _app(
          InputField(
            controller: TextEditingController(),
            maxLines: 5,
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => tapped = true,
            ),
            suffixIconAlignment: SuffixIconAlignment.top,
          ),
        ),
      );
      await tester.tap(visibleIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('SuffixIconAlignment.top sits at the end edge in RTL', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Directionality(
            textDirection: TextDirection.rtl,
            child: InputField(
              controller: TextEditingController(),
              maxLines: 5,
              suffixIcon: const Icon(Icons.send),
              suffixIconAlignment: SuffixIconAlignment.top,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(visibleIcon(Icons.send)).dx,
        tester.getTopLeft(find.byType(TextField)).dx,
      );
    });

    testWidgets('SuffixIconAlignment.top leaves single-line fields alone', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          InputField(
            controller: TextEditingController(),
            suffixIcon: const Icon(Icons.send),
            suffixIconAlignment: SuffixIconAlignment.top,
          ),
        ),
      );

      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('Field.textArea takes suffixIconAlignment from its style', (
      tester,
    ) async {
      final Field field = Field.textArea(
        "message",
        label: "Message",
        style: FieldStyleTextField(
          maxLines: 5,
          minLines: 5,
          suffixIcon: const Icon(Icons.send),
          suffixIconAlignment: SuffixIconAlignment.top,
        ),
      );
      await tester.pumpWidget(_app(field.widget!));
      await tester.pumpAndSettle();

      final InputField input = tester.widget(find.byType(InputField));
      expect(input.suffixIconAlignment, SuffixIconAlignment.top);
      expect(
        tester.getTopLeft(visibleIcon(Icons.send)).dy,
        lessThan(tester.getCenter(find.byType(TextField)).dy - 24),
      );
    });
  });
}
