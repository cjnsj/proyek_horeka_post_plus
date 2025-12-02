import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_event.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_state.dart';
import 'package:horeka_post_plus/features/auth/data/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  Timer? _backgroundTimer;

  AuthBloc({required this.repository}) : super(const AuthState()) {
    on<CheckActivationStatusRequested>(_onCheckActivationStatus);
    on<ActivationRequested>(_onActivationRequested);
    on<FetchDeviceInfoRequested>(_onFetchDeviceInfo);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<BackgroundTicked>(_onBackgroundTicked);

    // Mulai timer carousel saat bloc dibuat (di halaman auth)
    _startBackgroundTimer();
  }

  void _startBackgroundTimer() {
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer.periodic(
      const Duration(seconds: 2), // ganti gambar tiap 2 detik
      (_) => add(const BackgroundTicked()),
    );
  }

  @override
  Future<void> close() {
    _backgroundTimer?.cancel();
    return super.close();
  }

  Future<void> _onCheckActivationStatus(
    CheckActivationStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final isActivated = await repository.checkActivationStatus();

      emit(state.copyWith(
        status: AuthStatus.success,
        isActivated: isActivated,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onActivationRequested(
    ActivationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await repository.activateDevice(event.activationCode);

      emit(state.copyWith(
        status: AuthStatus.success,
        isActivated: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
      emit(state.copyWith(status: AuthStatus.initial));
    }
  }

  Future<void> _onFetchDeviceInfo(
    FetchDeviceInfoRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final deviceInfo = await repository.getDeviceInfo();

      emit(state.copyWith(
        status: AuthStatus.success,
        branchName: deviceInfo['branch_name'],
        schedules: deviceInfo['schedules'],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final username = await repository.login(
        event.username,
        event.password,
        event.shiftId,
      );

      // STOP timer setelah login sukses (background di AuthPage tidak perlu lagi)
      _backgroundTimer?.cancel();

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        isAuthenticated: true,
        username: username,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
      emit(state.copyWith(status: AuthStatus.success));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await repository.logout();

    // Hidupkan lagi timer untuk halaman auth (welcome/login)
    _startBackgroundTimer();

    emit(const AuthState(
      status: AuthStatus.success,
      isActivated: true,
      isAuthenticated: false,
    ));
  }

  // Ganti index background untuk carousel
  Future<void> _onBackgroundTicked(
    BackgroundTicked event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(backgroundIndex: state.backgroundIndex + 1));
  }
}
