import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';

/// The base class for all events
abstract class AppEvent extends Equatable {
  /// Create the event
  const AppEvent();

  /// The event time
  DateTime get timestamp => clock.now();
}

/// The event completion event
class EventCompletionEvent extends AppEvent {
  /// Create the event
  const EventCompletionEvent(this.event);

  /// The event that is completed
  final AppEvent event;

  @override
  List<Object> get props => [event];
}

/// The empty event
class EmptyEvent extends AppEvent {
  @override
  List<Object?> get props => [];
}
