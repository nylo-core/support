import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/playbook/ny_playbook.dart';
import 'package:nylo_support/screenshot/ny_screenshot.dart';
import 'package:nylo_support/testing/src/ny_playbook_testing.dart';

import 'playbook_test_app.dart';

class _Shots extends Playbook {
  _Shots(this.shots);

  final List<PlaybookStep> shots;

  @override
  List<PlaybookStep> get steps => [see('Get started'), ...shots];
}

/// Stands in for [ScreenshotLook]: the app "shows" a locale and theme,
/// and only `en` and `es` have language files.
class _FakeLook {
  String locale = 'en';
  String theme = 'light';
  int switches = 0;

  Future<Future<void> Function()> call({String? locale, String? theme}) async {
    if (locale != null && !['en', 'es'].contains(locale)) {
      throw StateError(
        'Couldn\'t switch to "$locale". Check that lang/$locale.json exists '
        'and is listed in your assets.',
      );
    }
    final String localeBefore = this.locale;
    final String themeBefore = this.theme;
    if (locale != null || theme != null) switches++;
    this.locale = locale ?? this.locale;
    this.theme = theme ?? this.theme;
    return () async {
      this.locale = localeBefore;
      this.theme = themeBefore;
    };
  }
}

typedef _Result = ({
  List<String> shots,
  List<String> seen,
  PlaybookReport report,
  _FakeLook look,
});

void main() {
  setUp(PlaybookCamera.reset);

  /// Runs [steps], returning each shot's label and the locale and theme the
  /// app showed when it was captured.
  Future<_Result> run(
    WidgetTester tester,
    List<PlaybookStep> Function(Playbook playbook) steps, {
    ({String? locale, String? theme})? matrix,
  }) async {
    await tester.pumpWidget(const PlaybookTestApp());
    final _FakeLook look = _FakeLook();
    final List<String> seen = [];
    final List<String> shots = [];
    final _Shots playbook = _Shots(const []);
    final _Shots withSteps = _Shots(steps(playbook));
    final PlaybookSession session = await Playbook.open(
      clock: NyTesterClock(tester),
      overlay: false,
      camera: PlaybookCamera(
        mode: PlaybookScreenshots.auto,
        matrix: matrix,
        look: look.call,
        looks: () async => (locales: ['en', 'es'], themes: ['light', 'dark']),
        onShot: (PlaybookShot shot) =>
            shots.add([shot.name, ?shot.locale, ?shot.theme].join(' ')),
        capture: (double pixelRatio) async {
          seen.add('${look.locale} ${look.theme}');
          return Screenshot(bytes: Uint8List(1), width: 1, height: 1);
        },
      ),
    );
    try {
      final PlaybookReport report = await withSteps.runWith(
        session,
        speed: PlaybookSpeed.instant,
      );
      return (shots: shots, seen: seen, report: report, look: look);
    } finally {
      Playbook.close(session);
    }
  }

  testWidgets('takes one shot per locale and switches back', (
    WidgetTester tester,
  ) async {
    final _Result result = await run(
      tester,
      (Playbook p) => [
        p.screenshot('cart', locales: ['en', 'es']),
      ],
    );

    expect(result.shots, ['cart en', 'cart es']);
    expect(result.seen, ['en light', 'es light']);
    expect(result.look.locale, 'en');
    expect(result.report.passed, isTrue);
  });

  testWidgets('crosses locales with themes, locales first', (
    WidgetTester tester,
  ) async {
    final _Result result = await run(
      tester,
      (Playbook p) => [
        p.screenshot('cart', locales: ['en', 'es'], themes: ['light', 'dark']),
      ],
    );

    expect(result.shots, [
      'cart en light',
      'cart en dark',
      'cart es light',
      'cart es dark',
    ]);
    expect(result.seen, ['en light', 'en dark', 'es light', 'es dark']);
    expect(result.look.theme, 'light');
  });

  testWidgets('allLocales and allThemes read the app', (
    WidgetTester tester,
  ) async {
    final _Result result = await run(
      tester,
      (Playbook p) => [
        p.screenshot(
          'home',
          locales: Screenshot.allLocales,
          themes: Screenshot.allThemes,
        ),
      ],
    );

    expect(result.shots, [
      'home en light',
      'home en dark',
      'home es light',
      'home es dark',
    ]);
  });

  testWidgets('a matrix pass takes only its own cell, without switching', (
    WidgetTester tester,
  ) async {
    final _Result result = await run(
      tester,
      (Playbook p) => [
        p.screenshot('cart', locales: ['en', 'es']),
        p.screenshot('home', locales: ['ja']),
        p.screenshot('plain'),
      ],
      matrix: (locale: 'es', theme: 'dark'),
    );

    expect(result.shots, ['cart es', 'plain']);
    // Metro switches the app for a pass, so the camera leaves it alone.
    expect(result.seen, ['en light', 'en light']);
    expect(result.look.switches, 0);
  });

  testWidgets('a locale without a language file fails the step', (
    WidgetTester tester,
  ) async {
    final _Result result = await run(
      tester,
      (Playbook p) => [
        p.screenshot('cart', locales: ['en', 'ja']),
      ],
    );

    expect(result.report.passed, isFalse);
    expect(
      result.report.steps.last.error,
      'Couldn\'t capture "cart" in ja: Couldn\'t switch to "ja". Check that '
      'lang/ja.json exists and is listed in your assets.',
    );
    expect(result.look.locale, 'en');
  });

  testWidgets('a run without a camera passes the step', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlaybookTestApp());
    final PlaybookReport report = await _Shots([
      _Shots(const []).screenshot('cart', locales: ['en', 'es']),
    ]).run(clock: NyTesterClock(tester), speed: PlaybookSpeed.instant);

    expect(report.passed, isTrue);
  });
}
