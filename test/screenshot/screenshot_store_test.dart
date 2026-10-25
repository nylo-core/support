import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/live/ny_live.dart';
import 'package:nylo_support/screenshot/ny_screenshot.dart';

/// The color of the pixel at [x], [y] in [png].
Future<Color> _pixel(Uint8List png, int x, int y) async {
  final ui.Codec codec = await ui.instantiateImageCodec(png);
  final ui.Image image = (await codec.getNextFrame()).image;
  final ByteData data = (await image.toByteData())!;
  final int offset = (y * image.width + x) * 4;
  final Color color = Color.fromARGB(
    data.getUint8(offset + 3),
    data.getUint8(offset),
    data.getUint8(offset + 1),
    data.getUint8(offset + 2),
  );
  image.dispose();
  return color;
}

/// Pumps frames and lets real time pass until [future] completes, for work
/// that needs both, like a capture followed by decoding the PNG.
Future<T> _finish<T>(WidgetTester tester, Future<T> future) async {
  bool done = false;
  late T value;
  Object? error;
  future.then<void>(
    (T result) {
      value = result;
      done = true;
    },
    onError: (Object e) {
      error = e;
      done = true;
    },
  );
  for (int i = 0; i < 200 && !done; i++) {
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5)),
    );
  }
  if (error != null) throw error!;
  expect(done, isTrue, reason: 'The capture didn\'t finish.');
  return value;
}

const Color _red = Color(0xFFE53935);
const Color _placeholder = Color(0xFF9AA4B1);

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    builder: (BuildContext context, Widget? child) =>
        ScreenshotRoot(child: child!),
    home: const Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: ScreenshotHidden(
          child: SizedBox(
            width: 100,
            height: 100,
            child: ColoredBox(color: _red),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders a widget that is never shown', (
    WidgetTester tester,
  ) async {
    final Screenshot? shot = await tester.runAsync(
      () => Screenshot.widget(
        const SizedBox(width: 120, height: 80, child: ColoredBox(color: _red)),
        pixelRatio: 2,
      ),
    );

    expect(shot!.width, 240);
    expect(shot.height, 160);
    expect(await tester.runAsync(() => _pixel(shot.bytes, 10, 10)), _red);
  });

  testWidgets('a widget rendered offscreen hides its ScreenshotHidden parts', (
    WidgetTester tester,
  ) async {
    final Screenshot? shot = await tester.runAsync(
      () => Screenshot.widget(
        const ScreenshotHidden(
          child: SizedBox(
            width: 50,
            height: 50,
            child: ColoredBox(color: _red),
          ),
        ),
        pixelRatio: 1,
      ),
    );

    expect(
      await tester.runAsync(() => _pixel(shot!.bytes, 25, 25)),
      _placeholder,
    );
  });

  testWidgets('captures show the placeholder, and the screen keeps the child', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _App());

    final Future<Screenshot> pending = Screenshot.capture(pixelRatio: 1);
    await tester.pump();
    final Screenshot? shot = await tester.runAsync(() => pending);
    await tester.pump();

    expect(
      await tester.runAsync(() => _pixel(shot!.bytes, 50, 50)),
      _placeholder,
    );
    expect(find.byType(Positioned), findsNothing);
  });

  testWidgets('forStore fits the screen to the store size', (
    WidgetTester tester,
  ) async {
    final Screenshot? store = await tester.runAsync(() async {
      final Screenshot shot = await Screenshot.widget(
        const SizedBox(width: 100, height: 200, child: ColoredBox(color: _red)),
        pixelRatio: 1,
      );
      return shot.forStore(
        ScreenshotStore.playPhone,
        background: const Color(0xFF000000),
      );
    });

    expect(store!.width, 1080);
    expect(store.height, 1920);
    // 1:2 is narrower than 9:16, so it's fitted with bars at the sides.
    expect(
      await tester.runAsync(() => _pixel(store.bytes, 5, 960)),
      const Color(0xFF000000),
    );
    expect(await tester.runAsync(() => _pixel(store.bytes, 540, 960)), _red);
  });

  testWidgets('a screen of nearly the store\'s shape fills it', (
    WidgetTester tester,
  ) async {
    final Screenshot? store = await tester.runAsync(() async {
      final Screenshot shot = await Screenshot.widget(
        const SizedBox(
          width: 603,
          height: 1311,
          child: ColoredBox(color: _red),
        ),
        size: const Size(603, 1311),
        pixelRatio: 1,
      );
      return shot.forStore(ScreenshotStore.ios69);
    });

    expect(store!.width, 1320);
    expect(store.height, 2868);
    expect(await tester.runAsync(() => _pixel(store.bytes, 2, 2)), _red);
  });

  testWidgets('a framed screenshot sits in an outline on the background', (
    WidgetTester tester,
  ) async {
    const Color background = Color(0xFF1B2027);
    final Screenshot? framed = await tester.runAsync(() async {
      final Screenshot shot = await Screenshot.widget(
        const SizedBox(width: 300, height: 650, child: ColoredBox(color: _red)),
        pixelRatio: 1,
      );
      return shot.forStore(
        ScreenshotStore.ios69,
        frame: true,
        caption: 'Checkout in one tap',
        background: background,
      );
    });

    expect(framed!.width, 1320);
    expect(framed.height, 2868);
    expect(
      await tester.runAsync(() => _pixel(framed.bytes, 4, 2864)),
      background,
    );
    expect(await tester.runAsync(() => _pixel(framed.bytes, 660, 1700)), _red);
  });

  test('store sizes are listed by id', () {
    expect(ScreenshotStore.named('ios-6.9'), ScreenshotStore.ios69);
    expect(ScreenshotStore.named('nope'), isNull);
    expect(ScreenshotStore.playPhone.toJson(), {
      'id': 'play-phone',
      'width': 1080,
      'height': 1920,
      'label': 'Google Play phone',
    });
  });

  group('live', () {
    setUp(() => NyLive.debugBuildOverride = true);
    tearDown(() => NyLive.debugBuildOverride = null);

    testWidgets('screenshot.capture names the store sizes', (
      WidgetTester tester,
    ) async {
      await expectLater(
        NyLive.dispatch('screenshot.capture', {'store': 'ios-7'}),
        throwsA(
          isA<LiveException>().having(
            (LiveException e) => e.message,
            'message',
            'There\'s no store size "ios-7". Store sizes: ios-6.9, ios-6.5, '
                'ipad-13, play-phone, play-tablet.',
          ),
        ),
      );
    });

    testWidgets('screenshot.capture checks the background color', (
      WidgetTester tester,
    ) async {
      await expectLater(
        NyLive.dispatch('screenshot.capture', {
          'frame': true,
          'background': 'navy',
        }),
        throwsA(
          isA<LiveException>().having(
            (LiveException e) => e.message,
            'message',
            '"background" must be a color like #1B2027, not "navy".',
          ),
        ),
      );
    });

    testWidgets('screenshot.capture returns the store size', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _App());

      final Future<Object?> pending = NyLive.dispatch('screenshot.capture', {
        'store': 'play-phone',
        'frame': true,
        'caption': 'Hello',
        'background': '#FFFFFF',
      });
      final Map<Object?, Object?> result =
          (await _finish(tester, pending))! as Map;

      expect(result['width'], 1080);
      expect(result['height'], 1920);
    });
  });
}
