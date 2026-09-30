import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

/// A bare NyState to call [NyBaseState.setLoading] on.
class LoadingProbe extends StatefulWidget {
  const LoadingProbe({super.key});

  @override
  createState() => _LoadingProbeState();
}

class _LoadingProbeState extends NyState<LoadingProbe> {
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

  Future<_LoadingProbeState> pumpProbe(WidgetTester tester) async {
    await tester.pumpNyWidget(const LoadingProbe());
    return tester.state<_LoadingProbeState>(find.byType(LoadingProbe));
  }

  nyGroup('setLoading', () {
    nyWidgetTest('tracks the loading state', (tester) async {
      final state = await pumpProbe(tester);

      state.setLoading(true, name: 'save');
      expect(state.isLoading(name: 'save'), isTrue);

      state.setLoading(false, name: 'save');
      expect(state.isLoading(name: 'save'), isFalse);
    });

    nyWidgetTest('is a no-op once the state is disposed', (tester) async {
      /// Async work that finished after its page had closed, such as a
      /// list's pull-to-refresh, called setState on a disposed state.
      final state = await pumpProbe(tester);
      await tester.pumpWidget(const SizedBox());

      expect(() => state.setLoading(false), returnsNormally);
    });
  });
}
