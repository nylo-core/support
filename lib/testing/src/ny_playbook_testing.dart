import 'package:flutter_test/flutter_test.dart';

import '/playbook/ny_playbook.dart';

/// A [PlaybookClock] for widget tests: it pumps the tester instead of
/// sleeping, so a playbook at natural speed finishes in about a second.
///
/// ```dart
/// testWidgets('signs up', (tester) async {
///   await tester.pumpWidget(const MyApp());
///   final report = await SignUpPlaybook().run(clock: NyTesterClock(tester));
///   expectPlaybookPassed(report);
/// });
/// ```
class NyTesterClock extends PlaybookClock {
  /// Creates a clock that pumps [tester].
  NyTesterClock(this.tester);

  /// The tester whose frames this clock pumps.
  final WidgetTester tester;

  Duration _elapsed = Duration.zero;

  @override
  Duration get elapsed => _elapsed;

  @override
  Future<void> wait(Duration duration) async {
    _elapsed += duration;
    await tester.pump(duration);
  }

  @override
  Future<void> frame() => tester.pump();
}

/// Lets a playbook's touches reach the app in an integration test.
///
/// The integration test binding drops pointer events that don't come from
/// the tester, and throws if that setting changes during a test, so call
/// this before `testWidgets`:
///
/// ```dart
/// void main() {
///   preparePlaybookBinding(IntegrationTestWidgetsFlutterBinding.ensureInitialized());
///
///   testWidgets('sign up journey', (tester) async {
///     app.main();
///     await tester.pumpAndSettle();
///     expectPlaybookPassed(await SignUpPlaybook().run());
///   });
/// }
/// ```
///
/// Widget tests don't need it.
void preparePlaybookBinding(TestWidgetsFlutterBinding binding) {
  if (binding is! LiveTestWidgetsFlutterBinding) return;
  binding.shouldPropagateDevicePointerEvents = true;
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
}

/// Fails the test with the playbook's report when [report] didn't pass.
void expectPlaybookPassed(PlaybookReport report) {
  expect(report.passed, isTrue, reason: '\n$report');
}
