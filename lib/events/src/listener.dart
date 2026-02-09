import '/events/ny_events.dart' show NyEvent;

/// Base class for listeners
class NyListener {
  NyEvent? _event;

  /// Set the [event] that the listener was called from
  void setEvent(NyEvent event) {
    _event = event;
  }

  /// Get the [NyEvent] that the listener was called from
  /// Returns null if no event has been set
  NyEvent? getEvent() => _event;

  /// Handle the payload from the event
  /// The [data] argument provides a Map of the data
  Future handle(Map? data) async {}
}
