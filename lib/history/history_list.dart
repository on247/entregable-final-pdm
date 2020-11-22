import 'package:entregable2/models/run.dart';
import 'package:flutter/material.dart';
import 'package:entregable2/history/bloc/history_bloc.dart';
import 'package:entregable2/history/history_item.dart';
import 'package:entregable2/history/run_details.dart';

class HistoryList extends StatefulWidget {
  final HistoryBloc bloc;
  HistoryList({Key key, @required this.bloc}) : super(key: key);

  @override
  _HistoryListState createState() => _HistoryListState(bloc: bloc);
}

void openDetails(BuildContext context, Run run, HistoryBloc bloc) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext ctx) {
        return RunDetails(carrera: run, bloc: bloc);
      },
    ),
  );
}

class _HistoryListState extends State<HistoryList> {
  HistoryBloc bloc;
  _HistoryListState({@required this.bloc});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
          itemCount: widget.bloc.listaCarreras.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              child: HistoryItem(
                carrera: widget.bloc.listaCarreras[index],
              ),
              onTap: () {
                HistoryBloc _bloc = bloc;
                openDetails(context, widget.bloc.listaCarreras[index], _bloc);
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            widget.bloc.add(LoadHistoryEvent());
            setState(() {});
          },
          child: Icon(Icons.refresh),
        ));
  }
}
