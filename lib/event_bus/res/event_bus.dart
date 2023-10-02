import 'package:nylo_support/helpers/helper.dart';
import 'package:rxdart/subjects.dart';

import 'app_event.dart';
import 'history_entry.dart';
import 'subscription.dart';

/// The event bus interface
abstract class IEventBus {
  /// Whether the event bus is busy
  bool get isBusy;

  /// Whether the event bus is busy
  Stream<bool> get isBusy$;

  /// The last event
  AppEvent? get last;

  /// The last event
  Stream<AppEvent?> get last$;

  /// The list of events that are in progress
  Stream<List<AppEvent>> get inProgress$;

  /// Subscribe `EventBus` on a specific type of event, and register responder to it.
  Stream<T> on<T extends AppEvent>();

  /// Subscribe `EventBus` on a specific type of event, and register responder to it.
  Stream<bool> whileInProgress<T extends AppEvent>();

  /// Subscribe `EventBus` on a specific type of event, and register responder to it.
  Subscription respond<T>(Responder<T> responder);

  /// The history of events
  List<EventBusHistoryEntry> get history;

  /// Fire a event
  void fire(AppEvent event);

  /// Fire a event and wait for it to be completed
  void watch(AppEvent event);

  /// Complete a event
  void complete(AppEvent event, {AppEvent? nextEvent});

  ///
  bool isInProgress<T>();

  /// Reset the event bus
  void reset();

  /// Dispose the event bus
  void dispose();

  /// Clear the history
  void clearHistory();
}

/// The event bus implementation
class EventBus implements IEventBus {
  /// Create the event bus
  EventBus({
    this.maxHistoryLength = 100,
    this.map = const {},
    this.allowLogging = false,
  });

  /// The maximum length of history
  final int maxHistoryLength;

  /// allow to log all events this when you call [fire]
  /// the event will be in console log
  final bool allowLogging;

  /// The map of events
  final Map<Type, List<AppEvent Function(AppEvent event)>> map;

  @override
  bool get isBusy => _inProgress.value.isNotEmpty;
  @override
  Stream<bool> get isBusy$ => _inProgress.map((event) => event.isNotEmpty);

  final _lastEventSubject = BehaviorSubject<AppEvent>();
  @override
  AppEvent? get last => _lastEventSubject.valueOrNull;
  @override
  Stream<AppEvent?> get last$ => _lastEventSubject.distinct();

  final _inProgress = BehaviorSubject<List<AppEvent>>.seeded([]);
  List<AppEvent> get _isInProgressEvents => _inProgress.value;
  @override
  Stream<List<AppEvent>> get inProgress$ => _inProgress;

  @override
  List<EventBusHistoryEntry> get history => List.unmodifiable(_history);
  final List<EventBusHistoryEntry> _history = [];

  @override
  void fire(AppEvent event) {
    if (_history.length >= maxHistoryLength) {
      _history.removeAt(0);
    }
    _history.add(EventBusHistoryEntry(event, event.timestamp));
    // 1. Fire the event
    _lastEventSubject.add(event);
    // 2. Map if needed
    _map(event);
    // 3. Reset stream
    _lastEventSubject.add(EmptyEvent());
    if (allowLogging) {
      NyLogger.debug(' ⚡️ [${event.timestamp}] $event');
    }
  }

  @override
  void watch(AppEvent event) {
    fire(event);
    _inProgress.add([
      ..._isInProgressEvents,
      event,
    ]);
  }

  @override
  void complete(AppEvent event, {AppEvent? nextEvent}) {
    // complete the event
    if (_isInProgressEvents.any((e) => e == event)) {
      final newArr = _isInProgressEvents.toList()
        ..removeWhere((e) => e == event);
      _inProgress.add(newArr);
      fire(EventCompletionEvent(event));
    }

    // fire next event if any
    if (nextEvent != null) {
      fire(nextEvent);
    }
  }

  @override
  bool isInProgress<T>() {
    return _isInProgressEvents.whereType<T>().isNotEmpty;
  }

  @override
  Stream<T> on<T extends AppEvent>() {
    if (T == dynamic) {
      return _lastEventSubject.stream as Stream<T>;
    } else {
      return _lastEventSubject.stream.where((event) => event is T).cast<T>();
    }
  }

  /// Subscribe `EventBus` on a specific type of event, and register responder to it.
  ///
  /// When [T] is not given or given as `dynamic`, it listens to all events regardless of the type.
  /// Returns [Subscription], which can be disposed to cancel all the subscription registered to itself.
  @override
  Subscription respond<T>(Responder<T> responder) =>
      Subscription(_lastEventSubject).respond<T>(responder);

  @override
  Stream<bool> whileInProgress<T extends AppEvent>() {
    return _inProgress.map((events) {
      return events.whereType<T>().isNotEmpty;
    });
  }

  void _map(AppEvent? event) {
    if (event == null) {
      return;
    }

    final functions = map[event.runtimeType] ?? [];
    if (functions.isEmpty) {
      return;
    }

    for (final func in functions) {
      final newEvent = func(event);
      if (newEvent.runtimeType == event.runtimeType) {
        if (allowLogging) {
          NyLogger.debug(
              ' 🟠 SKIP EVENT: ${newEvent.runtimeType} => ${event.runtimeType}');
        }
        continue;
      }
      fire(newEvent);
    }
  }

  @override
  void clearHistory() {
    _history.clear();
  }

  @override
  void reset() {
    clearHistory();
    _inProgress.add([]);
    _lastEventSubject.add(EmptyEvent());
  }

  @override
  void dispose() {
    _inProgress.close();
    _lastEventSubject.close();
  }
}
