part of 'history_bloc.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

class MisNoticiasInitial extends HistoryState {}

class HistoryLoadedState extends HistoryState {}

class HistoryErrorState extends HistoryState {
  final String errorMessage;

  HistoryErrorState({@required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
