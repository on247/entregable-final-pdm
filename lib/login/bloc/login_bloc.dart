import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter/foundation.dart';
import 'package:entregable2/auth/user_auth_provider.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  UserAuthProvider _authProvider = UserAuthProvider();

  LoginBloc() : super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is VerifyLogInEvent) {
      try {
        if (_authProvider.isAlreadyLogged())
          yield LoginSuccessState();
        else
          yield LoginInitial();
      } catch (e) {
        print(e.toString());
        yield LoginInitial();
      }
    } else if (event is LoginWithGoogleEvent) {
      try {
        yield LoginLoadingState();
        String errorCode = await _authProvider.signInWithGoogle();
        if (errorCode != null) {
          String errorMessage = UserAuthProvider.errorMessages[errorCode];
          yield LoginErrorState(error: errorMessage, code: errorCode);
        } else {
          yield LoginSuccessState();
        }
        // open home page widget
      } catch (e) {
        print(e.toString());
        yield LoginErrorState(
          error: "Error al hacer login con Google: ${e.toString()}",
        );
      }
    } else if (event is LoginWithFacebookEvent) {
      yield LoginLoadingState();
      String errorCode = await _authProvider.signInWithFacebook();
      if (errorCode != null) {
        String errorMessage = UserAuthProvider.errorMessages[errorCode];
        yield LoginErrorState(error: errorMessage, code: errorCode);
      } else {
        yield LoginSuccessState();
      }
    } else if (event is RegisterWithEmailEvent) {
      yield LoginLoadingState();
      String errorCode =
          await _authProvider.registerWithEmail(event.email, event.password);
      if (errorCode != null) {
        String errorMessage = UserAuthProvider.errorMessages[errorCode];
        yield LoginErrorState(error: errorMessage, code: errorCode);
      } else {
        yield LoginSuccessState();
      }
    } else if (event is LoginWithEmailEvent) {
      yield LoginLoadingState();
      String errorCode =
          await _authProvider.signInWithEmail(event.email, event.password);
      if (errorCode != null) {
        String errorMessage = UserAuthProvider.errorMessages[errorCode];
        yield LoginErrorState(error: errorMessage, code: errorCode);
      } else {
        yield LoginSuccessState();
      }
    } else if (event is ForgotPasswordEvent) {
      yield LoginLoadingState();
      String errorCode = await _authProvider.resetPassword(event.email);
      if (errorCode != null) {
        String errorMessage = UserAuthProvider.errorMessages[errorCode];
        yield LoginErrorState(error: errorMessage, code: errorCode);
      } else {
        yield LoginErrorState(
            error: "Correo de recuperacion de contraseña enviado");
      }
    }
  }
}
