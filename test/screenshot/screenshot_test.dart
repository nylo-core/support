import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/file_storage/ny_file_storage.dart';
import 'package:nylo_support/live/ny_live.dart';
import 'package:nylo_support/screenshot/ny_screenshot.dart';
import 'package:nylo_support/testing/src/fake_disk.dart';

const List<int> _pngSignature = [137, 80, 78, 71, 13, 10, 26, 10];

bool _isPng(Uint8List bytes) =>
    bytes.length > 8 && listEquals(bytes.sublist(0, 8), _pngSignature);

class _App extends StatelessWidget {
  const _App({this.root = true, this.area = true});

  final bool root;
  final bool area;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    builder: root
        ? (BuildContext context, Widget? child) => ScreenshotRoot(child: child!)
        : null,
    home: Scaffold(
      body: Center(
        child: area
            ? const ScreenshotArea(
                name: 'card',
                child: SizedBox(width: 100, height: 50, child: Text('Card')),
              )
            : const Text('No card'),
      ),
    ),
  );
}

void main() {
  setUp(FileStorage.reset);

  testWidgets('captures the root boundary at the given pixel ratio', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _App());

    final Screenshot? shot = await tester.runAsync(
      () => Screenshot.capture(pixelRatio: 1, settle: false),
    );

    expect(shot!.width, 800);
    expect(shot.height, 600);
    expect(_isPng(shot.bytes), isTrue);
  });

  testWidgets('captures the whole view without a ScreenshotRoot', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _App(root: false));

    final Screenshot? shot = await tester.runAsync(
      () => Screenshot.capture(pixelRatio: 1, settle: false),
    );

    expect(shot!.width, 800);
    expect(shot.height, 600);
    expect(_isPng(shot.bytes), isTrue);
  });

  testWidgets('captures a ScreenshotArea by name', (WidgetTester tester) async {
    await tester.pumpWidget(const _App());

    expect(Screenshot.areas, ['card']);
    final Screenshot? shot = await tester.runAsync(
      () => Screenshot.area('card', pixelRatio: 2, settle: false),
    );

    expect(shot!.width, 200);
    expect(shot.height, 100);
  });

  testWidgets('names the areas on screen when one is missing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _App());

    await expectLater(
      Screenshot.area('receipt', settle: false),
      throwsA(
        isA<StateError>().having(
          (StateError e) => e.message,
          'message',
          'There\'s no ScreenshotArea called "receipt" on screen. '
              'On screen: card.',
        ),
      ),
    );
  });

  testWidgets('an area is released when it leaves the screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _App());
    expect(Screenshot.areas, ['card']);

    await tester.pumpWidget(const _App(area: false));

    expect(Screenshot.areas, isEmpty);
  });

  testWidgets('stores the PNG on a disk', (WidgetTester tester) async {
    final FakeDisk disk = FileStorage.fake('public');
    final Screenshot shot = Screenshot(
      bytes: Uint8List.fromList([137, 80, 78, 71]),
      width: 1,
      height: 1,
    );

    final String? path = await tester.runAsync(
      () => shot.store('reports/home.png', disk: 'public'),
    );

    expect(path, 'reports/home.png');
    disk.assertExists('reports/home.png');
  });

  testWidgets('the root keeps an overlay above the boundary', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _App());

    expect(Screenshot.overlayKey.currentState, isNotNull);
    expect(
      find.descendant(
        of: find.byKey(Screenshot.rootKey),
        matching: find.byKey(Screenshot.overlayKey),
      ),
      findsNothing,
    );
  });

  testWidgets('screenshot.capture returns the PNG in profile builds', (
    WidgetTester tester,
  ) async {
    NyLive.debugBuildOverride = false;
    addTearDown(() => NyLive.debugBuildOverride = null);
    await tester.pumpWidget(const _App());

    // A frame is drawn first, so pump while the capture waits for it.
    final Future<Object?> pending = NyLive.dispatch('screenshot.capture', {
      'area': 'card',
      'pixelRatio': 0.5,
    });
    await tester.pump();
    final Object? result = await tester.runAsync<Object?>(() => pending);

    final Map<String, Object?> json = Map<String, Object?>.from(result! as Map);
    expect(json['width'], 150);
    expect(json['height'], 75);
    expect(json['png'], isA<String>());
    expect(json['mode'], 'profile');
  });

  testWidgets('screenshot.capture names a missing area', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _App());

    final Future<void> expectation = expectLater(
      NyLive.dispatch('screenshot.capture', {'area': 'receipt'}),
      throwsA(
        isA<LiveException>().having(
          (LiveException e) => e.message,
          'message',
          contains('On screen: card.'),
        ),
      ),
    );
    await tester.pump();
    await expectation;
  });

  testWidgets('screenshot.capture checks the pixel ratio', (
    WidgetTester tester,
  ) async {
    await expectLater(
      NyLive.dispatch('screenshot.capture', {'pixelRatio': 9}),
      throwsA(isA<LiveException>()),
    );
  });
}
