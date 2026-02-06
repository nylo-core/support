import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/dart_console/ny_dart_console.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('SpinnerStyle', () {
    nyTest('line should have 4 characters', () async {
      expect(SpinnerStyle.line, hasLength(4));
      expect(SpinnerStyle.line, ['|', '/', '-', '\\']);
    });

    nyTest('dots should have 10 characters', () async {
      expect(SpinnerStyle.dots, hasLength(10));
    });

    nyTest('bouncingBar should have 6 characters', () async {
      expect(SpinnerStyle.bouncingBar, hasLength(6));
    });

    nyTest('arrows should have 8 characters', () async {
      expect(SpinnerStyle.arrows, hasLength(8));
    });

    nyTest('circle should have 4 characters', () async {
      expect(SpinnerStyle.circle, hasLength(4));
    });

    nyTest('square should have 4 characters', () async {
      expect(SpinnerStyle.square, hasLength(4));
    });

    nyTest('clock should have 12 characters', () async {
      expect(SpinnerStyle.clock, hasLength(12));
    });

    nyTest('simpleDots should have 5 characters', () async {
      expect(SpinnerStyle.simpleDots, hasLength(5));
    });
  });

  nyGroup('Spinner', () {
    nyTest('should create with defaults', () async {
      final spinner = Spinner();
      expect(spinner.message, '');
      expect(spinner.intervalMs, 100);
      expect(spinner.spinnerCharacters, ['|', '/', '-', '\\']);
      expect(spinner.isRunning, isFalse);
    });

    nyTest('should create with custom message', () async {
      final spinner = Spinner(message: 'Loading...');
      expect(spinner.message, 'Loading...');
    });

    nyTest('should create with custom characters', () async {
      final spinner = Spinner(spinnerCharacters: SpinnerStyle.dots);
      expect(spinner.spinnerCharacters, SpinnerStyle.dots);
    });

    nyTest('should create with custom interval', () async {
      final spinner = Spinner(intervalMs: 200);
      expect(spinner.intervalMs, 200);
    });

    nyTest('isRunning should be false by default', () async {
      final spinner = Spinner();
      expect(spinner.isRunning, isFalse);
    });
  });
}
