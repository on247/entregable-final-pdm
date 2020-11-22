import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:entregable2/history/bloc/history_bloc.dart';
import 'package:entregable2/history/history_list.dart';

class History extends StatefulWidget {
  const History({Key key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  void refresh() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial'),
      ),
      body: BlocProvider(
        create: (context) => HistoryBloc()..add(LoadHistoryEvent()),
        child: BlocConsumer<HistoryBloc, HistoryState>(
          listener: (context, state) {
            if (state is HistoryErrorState) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(state.errorMessage),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is HistoryLoadedState) {
              return HistoryList(
                bloc: BlocProvider.of<HistoryBloc>(context),
              );
            }
            return Center(
              child: Text("No hay carreras"),
            );
          },
        ),
      ),
    );
  }
}
