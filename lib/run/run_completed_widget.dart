import 'package:entregable2/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RunCompletedWidget extends StatefulWidget {
  final HomeBloc bloc;
  RunCompletedWidget({
    @required this.bloc,
    Key key,
  }) : super(key: key);

  @override
  _RunCompletedWidgetState createState() => _RunCompletedWidgetState(this.bloc);
}

class _RunCompletedWidgetState extends State<RunCompletedWidget> {
  GoogleMapController mapController;
  Set<Polyline> routePolylines = Set<Polyline>();
  RunCompletedState state;
  String runName = "";
  String runNote = "";
  bool editingRunName = false;
  bool editingRunNote = false;
  TextEditingController runNameController = new TextEditingController();
  TextEditingController runNoteController = new TextEditingController();

  _RunCompletedWidgetState(HomeBloc bloc) {
    state = bloc.state;
    DateTime date = state.startDate;
    runName =
        "Carrera del ${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
    runNameController.value = TextEditingValue(text: runName);
  }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    drawRoute();
    fitMarkers();
  }

  void drawRoute() {
    setState(() {
      Polyline newPolyline = Polyline(
        polylineId: PolylineId(
          routePolylines.length.toString(),
        ),
        color: Colors.red,
        points: state.route,
      );
      routePolylines.clear();
      routePolylines.add(newPolyline);
    });
  }

  void fitMarkers() async {
    LatLng startMarkerLoc = state.route[0];
    LatLng endMarkerLoc = state.route.last;
    LatLngBounds currentBounds = await mapController.getVisibleRegion();
    bool startMarkerVisible = currentBounds.contains(startMarkerLoc);
    bool endMarkerVisible = currentBounds.contains(endMarkerLoc);
    if (!startMarkerVisible || !endMarkerVisible) {
      double currentZoom = await mapController.getZoomLevel();
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(startMarkerLoc, currentZoom - 0.5),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    TextField runNameField = TextField(
      controller: runNameController,
    );
    TextField runNoteField = TextField(
      controller: runNoteController,
    );
    Text runNameLabel = Text(
      (runName != "") ? runName : "Agrega un titulo",
      style: Theme.of(context).textTheme.headline6,
    );
    Text runNoteLabel = Text((runNote != "") ? runNote : "Agrega un nota",
        style: Theme.of(context).textTheme.bodyText1);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              polylines: routePolylines,
              initialCameraPosition: CameraPosition(
                target: state.route[0],
                zoom: 15.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                editingRunName ? Expanded(child: runNameField) : runNameLabel,
                IconButton(
                  icon: Icon(editingRunName ? Icons.check : Icons.edit),
                  onPressed: !editingRunName ? editRunName : saveRunName,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                editingRunNote ? Expanded(child: runNoteField) : runNoteLabel,
                IconButton(
                  icon: Icon(editingRunNote ? Icons.check : Icons.edit),
                  onPressed: !editingRunNote ? editRunNote : saveRunNote,
                )
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
                  formatTimer(state.totalTime),
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
                  formatDistance(state.distance),
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
                  formatSpeed(state.avgSpeed),
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
                  formatSpeed(state.topSpeed),
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ),
          RaisedButton(
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            child: Text("Nueva Carrera"),
            onPressed: () {
              if (runName == "") {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text("La carrera debe tener nombre"),
                  ),
                );
              } else {
                BlocProvider.of<HomeBloc>(context).add(
                  RunEndEvent(
                    title: runName,
                    note: runNote,
                    totalTime: state.totalTime,
                    startDate: state.startDate,
                    distance: state.distance,
                    avgSpeed: state.avgSpeed,
                    topSpeed: state.topSpeed,
                    map: mapController,
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
