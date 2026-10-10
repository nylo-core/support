import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';

/// A page whose build reads `context.isDeviceInDarkMode` and counts builds.
class _DarkModeProbe extends StatefulWidget {
  const _DarkModeProbe();

  @override
  State<_DarkModeProbe> createState() => _DarkModeProbeState();
}

class _DarkModeProbeState extends State<_DarkModeProbe> {
  int buildCount = 0;
  bool? lastIsDark;

  @override
  Widget build(BuildContext context) {
    buildCount++;
    lastIsDark = context.isDeviceInDarkMode;
    return Text(lastIsDark! ? 'dark' : 'light');
  }
}

/// A page whose build resolves a colour through [NyColor.resolveColor].
class _NyColorProbe extends StatefulWidget {
  const _NyColorProbe();

  @override
  State<_NyColorProbe> createState() => _NyColorProbeState();
}

class _NyColorProbeState extends State<_NyColorProbe> {
  int buildCount = 0;
  Color? lastColor;

  @override
  Widget build(BuildContext context) {
    buildCount++;
    lastColor = NyColor.resolveColor(
      context,
      light: Colors.white,
      dark: Colors.black,
    );
    return ColoredBox(color: lastColor!);
  }
}

/// A page whose build reads `context.widgetWidth()` / `widgetHeight()`.
class _SizeProbe extends StatefulWidget {
  const _SizeProbe();

  @override
  State<_SizeProbe> createState() => _SizeProbeState();
}

class _SizeProbeState extends State<_SizeProbe> {
  int buildCount = 0;
  double? width;
  double? height;

  @override
  Widget build(BuildContext context) {
    buildCount++;
    width = context.widgetWidth();
    height = context.widgetHeight();
    return const SizedBox.shrink();
  }
}

/// Hosts [child] under a controlled [MediaQuery].
///
/// Each test passes the SAME probe instance to every pump so that the only
/// way the probe can rebuild is through an inherited-widget dependency; a
/// fresh widget instance per pump would rebuild it via an ordinary update.
Widget _host(MediaQueryData data, Widget child) => MediaQuery(
  data: data,
  child: Directionality(textDirection: TextDirection.ltr, child: child),
);

const MediaQueryData _light = MediaQueryData(
  size: Size(400, 800),
  platformBrightness: Brightness.light,
);

void main() {
  NyTest.init();

  nyGroup('context.isDeviceInDarkMode', () {
    nyWidgetTest('does not rebuild when only viewInsets change', (
      tester,
    ) async {
      const probe = _DarkModeProbe();
      await tester.pumpWidget(_host(_light, probe));
      final _DarkModeProbeState state = tester.state<_DarkModeProbeState>(
        find.byType(_DarkModeProbe),
      );
      expect(state.buildCount, 1);
      expect(state.lastIsDark, isFalse);

      // Simulate keyboard animation frames: only viewInsets change.
      for (double inset = 20; inset <= 300; inset += 20) {
        await tester.pumpWidget(
          _host(
            _light.copyWith(viewInsets: EdgeInsets.only(bottom: inset)),
            probe,
          ),
        );
      }

      expect(state.buildCount, 1);
    });

    nyWidgetTest('does not rebuild when size or padding change', (
      tester,
    ) async {
      const probe = _DarkModeProbe();
      await tester.pumpWidget(_host(_light, probe));
      final _DarkModeProbeState state = tester.state<_DarkModeProbeState>(
        find.byType(_DarkModeProbe),
      );
      expect(state.buildCount, 1);

      await tester.pumpWidget(
        _host(
          _light.copyWith(
            size: const Size(800, 400),
            padding: const EdgeInsets.all(24),
            textScaler: const TextScaler.linear(1.5),
          ),
          probe,
        ),
      );

      expect(state.buildCount, 1);
    });

    nyWidgetTest('rebuilds when platformBrightness changes', (tester) async {
      const probe = _DarkModeProbe();
      await tester.pumpWidget(_host(_light, probe));
      final _DarkModeProbeState state = tester.state<_DarkModeProbeState>(
        find.byType(_DarkModeProbe),
      );
      expect(state.buildCount, 1);
      expect(state.lastIsDark, isFalse);

      await tester.pumpWidget(
        _host(_light.copyWith(platformBrightness: Brightness.dark), probe),
      );

      expect(state.buildCount, 2);
      expect(state.lastIsDark, isTrue);
      expect(find.text('dark'), findsOneWidget);
    });
  });

  nyGroup('NyColor.resolveColor', () {
    nyWidgetTest('does not rebuild the caller on viewInsets changes', (
      tester,
    ) async {
      const probe = _NyColorProbe();
      await tester.pumpWidget(_host(_light, probe));
      final _NyColorProbeState state = tester.state<_NyColorProbeState>(
        find.byType(_NyColorProbe),
      );
      expect(state.buildCount, 1);
      expect(state.lastColor, Colors.white);

      await tester.pumpWidget(
        _host(
          _light.copyWith(viewInsets: const EdgeInsets.only(bottom: 250)),
          probe,
        ),
      );

      expect(state.buildCount, 1);
    });

    nyWidgetTest('rebuilds the caller when platformBrightness changes', (
      tester,
    ) async {
      const probe = _NyColorProbe();
      await tester.pumpWidget(_host(_light, probe));
      final _NyColorProbeState state = tester.state<_NyColorProbeState>(
        find.byType(_NyColorProbe),
      );
      expect(state.lastColor, Colors.white);

      await tester.pumpWidget(
        _host(_light.copyWith(platformBrightness: Brightness.dark), probe),
      );

      expect(state.buildCount, 2);
      expect(state.lastColor, Colors.black);
    });
  });

  nyGroup('context.widgetWidth / widgetHeight', () {
    nyWidgetTest('return the MediaQuery size', (tester) async {
      const probe = _SizeProbe();
      await tester.pumpWidget(_host(_light, probe));
      final _SizeProbeState state = tester.state<_SizeProbeState>(
        find.byType(_SizeProbe),
      );
      expect(state.width, 400);
      expect(state.height, 800);
    });

    nyWidgetTest('do not rebuild when only viewInsets change', (tester) async {
      const probe = _SizeProbe();
      await tester.pumpWidget(_host(_light, probe));
      final _SizeProbeState state = tester.state<_SizeProbeState>(
        find.byType(_SizeProbe),
      );
      expect(state.buildCount, 1);

      await tester.pumpWidget(
        _host(
          _light.copyWith(viewInsets: const EdgeInsets.only(bottom: 250)),
          probe,
        ),
      );

      expect(state.buildCount, 1);
    });

    nyWidgetTest('rebuild when the size changes', (tester) async {
      const probe = _SizeProbe();
      await tester.pumpWidget(_host(_light, probe));
      final _SizeProbeState state = tester.state<_SizeProbeState>(
        find.byType(_SizeProbe),
      );

      await tester.pumpWidget(
        _host(_light.copyWith(size: const Size(300, 600)), probe),
      );

      expect(state.buildCount, 2);
      expect(state.width, 300);
      expect(state.height, 600);
    });
  });
}
