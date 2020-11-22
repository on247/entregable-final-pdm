import 'package:entregable2/history/bloc/history_bloc.dart';
import 'package:entregable2/models/run.dart';
import 'package:flutter/material.dart';

class RunDetails extends StatefulWidget {
  final Run carrera;
  final HistoryBloc bloc;
  RunDetails({
    @required this.carrera,
    @required this.bloc,
    Key key,
  }) : super(key: key);

  @override
  _RunDetailsState createState() => _RunDetailsState(this.bloc, this.carrera);
}

class _RunDetailsState extends State<RunDetails> {
  String runNote = "";
  String runName = "";
  bool editingRunName = false;
  bool editingRunNote = false;
  TextEditingController runNameController = new TextEditingController();
  TextEditingController runNoteController = new TextEditingController();

  _RunDetailsState(HistoryBloc bloc, Run carrera) {
    runName = carrera.title;
    runNote = carrera.note;
    runNameController.value = TextEditingValue(text: runName);
  }

  String formatTimer(Duration timer) {
    int seconds = timer.inSeconds % 60;
    String secondsText = seconds > 9 ? "$seconds" : "0$seconds";
    int minutes = timer.inMinutes % 60;
    String minutesText = minutes > 9 ? "$minutes" : "0$minutes";
    int hours = timer.inHours % 24;
    String hoursText = hours > 9 ? "$hours" : "0$hours";
    String timerText = "$hoursText:$minutesText:$secondsText";
    return timerText;
  }

  String formatDistance(double distance) {
    if (distance < 1000) {
      return "${distance.toStringAsFixed(0)} m";
    } else {
      double km = distance / 1000.0;
      return "${km.toStringAsFixed(1)} km";
    }
  }

  String formatSpeed(double speed) {
    return "${speed.toStringAsFixed(2)} km/h";
  }

  void editRunName() {
    setState(() {
      editingRunName = true;
    });
  }

  void saveRunName() {
    setState(() {
      runName = runNameController.text;
      editingRunName = false;
    });
  }

  void editRunNote() {
    setState(() {
      editingRunNote = true;
    });
  }

  void saveRunNote() {
    setState(() {
      runNote = runNoteController.text;
      editingRunNote = false;
    });
  }

  final List<String> _choices = [
    "Historial",
    "Objetivos",
    "Estadisticas",
    "Configuracion",
  ];

  @override
  Widget build(BuildContext context) {
    TextField runNameField = TextField(
      controller: runNameController,
    );
    TextField runNoteField = TextField(
      controller: runNoteController,
    );
    Text runNameLabel = Text(
      "$runName",
      style: Theme.of(context).textTheme.headline6,
    );
    Text runNoteLabel = Text((runNote != "") ? runNote : "Agrega un nota",
        style: Theme.of(context).textTheme.bodyText1);
    return Scaffold(
      appBar: AppBar(
        title: Text("Carrera"),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: _onActionSelected,
            itemBuilder: (context) => _choices
                .map(
                  (item) => PopupMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: Image.network(widget.carrera.mapImage),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  editingRunName ? Expanded(child: runNameField) : runNameLabel,
                  /*
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: !editingRunName ? editRunName : saveRunName,
                )
                */
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  editingRunNote ? Expanded(child: runNoteField) : runNoteLabel,
                  /*IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: !editingRunNote ? editRunNote : saveRunNote,
                )*/
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 8, 48, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Tiempo total:",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Expanded(child: Container()),
                  Text(
                    formatTimer(widget.carrera.totalTime),
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 8, 48, 8),
              child: Row(
                children: [
                  Text(
                    "Distancia Total:",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Expanded(child: Container()),
                  Text(
                    formatDistance(widget.carrera.distance),
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 8, 48, 8),
              child: Row(
                children: [
                  Text(
                    "Vel. Promedio:",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Expanded(child: Container()),
                  Text(
                    formatSpeed(widget.carrera.avgSpeed),
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 8, 48, 8),
              child: Row(
                children: [
                  Text(
                    "Vel. Máxima:",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Expanded(child: Container()),
                  Text(
                    formatSpeed(widget.carrera.topSpeed),
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ],
              ),
            ),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
    );
  }

  void _onActionSelected(selection) {
    print(selection);
  }
}
