import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NyAppUsage', () {
    nyGroup('prefix', () {
      nyTest('should be ny_app_usage_', () async {
        expect(NyAppUsage.prefix, 'ny_app_usage_');
      });
    });

    nyGroup('key', () {
      nyTest('should prepend prefix to name', () async {
        expect(NyAppUsage.key('test'), 'ny_app_usage_test');
      });

      nyTest('should handle empty name', () async {
        expect(NyAppUsage.key(''), 'ny_app_usage_');
      });

      nyTest('should handle launch_count key', () async {
        expect(NyAppUsage.key('launch_count'), 'ny_app_usage_launch_count');
      });

      nyTest('should handle first_launch key', () async {
        expect(NyAppUsage.key('first_launch'), 'ny_app_usage_first_launch');
      });
    });
  });
}
