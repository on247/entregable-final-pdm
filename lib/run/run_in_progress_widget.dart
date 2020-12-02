import 'dart:async';
import 'dart:math';
import 'package:entregable2/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class RunInProgressWidget extends StatefulWidget {
  RunInProgressWidget({
    Key key,
  }) : super(key: key);

  @override
  _RunInProgressWidgetState createState() => _RunInProgressWidgetState();
}

class _RunInProgressWidgetState extends State<RunInProgressWidget> {
  GoogleMapController mapController;
  StreamSubscription<Position> positionStream;
  Stopwatch stopwatch = new Stopwatch();
  Stream<int> timerStream;
  bool timerRunning = true;
  int prevTime = 0;
  Set<Marker> markers = Set<Marker>();
  Marker endMarker;
  Marker startMarker;
  final LatLng _center = const LatLng(45.521563, -122.677433);
  List<LatLng> route;
  LatLng prevLocation;

  Set<Polyline> routePolylines = Set<Polyline>();
  List<LatLng> routePoints = List<LatLng>();

  final DateTime startTime = DateTime.now();
  double speed = 0.0;
  double distance = 0.0;
  double avgSpeed = 0.0;
  double topSpeed = 0.0;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    getInitialPosition();
  }

  Stream<int> generateTimerStream() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      yield stopwatch.elapsedMilliseconds;
    }
  }

  String getTimerText() {
    int seconds = stopwatch.elapsed.inSeconds % 60;
    String secondsText = seconds > 9 ? "$seconds" : "0$seconds";
    int minutes = stopwatch.elapsed.inMinutes % 60;
    String minutesText = minutes > 9 ? "$minutes" : "0$minutes";
    int hours = stopwatch.elapsed.inHours % 24;
    String hoursText = hours > 9 ? "$hours" : "0$hours";
    String timerText = "$hoursText:$minutesText:$secondsText";
    return timerText;
  }

  void pauseTimer() {
    stopwatch.stop();
    timerRunning = false;
  }

  void resumeTimer() {
    stopwatch.start();
    timerRunning = true;
  }

  void getInitialPosition() async {
    // obtener ubicacion de inicio
    Position position = await Geolocator.getCurrentPosition();
    LatLng initialPosition = toLng(position);
    // agregar un marcador con la ubicacion de inicio
    startMarker =
        Marker(markerId: MarkerId("Start"), position: initialPosition);
    markers.add(startMarker);
    // guardar ubicacion , despues se usara como ubicacion previa para calcular distancias
    prevLocation = initialPosition;
    // mover el mapa a la ubicacion inicial
    setState(() {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: initialPosition,
            zoom: 17.0,
          ),
        ),
      );
    });
  }

  void saveLocation(Position position) {
    // guardar ubicacion previa y agregar a la lista de puntos de la ruta
    prevLocation = toLng(position);
    routePoints.add(prevLocation);
  }

  // ajustar nivel de zoom para que la ruta completa sea visible
  void fitMarkers() async {
    LatLng startMarkerLoc = startMarker.position;
    LatLng endMarkerLoc = endMarker.position;
    if (startMarker.position == endMarker.position) {
      return;
    }
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

  // mover el marcado que indica el fin de la ruta (la ubicacion actual)
  void updateCurrentLocationMarker(Position position) {
    // quitar el marcador de fin que ya esta en mapa
    markers.remove(endMarker);
    // crear marcador nuevo
    LatLng markerPosition = new LatLng(position.latitude, position.longitude);
    endMarker = Marker(
      markerId: MarkerId("2"),
      position: markerPosition,
    );
    // agregar a map
    markers.add(endMarker);
  }

  // genera una linea poligiona de color rojo con los puntos (LatLng) de la ruta ,
  // pasados desde la pantalla anterior en el estado
  void updateRoutePolygon() {
    Polyline newPolyline = Polyline(
        polylineId: PolylineId(
          routePolylines.length.toString(),
        ),
        color: Colors.red,
        points: routePoints);
    routePolylines.clear();
    routePolylines.add(newPolyline);
  }

  // calula las estadisitcas actuales segun la ubicacion previa , la actual y
  // tiempo transcurrido entre actualizaciones de GPS
  void updateStats(Position newPosition) {
    int deltaTime = stopwatch.elapsedMilliseconds - prevTime;
    prevTime = stopwatch.elapsedMilliseconds;
    LatLng newLocation = toLng(newPosition);
    // calculo de metros recorridos entre las ubicaciones previa actual
    double deltaMeters = Geolocator.distanceBetween(prevLocation.latitude,
        prevLocation.longitude, newLocation.latitude, newLocation.longitude);
    // agregar a distancia total
    distance += deltaMeters;
    // calcular velocidad instanea
    speed = deltaMeters * (1000.0 / deltaTime) * 3.6;
    // vel promedio y maxima
    avgSpeed = ((distance * 1000.0) / stopwatch.elapsedMilliseconds) * 3.6;
    topSpeed = max(topSpeed, speed);
  }

  @override
  void initState() {
    super.initState();
    // al inciar la pantalla
    // inciar el contador de reloj;
    stopwatch.start();
    // iniciar el timer para la actualizacion del cronometro
    // refresh cada 1 s
    timerStream = generateTimerStream();
    // inciar stream de ubicaciones
    positionStream = Geolocator.getPositionStream(distanceFilter: 10)
        .listen((Position position) {
      setState(() {
        // para cada actualizacion

        if (timerRunning) {
          // mover el marcador de ubicacion actual
          updateCurrentLocationMarker(position);
          // recalcular estadisticas , solo si se pudo obtener una nueva ubicacion
          if (prevLocation != null) {
            updateStats(position);
          }
          // guardar la ubicacion actual
          saveLocation(position);
          // ajustar el mapa
          fitMarkers();
          // redibujar la ruta
          updateRoutePolygon();
        }
        // si cronometro esta detenido la velocidadas es 0 , no se esta
        // corriendo.
        else {
          speed = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  LatLng toLng(Position pos) {
    if (pos == null) {
      return _center;
    }
    return LatLng(pos.latitude, pos.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            polylines: routePolylines,
            markers: markers,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 17.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(48, 8, 48, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Tiempo transcurrido",
                style: Theme.of(context).textTheme.headline6,
              ),
            ],
          ),
        ),
        StreamBuilder<Object>(
            stream: timerStream,
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(48, 8, 48, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getTimerText(),
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    IconButton(
                      icon: timerRunning
                          ? Icon(Icons.pause_circle_filled)
                          : Icon(Icons.play_circle_fill),
                      onPressed: timerRunning ? pauseTimer : resumeTimer,
                    )
                  ],
                ),
              );
            }),
        Padding(
          padding: const EdgeInsets.fromLTRB(48, 8, 48, 8),
          child: Row(
            children: [
              Text(
                "Distancia:",
                style: Theme.of(context).textTheme.headline5,
              ),
              Expanded(child: Container()),
              Text(
                distance < 1000.0
                    ? "${distance.toStringAsFixed(0)}"
                    : "${(distance / 1000).toStringAsFixed(1)} km",
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
                "Velocidad:",
                style: Theme.of(context).textTheme.headline5,
              ),
              Expanded(child: Container()),
              Text(
                "${speed.toStringAsFixed(2)} km/h",
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
                "Vel promedio:",
                style: Theme.of(context).textTheme.headline5,
              ),
              Expanded(child: Container()),
              Text(
                "${avgSpeed.toStringAsFixed(2)} km/h",
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
        ),
        RaisedButton(
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          child: Text("Terminar Carrera"),
          onPressed: () {
            // al terminar carrera emite estado con estadisticas y la ruta
            BlocProvider.of<HomeBloc>(context).add(RunCompleteEvent(
                totalTime: stopwatch.elapsed,
                startDate: startTime,
                distance: distance,
                avgSpeed: avgSpeed,
                topSpeed: topSpeed,
                route: routePoints));
          },
        )
      ],
    ));
  }
}
