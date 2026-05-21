import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('PageTransitionSettings', () {
    nyGroup('default constructor', () {
      nyTest('should create with all null values', () async {
        const settings = PageTransitionSettings();

        expect(settings.childCurrent, isNull);
        expect(settings.context, isNull);
        expect(settings.inheritTheme, isNull);
        expect(settings.curve, isNull);
        expect(settings.alignment, isNull);
        expect(settings.duration, isNull);
        expect(settings.reverseDuration, isNull);
        expect(settings.fullscreenDialog, isNull);
        expect(settings.opaque, isNull);
        expect(settings.isIos, isNull);
        expect(settings.matchingBuilder, isNull);
      });

      nyTest('should create with custom duration', () async {
        const settings = PageTransitionSettings(
          duration: Duration(milliseconds: 500),
        );

        expect(settings.duration, const Duration(milliseconds: 500));
      });

      nyTest('should create with custom reverseDuration', () async {
        const settings = PageTransitionSettings(
          reverseDuration: Duration(milliseconds: 300),
        );

        expect(settings.reverseDuration, const Duration(milliseconds: 300));
      });

      nyTest('should create with custom curve', () async {
        const settings = PageTransitionSettings(curve: Curves.easeInOut);

        expect(settings.curve, Curves.easeInOut);
      });

      nyTest('should create with custom alignment', () async {
        const settings = PageTransitionSettings(alignment: Alignment.center);

        expect(settings.alignment, Alignment.center);
      });

      nyTest('should create with inheritTheme', () async {
        const settings = PageTransitionSettings(inheritTheme: true);

        expect(settings.inheritTheme, isTrue);
      });

      nyTest('should create with fullscreenDialog', () async {
        const settings = PageTransitionSettings(fullscreenDialog: true);

        expect(settings.fullscreenDialog, isTrue);
      });

      nyTest('should create with opaque', () async {
        const settings = PageTransitionSettings(opaque: true);

        expect(settings.opaque, isTrue);
      });

      nyTest('should create with isIos', () async {
        const settings = PageTransitionSettings(isIos: true);

        expect(settings.isIos, isTrue);
      });

      nyTest('should create with matchingBuilder', () async {
        const builder = CupertinoPageTransitionsBuilder();
        const settings = PageTransitionSettings(matchingBuilder: builder);

        expect(
          settings.matchingBuilder,
          isA<CupertinoPageTransitionsBuilder>(),
        );
      });

      nyTest('should create with childCurrent widget', () async {
        const widget = SizedBox(width: 100);
        const settings = PageTransitionSettings(childCurrent: widget);

        expect(settings.childCurrent, isA<SizedBox>());
      });
    });

    nyGroup('base constructor', () {
      nyTest('should create with default base values', () async {
        const settings = PageTransitionSettings.base();

        expect(settings.inheritTheme, isFalse);
        expect(settings.curve, Curves.easeInOut);
        expect(settings.fullscreenDialog, isFalse);
        expect(settings.opaque, isFalse);
        expect(
          settings.matchingBuilder,
          isA<CupertinoPageTransitionsBuilder>(),
        );
      });

      nyTest('should allow overriding base defaults', () async {
        const settings = PageTransitionSettings.base(
          inheritTheme: true,
          curve: Curves.bounceIn,
          fullscreenDialog: true,
          opaque: true,
          duration: Duration(seconds: 1),
        );

        expect(settings.inheritTheme, isTrue);
        expect(settings.curve, Curves.bounceIn);
        expect(settings.fullscreenDialog, isTrue);
        expect(settings.opaque, isTrue);
        expect(settings.duration, const Duration(seconds: 1));
      });
    });

    nyGroup('toString()', () {
      nyTest('should return readable string representation', () async {
        const settings = PageTransitionSettings(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );

        final str = settings.toString();

        expect(str, contains('PageTransitionSettings'));
        expect(str, contains('duration'));
        expect(str, contains('curve'));
      });
    });
  });

  nyGroup('TransitionType', () {
    nyGroup('fade', () {
      nyTest('should create fade transition', () async {
        final transition = TransitionType.fade();

        expect(transition.pageTransitionType, PageTransitionType.fade);
        expect(transition.pageTransitionSettings, isNotNull);
      });

      nyTest('should accept custom settings', () async {
        final transition = TransitionType.fade(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );

        expect(
          transition.pageTransitionSettings!.duration,
          const Duration(milliseconds: 500),
        );
        expect(transition.pageTransitionSettings!.curve, Curves.easeIn);
      });
    });

    nyGroup('rightToLeft', () {
      nyTest('should create rightToLeft transition', () async {
        final transition = TransitionType.rightToLeft();

        expect(transition.pageTransitionType, PageTransitionType.rightToLeft);
      });
    });

    nyGroup('leftToRight', () {
      nyTest('should create leftToRight transition', () async {
        final transition = TransitionType.leftToRight();

        expect(transition.pageTransitionType, PageTransitionType.leftToRight);
      });
    });

    nyGroup('topToBottom', () {
      nyTest('should create topToBottom transition', () async {
        final transition = TransitionType.topToBottom();

        expect(transition.pageTransitionType, PageTransitionType.topToBottom);
      });
    });

    nyGroup('bottomToTop', () {
      nyTest('should create bottomToTop transition', () async {
        final transition = TransitionType.bottomToTop();

        expect(transition.pageTransitionType, PageTransitionType.bottomToTop);
      });
    });

    nyGroup('scale', () {
      nyTest('should create scale transition with alignment', () async {
        final transition = TransitionType.scale(alignment: Alignment.center);

        expect(transition.pageTransitionType, PageTransitionType.scale);
        expect(transition.pageTransitionSettings!.alignment, Alignment.center);
      });
    });

    nyGroup('rotate', () {
      nyTest('should create rotate transition with alignment', () async {
        final transition = TransitionType.rotate(alignment: Alignment.topLeft);

        expect(transition.pageTransitionType, PageTransitionType.rotate);
        expect(transition.pageTransitionSettings!.alignment, Alignment.topLeft);
      });
    });

    nyGroup('size', () {
      nyTest('should create size transition with alignment', () async {
        final transition = TransitionType.size(
          alignment: Alignment.bottomRight,
        );

        expect(transition.pageTransitionType, PageTransitionType.size);
        expect(
          transition.pageTransitionSettings!.alignment,
          Alignment.bottomRight,
        );
      });
    });

    nyGroup('rightToLeftWithFade', () {
      nyTest('should create rightToLeftWithFade transition', () async {
        final transition = TransitionType.rightToLeftWithFade();

        expect(
          transition.pageTransitionType,
          PageTransitionType.rightToLeftWithFade,
        );
      });
    });

    nyGroup('leftToRightWithFade', () {
      nyTest('should create leftToRightWithFade transition', () async {
        final transition = TransitionType.leftToRightWithFade();

        expect(
          transition.pageTransitionType,
          PageTransitionType.leftToRightWithFade,
        );
      });
    });

    nyGroup('joined transitions', () {
      nyTest('should create leftToRightJoined transition', () async {
        final transition = TransitionType.leftToRightJoined(
          childCurrent: const SizedBox(),
        );

        expect(
          transition.pageTransitionType,
          PageTransitionType.leftToRightJoined,
        );
        expect(transition.pageTransitionSettings!.childCurrent, isNotNull);
      });

      nyTest('should create rightToLeftJoined transition', () async {
        final transition = TransitionType.rightToLeftJoined(
          childCurrent: const SizedBox(),
        );

        expect(
          transition.pageTransitionType,
          PageTransitionType.rightToLeftJoined,
        );
      });

      nyTest('should create topToBottomJoined transition', () async {
        final transition = TransitionType.topToBottomJoined(
          childCurrent: const SizedBox(),
        );

        expect(
          transition.pageTransitionType,
          PageTransitionType.topToBottomJoined,
        );
      });

      nyTest('should create bottomToTopJoined transition', () async {
        final transition = TransitionType.bottomToTopJoined(
          childCurrent: const SizedBox(),
        );

        expect(
          transition.pageTransitionType,
          PageTransitionType.bottomToTopJoined,
        );
      });
    });

    nyGroup('pop transitions', () {
      nyTest('should create leftToRightPop transition', () async {
        final transition = TransitionType.leftToRightPop(
          childCurrent: const SizedBox(),
        );

        expect(
          transition.pageTransitionType,
          PageTransitionType.leftToRightPop,
        );
      });

      nyTest('should create rightToLeftPop transition', () async {
        final transition = TransitionType.rightToLeftPop(
          childCurrent: const SizedBox(),
        );

        expect(
          transition.pageTransitionType,
          PageTransitionType.rightToLeftPop,
        );
      });

      nyTest('should create topToBottomPop transition', () async {
        final transition = TransitionType.topToBottomPop(
          childCurrent: const SizedBox(),
        );

        expect(
          transition.pageTransitionType,
          PageTransitionType.topToBottomPop,
        );
      });

      nyTest('should create bottomToTopPop transition', () async {
        final transition = TransitionType.bottomToTopPop(
          childCurrent: const SizedBox(),
        );

        expect(
          transition.pageTransitionType,
          PageTransitionType.bottomToTopPop,
        );
      });
    });

    nyGroup('shared axis transitions', () {
      nyTest('should create sharedAxisHorizontal transition', () async {
        final transition = TransitionType.sharedAxisHorizontal();

        expect(
          transition.pageTransitionType,
          PageTransitionType.sharedAxisHorizontal,
        );
      });

      nyTest('should create sharedAxisVertical transition', () async {
        final transition = TransitionType.sharedAxisVertical();

        expect(
          transition.pageTransitionType,
          PageTransitionType.sharedAxisVertical,
        );
      });

      nyTest('should create sharedAxisScale transition', () async {
        final transition = TransitionType.sharedAxisScale();

        expect(
          transition.pageTransitionType,
          PageTransitionType.sharedAxisScale,
        );
      });
    });

    nyGroup('theme transition', () {
      nyTest('should create theme transition', () async {
        final transition = TransitionType.theme();

        expect(transition.pageTransitionType, PageTransitionType.theme);
      });
    });
  });

  nyGroup('PageTransitionType enum', () {
    nyTest('should have all expected values', () async {
      expect(
        PageTransitionType.values,
        containsAll([
          PageTransitionType.theme,
          PageTransitionType.fade,
          PageTransitionType.rightToLeft,
          PageTransitionType.leftToRight,
          PageTransitionType.topToBottom,
          PageTransitionType.bottomToTop,
          PageTransitionType.scale,
          PageTransitionType.rotate,
          PageTransitionType.size,
          PageTransitionType.rightToLeftWithFade,
          PageTransitionType.leftToRightWithFade,
          PageTransitionType.leftToRightJoined,
          PageTransitionType.rightToLeftJoined,
          PageTransitionType.topToBottomJoined,
          PageTransitionType.bottomToTopJoined,
          PageTransitionType.leftToRightPop,
          PageTransitionType.rightToLeftPop,
          PageTransitionType.topToBottomPop,
          PageTransitionType.bottomToTopPop,
          PageTransitionType.sharedAxisHorizontal,
          PageTransitionType.sharedAxisVertical,
          PageTransitionType.sharedAxisScale,
        ]),
      );
    });
  });
}
