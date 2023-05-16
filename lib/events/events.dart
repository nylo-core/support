/// Base interface for Events
abstract class NyEvent {
  final Map<Type, NyListener> listeners = {};
}

/// Base class for listeners
class NyListener {
  late NyEvent _event;

  /// Set the [event] that the listener was called from
  setEvent(NyEvent event) {
    _event = event;
  }

  /// Get the [NyEvent] that the listener was called from
  NyEvent getEvent() => _event;

  /// Handle the payload from the event
  /// The [event] argument provides a Map of the data
  /// event<ChatCreated>(data: {"chat": Chat()});
  /// E.g. [event] = {"chat":"Chat instance"}
  Future<dynamic> handle(Map? event) async {}
}
