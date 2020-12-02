part of 'goals_bloc.dart';

abstract class GoalsState extends Equatable {
  const GoalsState();

  @override
  List<Object> get props => [];
}

class GoalsInitial extends GoalsState {}

class GoalsLoadedState extends GoalsState {
  // objetivos de dia , semana , mes me en total
  final double overallGoal;
  final double monthlyGoal;
  final double weeklyGoal;
  final double dailyGoal;

  // cuando comienza el dia , semana , mes , (ultimo reseteo o primer uso de app)
  final DateTime overallStartDate;
  final DateTime monthlyStartDate;
  final DateTime weeklyStartDate;
  final DateTime dailyStartDate;

  // mensaje de exito a mostrar (opcional)
  final String message;
  // mensaje de error a mostrar (opcional)
  final String error;
  GoalsLoadedState(
      {@required this.overallGoal,
      @required this.monthlyGoal,
      @required this.weeklyGoal,
      @required this.dailyGoal,
      @required this.overallStartDate,
      @required this.monthlyStartDate,
      @required this.weeklyStartDate,
      @required this.dailyStartDate,
      this.message,
      this.error});

  @override
  List<Object> get props => [
        overallGoal,
        monthlyGoal,
        weeklyGoal,
        dailyGoal,
        overallStartDate,
        monthlyStartDate,
        weeklyStartDate,
        dailyStartDate,
        message,
        error,
      ];
}
