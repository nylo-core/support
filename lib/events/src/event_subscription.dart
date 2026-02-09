import '/events/ny_events.dart' show NyEventBus, NyEvent, NyListener;

/// Subscription handle that can be used to cancel listening
class NyEventSubscription<T extends NyEvent> {
  final NyListener _listener;
  bool _active = true;

  NyEventSubscription(this._listener);

  /// Cancel this subscription
  void cancel() {
    if (_active) {
      NyEventBus().off<T>(_listener);
      _active = false;
    }
  }

  bool get isActive => _active;
}

class NyEventCallbackListener extends NyListener {
  final Function(Map? data) callback;
  bool _shouldCancel = false;

  NyEventCallbackListener(this.callback);

  @override
  Future handle(Map? data) async {
    final result = await callback(data);

    // If callback returns false, flag this subscription for cancellation
    if (result != null && result == false) {
      _shouldCancel = true;
      // Use the new method that doesn't require type parameter
      NyEventBus().removeListener(this);
      return false;
    }
    return result;
  }

  bool get shouldCancel => _shouldCancel;
}

NyEventSubscription listenOn<E extends NyEvent>(Function(Map? data) callback) {
  final listener = NyEventCallbackListener(callback);
  NyEventBus().on<E>(listener);
  return NyEventSubscription<E>(listener);
}
