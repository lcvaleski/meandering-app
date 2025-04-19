import 'dart:developer';
import 'package:sleepless_app/backend/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/error_model.dart';
import '../models/user_model.dart';

abstract class AuthState {}

class AuthenticatedState extends AuthState {
  AuthenticatedState({
    required this.user,
  });

  final UserModel user;
}

class UnAuthenticatedState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthErrorState extends AuthState {
  AuthErrorState({required this.message});

  final String message;
}

// 3. Error handling
class AuthBloc extends Cubit<AuthState> {
  AuthBloc(super.initialState, this.authService) {
    emit(AuthLoadingState());
    authService.checkForExistingUser().then(
      (value) {
        if (value != null) {
          currentUser = value;
          emit(AuthenticatedState(user: value));
        } else {
          emit(UnAuthenticatedState());
        }
      },
    );
  }

  final AuthService authService;
  UserModel? currentUser;

  Future<void> login({required final UserLoginModel user}) async {
    emit(AuthLoadingState());
    try {
      final authUser = await authService.logInWithEmailAndPassword(
          user.email, user.password);
      emit(AuthenticatedState(user: authUser));
    } catch (_) {
      emit(AuthErrorState(message: "Invalid credentials"));
    }
  }

  Future<void> signUp({required final UserRegistrationModel user}) async {
    emit(AuthLoadingState());
    try {
      final result = await authService.signUpWithEmailAndPassword(user);
      emit(AuthenticatedState(user: result));
    } catch (exception, stacktrace) {
      log('Error creating account $exception',
          stackTrace: stacktrace, level: 1000);
      if (exception is MeanderingException) {
        switch (exception.errorCode) {
          case 401:
            emit(AuthErrorState(message: "Email already in use"));
          case 402:
            emit(
              AuthErrorState(
                  message: 'Password should be at least 6 characters'),
            );
          case 403:
            emit(
              AuthErrorState(message: 'Not a valid email'),
            );
          default:
            emit(
              AuthErrorState(message: 'Something went wrong, please see logs'),
            );
        }
      }
    }
  }

  Future<void> logout() async {
    await authService.logout();
    emit(UnAuthenticatedState());
  }
}
