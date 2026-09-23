import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

/// A one-field form for driving the submitForm path.
class EmailForm extends NyFormWidget {
  EmailForm({super.key});

  @override
  List<dynamic> fields() => [
    Field.email("Email", validator: FormValidator.email()),
  ];
}

/// Helper to initialize Nylo for widget tests that use NyState.
void _initNylo() {
  NyEnvRegistry.register(
    getter: (String key, {dynamic defaultValue}) => defaultValue,
    containsKey: (String key) => false,
  );
  Backpack.instance.save("nylo", Nylo());
  // Fresh EventBus per test so state events do not leak between tests.
  Backpack.instance.save("event_bus", EventBus(maxHistoryLength: 10));
}

/// A [ButtonState] drawn as a [TextButton]. ButtonState hands its child a
/// null callback while locked, so the button is disabled exactly then.
Widget _button({
  Function()? onPressed,
  (dynamic, Function(dynamic data))? submitForm,
}) {
  return ButtonState(
    onSubmit: (onPressed, submitForm),
    loadingStyle: const LoadingStyle.none(),
    showToastError: false,
    child: (pressed) =>
        TextButton(onPressed: pressed, child: const Text('Submit')),
  );
}

void main() {
  NyTest.init();

  setUp(() {
    _initNylo();
  });

  bool isLocked(WidgetTester tester) =>
      tester.widget<TextButton>(find.byType(TextButton)).onPressed == null;

  nyGroup('ButtonState onPressed', () {
    nyWidgetTest('locks while a void-declared async callback runs', (
      tester,
    ) async {
      /// Declared `void`, so the tear-off is typed `void Function()`. Calling
      /// it still returns a Future, and the Future is what has to count.
      final Completer<void> request = Completer<void>();
      int presses = 0;
      void submit() async {
        presses++;
        await request.future;
      }

      await tester.pumpNyWidget(_button(onPressed: submit));

      /// Two taps before the rebuild: the second lands on a button that has
      /// not been redrawn as locked yet.
      await tester.tap(find.byType(TextButton));
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(isLocked(tester), isTrue);
      expect(presses, 1);

      request.complete();
      await tester.pump();
      expect(isLocked(tester), isFalse);
    });

    nyWidgetTest('locks while a Future-returning callback runs', (
      tester,
    ) async {
      final Completer<void> request = Completer<void>();
      Future<void> submit() => request.future;

      await tester.pumpNyWidget(_button(onPressed: submit));
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(isLocked(tester), isTrue);

      request.complete();
      await tester.pump();
      expect(isLocked(tester), isFalse);
    });

    nyWidgetTest('does not lock for a synchronous callback', (tester) async {
      int presses = 0;
      void submit() {
        presses++;
      }

      await tester.pumpNyWidget(_button(onPressed: submit));
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(presses, 2);
      expect(isLocked(tester), isFalse);
    });
  });

  nyGroup('ButtonState submitForm', () {
    Future<void> pumpForm(
      WidgetTester tester,
      Function(dynamic data) onSubmit,
    ) async {
      await tester.pumpNyWidget(
        Material(
          child: Column(
            children: [
              EmailForm(),
              _button(submitForm: ('EmailForm', onSubmit)),
            ],
          ),
        ),
      );
    }

    nyWidgetTest('locks while a void-declared async onSubmit runs', (
      tester,
    ) async {
      final Completer<void> request = Completer<void>();
      dynamic submitted;
      void onSubmit(dynamic data) async {
        submitted = data;
        await request.future;
      }

      await pumpForm(tester, onSubmit);
      await tester.enterText(find.byType(EditableText), 'dev@nylo.dev');
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(submitted, {'email': 'dev@nylo.dev'});
      expect(isLocked(tester), isTrue);

      request.complete();
      await tester.pump();
      expect(isLocked(tester), isFalse);
    });

    nyWidgetTest('does not lock when the form fails validation', (
      tester,
    ) async {
      bool submitted = false;
      await pumpForm(tester, (data) async => submitted = true);

      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(submitted, isFalse);
      expect(isLocked(tester), isFalse);
    });
  });
}
