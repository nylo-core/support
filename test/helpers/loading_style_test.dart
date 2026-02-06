import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  // ═══════════════════════════════════════════════════════════════════════════
  // LoadingStyleType Enum Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('LoadingStyleType', () {
    nyTest('should have normal type', () async {
      expect(LoadingStyleType.normal, isNotNull);
    });

    nyTest('should have skeletonizer type', () async {
      expect(LoadingStyleType.skeletonizer, isNotNull);
    });

    nyTest('should have none type', () async {
      expect(LoadingStyleType.none, isNotNull);
    });

    nyTest('should have three types total', () async {
      expect(LoadingStyleType.values.length, 3);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SkeletonizerEffect Enum Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('SkeletonizerEffect', () {
    nyTest('should have shimmer effect', () async {
      expect(SkeletonizerEffect.shimmer, isNotNull);
    });

    nyTest('should have solid effect', () async {
      expect(SkeletonizerEffect.solid, isNotNull);
    });

    nyTest('should have pulse effect', () async {
      expect(SkeletonizerEffect.pulse, isNotNull);
    });

    nyTest('should have three effects total', () async {
      expect(SkeletonizerEffect.values.length, 3);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // LoadingStyle.normal Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('LoadingStyle.normal', () {
    nyTest('should create normal loading style', () async {
      final style = LoadingStyle.normal();

      expect(style.type, LoadingStyleType.normal);
    });

    nyTest('should have null child by default', () async {
      final style = LoadingStyle.normal();

      expect(style.child, isNull);
    });

    nyTest('should accept custom child widget', () async {
      final customWidget = Container();
      final style = LoadingStyle.normal(child: customWidget);

      expect(style.child, customWidget);
    });

    nyTest('should have null skeletonizerEffect', () async {
      final style = LoadingStyle.normal();

      expect(style.skeletonizerEffect, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // LoadingStyle.skeletonizer Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('LoadingStyle.skeletonizer', () {
    nyTest('should create skeletonizer loading style', () async {
      final style = LoadingStyle.skeletonizer();

      expect(style.type, LoadingStyleType.skeletonizer);
    });

    nyTest('should have null child by default', () async {
      final style = LoadingStyle.skeletonizer();

      expect(style.child, isNull);
    });

    nyTest('should accept custom child widget', () async {
      final customWidget = Container();
      final style = LoadingStyle.skeletonizer(child: customWidget);

      expect(style.child, customWidget);
    });

    nyTest('should accept effect parameter', () async {
      final style = LoadingStyle.skeletonizer(
        effect: SkeletonizerEffect.shimmer,
      );

      expect(style.skeletonizerEffect, SkeletonizerEffect.shimmer);
    });

    nyTest('should support all effect types', () async {
      final shimmer = LoadingStyle.skeletonizer(
        effect: SkeletonizerEffect.shimmer,
      );
      final solid = LoadingStyle.skeletonizer(effect: SkeletonizerEffect.solid);
      final pulse = LoadingStyle.skeletonizer(effect: SkeletonizerEffect.pulse);

      expect(shimmer.skeletonizerEffect, SkeletonizerEffect.shimmer);
      expect(solid.skeletonizerEffect, SkeletonizerEffect.solid);
      expect(pulse.skeletonizerEffect, SkeletonizerEffect.pulse);
    });

    nyTest('should have null effect by default', () async {
      final style = LoadingStyle.skeletonizer();

      expect(style.skeletonizerEffect, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // LoadingStyle.none Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('LoadingStyle.none', () {
    nyTest('should create none loading style', () async {
      final style = LoadingStyle.none();

      expect(style.type, LoadingStyleType.none);
    });

    nyTest('should have null child', () async {
      final style = LoadingStyle.none();

      expect(style.child, isNull);
    });

    nyTest('should have null skeletonizerEffect', () async {
      final style = LoadingStyle.none();

      expect(style.skeletonizerEffect, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // LoadingStyle Default Constructor Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('LoadingStyle default constructor', () {
    nyTest('should default to normal type', () async {
      final style = LoadingStyle();

      expect(style.type, LoadingStyleType.normal);
    });

    nyTest('should accept type parameter', () async {
      final style = LoadingStyle(type: LoadingStyleType.skeletonizer);

      expect(style.type, LoadingStyleType.skeletonizer);
    });

    nyTest('should accept child parameter', () async {
      final customWidget = Container();
      final style = LoadingStyle(child: customWidget);

      expect(style.child, customWidget);
    });

    nyTest('should have null skeletonizerEffect', () async {
      final style = LoadingStyle();

      expect(style.skeletonizerEffect, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // render() Method Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('LoadingStyle.render', () {
    nyWidgetTest('should render SizedBox.shrink for none type', (tester) async {
      final style = LoadingStyle.none();

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: style.render())),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    nyWidgetTest('should render custom child for normal type', (tester) async {
      final style = LoadingStyle.normal(child: Text('Loading...'));

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: style.render())),
      );

      expect(find.text('Loading...'), findsOneWidget);
    });

    nyWidgetTest('should render child in skeletonizer type', (tester) async {
      final style = LoadingStyle.skeletonizer(
        effect: SkeletonizerEffect.pulse,
        child: Text('Skeleton'),
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: style.render())),
      );

      expect(find.text('Skeleton'), findsOneWidget);
    });

    nyWidgetTest(
      'should use passed child over instance child in skeletonizer',
      (tester) async {
        final style = LoadingStyle.skeletonizer(child: Text('Instance'));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: style.render(child: Text('Passed'))),
          ),
        );

        expect(find.text('Passed'), findsOneWidget);
        expect(find.text('Instance'), findsNothing);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Integration Tests
  // ═══════════════════════════════════════════════════════════════════════════

  nyGroup('LoadingStyle Integration', () {
    nyTest('should differentiate between style types', () async {
      final normal = LoadingStyle.normal();
      final skeletonizer = LoadingStyle.skeletonizer();
      final none = LoadingStyle.none();

      expect(normal.type, isNot(skeletonizer.type));
      expect(normal.type, isNot(none.type));
      expect(skeletonizer.type, isNot(none.type));
    });

    nyTest('should handle style selection pattern', () async {
      LoadingStyle selectStyle(String type) {
        switch (type) {
          case 'skeleton':
            return LoadingStyle.skeletonizer();
          case 'none':
            return LoadingStyle.none();
          default:
            return LoadingStyle.normal();
        }
      }

      expect(selectStyle('skeleton').type, LoadingStyleType.skeletonizer);
      expect(selectStyle('none').type, LoadingStyleType.none);
      expect(selectStyle('normal').type, LoadingStyleType.normal);
      expect(selectStyle('anything').type, LoadingStyleType.normal);
    });
  });
}
