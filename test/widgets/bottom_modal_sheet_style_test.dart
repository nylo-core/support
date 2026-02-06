import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('BottomModalSheetStyle', () {
    nyTest('should create with no parameters', () async {
      final style = BottomModalSheetStyle();
      expect(style.backgroundColor, isNull);
      expect(style.barrierColor, isNull);
      expect(style.useRootNavigator, isFalse);
      expect(style.routeSettings, isNull);
      expect(style.titleStyle, isNull);
      expect(style.itemStyle, isNull);
      expect(style.clearButtonStyle, isNull);
    });

    nyTest('should default useRootNavigator to false', () async {
      final style = BottomModalSheetStyle();
      expect(style.useRootNavigator, isFalse);
    });

    nyTest('should accept useRootNavigator true', () async {
      final style = BottomModalSheetStyle(useRootNavigator: true);
      expect(style.useRootNavigator, isTrue);
    });

    nyTest('should accept routeSettings', () async {
      final settings = RouteSettings(name: '/test');
      final style = BottomModalSheetStyle(routeSettings: settings);
      expect(style.routeSettings, settings);
      expect(style.routeSettings!.name, '/test');
    });

    nyTest('should accept titleStyle', () async {
      final textStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
      final style = BottomModalSheetStyle(titleStyle: textStyle);
      expect(style.titleStyle, textStyle);
    });

    nyTest('should accept itemStyle', () async {
      final textStyle = TextStyle(fontSize: 14);
      final style = BottomModalSheetStyle(itemStyle: textStyle);
      expect(style.itemStyle, textStyle);
    });

    nyTest('should accept clearButtonStyle', () async {
      final textStyle = TextStyle(color: Colors.red);
      final style = BottomModalSheetStyle(clearButtonStyle: textStyle);
      expect(style.clearButtonStyle, textStyle);
    });
  });
}
