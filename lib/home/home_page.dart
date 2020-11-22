import 'package:entregable2/login/login_page.dart';
import 'package:entregable2/run/run_in_progress_widget.dart';
import 'package:entregable2/run/run_start_widget.dart';
import 'package:entregable2/run/run_completed_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:entregable2/history/history.dart';
import 'bloc/home_bloc.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeBloc _bloc;
  final List<String> _choices = [
    "Historial",
    "Objetivos",
    "Estadisticas",
    "Configuracion",
    "Cerrar Sesión"
  ];

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: BlocProvider(
        create: (context) {
          _bloc = HomeBloc();
          return _bloc;
        },
        child: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is RunSaveErrorState) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error!"),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is RunNotStartedState) {
              return RunStartWidget();
            }
            if (state is RunStartedState) {
              return RunInProgressWidget();
            }
            if (state is RunCompletedState) {
              return RunCompletedWidget(bloc: _bloc);
            }
            return Center(child: Container());
          },
        ),
      ),
    );
  }

  void _onActionSelected(selection) {
    if (selection == "Historial") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext ctx) {
            return History();
          },
        ),
      );
    }
    if (selection == "Cerrar Sesión") {
      FirebaseAuth.instance.signOut();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext ctx) {
            return LoginPage();
          },
        ),
      );
    }
    print(selection);
  }
}
