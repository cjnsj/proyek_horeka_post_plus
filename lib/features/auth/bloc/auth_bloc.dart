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
    on<ValidatePinRequested>(_onValidatePinRequested);
    on<OpenShiftRequested>(_onOpenShiftRequested);
    on<CloseShiftRequested>(_onCloseShiftRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<BackgroundTicked>(_onBackgroundTicked);

    _startBackgroundTimer();
  }

  void _startBackgroundTimer() {
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => add(const BackgroundTicked()),
    );
  }

  @override
  Future<void> close() {
    _backgroundTimer?.cancel();
    return super.close();
  }

  // ... (Handler CheckActivation, Activation, FetchDevice, Login, ValidatePin, OpenShift TETAP SAMA) ...
  // Copy dari kode sebelumnya untuk handler-handler di atas.

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
      
      _backgroundTimer?.cancel();
      
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        isAuthenticated: true,
        username: username,
        isShiftOpen: false,
        isPinValidated: false, 
        tempCashierId: null,
        tempCashierName: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
      emit(state.copyWith(status: AuthStatus.success));
    }
  }

  Future<void> _onValidatePinRequested(
    ValidatePinRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final result = await repository.validatePin(event.pin);
      
      emit(state.copyWith(
        status: AuthStatus.success,
        isPinValidated: true,
        tempCashierId: result['cashier_id'],
        tempCashierName: result['full_name'],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error, 
        errorMessage: e.toString(),
        isPinValidated: false,
      ));
      emit(state.copyWith(status: AuthStatus.authenticated)); 
    }
  }

  Future<void> _onOpenShiftRequested(
    OpenShiftRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await repository.openShift(event.cashierId, event.openingCash);
      
      emit(state.copyWith(
        status: AuthStatus.success,
        isShiftOpen: true,
        isPinValidated: false,
        tempCashierId: null,
        tempCashierName: null,
      ));
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.toLowerCase().contains('already active') || 
          errorMessage.toLowerCase().contains('sudah aktif')) {
        emit(state.copyWith(
          status: AuthStatus.success,
          isShiftOpen: true,
          isPinValidated: false,
          tempCashierId: null,
          tempCashierName: null,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error, 
          errorMessage: errorMessage,
          isShiftOpen: false,
        ));
        emit(state.copyWith(status: AuthStatus.authenticated)); 
      }
    }
  }

  // --- [PERBAIKAN] Handler Tutup Shift ---
  Future<void> _onCloseShiftRequested(
    CloseShiftRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await repository.closeShift();
      await repository.logout();
      _startBackgroundTimer();

      // [FIX]: Jangan pakai const AuthState() karena akan mereset branchName.
      // Gunakan nilai dari state saat ini.
      emit(AuthState(
        status: AuthStatus.success,
        isActivated: true,
        isAuthenticated: false, // Trigger navigasi ke Login
        isShiftOpen: false,
        isPinValidated: false,
        branchName: state.branchName, // [PENTING] Pertahankan Nama Cabang
        schedules: state.schedules,   // [PENTING] Pertahankan Jadwal Shift
        backgroundIndex: state.backgroundIndex,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error, 
        errorMessage: "Gagal Tutup Shift: ${e.toString()}",
      ));
      emit(state.copyWith(status: AuthStatus.authenticated));
    }
  }

  // --- [PERBAIKAN] Handler Logout Biasa ---
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await repository.logout();
    _startBackgroundTimer();
    
    // [FIX]: Pertahankan data cabang dan jadwal
    emit(AuthState(
      status: AuthStatus.success,
      isActivated: true,
      isAuthenticated: false,
      isShiftOpen: false,
      isPinValidated: false,
      branchName: state.branchName, // [PENTING] Pertahankan Nama Cabang
      schedules: state.schedules,   // [PENTING] Pertahankan Jadwal Shift
      backgroundIndex: state.backgroundIndex,
    ));
  }

  Future<void> _onBackgroundTicked(
    BackgroundTicked event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(backgroundIndex: state.backgroundIndex + 1));
  }
}