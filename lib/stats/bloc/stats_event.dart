part of 'stats_bloc.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object> get props => [];
}

// evento para cargar estadisticas
class GetStatsEvent extends StatsEvent {}
