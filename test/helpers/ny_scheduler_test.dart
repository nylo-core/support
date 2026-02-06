import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NyScheduler', () {
    nyGroup('prefix', () {
      nyTest('should be ny_scheduler_', () async {
        expect(NyScheduler.prefix, 'ny_scheduler_');
      });
    });

    nyGroup('key', () {
      nyTest('should prepend prefix to name', () async {
        expect(NyScheduler.key('test'), 'ny_scheduler_test');
      });

      nyTest('should handle empty name', () async {
        expect(NyScheduler.key(''), 'ny_scheduler_');
      });

      nyTest('should handle complex names', () async {
        expect(NyScheduler.key('my_task_daily'), 'ny_scheduler_my_task_daily');
      });
    });

    nyGroup('getKeyTaskOnce', () {
      nyTest('should append _once to name', () async {
        expect(NyScheduler.getKeyTaskOnce('myTask'), 'myTask_once');
      });

      nyTest('should handle empty name', () async {
        expect(NyScheduler.getKeyTaskOnce(''), '_once');
      });
    });
  });
}
