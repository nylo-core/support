import 'package:equatable/equatable.dart';

import 'app_event.dart';

/// The history entry
class EventBusHistoryEntry extends Equatable {
  /// The history entry
  const EventBusHistoryEntry(this.event, this.timestamp);

  /// The event
  final AppEvent event;

  /// The timestamp
  final DateTime timestamp;

  @override
  List<Object?> get props => [event, timestamp];
}
