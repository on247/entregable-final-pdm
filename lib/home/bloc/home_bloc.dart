import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as Ui;
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entregable2/models/run.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(RunNotStartedState());

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is RunStartEvent) {
      yield RunStartedState();
    } else if (event is RunCompleteEvent) {
      yield RunCompletedState(
        totalTime: event.totalTime,
        startDate: event.startDate,
        distance: event.distance,
        avgSpeed: event.avgSpeed,
        topSpeed: event.topSpeed,
        route: event.route,
      );
    } else if (event is RunEndEvent) {
      try {
        File mapImage = await _getMapSnapshot(event.map);
        String imageUrl = await _uploadPicture(mapImage);
        Run newRun = Run(
            totalTime: event.totalTime,
            startDate: event.startDate,
            distance: event.distance,
            avgSpeed: event.avgSpeed,
            topSpeed: event.topSpeed,
            title: event.title,
            note: event.note,
            mapImage: imageUrl);
        await _saveRun(newRun);
        yield RunNotStartedState();
      } catch (e) {
        // estado falso , revierte al anterior inmediatamente
        RunCompletedState prevState = this.state;
        yield RunSaveErrorState(
          error: e.toString(),
          prevState: prevState,
        );
        yield RunCompletedState(
          totalTime: event.totalTime,
          startDate: event.startDate,
          distance: event.distance,
          avgSpeed: event.avgSpeed,
          topSpeed: event.topSpeed,
          route: prevState.route,
        );
      }
    }
  }

  Future _saveRun(Run run) async {
    await FirebaseFirestore.instance
        .collection("carreras")
        .doc()
        .set(run.toJson());
  }

  Future<String> _uploadPicture(File image) async {
    String imagePath = image.path;
    // referencia al storage de firebase
    StorageReference reference = FirebaseStorage.instance
        .ref()
        .child("images/${Path.basename(imagePath)}");

    // subir el archivo a firebase
    StorageUploadTask uploadTask = reference.putFile(image);
    await uploadTask.onComplete;

    // recuperar la url del archivo que acabamos de subir
    dynamic imageURL = await reference.getDownloadURL();
    return imageURL;
  }

  Future<File> _getMapSnapshot(GoogleMapController map) async {
    Uint8List imageBytes = await map.takeSnapshot();
    Ui.Codec codec = await Ui.instantiateImageCodec(imageBytes);
    Ui.FrameInfo frame = await codec.getNextFrame();
    Ui.Image img = frame.image;
    ByteData byteData = await img.toByteData(format: Ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    Directory tmpDir = await getTemporaryDirectory();
    String tmpPath = tmpDir.path;
    var uuid = Uuid();
    String filename = uuid.v4() + ".png";
    String filePath = tmpPath + '/' + filename;
    return new File(filePath).writeAsBytes(pngBytes);
  }
}
