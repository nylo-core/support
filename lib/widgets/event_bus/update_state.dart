import 'package:event_bus_plus/event_bus_plus.dart';

/// UpdateState Model.

class UpdateState extends AppEvent {
  UpdateState({this.data, this.stateName});

  final String? stateName;
  final dynamic data;

  @override
  List<Object?> get props => [stateName, data];
}
