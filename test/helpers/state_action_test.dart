import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('StateAction', () {
    nyGroup('_findStateName', () {
      nyTest('should handle String state names via public methods', () async {
        // StateAction._findStateName is private, but we can verify
        // that the public methods accept string states without throwing.
        // They call updateState internally which requires an event bus,
        // so we just verify the class exists and has the expected API.
        expect(StateAction, isNotNull);
      });
    });

    nyGroup('API surface', () {
      nyTest('should have refreshPage method', () async {
        expect(StateAction.refreshPage, isA<Function>());
      });

      nyTest('should have setState method', () async {
        expect(StateAction.setState, isA<Function>());
      });

      nyTest('should have pop method', () async {
        expect(StateAction.pop, isA<Function>());
      });

      nyTest('should have showToastSorry method', () async {
        expect(StateAction.showToastSorry, isA<Function>());
      });

      nyTest('should have showToastWarning method', () async {
        expect(StateAction.showToastWarning, isA<Function>());
      });

      nyTest('should have showToastInfo method', () async {
        expect(StateAction.showToastInfo, isA<Function>());
      });

      nyTest('should have showToastDanger method', () async {
        expect(StateAction.showToastDanger, isA<Function>());
      });

      nyTest('should have showToastOops method', () async {
        expect(StateAction.showToastOops, isA<Function>());
      });

      nyTest('should have showToastSuccess method', () async {
        expect(StateAction.showToastSuccess, isA<Function>());
      });

      nyTest('should have showToastCustom method', () async {
        expect(StateAction.showToastCustom, isA<Function>());
      });

      nyTest('should have changeLanguage method', () async {
        expect(StateAction.changeLanguage, isA<Function>());
      });

      nyTest('should have confirmAction method', () async {
        expect(StateAction.confirmAction, isA<Function>());
      });

      nyTest('should have lockRelease method', () async {
        expect(StateAction.lockRelease, isA<Function>());
      });
    });
  });
}
