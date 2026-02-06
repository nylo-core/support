import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('UrlLaunchModeType', () {
    nyTest('should have all expected values', () async {
      expect(UrlLaunchModeType.values, hasLength(4));
      expect(
        UrlLaunchModeType.values,
        contains(UrlLaunchModeType.externalApplication),
      );
      expect(
        UrlLaunchModeType.values,
        contains(UrlLaunchModeType.inAppWebView),
      );
      expect(
        UrlLaunchModeType.values,
        contains(UrlLaunchModeType.inAppBrowserView),
      );
      expect(
        UrlLaunchModeType.values,
        contains(UrlLaunchModeType.platformDefault),
      );
    });

    nyTest('externalApplication should be the first value', () async {
      expect(
        UrlLaunchModeType.values[0],
        UrlLaunchModeType.externalApplication,
      );
    });
  });
}
