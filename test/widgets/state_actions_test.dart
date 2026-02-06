import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';
import 'package:nylo_support/testing/ny_testing.dart';

class ConcreteStateActions extends StateActions {
  ConcreteStateActions(super.state);
}

void main() {
  NyTest.init();

  nyGroup('StateActions', () {
    nyTest('should store state value', () async {
      final actions = ConcreteStateActions('test_state');
      expect(actions.state, 'test_state');
    });

    nyTest('should allow updating state', () async {
      final actions = ConcreteStateActions('initial');
      actions.state = 'updated';
      expect(actions.state, 'updated');
    });

    nyTest('should handle empty state', () async {
      final actions = ConcreteStateActions('');
      expect(actions.state, '');
    });
  });
}
