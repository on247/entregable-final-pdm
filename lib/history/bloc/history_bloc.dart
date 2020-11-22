import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entregable2/models/run.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  List<Run> _runList;
  List<Run> get listaCarreras => _runList;
  File chosenImage;
  HistoryBloc() : super(MisNoticiasInitial());

  @override
  Stream<HistoryState> mapEventToState(
    HistoryEvent event,
  ) async* {
    if (event is LoadHistoryEvent) {
      try {
        await _getAllRuns();
        yield HistoryLoadedState();
      } catch (e) {
        yield HistoryErrorState(
            errorMessage: "No se pudo descargar el historial");
      }
    }
  }

  Future _getAllRuns() async {
    // recuperar lista de docs guardados en Cloud firestore
    // agregar cada ojeto a una lista
    var carreras =
        await FirebaseFirestore.instance.collection("carreras").get();

    print("q");
    // QuerySnapshot query
    _runList =
        carreras.docs.map((elemento) => Run.fromJson(elemento.data())).toList();
  }
}
