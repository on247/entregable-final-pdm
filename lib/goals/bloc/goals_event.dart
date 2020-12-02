part of 'goals_bloc.dart';

abstract class GoalsEvent extends Equatable {
  const GoalsEvent();

  @override
  List<Object> get props => [];
}

enum GoalPeriod { daily, weekly, monthly, overall }

// Evento con datos de los nuevos objetivos a guardar
class SaveGoalsEvent extends GoalsEvent {
  final goalOverall;
  final goalMonthly;
  final goalWeekly;
  final goalDaily;

  SaveGoalsEvent(
      {@required this.goalOverall,
      @required this.goalMonthly,
      @required this.goalWeekly,
      @required this.goalDaily});

  @override
  List<Object> get props =>
      [this.goalOverall, this.goalMonthly, this.goalWeekly, this.goalDaily];
}

// no implementado , evento para resetear estadisitcas
// se vuelve a 0 y el dia , semana o mes se comienza desde el momento actual

class ResetGoalEvent extends GoalsEvent {
  final GoalPeriod period;

  ResetGoalEvent({@required this.period});

  @override
  List<Object> get props => [this.period];
}

// Evento de cargar de objetivos
class GetGoalsEvent extends GoalsEvent {}
