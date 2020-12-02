import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'goals_event.dart';
part 'goals_state.dart';

class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  GoalsBloc() : super(GoalsInitial());
  final List<String> periodNames = ["overall", "monthly", "weekly", "daily"];
  @override
  Stream<GoalsState> mapEventToState(
    GoalsEvent event,
  ) async* {
    // si se estan cargado las metas
    if (event is GetGoalsEvent) {
      // comprobar si se debe incializar los objetivos por defecto
      await initGoals();
      // comprobar si se deben actualizar los periodos al siguiente dia / sem
      // mes
      await rollOverGoals();
      // cargar objetivos almacenados y las fechas
      Map<String, dynamic> goals = await loadGoals();
      // pasar al estado de objetivos cargados con estos datos
      yield GoalsLoadedState(
        overallGoal: goals["overallGoal"] as double,
        monthlyGoal: goals["monthlyGoal"] as double,
        weeklyGoal: goals["weeklyGoal"] as double,
        dailyGoal: goals["dailyGoal"] as double,
        overallStartDate: goals["overallStartDate"] as DateTime,
        monthlyStartDate: goals["monthlyStartDate"] as DateTime,
        weeklyStartDate: goals["weeklyStartDate"] as DateTime,
        dailyStartDate: goals["dailyStartDate"] as DateTime,
      );
    }
    if (event is SaveGoalsEvent) {
      // gurdar los nuevos objetivos
      await saveGoals(event.goalOverall, event.goalMonthly, event.goalWeekly,
          event.goalDaily);
      Map<String, dynamic> goals = await loadGoals();
      // pasar al mismo estado de objetivos cargados pero con los nuevos datos
      yield GoalsLoadedState(
        message: "Objetivos guardados",
        overallGoal: goals["overallGoal"] as double,
        monthlyGoal: goals["monthlyGoal"] as double,
        weeklyGoal: goals["weeklyGoal"] as double,
        dailyGoal: goals["dailyGoal"] as double,
        overallStartDate: goals["overallStartDate"] as DateTime,
        monthlyStartDate: goals["monthlyStartDate"] as DateTime,
        weeklyStartDate: goals["weeklyStartDate"] as DateTime,
        dailyStartDate: goals["dailyStartDate"] as DateTime,
      );
    }
  }

  // guardar objerivos
  Future<void> saveGoals(
    double overallGoal,
    double monthlyGoal,
    double weeklyGoal,
    double dailyGoal,
  ) async {
    Box goalBox = await Hive.openBox("goals");
    goalBox.putAll({
      "overallGoal": overallGoal,
      "monthlyGoal": monthlyGoal,
      "weeklyGoal": weeklyGoal,
      "dailyGoal": dailyGoal,
    });
  }

  // Verificar si en este momento ya se paso el periodo (mes,semana,dia )
  // y si es asi pasar al siguiente interval respectivo

  Future<void> rollOverGoals() async {
    Box goalBox = await Hive.openBox("goals");
    DateTime dayStart = goalBox.get("dailyStartDate");
    DateTime weekStart = goalBox.get("weeklyStartDate");
    DateTime monthStart = goalBox.get("monthlyStartDate");
    DateTime now = DateTime.now();
    // si el momento actual es un dia o mas despues de que comenzo el periodo guardado
    // avanzar un dia
    if (now.isAfter(dayStart.add(Duration(days: 1)))) {
      dayStart = dayStart.add(Duration(days: 1));
    }
    // Lo mismo con la semana (de 7 en 7 dias)
    if (now.isAfter(weekStart.add(Duration(days: 7)))) {
      weekStart = weekStart.add(Duration(days: 7));
    }
    // y el mes
    if (now.isAfter(monthStart.add(Duration(days: 30)))) {
      monthStart = monthStart.add(Duration(days: 30));
    }
    await goalBox.putAll({
      "monthlyStartDate": dayStart,
      "weeklyStartDate": weekStart,
      "dailyStartDate": monthStart
    });
  }

  // inicializar la configuracion por defecto de objetivos la primera vez que se usa la app
  // o se borran los datos

  Future<void> initGoals() async {
    Box goalBox = await Hive.openBox("goals");
    var goalsInit = goalBox.get("goalsInit");
    if (goalsInit == null) {
      DateTime now = DateTime.now();
      goalBox.putAll({
        "goalsInit": true,
        "overallGoal": 0.0,
        "monthlyGoal": 0.0,
        "weeklyGoal": 0.0,
        "dailyGoal": 0.0,
        "overallStartDate": now,
        "monthlyStartDate": now,
        "weeklyStartDate": now,
        "dailyStartDate": now,
      });
    }
  }

  Future<Map<String, dynamic>> loadGoals() async {
    Box goalBox = await Hive.openBox("goals");
    Map<String, dynamic> goals = Map<String, dynamic>();
    periodNames.forEach((String period) {
      goals[period + "Goal"] = goalBox.get(period + "Goal");
      goals[period + "StartDate"] = goalBox.get(period + "StartDate");
    });
    return goals;
  }
}
