import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/playbook/ny_playbook.dart';
import 'package:nylo_support/testing/src/ny_playbook_testing.dart';

/// A long list, with a button that opens another long list in a page route
/// that isn't opaque, as Nylo's routes are by default.
class _App extends StatelessWidget {
  const _App();

  static Widget _list(String name) => ListView.builder(
    itemCount: 60,
    itemBuilder: (BuildContext context, int i) =>
        SizedBox(height: 48, child: Text('$name item $i')),
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Builder(
      builder: (BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).push(
                PageRouteBuilder<void>(
                  opaque: false,
                  pageBuilder: (_, _, _) =>
                      Scaffold(appBar: AppBar(), body: _list('Upper')),
                ),
              ),
              child: const Text('Open'),
            ),
          ],
        ),
        body: _list('Lower'),
      ),
    ),
  );
}

class _ScrollUpper extends Playbook {
  @override
  List<PlaybookStep> get steps => [
    tap('Open'),
    scrollTo('Upper item 50'),
    dontSee('Lower item 0'),
  ];
}

class _SeeLower extends Playbook {
  @override
  List<PlaybookStep> get steps => [tap('Open'), see('Lower item 0')];
}

void main() {
  testWidgets('scrollTo scrolls the page on top, not the one under it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _App());

    final PlaybookReport report = await _ScrollUpper().run(
      clock: NyTesterClock(tester),
      speed: PlaybookSpeed.instant,
    );

    expectPlaybookPassed(report);
  });

  testWidgets('a covered page\'s text isn\'t seen or listed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _App());

    final PlaybookReport report = await _SeeLower().run(
      clock: NyTesterClock(tester),
      speed: PlaybookSpeed.instant,
    );

    expect(report.passed, isFalse);
    final List<String> visible = report.failure!.visibleText;
    expect(visible, contains('Upper item 0'));
    expect(visible.any((String text) => text.startsWith('Lower')), isFalse);
  });

  testWidgets('the page under a dialog is still seen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const AlertDialog(content: Text('Sure?')),
                ),
                child: const Text('Ask'),
              ),
            ),
          ),
        ),
      ),
    );

    final PlaybookReport report = await _DialogOverPage().run(
      clock: NyTesterClock(tester),
      speed: PlaybookSpeed.instant,
    );

    expectPlaybookPassed(report);
  });
}

class _DialogOverPage extends Playbook {
  @override
  List<PlaybookStep> get steps => [tap('Ask'), see('Sure?'), see('Ask')];
}
