import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('ColorOpacityExt', () {
    nyTest('setOpacity should return new color with given opacity', () async {
      final color = Color(0xFF0000FF);
      final result = color.setOpacity(0.5);
      expect(result.a, closeTo(0.5, 0.01));
    });

    nyTest('setOpacity 1.0 should return fully opaque color', () async {
      final color = Color(0xFF0000FF);
      final result = color.setOpacity(1.0);
      expect(result.a, closeTo(1.0, 0.01));
    });

    nyTest('setOpacity 0.0 should return fully transparent color', () async {
      final color = Color(0xFF0000FF);
      final result = color.setOpacity(0.0);
      expect(result.a, closeTo(0.0, 0.01));
    });
  });
}
