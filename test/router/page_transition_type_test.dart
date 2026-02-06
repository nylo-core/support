import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/router/src/page_transition/src/enum.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('PageTransitionType', () {
    nyTest('should have 22 values', () async {
      expect(PageTransitionType.values, hasLength(22));
    });

    nyTest('should contain all basic transitions', () async {
      expect(PageTransitionType.values, contains(PageTransitionType.theme));
      expect(PageTransitionType.values, contains(PageTransitionType.fade));
      expect(
        PageTransitionType.values,
        contains(PageTransitionType.rightToLeft),
      );
      expect(
        PageTransitionType.values,
        contains(PageTransitionType.leftToRight),
      );
      expect(
        PageTransitionType.values,
        contains(PageTransitionType.topToBottom),
      );
      expect(
        PageTransitionType.values,
        contains(PageTransitionType.bottomToTop),
      );
      expect(PageTransitionType.values, contains(PageTransitionType.scale));
      expect(PageTransitionType.values, contains(PageTransitionType.rotate));
      expect(PageTransitionType.values, contains(PageTransitionType.size));
    });

    nyTest('should contain fade variants', () async {
      expect(
        PageTransitionType.values,
        contains(PageTransitionType.rightToLeftWithFade),
      );
      expect(
        PageTransitionType.values,
        contains(PageTransitionType.leftToRightWithFade),
      );
    });

    nyTest('should contain joined variants', () async {
      expect(
        PageTransitionType.values,
        contains(PageTransitionType.leftToRightJoined),
      );
      expect(
        PageTransitionType.values,
        contains(PageTransitionType.rightToLeftJoined),
      );
      expect(
        PageTransitionType.values,
        contains(PageTransitionType.topToBottomJoined),
      );
      expect(
        PageTransitionType.values,
        contains(PageTransitionType.bottomToTopJoined),
      );
    });

    nyTest('should contain pop variants', () async {
      expect(
        PageTransitionType.values,
        contains(PageTransitionType.leftToRightPop),
      );
      expect(
        PageTransitionType.values,
        contains(PageTransitionType.rightToLeftPop),
      );
      expect(
        PageTransitionType.values,
        contains(PageTransitionType.topToBottomPop),
      );
      expect(
        PageTransitionType.values,
        contains(PageTransitionType.bottomToTopPop),
      );
    });

    nyTest('should contain shared axis variants', () async {
      expect(
        PageTransitionType.values,
        contains(PageTransitionType.sharedAxisHorizontal),
      );
      expect(
        PageTransitionType.values,
        contains(PageTransitionType.sharedAxisVertical),
      );
      expect(
        PageTransitionType.values,
        contains(PageTransitionType.sharedAxisScale),
      );
    });

    nyTest('enum index should be deterministic', () async {
      expect(PageTransitionType.theme.index, 0);
      expect(PageTransitionType.fade.index, 1);
    });
  });
}
