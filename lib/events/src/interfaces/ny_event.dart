import '/events/ny_events.dart' show NyListener;

/// Base interface for Events
abstract class NyEvent {
  final Map<dynamic, NyListener> listeners = {};
}
