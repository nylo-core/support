import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

/// A one-field form, so validation can pass or fail on demand.
class EmailForm extends NyFormWidget {
  EmailForm({super.key});

  static NyFormActions get actions => const NyFormActions('EmailForm');

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

void main() {
  NyTest.init();

  setUp(() {
    _initNylo();
  });

  Future<void> pumpForm(WidgetTester tester, {String? email}) async {
    await tester.pumpNyWidget(Material(child: EmailForm()));
    if (email != null) {
      await tester.enterText(find.byType(EditableText), email);
    }
  }

  nyGroup('NyFormActions.submit', () {
    nyWidgetTest('completes once an async onSuccess has finished', (
      tester,
    ) async {
      await pumpForm(tester, email: 'dev@nylo.dev');
      final Completer<void> request = Completer<void>();
      dynamic submitted;
      bool completed = false;

      unawaited(
        EmailForm.actions
            .submit(
              onSuccess: (data) {
                submitted = data;
                return request.future;
              },
            )
            .then((_) => completed = true),
      );
      await tester.pump();
      expect(submitted, {'email': 'dev@nylo.dev'});
      expect(completed, isFalse);

      request.complete();
      await tester.pump();
      expect(completed, isTrue);
    });

    nyWidgetTest('completes after reporting a failed validation', (
      tester,
    ) async {
      await pumpForm(tester);
      bool succeeded = false;
      List<FormValidationError>? errors;

      await EmailForm.actions.submit(
        onSuccess: (_) => succeeded = true,
        onFailure: (e) => errors = e,
        showToastError: false,
      );

      expect(succeeded, isFalse);
      expect(errors, isNotEmpty);
    });

    nyWidgetTest('completes with the error onSuccess throws', (tester) async {
      await pumpForm(tester, email: 'dev@nylo.dev');

      await expectLater(
        EmailForm.actions.submit(
          onSuccess: (_) async => throw StateError('request failed'),
        ),
        throwsStateError,
      );
    });

    nyWidgetTest('completes straight away when no such form is mounted', (
      tester,
    ) async {
      /// Nothing would ever answer the submit, so a Future waiting on it
      /// would never complete - and a button waiting on that would stay
      /// locked for good.
      await pumpForm(tester, email: 'dev@nylo.dev');
      await tester.pumpWidget(const SizedBox());
      bool succeeded = false;

      await EmailForm.actions.submit(onSuccess: (_) => succeeded = true);

      expect(succeeded, isFalse);
    });

    nyWidgetTest('keeps a ButtonState locked while onSuccess runs', (
      tester,
    ) async {
      final Completer<void> request = Completer<void>();
      await tester.pumpNyWidget(
        Material(
          child: Column(
            children: [
              EmailForm(),
              ButtonState(
                onSubmit: (
                  () => EmailForm.actions.submit(
                    onSuccess: (_) => request.future,
                  ),
                  null,
                ),
                loadingStyle: const LoadingStyle.none(),
                child: (pressed) =>
                    TextButton(onPressed: pressed, child: const Text('Submit')),
              ),
            ],
          ),
        ),
      );
      bool isLocked() =>
          tester.widget<TextButton>(find.byType(TextButton)).onPressed == null;

      await tester.enterText(find.byType(EditableText), 'dev@nylo.dev');
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(isLocked(), isTrue);

      request.complete();
      await tester.pump();
      expect(isLocked(), isFalse);
    });
  });
}
