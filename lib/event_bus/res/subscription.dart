import 'dart:async';

/// The function/method signature for the event handler
typedef Responder<T> = void Function(T event);

/// The class manages the subscription to event bus
class Subscription {
  /// Create the subscription
  ///
  /// Should barely used directly, to subscribe to event bus, use `EventBus.respond`.
  Subscription(this._stream);

  /// Returns an instance that indicates there is no subscription
  factory Subscription.empty() => const _EmptySubscription();

  final Stream _stream;

  /// Subscriptions that registered to event bus
  final List<StreamSubscription> subscriptions = [];

  Stream<T> _cast<T>() {
    if (T == dynamic) {
      return _stream as Stream<T>;
    } else {
      return _stream.where((event) => event is T).cast<T>();
    }
  }

  /// Register a [responder] to event bus for the event type [T].
  /// If [T] is omitted or given as `dynamic`, it listens to all events that published on [EventBus].
  ///
  /// Method call can be safely chained, and the order doesn't matter.
  ///
  /// ```
  /// eventBus
  ///   .respond<EventA>(responderA)
  ///   .respond<EventB>(responderB);
  /// ```
  Subscription respond<T>(Responder<T> responder) {
    subscriptions.add(_cast<T>().listen(responder));
    return this;
  }

  /// Cancel all the registered subscriptions.
  /// After calling this method, all the events published won't be delivered to the cleared responders any more.
  ///
  /// No harm to call more than once.
  void dispose() {
    if (subscriptions.isEmpty) {
      return;
    }
    for (final s in subscriptions) {
      s.cancel();
    }
    subscriptions.clear();
  }
}

class _EmptySubscription implements Subscription {
  const _EmptySubscription();
  static final List<StreamSubscription> emptyList =
      List.unmodifiable(<StreamSubscription>[]);

  @override
  void dispose() {}

  @override
  Subscription respond<T>(responder) => throw Exception('Not supported');

  @override
  List<StreamSubscription> get subscriptions => emptyList;

  @override
  Stream<T> _cast<T>() => throw Exception('Not supported');

  @override
  Stream get _stream => throw Exception('Not supported');
}
