import 'dart:async';
import '/events/ny_events.dart' show NyEvent, NyListener;

class NyEventBus {
  static final NyEventBus _instance = NyEventBus._internal();
  factory NyEventBus() => _instance;
  NyEventBus._internal();

  final Map<Type, List<NyListener>> _subscriptions = {};

  /// Enable debug mode to log event broadcasts
  bool debugMode = false;

  /// Optional error handler called when a listener throws an exception
  void Function(Object error, StackTrace stackTrace)? onError;

  /// Optional callback invoked before broadcasting to listeners
  void Function(NyEvent event, int listenerCount)? onBroadcast;

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

  /// Subscribe a listener that will be automatically removed after first execution
  void once<T extends NyEvent>(NyListener listener) {
    final wrapper = _OnceListenerWrapper(
      listener,
      () => removeListener(listener),
    );
    on<T>(wrapper);
  }

  Future<void> broadcast(NyEvent event, [Map? params]) async {
    final Type eventType = event.runtimeType;

    if (_subscriptions.containsKey(eventType)) {
      final listeners = List<NyListener>.from(_subscriptions[eventType]!);

      // Invoke onBroadcast callback if set
      onBroadcast?.call(event, listeners.length);

      for (var listener in listeners) {
        // Skip if listener was already removed (could happen if returning false in a callback)
        if (!_subscriptions.containsKey(eventType) ||
            !_subscriptions[eventType]!.contains(listener)) {
          continue;
        }

        try {
          listener.setEvent(event);
          dynamic result = await listener.handle(params);

          // Check if we should stop propagation
          if (result != null && result == false) {
            break;
          }
        } catch (e, stackTrace) {
          // Log or handle error without breaking the chain
          if (onError != null) {
            onError!(e, stackTrace);
          } else if (debugMode) {
            // ignore: avoid_print
            print(
              'NyEventBus Error in listener for $eventType: $e\n$stackTrace',
            );
          }
        }
      }
    }
  }

  /// Remove a listener without needing to specify the type
  void removeListener(NyListener listener) {
    // Handle wrapper listeners
    NyListener targetListener = listener;
    if (listener is _OnceListenerWrapper) {
      targetListener = listener._inner;
    }

    for (var type in _subscriptions.keys.toList()) {
      _subscriptions[type]!.removeWhere((l) {
        if (l == targetListener) return true;
        if (l is _OnceListenerWrapper && l._inner == targetListener) {
          return true;
        }
        return false;
      });
      if (_subscriptions[type]!.isEmpty) {
        _subscriptions.remove(type);
      }
    }
  }

  /// Clear all subscriptions
  void clear() {
    _subscriptions.clear();
  }

  /// Clear all subscriptions for a specific event type
  void clearType<T extends NyEvent>() {
    _subscriptions.remove(T);
  }

  /// Get the number of listeners for a specific event type
  int listenerCount<T extends NyEvent>() {
    return _subscriptions[T]?.length ?? 0;
  }

  /// Check if there are any listeners for a specific event type
  bool hasListeners<T extends NyEvent>() {
    return _subscriptions.containsKey(T) && _subscriptions[T]!.isNotEmpty;
  }

  /// Get all registered event types
  List<Type> get registeredEventTypes => _subscriptions.keys.toList();

  /// Get a stream of events for a specific type
  /// The stream will receive events whenever they are broadcast
  ///
  /// Remember to cancel the subscription when done to avoid memory leaks.
  Stream<T> stream<T extends NyEvent>() {
    late _StreamListener<T> listener;
    final controller = StreamController<T>.broadcast(
      onCancel: () => off<T>(listener),
    );
    listener = _StreamListener<T>(controller);
    on<T>(listener);
    return controller.stream;
  }
}

/// Internal wrapper for one-shot listeners
class _OnceListenerWrapper extends NyListener {
  final NyListener _inner;
  final void Function() _onComplete;

  _OnceListenerWrapper(this._inner, this._onComplete);

  @override
  void setEvent(NyEvent event) {
    _inner.setEvent(event);
  }

  @override
  NyEvent? getEvent() => _inner.getEvent();

  @override
  Future handle(Map? params) async {
    try {
      return await _inner.handle(params);
    } finally {
      _onComplete();
    }
  }
}

/// Internal listener for stream support
class _StreamListener<T extends NyEvent> extends NyListener {
  final StreamController<T> _controller;

  _StreamListener(this._controller);

  @override
  Future handle(Map? params) async {
    final event = getEvent();
    if (!_controller.isClosed && event != null) {
      _controller.add(event as T);
    }
  }
}
