/// Playbooks: user journeys your app performs on itself.
///
/// A [Playbook] lists the taps, typing, scrolling and page changes of a
/// journey. The app performs it at a natural, fast or slow pace, optionally
/// with a visible finger and step captions, from Metro (`metro live:run playbook <name>`), on boot
/// (`PLAYBOOK_ON_BOOT`), or in a widget or integration test.
library;

export 'src/playbook.dart' show Playbook;
export 'src/playbook_actor.dart'
    show PlaybookActor, PlaybookFailure, PlaybookStopped, PlaybookSession;
export 'src/playbook_camera.dart';
export 'src/playbook_clock.dart';
export 'src/playbook_finder.dart'
    show Find, PlaybookFinder, PlaybookTree, playbookVisibleRect;
export 'src/playbook_overlay.dart' show PlaybookCaption;
export 'src/playbook_registry.dart';
export 'src/playbook_report.dart';
export 'src/playbook_runner.dart';
export 'src/playbook_speed.dart';
export 'src/playbook_step.dart';
