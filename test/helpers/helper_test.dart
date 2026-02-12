import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/src/helper.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  // ===========================================================================
  // nyHexColor tests
  // ===========================================================================

  nyGroup('nyHexColor', () {
    nyTest('should convert 6-digit hex to Color', () async {
      final color = nyHexColor('#FF0000');
      expect(color, isA<Color>());
      expect(color.toARGB32(), 0xFFFF0000);
    });

    nyTest('should handle hex without hash', () async {
      final color = nyHexColor('00FF00');
      expect(color.toARGB32(), 0xFF00FF00);
    });

    nyTest('should handle lowercase hex', () async {
      final color = nyHexColor('#ff0000');
      expect(color.toARGB32(), 0xFFFF0000);
    });

    nyTest('should handle 8-digit hex with alpha', () async {
      final color = nyHexColor('80FF0000');
      expect(color.toARGB32(), 0x80FF0000);
    });

    nyTest('should handle white', () async {
      final color = nyHexColor('#FFFFFF');
      expect(color.toARGB32(), 0xFFFFFFFF);
    });

    nyTest('should handle black', () async {
      final color = nyHexColor('#000000');
      expect(color.toARGB32(), 0xFF000000);
    });
  });

  // ===========================================================================
  // match tests
  // ===========================================================================

  nyGroup('match', () {
    nyTest('should return matched value from map', () async {
      final result = match<String>('a', () => {'a': 'Apple', 'b': 'Banana'});
      expect(result, 'Apple');
    });

    nyTest('should return default when value is null', () async {
      final result = match<String>(
        null,
        () => {'a': 'Apple'},
        defaultValue: 'Default',
      );
      expect(result, 'Default');
    });

    nyTest('should match integer keys', () async {
      final result = match<String>(1, () => {1: 'One', 2: 'Two'});
      expect(result, 'One');
    });
  });

  // ===========================================================================
  // now tests
  // ===========================================================================

  nyGroup('now', () {
    nyTest('should return current DateTime', () async {
      final before = DateTime.now();
      final result = now();
      final after = DateTime.now();
      expect(result.isAfter(before) || result.isAtSameMomentAs(before), isTrue);
      expect(result.isBefore(after) || result.isAtSameMomentAs(after), isTrue);
    });

    nyTest('should return DateTime type', () async {
      expect(now(), isA<DateTime>());
    });
  });

  // ===========================================================================
  // sleep tests
  // ===========================================================================

  nyGroup('sleep', () {
    nyTest('should delay execution', () async {
      final before = DateTime.now();
      await sleep(0, 100000); // 100ms
      final after = DateTime.now();
      final diff = after.difference(before).inMilliseconds;
      expect(diff, greaterThanOrEqualTo(50)); // Allow some tolerance
    });

    nyTest('should accept seconds parameter', () async {
      final before = DateTime.now();
      await sleep(0, 50000); // 50ms
      final after = DateTime.now();
      expect(after.isAfter(before), isTrue);
    });
  });
}
