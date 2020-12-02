part of 'stats_bloc.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object> get props => [];
}

class StatsInitial extends StatsState {}

// Estado que representa la pantalla de estadisticas con estadisticas cargadas
class StatsLoadedState extends StatsState {
  // objetivos en metros, segun se configuraron en la pantalla objetivos
  final double overallGoal;
  final double monthlyGoal;
  final double weeklyGoal;
  final double dailyGoal;

  // progreso actual en cada periodos , es decir metros recorridos en total
  // mes , semana  , diarios
  final double overallProgress;
  final double monthlyProgress;
  final double weeklyProgress;
  final double dailyProgress;

  // lista con las distancias recoridas los 7 dias pasados
  final List<double> lastWeekPerDayDistance;

  final String message;
  final String error;
  StatsLoadedState(
      {@required this.overallGoal,
      @required this.monthlyGoal,
      @required this.weeklyGoal,
      @required this.dailyGoal,
      @required this.overallProgress,
      @required this.monthlyProgress,
      @required this.weeklyProgress,
      @required this.dailyProgress,
      @required this.lastWeekPerDayDistance,
      this.message,
      this.error});

  @override
  List<Object> get props => [
        overallGoal,
        monthlyGoal,
        weeklyGoal,
        dailyGoal,
        overallProgress,
        monthlyProgress,
        weeklyProgress,
        dailyProgress,
        message,
        error,
      ];
}
