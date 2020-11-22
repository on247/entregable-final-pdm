part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class RunStartEvent extends HomeEvent {}

class RunCompleteEvent extends HomeEvent {
  final DateTime startDate;
  final Duration totalTime;
  final double distance;
  final double avgSpeed;
  final double topSpeed;
  final List<LatLng> route;

  RunCompleteEvent({
    @required this.totalTime,
    @required this.startDate,
    @required this.distance,
    @required this.avgSpeed,
    @required this.topSpeed,
    @required this.route,
  });
}

class RunEndEvent extends HomeEvent {
  final GoogleMapController map;
  final String title;
  final String note;
  final DateTime startDate;
  final Duration totalTime;
  final double distance;
  final double avgSpeed;
  final double topSpeed;

  RunEndEvent({
    @required this.title,
    @required this.note,
    @required this.totalTime,
    @required this.startDate,
    @required this.distance,
    @required this.avgSpeed,
    @required this.topSpeed,
    @required this.map,
  });
}

class StartLocationEvent extends HomeEvent {}

class LogoutEvent extends HomeEvent {}

class LocationUpdateEvent extends HomeEvent {}
