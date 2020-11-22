part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class VerifyLogInEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class LoginWithFacebookEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class LoginWithGoogleEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class RegisterWithEmailEvent extends LoginEvent {
  final String email;
  final String password;

  RegisterWithEmailEvent({@required this.email, @required this.password});

  @override
  List<Object> get props => [];
}

class LoginWithEmailEvent extends LoginEvent {
  final String email;
  final String password;

  LoginWithEmailEvent({@required this.email, @required this.password});

  @override
  List<Object> get props => [];
}

class ForgotPasswordEvent extends LoginEvent {
  final String email;

  ForgotPasswordEvent({@required this.email});
  @override
  List<Object> get props => [];
}
