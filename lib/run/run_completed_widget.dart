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
  // lineas del poligono de la ruta recorrida
  Set<Polyline> routePolylines = Set<Polyline>();
  // Estado con datos de la carrera teminada
  RunCompletedState state;
  // nombre de la carrera introducido (guardado temporalmente en widget)
  String runName = "";
  String runNote = "";
  // variable que controlan si se muestra la entrada de texto para la nota y el nombre de carrera
  bool editingRunName = false;
  bool editingRunNote = false;
  TextEditingController runNameController = new TextEditingController();
  TextEditingController runNoteController = new TextEditingController();

  _RunCompletedWidgetState(HomeBloc bloc) {
    state = bloc.state;
    DateTime date = state.startDate;
    // generar un nombre de carrera por defecto , con la fecha y hora actual
    runName =
        "Carrera del ${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
    runNameController.value = TextEditingValue(text: runName);
  }

  // al cargarse el mapa
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // dibuja la ruta recorrida
    drawRoute();
    // ajusta el zoom para que la ruta sea visiable
    fitMarkers();
  }

  void drawRoute() {
    setState(() {
      // genera una linea poligiona de color rojo con los puntos (LatLng) de la ruta ,
      // pasados desde la pantalla anterior en el estado
      Polyline newPolyline = Polyline(
        polylineId: PolylineId(
          routePolylines.length.toString(),
        ),
        color: Colors.red,
        points: state.route,
      );
      // borrar cualquier otra linea
      routePolylines.clear();
      // agregar al mapa
      routePolylines.add(newPolyline);
    });
  }

  void fitMarkers() async {
    // punto de incio de ruta
    LatLng startMarkerLoc = state.route[0];
    // punto de termino de la ruta
    LatLng endMarkerLoc = state.route.last;
    // obtener coordenadas visible dentro del mapa (limites)
    LatLngBounds currentBounds = await mapController.getVisibleRegion();
    // El punto inciial esta en el mapa?
    bool startMarkerVisible = currentBounds.contains(startMarkerLoc);
    // El punto final esta en el mapa?
    bool endMarkerVisible = currentBounds.contains(endMarkerLoc);
    // mientras algunos de los puntos esten fuera del mapa
    while (!startMarkerVisible || !endMarkerVisible) {
      // comprobar otra vez
      startMarkerVisible = currentBounds.contains(startMarkerLoc);
      endMarkerVisible = currentBounds.contains(endMarkerLoc);
      // alejar el zoom.
      double currentZoom = await mapController.getZoomLevel();
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(startMarkerLoc, currentZoom - 0.5),
      );
    }
  }

  // convertir un intervalo de tiempo a cadena con formato "HH:MM:SS"
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

  // mostrar distancia en km o metros
  String formatDistance(double distance) {
    if (distance < 1000) {
      return "${distance.toStringAsFixed(0)} m";
    } else {
      double km = distance / 1000.0;
      return "${km.toStringAsFixed(1)} km";
    }
  }

  // mostrar solo 2 decimales en velocidad
  String formatSpeed(double speed) {
    return "${speed.toStringAsFixed(2)} km/h";
  }

  // al hacer clic en el icono editar , cambiar a modo de edicion de titulo de carrera
  void editRunName() {
    setState(() {
      editingRunName = true;
    });
  }

  // al hacer clic en el icono de guardar (check) , guardar el contenido de campo en la
  // variable para el nombre de carrera
  void saveRunName() {
    setState(() {
      runName = runNameController.text;
      editingRunName = false;
    });
  }

  // al hacer clic en el icono editar , cambiar a modo de edicion de titulo de carrera

  void editRunNote() {
    setState(() {
      editingRunNote = true;
    });
  }

// al hacer clic en el icono de guardar (check) , guardar el contenido de campo en la
  // variable para el nota de carrera
  void saveRunNote() {
    setState(() {
      runNote = runNoteController.text;
      editingRunNote = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // campo de texto de edicion de titulo
    TextField runNameField = TextField(
      controller: runNameController,
    );
    // campo de texto de edicion de titulo
    TextField runNoteField = TextField(
      controller: runNoteController,
    );
    // Fuera del modo de edicion no hay titulo mostrar un mensaje o mostrar titulo
    Text runNameLabel = Text(
      (runName != "") ? runName : "Agrega un titulo",
      style: Theme.of(context).textTheme.headline6,
    );

    // Fuera del modo de edicion si no hay titulo mostrar un mensaje o mostrar nota
    Text runNoteLabel = Text((runNote != "") ? runNote : "Agrega un nota",
        style: Theme.of(context).textTheme.bodyText1);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            // MAPA DE GOOGLE
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
            // campo de edicion de titu o texto con  titulo
            padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // si se esta editando mostrar campo de texto de lo contrario
                // mostrar texto de nota
                editingRunName ? Expanded(child: runNameField) : runNameLabel,
                // boton de guardar o de editar segun el modo actual
                IconButton(
                  icon: Icon(editingRunName ? Icons.check : Icons.edit),
                  onPressed: !editingRunName ? editRunName : saveRunName,
                )
              ],
            ),
          ),
          Padding(
            // campo de edicion de nota  , funciona de manera similar al anterior
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
          // Datos de carrera : Duracion
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
          // Datos de carrera : Distancia
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
          // Datos de carrera : velocidad
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
          // Datos de carrera : Velocidad maxima
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
          // GUARDAR CARRERA
          RaisedButton(
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            child: Text("Nueva Carrera"),
            onPressed: () {
              // El titulo no puede estar vacio , mostrar mensaje
              if (runName == "") {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text("La carrera debe tener nombre"),
                  ),
                );
              } else {
                // generar evento para guardar datos en firebase con todas las
                // estadisitcas de la carrera , titulo y nota
                // Adicionalmente , se pasa la referencia al mapa para poder generar
                // una captura de este en el Bloc
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
