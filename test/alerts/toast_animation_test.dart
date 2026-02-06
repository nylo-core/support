import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/alerts/ny_alerts.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('ToastAnimationType', () {
    nyTest('has all expected animation types', () async {
      expect(
        ToastAnimationType.values,
        containsAll([
          ToastAnimationType.fade,
          ToastAnimationType.scale,
          ToastAnimationType.slideFromTop,
          ToastAnimationType.slideFromTopFade,
          ToastAnimationType.slideFromBottom,
          ToastAnimationType.slideFromBottomFade,
          ToastAnimationType.slideFromLeft,
          ToastAnimationType.slideFromLeftFade,
          ToastAnimationType.slideFromRight,
          ToastAnimationType.slideFromRightFade,
          ToastAnimationType.fadeScale,
          ToastAnimationType.rotate,
          ToastAnimationType.fadeRotate,
          ToastAnimationType.none,
        ]),
      );
    });

    nyTest('has exactly 14 animation types', () async {
      expect(ToastAnimationType.values.length, 14);
    });
  });

  nyGroup('ToastAnimation', () {
    nyGroup('none constructor', () {
      nyTest('creates with correct type', () async {
        const animation = ToastAnimation.none();

        expect(animation.type, ToastAnimationType.none);
        expect(animation.duration, isNull);
        expect(animation.curve, isNull);
      });
    });

    nyGroup('fade factory', () {
      nyTest('creates with default values', () async {
        final animation = ToastAnimation.fade();

        expect(animation.type, ToastAnimationType.fade);
        expect(animation.duration, isNull);
        expect(animation.curve, isNull);
      });

      nyTest('creates with custom duration', () async {
        final animation = ToastAnimation.fade(
          duration: const Duration(milliseconds: 300),
        );

        expect(animation.type, ToastAnimationType.fade);
        expect(animation.duration, const Duration(milliseconds: 300));
        expect(animation.curve, isNull);
      });

      nyTest('creates with custom curve', () async {
        final animation = ToastAnimation.fade(curve: Curves.easeOutBack);

        expect(animation.type, ToastAnimationType.fade);
        expect(animation.duration, isNull);
        expect(animation.curve, Curves.easeOutBack);
      });

      nyTest('creates with all custom values', () async {
        final animation = ToastAnimation.fade(
          duration: const Duration(milliseconds: 500),
          curve: Curves.bounceOut,
        );

        expect(animation.type, ToastAnimationType.fade);
        expect(animation.duration, const Duration(milliseconds: 500));
        expect(animation.curve, Curves.bounceOut);
      });
    });

    nyGroup('scale factory', () {
      nyTest('creates with correct type', () async {
        final animation = ToastAnimation.scale();

        expect(animation.type, ToastAnimationType.scale);
      });

      nyTest('creates with custom values', () async {
        final animation = ToastAnimation.scale(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        );

        expect(animation.duration, const Duration(milliseconds: 200));
        expect(animation.curve, Curves.easeIn);
      });
    });

    nyGroup('slideFromTop factory', () {
      nyTest('creates with correct type', () async {
        final animation = ToastAnimation.slideFromTop();

        expect(animation.type, ToastAnimationType.slideFromTop);
      });

      nyTest('creates with custom values', () async {
        final animation = ToastAnimation.slideFromTop(
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
        );

        expect(animation.duration, const Duration(milliseconds: 400));
        expect(animation.curve, Curves.elasticOut);
      });
    });

    nyGroup('slideFromTopFade factory', () {
      nyTest('creates with correct type', () async {
        final animation = ToastAnimation.slideFromTopFade();

        expect(animation.type, ToastAnimationType.slideFromTopFade);
      });
    });

    nyGroup('slideFromBottom factory', () {
      nyTest('creates with correct type', () async {
        final animation = ToastAnimation.slideFromBottom();

        expect(animation.type, ToastAnimationType.slideFromBottom);
      });
    });

    nyGroup('slideFromBottomFade factory', () {
      nyTest('creates with correct type', () async {
        final animation = ToastAnimation.slideFromBottomFade();

        expect(animation.type, ToastAnimationType.slideFromBottomFade);
      });
    });

    nyGroup('slideFromLeft factory', () {
      nyTest('creates with correct type', () async {
        final animation = ToastAnimation.slideFromLeft();

        expect(animation.type, ToastAnimationType.slideFromLeft);
      });
    });

    nyGroup('slideFromLeftFade factory', () {
      nyTest('creates with correct type', () async {
        final animation = ToastAnimation.slideFromLeftFade();

        expect(animation.type, ToastAnimationType.slideFromLeftFade);
      });
    });

    nyGroup('slideFromRight factory', () {
      nyTest('creates with correct type', () async {
        final animation = ToastAnimation.slideFromRight();

        expect(animation.type, ToastAnimationType.slideFromRight);
      });
    });

    nyGroup('slideFromRightFade factory', () {
      nyTest('creates with correct type', () async {
        final animation = ToastAnimation.slideFromRightFade();

        expect(animation.type, ToastAnimationType.slideFromRightFade);
      });
    });

    nyGroup('fadeScale factory', () {
      nyTest('creates with correct type', () async {
        final animation = ToastAnimation.fadeScale();

        expect(animation.type, ToastAnimationType.fadeScale);
      });

      nyTest('creates with custom values', () async {
        final animation = ToastAnimation.fadeScale(
          duration: const Duration(milliseconds: 350),
          curve: Curves.fastOutSlowIn,
        );

        expect(animation.duration, const Duration(milliseconds: 350));
        expect(animation.curve, Curves.fastOutSlowIn);
      });
    });

    nyGroup('rotate factory', () {
      nyTest('creates with correct type', () async {
        final animation = ToastAnimation.rotate();

        expect(animation.type, ToastAnimationType.rotate);
      });
    });

    nyGroup('fadeRotate factory', () {
      nyTest('creates with correct type', () async {
        final animation = ToastAnimation.fadeRotate();

        expect(animation.type, ToastAnimationType.fadeRotate);
      });
    });

    nyGroup('bounceInFromTop factory', () {
      nyTest('creates with correct type and curve', () async {
        final animation = ToastAnimation.bounceInFromTop();

        expect(animation.type, ToastAnimationType.slideFromTop);
        expect(animation.duration, const Duration(milliseconds: 600));
        expect(animation.curve, Curves.elasticOut);
      });

      nyTest('allows custom duration', () async {
        final animation = ToastAnimation.bounceInFromTop(
          duration: const Duration(milliseconds: 800),
        );

        expect(animation.duration, const Duration(milliseconds: 800));
        expect(animation.curve, Curves.elasticOut);
      });
    });

    nyGroup('bounceInFromBottom factory', () {
      nyTest('creates with correct type and curve', () async {
        final animation = ToastAnimation.bounceInFromBottom();

        expect(animation.type, ToastAnimationType.slideFromBottom);
        expect(animation.duration, const Duration(milliseconds: 600));
        expect(animation.curve, Curves.elasticOut);
      });
    });

    nyGroup('bounceIn factory', () {
      nyTest('creates with scale type and elastic curve', () async {
        final animation = ToastAnimation.bounceIn();

        expect(animation.type, ToastAnimationType.scale);
        expect(animation.duration, const Duration(milliseconds: 500));
        expect(animation.curve, Curves.elasticOut);
      });
    });

    nyGroup('springFromTop factory', () {
      nyTest('creates with correct type and curve', () async {
        final animation = ToastAnimation.springFromTop();

        expect(animation.type, ToastAnimationType.slideFromTopFade);
        expect(animation.duration, const Duration(milliseconds: 400));
        expect(animation.curve, Curves.easeOutBack);
      });
    });

    nyGroup('springFromBottom factory', () {
      nyTest('creates with correct type and curve', () async {
        final animation = ToastAnimation.springFromBottom();

        expect(animation.type, ToastAnimationType.slideFromBottomFade);
        expect(animation.duration, const Duration(milliseconds: 400));
        expect(animation.curve, Curves.easeOutBack);
      });
    });

    nyGroup('copyWith', () {
      nyTest('preserves unchanged fields', () async {
        final original = ToastAnimation.fade(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );

        final copied = original.copyWith();

        expect(copied.type, original.type);
        expect(copied.duration, original.duration);
        expect(copied.curve, original.curve);
      });

      nyTest('updates specified fields only', () async {
        final original = ToastAnimation.scale(
          duration: const Duration(milliseconds: 200),
        );

        final copied = original.copyWith(
          duration: const Duration(milliseconds: 500),
        );

        expect(copied.type, ToastAnimationType.scale);
        expect(copied.duration, const Duration(milliseconds: 500));
        expect(copied.curve, isNull);
      });

      nyTest('can update type', () async {
        final original = ToastAnimation.fade();

        final copied = original.copyWith(type: ToastAnimationType.slideFromTop);

        expect(copied.type, ToastAnimationType.slideFromTop);
      });

      nyTest('can update all fields', () async {
        final original = ToastAnimation.fade();

        final copied = original.copyWith(
          type: ToastAnimationType.fadeScale,
          duration: const Duration(milliseconds: 600),
          curve: Curves.bounceInOut,
        );

        expect(copied.type, ToastAnimationType.fadeScale);
        expect(copied.duration, const Duration(milliseconds: 600));
        expect(copied.curve, Curves.bounceInOut);
      });

      nyTest('does not mutate original', () async {
        final original = ToastAnimation.scale(
          duration: const Duration(milliseconds: 250),
          curve: Curves.linear,
        );

        original.copyWith(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.decelerate,
        );

        expect(original.duration, const Duration(milliseconds: 250));
        expect(original.curve, Curves.linear);
      });
    });
  });

  nyGroup('ToastMeta with animation', () {
    nyTest('creates with null animation by default', () async {
      final meta = ToastMeta();

      expect(meta.animation, isNull);
    });

    nyTest('creates with custom animation', () async {
      final animation = ToastAnimation.slideFromTopFade(
        duration: const Duration(milliseconds: 300),
      );

      final meta = ToastMeta(animation: animation);

      expect(meta.animation, isNotNull);
      expect(meta.animation!.type, ToastAnimationType.slideFromTopFade);
      expect(meta.animation!.duration, const Duration(milliseconds: 300));
    });

    nyTest('copyWith preserves animation when not specified', () async {
      final meta = ToastMeta(title: 'Test', animation: ToastAnimation.scale());

      final copied = meta.copyWith(title: 'New Title');

      expect(copied.animation, isNotNull);
      expect(copied.animation!.type, ToastAnimationType.scale);
    });

    nyTest('copyWith can update animation', () async {
      final meta = ToastMeta(animation: ToastAnimation.fade());

      final copied = meta.copyWith(
        animation: ToastAnimation.rotate(curve: Curves.easeInOut),
      );

      expect(copied.animation!.type, ToastAnimationType.rotate);
      expect(copied.animation!.curve, Curves.easeInOut);
    });
  });
}
