import 'package:ai_performance_intelligence_platform/core/storage/token_storage.dart';
import 'package:ai_performance_intelligence_platform/features/auth/domain/usecases/login_usecase.dart';
import 'package:ai_performance_intelligence_platform/features/auth/presentation/bloc/auth_event.dart';
import 'package:ai_performance_intelligence_platform/features/auth/presentation/bloc/auth_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:ai_performance_intelligence_platform/features/auth/domain/usecases/signup_usecase.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignupUseCase signupUseCase;
  final TokenStorage tokenStorage;

  AuthBloc(this.loginUseCase, this.signupUseCase, this.tokenStorage)
    : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final token = await loginUseCase(event.email, event.password);
      await tokenStorage.saveToken(token);
      emit(AuthSuccess());
    } catch (e) {
      String message = e.toString();
      if (e is DioException) {
        message =
            e.response?.data['error'] ??
            e.message ??
            'An unknown error occurred';
      }
      emit(AuthFailure(message));
    }
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final token = await signupUseCase(event.email, event.password);
      await tokenStorage.saveToken(token);
      emit(AuthSuccess());
    } catch (e) {
      String message = e.toString();
      if (e is DioException) {
        message =
            e.response?.data['error'] ??
            e.message ??
            'An unknown error occurred';
      }
      emit(AuthFailure(message));
    }
  }
}
