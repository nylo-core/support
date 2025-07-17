/// Base interface for Events
abstract class NyEvent {
  final Map listeners = {};
}

/// Base class for listeners
class NyListener {
  late NyEvent _event;

  /// Set the [event] that the listener was called from
  void setEvent(NyEvent event) {
    _event = event;
  }

  /// Get the [NyEvent] that the listener was called from
  NyEvent getEvent() => _event;

  /// Handle the payload from the event
  /// The [event] argument provides a Map of the data
  Future handle(Map? event) async {}
}

class NyEventBus {
  static final NyEventBus _instance = NyEventBus._internal();
  factory NyEventBus() => _instance;
  NyEventBus._internal();

  final Map<Type, List<NyListener>> _subscriptions = {};

  void on<T extends NyEvent>(NyListener listener) {
    _subscriptions[T] ??= [];
    if (!_subscriptions[T]!.contains(listener)) {
      _subscriptions[T]!.add(listener);
    }
  }

  void off<T extends NyEvent>(NyListener listener) {
    if (_subscriptions.containsKey(T)) {
      _subscriptions[T]!.remove(listener);
      if (_subscriptions[T]!.isEmpty) {
        _subscriptions.remove(T);
      }
    }
  }

  Future<void> broadcast(NyEvent event, [Map? params]) async {
    final Type eventType = event.runtimeType;

    if (_subscriptions.containsKey(eventType)) {
      final listeners = List<NyListener>.from(_subscriptions[eventType]!);

      for (var listener in listeners) {
        // Skip if listener was already removed (could happen if returning false in a callback)
        if (!_subscriptions.containsKey(eventType) ||
            !_subscriptions[eventType]!.contains(listener)) {
          continue;
        }

        listener.setEvent(event);
        dynamic result = await listener.handle(params);

        // Check if we should stop propagation
        if (result != null && result == false) {
          break;
        }
      }
    }
  }

  // Add this method to remove a listener without needing to specify the type
  void removeListener(NyListener listener) {
    for (var type in _subscriptions.keys.toList()) {
      if (_subscriptions[type]!.contains(listener)) {
        _subscriptions[type]!.remove(listener);
        if (_subscriptions[type]!.isEmpty) {
          _subscriptions.remove(type);
        }
        break; // Assuming a listener is only registered once
      }
    }
  }
}

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

/// Extension on NyEvent that adds the new functionality
extension NyEventExtension on NyEvent {
  // Fire method that works with both existing and new listeners
  Future<void> fireAll(Map? params, {bool broadcast = true}) async {
    // Execute existing listeners using current pattern
    for (var listener in listeners.values.toList()) {
      if (listener is NyListener) {
        listener.setEvent(this);
        dynamic result = await listener.handle(params);
        if (result != null && result == false) {
          return; // Early termination if a listener returns false
        }
      }
    }

    if (!broadcast) return;
    // Execute dynamically registered listeners
    await NyEventBus().broadcast(this, params);
  }
}

class NyEventCallbackListener extends NyListener {
  final Function(Map? data) callback;
  bool _shouldCancel = false;

  NyEventCallbackListener(this.callback);

  @override
  Future handle(Map? event) async {
    final result = callback(event);

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
