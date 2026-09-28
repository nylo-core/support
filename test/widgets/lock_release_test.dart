import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

/// A bare NyState to call [NyBaseState.lockRelease] on.
class LockProbe extends StatefulWidget {
  const LockProbe({super.key});

  @override
  createState() => _LockProbeState();
}

class _LockProbeState extends NyState<LockProbe> {
  @override
  Widget view(BuildContext context) => const SizedBox();
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

  Future<_LockProbeState> pumpProbe(WidgetTester tester) async {
    await tester.pumpNyWidget(const LockProbe());
    return tester.state<_LockProbeState>(find.byType(LockProbe));
  }

  nyGroup('lockRelease', () {
    nyWidgetTest('holds the lock until perform has finished', (tester) async {
      final state = await pumpProbe(tester);
      final Completer<void> work = Completer<void>();

      final Future<void> released = state.lockRelease(
        'save',
        perform: () => work.future,
      );
      expect(state.isLocked('save'), isTrue);

      work.complete();
      await released;
      expect(state.isLocked('save'), isFalse);
    });

    nyWidgetTest('releases the lock when perform throws an Error', (
      tester,
    ) async {
      /// Only an Exception was caught, so anything else skipped the release
      /// and left the lock - and a ButtonState drawn from it - held for good.
      final state = await pumpProbe(tester);

      await expectLater(
        state.lockRelease(
          'save',
          perform: () async => throw StateError('save failed'),
        ),
        throwsStateError,
      );
      expect(state.isLocked('save'), isFalse);
    });

    nyWidgetTest('logs an Exception and releases the lock', (tester) async {
      final state = await pumpProbe(tester);

      await state.lockRelease(
        'save',
        perform: () async => throw Exception('save failed'),
      );
      expect(state.isLocked('save'), isFalse);
    });

    nyWidgetTest('logs an Exception with its stack trace', (tester) async {
      /// Only `e.toString()` was logged, so where it failed was lost.
      final state = await pumpProbe(tester);
      final List<NyLogEntry> entries = [];
      void listener(NyLogEntry entry) => entries.add(entry);
      NyLogger.addListener(listener);
      addTearDown(() => NyLogger.removeListener(listener));

      await state.lockRelease(
        'save',
        perform: () async => throw Exception('save failed'),
      );

      final NyLogEntry entry = entries.lastWhere((e) => e.type == 'error');
      expect(entry.message, contains('save failed'));
      expect(entry.stackTrace, isNotNull);
    });

    nyWidgetTest('passes an Exception to onError once the lock is released', (
      tester,
    ) async {
      /// An Exception was only ever logged, so a caller had no way to tell
      /// the user it failed or undo an optimistic change.
      final state = await pumpProbe(tester);
      final Exception failure = Exception('save failed');
      Object? received;
      StackTrace? receivedStack;
      bool? lockedDuringOnError;

      await state.lockRelease(
        'save',
        perform: () async => throw failure,
        onError: (error, stackTrace) {
          received = error;
          receivedStack = stackTrace;
          lockedDuringOnError = state.isLocked('save');
        },
      );

      expect(received, same(failure));
      expect(receivedStack, isNotNull);
      // Released first, so onError can offer to try again.
      expect(lockedDuringOnError, isFalse);
    });

    nyWidgetTest('lets onError run the same lock again', (tester) async {
      final state = await pumpProbe(tester);
      int attempts = 0;

      Future<void> save() => state.lockRelease(
        'save',
        perform: () async {
          attempts++;
          if (attempts == 1) throw Exception('offline');
        },
        onError: (error, stackTrace) => save(),
      );

      await save();
      await tester.pump();
      expect(attempts, 2);
      expect(state.isLocked('save'), isFalse);
    });

    nyWidgetTest('still rethrows an Error, without calling onError', (
      tester,
    ) async {
      final state = await pumpProbe(tester);
      bool onErrorCalled = false;

      await expectLater(
        state.lockRelease(
          'save',
          perform: () async => throw StateError('bug'),
          onError: (error, stackTrace) => onErrorCalled = true,
        ),
        throwsStateError,
      );
      expect(onErrorCalled, isFalse);
      expect(state.isLocked('save'), isFalse);
    });

    nyWidgetTest('does not call onError when perform succeeds', (tester) async {
      final state = await pumpProbe(tester);
      bool onErrorCalled = false;

      await state.lockRelease(
        'save',
        perform: () async {},
        onError: (error, stackTrace) => onErrorCalled = true,
      );
      expect(onErrorCalled, isFalse);
    });
  });
}
