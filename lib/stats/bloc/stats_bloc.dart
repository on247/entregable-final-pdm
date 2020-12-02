import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entregable2/models/run.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final List<String> periodNames = ["overall", "monthly", "weekly", "daily"];
  StatsBloc() : super(StatsInitial());

  @override
  Stream<StatsState> mapEventToState(
    StatsEvent event,
  ) async* {
    if (event is GetStatsEvent) {
      List<Run> runs = await getAllRuns();
      await rollOverGoals();
      Map<String, dynamic> goals = await loadGoals();
      Map<String, dynamic> stats = calcStats(runs, goals);
      yield StatsLoadedState(
        overallGoal: stats["overallGoal"],
        monthlyGoal: stats["monthlyGoal"],
        weeklyGoal: stats["weeklyGoal"],
        dailyGoal: stats["dailyGoal"],
        overallProgress: stats["overallProgress"],
        monthlyProgress: stats["monthlyProgress"],
        weeklyProgress: stats["weeklyProgress"],
        dailyProgress: stats["dailyProgress"],
        lastWeekPerDayDistance: stats["lastWeekPerDayDistance"],
      );
    }
  }
  
  // cargar los objetivos de distancia y las fechas en las que comienza
  // cada periodo (desde que se usa la app,mes,semana,dia) desde Hive
  Future<Map<String, dynamic>> loadGoals() async {
    Box goalBox = await Hive.openBox("goals");
    Map<String, dynamic> goals = Map<String, dynamic>();
    periodNames.forEach((String period) {
      goals[period + "Goal"] = goalBox.get(period + "Goal");
      goals[period + "StartDate"] = goalBox.get(period + "StartDate");
    });
    return goals;
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
  
   // Cargar todas las carreras desde hive 
  Future<List<Run>> getAllRuns() async {
    // recuperar lista de docs guardados en Cloud firestore
    // agregar cada ojeto a una lista
    var carreras =
        await FirebaseFirestore.instance.collection("carreras").get();
    return carreras.docs
        .map((elemento) => Run.fromJson(elemento.data()))
        .toList();
  }
 
  // Calcular las estadisticas 
  Map<String, dynamic> calcStats(List<Run> runs, Map<String, dynamic> goals) {
    Map<String, dynamic> stats = Map<String, dynamic>();
    // copiar las metas al mapa de estadisticas para pasarlas al estado
    periodNames.forEach((String period) {
      stats[period + "Goal"] = goals[period + "Goal"];
    });
    // distancias recorridas en cada periodo
    double overallProgress = 0;
    double monthlyProgress = 0;
    double weeklyProgress = 0;
    double dailyProgress = 0;

    // leer fechas de inicio de cada periodo
    DateTime dayStart = goals["dailyStartDate"];
    DateTime weekStart = goals["weeklyStartDate"];
    DateTime monthStart = goals["monthlyStartDate"];
    DateTime overallStart = goals["overallStartDate"];

    // Lista para almacenar el momento en el que comenzaron los 7 dias anteriores e incluye el dia de hoy, 

    List<DateTime> prev7DaysStart = List<DateTime>();

    // Lista para almacenar la distancia recorrida cada dia dias 
    List<double> lastWeekPerDayDistance = [0, 0, 0, 0, 0, 0, 0];
    DateTime now = DateTime.now();
    // determinar cuando comienza cada dia , desde el dia de hoy , hacia atras
    for (int i = 0; i < 8; i++) {
      prev7DaysStart.add(now.subtract(Duration(days: i)));
    }
    // para cada carrera
    runs.forEach((Run r) {
      // para cada dia 
      for (int i = 0; i < 7; i++) {
        // fin dia anterior , inicio dia actual
        DateTime periodStart = prev7DaysStart[i + 1];
        // fin dia actual
        DateTime periodEnd = prev7DaysStart[i];
        // si la carrera ocurrio en ese intervalo
        if (r.startDate.millisecondsSinceEpoch >=
                periodStart.millisecondsSinceEpoch &&
            r.startDate.millisecondsSinceEpoch <
                periodEnd.millisecondsSinceEpoch) {
          // agregar a distancia recorrida este dia
          lastWeekPerDayDistance[i] += r.distance;
        }
      }
      DateTime runDate = r.startDate;
      // si la carrera fue hoy agregar a la distancia recorrida hoy
      if (runDate.millisecondsSinceEpoch >= dayStart.millisecondsSinceEpoch) {
        dailyProgress += r.distance;
      }
      // si la carrera fue esta semana(periodo) agregar a la distancia recorrida 
      if (runDate.millisecondsSinceEpoch >= weekStart.millisecondsSinceEpoch) {
        weeklyProgress += r.distance;
      }
       // Lo mismo con el mes
      if (runDate.millisecondsSinceEpoch >= monthStart.millisecondsSinceEpoch) {
        monthlyProgress += r.distance;
      }
      // Agregar al total desde el ultimo reseteo de estadisticas
      if (runDate.millisecondsSinceEpoch >=
          overallStart.millisecondsSinceEpoch) {
        overallProgress += r.distance;
      }

      // copiar los datos calculados al mapa de estadisiticas
      stats["dailyProgress"] = dailyProgress;
      stats["weeklyProgress"] = weeklyProgress;
      stats["monthlyProgress"] = monthlyProgress;
      stats["overallProgress"] = overallProgress;
      stats["lastWeekPerDayDistance"] = lastWeekPerDayDistance;
    });
    return stats;
  }
}
