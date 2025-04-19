import 'dart:developer';
import 'package:sleepless_app/backend/services.dart';
import 'package:sleepless_app/backend/firebase_auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/error_model.dart';
import '../models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class SignUpRequested extends AuthEvent {
  const SignUpRequested(this.user);
  final UserRegistrationModel user;

  @override
  List<Object?> get props => [user];
}

class LoginRequested extends AuthEvent {
  const LoginRequested(this.user);
  final UserLoginModel user;

  @override
  List<Object?> get props => [user];
}

class SignOutRequested extends AuthEvent {}

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthenticatedState extends AuthState {
  const AuthenticatedState({
    required this.user,
  });

  final UserModel user;

  @override
  List<Object?> get props => [user];
}

class UnAuthenticatedState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthErrorState extends AuthState {
  const AuthErrorState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({AuthService? authService}) 
      : authService = authService ?? FirebaseAuthService(),
        super(AuthLoadingState()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignUpRequested>(_onSignUpRequested);
    on<LoginRequested>(_onLoginRequested);
    on<SignOutRequested>(_onSignOutRequested);
    add(CheckAuthStatus());
  }

  final AuthService authService;
  UserModel? currentUser;

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final user = await authService.checkForExistingUser();
      if (user != null) {
        currentUser = user;
        emit(AuthenticatedState(user: user));
      } else {
        emit(UnAuthenticatedState());
      }
    } catch (e) {
      emit(AuthErrorState(message: 'Failed to check auth status'));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final result = await authService.signUpWithEmailAndPassword(event.user);
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

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final authUser = await authService.logInWithEmailAndPassword(
          event.user.email, event.user.password);
      emit(AuthenticatedState(user: authUser));
    } catch (_) {
      emit(AuthErrorState(message: "Invalid credentials"));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      await authService.logout();
      emit(UnAuthenticatedState());
    } catch (e) {
      emit(AuthErrorState(message: 'Failed to sign out'));
    }
  }
}
