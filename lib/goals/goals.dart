import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:entregable2/goals/bloc/goals_bloc.dart';

class Goals extends StatefulWidget {
  const Goals({Key key}) : super(key: key);

  @override
  _GoalsState createState() => _GoalsState();
}

class _GoalsState extends State<Goals> {
  // esta variable controla si esta en modo de edicion de algun objetivo
  bool editingGoalMonthly = false;
  bool editingGoalWeekly = false;
  bool editingGoalDaily = false;
  bool editingGoalOverall = false;
  // la meta que se ha establecido hasta el momento
  double currentGoalOverall = 0.0;
  double currentGoalMonthly = 0.0;
  double currentGoalWeekly = 0.0;
  double currentGoalDaily = 0.0;
  // controladores de campo de texto
  TextEditingController overallController = new TextEditingController();
  TextEditingController monthlyController = new TextEditingController();
  TextEditingController weeklyController = new TextEditingController();
  TextEditingController dailyController = new TextEditingController();

  // mostrar objetivo en m / km / o que no existe aun
  String formatDistance(double distance) {
    if (distance == 0.0) {
      return "no establecida";
    }
    if (distance < 1000) {
      return "${distance.toStringAsFixed(0)} m";
    } else {
      double km = distance / 1000.0;
      return "${km.toStringAsFixed(1)} km";
    }
  }

  // formato de fecha dd/mm/aaaa
  String formatDate(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  // a partir de la fecha incial de un periodo calcula cuanto retrmina
  DateTime getEndDate(DateTime startDate, int days) {
    return startDate.add(Duration(days: days));
  }

  // muestra un rango de fechas como dd/mm/aaaa - dd/mm/aaaa

  String formatPeriod(DateTime startDate, int days) {
    if (days == 1) {
      return formatDate(startDate);
    } else {
      DateTime endDate = getEndDate(startDate, days);
      return "${formatDate(startDate)} - ${formatDate(endDate)}";
    }
  }

  /////////////////////////////////////////////////////////////
  // activar edicion de metas y guardar metas para cada periodo
  // se introducen en kilometros y se almacenan internamente en m
  ////////////////////////////////////////////////////////////
  void editGoalOverall() {
    setState(() {
      editingGoalOverall = true;
      overallController.value =
          new TextEditingValue(text: (currentGoalOverall / 1000).toString());
    });
  }

  void saveGoalOverall() {
    setState(() {
      editingGoalOverall = false;
      currentGoalOverall = double.parse(overallController.text) * 1000;
    });
  }

  void editGoalMonthly() {
    setState(() {
      editingGoalMonthly = true;
      monthlyController.value =
          new TextEditingValue(text: (currentGoalMonthly / 1000).toString());
    });
  }

  void saveGoalMonthly() {
    setState(() {
      editingGoalMonthly = false;
      currentGoalMonthly = double.parse(monthlyController.text) * 1000;
    });
  }

  void editGoalWeekly() {
    setState(() {
      editingGoalWeekly = true;
      weeklyController.value =
          new TextEditingValue(text: (currentGoalWeekly / 1000).toString());
    });
  }

  void saveGoalWeekly() {
    setState(() {
      editingGoalWeekly = false;
      currentGoalWeekly = double.parse(weeklyController.text) * 1000;
    });
  }

  void editGoalDaily() {
    setState(() {
      editingGoalDaily = true;
      dailyController.value =
          new TextEditingValue(text: (currentGoalDaily / 1000).toString());
    });
  }

  void saveGoalDaily() {
    setState(() {
      editingGoalDaily = false;
      currentGoalDaily = double.parse(dailyController.text) * 1000;
    });
  }

  //////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Objetivos'),
      ),
      body: BlocProvider(
        create: (context) => GoalsBloc()..add(GetGoalsEvent()),
        child: BlocConsumer<GoalsBloc, GoalsState>(
          listener: (context, state) {
            if (state is GoalsLoadedState) {
              // copiar las metas actuales cargada de almacanamiento local en
              // el estado al las variables ten widget
              currentGoalOverall = state.overallGoal;
              currentGoalMonthly = state.monthlyGoal;
              currentGoalWeekly = state.weeklyGoal;
              currentGoalDaily = state.dailyGoal;
              // mostrar mensaje de exito
              if (state.message != null) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            if (state is GoalsLoadedState) {
              // widgets Text que muestra las metas guardadas temporalmente despues de editar o
              //al cargar pagina
              Widget overallGoalText = Text(
                formatDistance(currentGoalOverall),
                style: Theme.of(context).textTheme.headline6,
              );
              Widget monthlyGoalText = Text(
                formatDistance(currentGoalMonthly),
                style: Theme.of(context).textTheme.headline6,
              );
              Widget weeklyGoalText = Text(
                formatDistance(currentGoalWeekly),
                style: Theme.of(context).textTheme.headline6,
              );
              Widget dailyGoalText = Text(
                formatDistance(currentGoalDaily),
                style: Theme.of(context).textTheme.headline6,
              );
              // Campos de texto para editar cada meta
              Widget overallGoalInput = SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: overallController,
                ),
              );
              Widget monthlyGoalInput = SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: monthlyController,
                ),
              );
              Widget weeklyGoalInput = SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: weeklyController,
                ),
              );
              Widget dailyGoalInput = SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: dailyController,
                ),
              );
              return SingleChildScrollView(
                // para cada meta , la interfaz muestraa la meta on el campo de texte
                // segun se este editando o no cada meta
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
                            "Meta total:",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Expanded(child: Container()),
                          editingGoalOverall
                              ? overallGoalInput
                              : overallGoalText,
                          IconButton(
                            icon: Icon(
                                editingGoalOverall ? Icons.check : Icons.edit),
                            onPressed: !editingGoalOverall
                                ? editGoalOverall
                                : saveGoalOverall,
                          )
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
                          editingGoalMonthly
                              ? monthlyGoalInput
                              : monthlyGoalText,
                          IconButton(
                            icon: Icon(
                                editingGoalMonthly ? Icons.check : Icons.edit),
                            onPressed: !editingGoalMonthly
                                ? editGoalMonthly
                                : saveGoalMonthly,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 0, 48, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            formatPeriod(state.monthlyStartDate, 30),
                            style: Theme.of(context).textTheme.bodyText2,
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
                          editingGoalWeekly ? weeklyGoalInput : weeklyGoalText,
                          IconButton(
                            icon: Icon(
                                editingGoalWeekly ? Icons.check : Icons.edit),
                            onPressed: !editingGoalWeekly
                                ? editGoalWeekly
                                : saveGoalWeekly,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 0, 48, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            formatPeriod(state.weeklyStartDate, 7),
                            style: Theme.of(context).textTheme.bodyText2,
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
                          editingGoalDaily ? dailyGoalInput : dailyGoalText,
                          IconButton(
                            icon: Icon(
                                editingGoalDaily ? Icons.check : Icons.edit),
                            onPressed: !editingGoalDaily
                                ? editGoalDaily
                                : saveGoalDaily,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 0, 48, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            formatPeriod(state.dailyStartDate, 1),
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ],
                      ),
                    ),
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text("Guardar"),
                      onPressed: () {
                        BlocProvider.of<GoalsBloc>(context).add(SaveGoalsEvent(
                          goalOverall: currentGoalOverall,
                          goalMonthly: currentGoalMonthly,
                          goalWeekly: currentGoalWeekly,
                          goalDaily: currentGoalDaily,
                        ));
                      },
                    )
                  ],
                ),
              );
            }
            return Center(
              child: Text("Cargando obejtivos.."),
            );
          },
        ),
      ),
    );
  }
}
