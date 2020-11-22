part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class RunNotStartedState extends HomeState {}

class RunStartedState extends HomeState {}

class RunCompletedState extends HomeState {
  final Duration totalTime;
  final DateTime startDate;
  final double distance;
  final double avgSpeed;
  final double topSpeed;
  final List<LatLng> route;

  RunCompletedState({
    @required this.totalTime,
    @required this.startDate,
    @required this.distance,
    @required this.avgSpeed,
    @required this.topSpeed,
    @required this.route,
  });
}

class RunSaveErrorState extends HomeState {
  final String error;
  final HomeState prevState;
  RunSaveErrorState({@required this.error, @required this.prevState});
}
