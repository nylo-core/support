import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/local_storage/ny_local_storage.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  setUp(() {
    Nylo.isTestMode = true;
  });

  tearDown(() async {
    await NyStorage.deleteAll();
    Nylo.isTestMode = true;
  });

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
      nyTest('should return the full prefixed storage key', () async {
        expect(
          NyScheduler.getKeyTaskOnce('myTask'),
          'ny_scheduler_myTask_once',
        );
      });

      nyTest('should handle empty name', () async {
        expect(NyScheduler.getKeyTaskOnce(''), 'ny_scheduler__once');
      });

      nyTest(
        'returned key matches the key actually written by taskOnce',
        () async {
          int calls = 0;
          await NyScheduler.taskOnce('match_test', () async => calls++);
          expect(calls, 1);

          final raw = await FlutterSecureStorage().read(
            key: NyScheduler.getKeyTaskOnce('match_test'),
          );
          expect(raw, 'true');
        },
      );
    });

    nyGroup('hasExecutedTaskOnce', () {
      nyTest('returns false before the task runs', () async {
        expect(await NyScheduler.hasExecutedTaskOnce('not_yet'), false);
      });

      nyTest('returns true after taskOnce completes', () async {
        await NyScheduler.taskOnce('has_run', () async {});
        expect(await NyScheduler.hasExecutedTaskOnce('has_run'), true);
      });
    });

    nyGroup('clearTaskOnce', () {
      nyTest('allows a once-task to run again after clearing', () async {
        int calls = 0;
        Future<void> work() async => calls++;

        await NyScheduler.taskOnce('rerun_me', work);
        await NyScheduler.taskOnce('rerun_me', work);
        expect(calls, 1);

        await NyScheduler.clearTaskOnce('rerun_me');
        expect(await NyScheduler.hasExecutedTaskOnce('rerun_me'), false);

        await NyScheduler.taskOnce('rerun_me', work);
        expect(calls, 2);
      });

      nyTest('is a no-op when the task was never executed', () async {
        await NyScheduler.clearTaskOnce('never_existed');
        expect(await NyScheduler.hasExecutedTaskOnce('never_existed'), false);
      });
    });

    nyGroup('developer-facing reset via NyStorage.delete', () {
      nyTest(
        'NyStorage.delete(getKeyTaskOnce(name)) resets the task',
        () async {
          int calls = 0;
          await NyScheduler.taskOnce('via_storage', () async => calls++);
          expect(calls, 1);

          await NyStorage.delete(NyScheduler.getKeyTaskOnce('via_storage'));
          expect(await NyScheduler.hasExecutedTaskOnce('via_storage'), false);

          await NyScheduler.taskOnce('via_storage', () async => calls++);
          expect(calls, 2);
        },
      );
    });
  });
}
