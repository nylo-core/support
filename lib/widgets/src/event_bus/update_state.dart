import '/event_bus/ny_event_bus.dart';

/// UpdateState Model.
class UpdateState extends AppEvent {
  const UpdateState({this.data, this.stateName});

  final String? stateName;
  final dynamic data;

  @override
  List<Object?> get props => [stateName, data];
}
