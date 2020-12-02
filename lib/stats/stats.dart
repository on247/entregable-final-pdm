import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/stats_bloc.dart';

class Stats extends StatefulWidget {
  const Stats({Key key}) : super(key: key);

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  String formatDistance(double distance) {
    if (distance < 1000) {
      return "${distance.toStringAsFixed(0)} m";
    } else {
      double km = distance / 1000.0;
      return "${km.toStringAsFixed(1)} km";
    }
  }

  String formatDate(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  DateTime getEndDate(DateTime startDate, int days) {
    return startDate.add(Duration(days: days));
  }

  String formatPeriod(DateTime startDate, int days) {
    if (days == 1) {
      return formatDate(startDate);
    } else {
      DateTime endDate = getEndDate(startDate, days);
      return "${formatDate(startDate)} - ${formatDate(endDate)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadisticas'),
      ),
      body: BlocProvider(
        create: (context) => StatsBloc()..add(GetStatsEvent()),
        child: BlocConsumer<StatsBloc, StatsState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is StatsLoadedState) {
              DateTime currentDate = DateTime.now();
              int currentDay = currentDate.day;
              List<FlSpot> chartPoints = List<FlSpot>();
              List<int> chartDays = List<int>();
              int spotId = 6;
              state.lastWeekPerDayDistance.forEach((double val) {
                FlSpot newChartPoint = FlSpot(spotId.toDouble(), val / 1000);
                chartPoints.add(newChartPoint);
                chartDays.add(currentDay);
                currentDate = currentDate.subtract(Duration(days: 1));
                currentDay = currentDate.day;
                spotId--;
              });

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 16, 48, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Progreso de objetivos",
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 16, 48, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Meta total:",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Expanded(child: Container()),
                          Text(
                            "${formatDistance(state.overallProgress)} / ${formatDistance(state.overallGoal)}",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 16, 48, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.deepOrange[200],
                              value: min(
                                  1, state.overallProgress / state.overallGoal),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.deepOrange),
                              minHeight: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 16, 48, 0),
                      child: Row(
                        children: [
                          Text(
                            "Mensual",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Expanded(child: Container()),
                          Text(
                            "${formatDistance(state.monthlyProgress)} / ${formatDistance(state.monthlyGoal)}",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 16, 48, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.deepOrange[200],
                              value: min(
                                  1, state.monthlyProgress / state.monthlyGoal),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.deepOrange),
                              minHeight: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 16, 48, 0),
                      child: Row(
                        children: [
                          Text(
                            "Semanal",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Expanded(child: Container()),
                          Text(
                            "${formatDistance(state.weeklyProgress)} / ${formatDistance(state.weeklyGoal)}",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 16, 48, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.deepOrange[200],
                              value: min(
                                  1, state.weeklyProgress / state.weeklyGoal),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.deepOrange),
                              minHeight: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 16, 48, 0),
                      child: Row(
                        children: [
                          Text(
                            "Diaria:",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Expanded(child: Container()),
                          Text(
                            "${formatDistance(state.dailyProgress)} / ${formatDistance(state.dailyGoal)}",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 16, 48, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.deepOrange[200],
                              value:
                                  min(1, state.dailyProgress / state.dailyGoal),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.deepOrange),
                              minHeight: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 16, 48, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Ultima semana",
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 16, 48, 0),
                      child: LineChart(
                        LineChartData(
                          titlesData: FlTitlesData(
                            leftTitles: SideTitles(
                              interval: 0.5,
                              showTitles: true,
                              getTitles: (value) {
                                return "$value km";
                              },
                              getTextStyles: (value) => const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            bottomTitles: SideTitles(
                                showTitles: true,
                                getTextStyles: (value) => const TextStyle(
                                    fontSize: 12,
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold),
                                getTitles: (value) {
                                  int idx = 6 - value.toInt();
                                  return chartDays[idx].toString();
                                }),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: chartPoints,
                              belowBarData: BarAreaData(
                                show: true,
                                colors: [
                                  Colors.deepOrange,
                                  Colors.deepOrange[200],
                                ],
                                gradientColorStops: [0.5, 1.0],
                                gradientFrom: const Offset(0, 0),
                                gradientTo: const Offset(0, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: Text("Cargando estadisticas."),
            );
          },
        ),
      ),
    );
  }
}
