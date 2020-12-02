import 'package:entregable2/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RunStartWidget extends StatefulWidget {
  RunStartWidget({
    Key key,
  }) : super(key: key);

  @override
  _RunStartWidgetState createState() => _RunStartWidgetState();
}

class _RunStartWidgetState extends State<RunStartWidget> {
  GoogleMapController mapController;

  // ubicacion actual.
  Position position;
  // ubicacion por defecto
  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getStartLocation();
  }

  // obtner ubicacion actual y mostrar mapa
  void _getStartLocation() async {
    // leer ubicacion
    position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    mapController.moveCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // MAPA DE GOOGLE
          SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center, // ubicacion por defecto
                zoom: 15.0,
              ),
            ),
          ),
          // BOTON DE INICIO
          RaisedButton(
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            child: Text("Iniciar Carrera"),
            onPressed: () {
              // Emitir evento de incio de carrera , pasando a carrera en progreso
              BlocProvider.of<HomeBloc>(context).add(RunStartEvent());
            },
          )
        ],
      ),
    );
  }
}
