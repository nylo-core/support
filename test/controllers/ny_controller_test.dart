import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/controllers/ny_controllers.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/src/event_bus/update_state.dart';

import 'mocks/mock_event_bus.dart';

/// Test implementation of NyController
class TestNyController extends NyController {
  TestNyController({super.context, super.request});
}

/// Test controller with singleton enabled
class SingletonTestController extends NyController {
  @override
  bool get singleton => true;
}

void main() {
  NyTest.init();

  late MockEventBus mockEventBus;

  nySetUp(() {
    mockEventBus = MockEventBus();
    Backpack.instance.save('event_bus', mockEventBus);
  });

  nyTearDown(() {
    mockEventBus.reset();
  });

  nyGroup('NyController', () {
    nyGroup('singleton', () {
      nyTest('returns false by default', () async {
        final controller = TestNyController();

        expect(controller.singleton, false);
      });

      nyTest('can be overridden to return true', () async {
        final controller = SingletonTestController();

        expect(controller.singleton, true);
      });
    });

    nyGroup('refreshPage()', () {
      nyTest('fires UpdateState event when state is set', () async {
        final controller = TestNyController();
        controller.state = 'TestPageState';

        controller.refreshPage();

        expect(mockEventBus.firedEvents.length, 1);
        expect(mockEventBus.firedEvents.first, isA<UpdateState>());

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.stateName, 'TestPageState');
        expect(event.data['action'], 'refresh-page');
      });

      nyTest('does nothing when state is null', () async {
        final controller = TestNyController();
        controller.state = null;

        controller.refreshPage();

        expect(mockEventBus.firedEvents, isEmpty);
      });
    });

    nyGroup('updatePageState()', () {
      nyTest('fires UpdateState with action and data', () async {
        final controller = TestNyController();
        controller.state = 'MyPageState';

        controller.updatePageState('custom-action', {'key': 'value'});

        expect(mockEventBus.firedEvents.length, 1);

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.stateName, 'MyPageState');
        expect(event.data['action'], 'custom-action');
        expect(event.data['data']['key'], 'value');
      });
    });

    nyGroup('pop()', () {
      nyTest('fires UpdateState with pop action when state is set', () async {
        final controller = TestNyController();
        controller.state = 'PopPageState';

        controller.pop(result: 'success');

        expect(mockEventBus.firedEvents.length, 1);

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.stateName, 'PopPageState');
        expect(event.data['action'], 'pop');
      });

      nyTest('does nothing when state is null', () async {
        final controller = TestNyController();
        controller.state = null;

        controller.pop();

        expect(mockEventBus.firedEvents, isEmpty);
      });
    });

    nyGroup('setState()', () {
      nyTest('fires UpdateState with set-state action', () async {
        final controller = TestNyController();
        controller.state = 'SetStatePageState';

        controller.setState(setState: () {});

        expect(mockEventBus.firedEvents.length, 1);

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.stateName, 'SetStatePageState');
        expect(event.data['action'], 'set-state');
      });

      nyTest('does nothing when state is null', () async {
        final controller = TestNyController();
        controller.state = null;

        controller.setState(setState: () {});

        expect(mockEventBus.firedEvents, isEmpty);
      });
    });

    nyGroup('toast methods', () {
      nyTest(
        'showToastSuccess fires UpdateState with toast-success action',
        () async {
          final controller = TestNyController();
          controller.state = 'ToastPageState';

          controller.showToastSuccess(description: 'Operation completed');

          expect(mockEventBus.firedEvents.length, 1);

          final event = mockEventBus.firedEvents.first as UpdateState;
          expect(event.stateName, 'ToastPageState');
          expect(event.data['action'], 'toast-success');
          expect(event.data['data']['description'], 'Operation completed');
          expect(event.data['data']['title'], 'Success');
        },
      );

      nyTest('showToastSuccess with custom title', () async {
        final controller = TestNyController();
        controller.state = 'ToastPageState';

        controller.showToastSuccess(
          title: 'Custom Title',
          description: 'Message',
        );

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.data['data']['title'], 'Custom Title');
      });

      nyTest('showToastDanger fires with toast-danger action', () async {
        final controller = TestNyController();
        controller.state = 'ToastPageState';

        controller.showToastDanger(description: 'Error occurred');

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.data['action'], 'toast-danger');
        expect(event.data['data']['title'], 'Error');
      });

      nyTest('showToastWarning fires with toast-warning action', () async {
        final controller = TestNyController();
        controller.state = 'ToastPageState';

        controller.showToastWarning(description: 'Be careful');

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.data['action'], 'toast-warning');
        expect(event.data['data']['title'], 'Warning');
      });

      nyTest('showToastInfo fires with toast-info action', () async {
        final controller = TestNyController();
        controller.state = 'ToastPageState';

        controller.showToastInfo(description: 'For your information');

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.data['action'], 'toast-info');
        expect(event.data['data']['title'], 'Info');
      });

      nyTest('showToastOops fires with toast-oops action', () async {
        final controller = TestNyController();
        controller.state = 'ToastPageState';

        controller.showToastOops(description: 'Something went wrong');

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.data['action'], 'toast-oops');
        expect(event.data['data']['title'], 'Oops');
      });

      nyTest('showToastSorry fires with toast-sorry action', () async {
        final controller = TestNyController();
        controller.state = 'ToastPageState';

        controller.showToastSorry(description: 'We apologize');

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.data['action'], 'toast-sorry');
        expect(event.data['data']['title'], 'Sorry');
      });

      nyTest('showToastCustom fires with toast-custom action', () async {
        final controller = TestNyController();
        controller.state = 'ToastPageState';

        controller.showToastCustom(
          title: 'Custom',
          description: 'Custom message',
          id: 'my-custom-toast',
        );

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.data['action'], 'toast-custom');
        expect(event.data['data']['id'], 'my-custom-toast');
      });

      nyTest('toast methods do nothing when state is null', () async {
        final controller = TestNyController();
        controller.state = null;

        controller.showToastSuccess(description: 'Message');
        controller.showToastDanger(description: 'Message');
        controller.showToastWarning(description: 'Message');
        controller.showToastInfo(description: 'Message');
        controller.showToastOops(description: 'Message');
        controller.showToastSorry(description: 'Message');
        controller.showToastCustom(description: 'Message');

        expect(mockEventBus.firedEvents, isEmpty);
      });
    });

    nyGroup('validate()', () {
      nyTest('fires UpdateState with validate action', () async {
        final controller = TestNyController();
        controller.state = 'ValidatePageState';

        controller.validate(
          rules: {'email': 'required|email'},
          data: {'email': 'test@example.com'},
          onSuccess: () {},
        );

        expect(mockEventBus.firedEvents.length, 1);

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.stateName, 'ValidatePageState');
        expect(event.data['action'], 'validate');
        expect(event.data['data']['rules'], {'email': 'required|email'});
        expect(event.data['data']['data'], {'email': 'test@example.com'});
      });

      nyTest('passes all validation parameters', () async {
        final controller = TestNyController();
        controller.state = 'ValidatePageState';
        var onFailureCalled = false;

        controller.validate(
          rules: {'name': 'required'},
          data: {'name': 'John'},
          messages: {'name.required': 'Name is required'},
          showAlert: false,
          alertDuration: const Duration(seconds: 5),
          alertStyle: 'danger',
          onSuccess: () {},
          onFailure: (e) {
            onFailureCalled = true;
          },
          lockRelease: 'validate-lock',
        );

        final event = mockEventBus.firedEvents.first as UpdateState;
        final eventData = event.data['data'];

        expect(eventData['rules'], {'name': 'required'});
        expect(eventData['messages'], {'name.required': 'Name is required'});
        expect(eventData['showAlert'], false);
        expect(eventData['alertDuration'], const Duration(seconds: 5));
        expect(eventData['alertStyle'], 'danger');
        expect(eventData['lockRelease'], 'validate-lock');
        expect(eventData['onSuccess'], isNotNull);
        expect(eventData['onFailure'], isNotNull);
      });
    });

    nyGroup('changeLanguage()', () {
      nyTest('fires UpdateState with change-language action', () async {
        final controller = TestNyController();
        controller.state = 'LanguagePageState';

        controller.changeLanguage('es');

        expect(mockEventBus.firedEvents.length, 1);

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.stateName, 'LanguagePageState');
        expect(event.data['action'], 'change-language');
        expect(event.data['data']['language'], 'es');
        expect(event.data['data']['restartState'], true);
      });

      nyTest('respects restartState parameter', () async {
        final controller = TestNyController();
        controller.state = 'LanguagePageState';

        controller.changeLanguage('fr', restartState: false);

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.data['data']['restartState'], false);
      });

      nyTest('does nothing when state is null', () async {
        final controller = TestNyController();
        controller.state = null;

        controller.changeLanguage('de');

        expect(mockEventBus.firedEvents, isEmpty);
      });
    });

    nyGroup('lockRelease()', () {
      nyTest('fires UpdateState with lock-release action', () async {
        final controller = TestNyController();
        controller.state = 'LockPageState';

        controller.lockRelease('submit-form', perform: () {});

        expect(mockEventBus.firedEvents.length, 1);

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.stateName, 'LockPageState');
        expect(event.data['action'], 'lock-release');
        expect(event.data['data']['name'], 'submit-form');
        expect(event.data['data']['shouldSetState'], true);
      });

      nyTest('respects shouldSetState parameter', () async {
        final controller = TestNyController();
        controller.state = 'LockPageState';

        controller.lockRelease(
          'async-task',
          perform: () {},
          shouldSetState: false,
        );

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.data['data']['shouldSetState'], false);
      });

      nyTest('does nothing when state is null', () async {
        final controller = TestNyController();
        controller.state = null;

        controller.lockRelease('task', perform: () {});

        expect(mockEventBus.firedEvents, isEmpty);
      });
    });

    nyGroup('confirmAction()', () {
      nyTest('fires UpdateState with confirm-action action', () async {
        final controller = TestNyController();
        controller.state = 'ConfirmPageState';

        controller.confirmAction(
          () {},
          title: 'Are you sure?',
          dismissText: 'No, cancel',
        );

        expect(mockEventBus.firedEvents.length, 1);

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.stateName, 'ConfirmPageState');
        expect(event.data['action'], 'confirm-action');
        expect(event.data['data']['title'], 'Are you sure?');
        expect(event.data['data']['dismissText'], 'No, cancel');
      });

      nyTest('uses default dismissText', () async {
        final controller = TestNyController();
        controller.state = 'ConfirmPageState';

        controller.confirmAction(() {}, title: 'Delete item?');

        final event = mockEventBus.firedEvents.first as UpdateState;
        expect(event.data['data']['dismissText'], 'Cancel');
      });

      nyTest('does nothing when state is null', () async {
        final controller = TestNyController();
        controller.state = null;

        controller.confirmAction(() {}, title: 'Confirm?');

        expect(mockEventBus.firedEvents, isEmpty);
      });
    });

    nyGroup('inheritance from BaseController', () {
      nyTest('inherits data() method', () async {
        final request = NyRequest(
          currentRoute: '/test',
          args: NyArgument({'id': 42}),
        );
        final controller = TestNyController(request: request);

        final result = controller.data<Map<String, dynamic>>();

        expect(result, isNotNull);
        expect(result!['id'], 42);
      });

      nyTest('inherits queryParameters() method', () async {
        final request = NyRequest(
          currentRoute: '/test',
          queryParameters: NyQueryParameters({'sort': 'desc'}),
        );
        final controller = TestNyController(request: request);

        final result = controller.queryParameters(key: 'sort');

        expect(result, 'desc');
      });

      nyTest('inherits routeGuards property', () async {
        final controller = TestNyController();

        expect(controller.routeGuards, isEmpty);
        expect(controller.routeGuards, isA<List<RouteGuard>>());
      });

      nyWidgetTest('inherits construct() method', (tester) async {
        late BuildContext capturedContext;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox();
              },
            ),
          ),
        );

        final controller = TestNyController();
        await controller.construct(capturedContext);

        expect(controller.context, capturedContext);
      });
    });
  });
}
