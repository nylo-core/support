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
  });
}
