import '/events/ny_events.dart' show NyEvent, NyEventBus;

/// Extensions on NyEvent
extension NyEventExtension on NyEvent {
  // Fire method that works with both existing and new listeners
  Future<void> fireAll(Map? data, {bool broadcast = true}) async {
    // Execute existing listeners using current pattern
    for (var listener in listeners.values.toList()) {
      listener.setEvent(this);
      dynamic result = await listener.handle(data);
      if (result != null && result == false) {
        return; // Early termination if a listener returns false
      }
    }

    if (!broadcast) return;
    // Execute dynamically registered listeners
    await NyEventBus().broadcast(this, data);
  }
}
