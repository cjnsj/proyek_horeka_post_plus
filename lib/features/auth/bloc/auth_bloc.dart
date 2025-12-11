import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_event.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_state.dart';
import 'package:horeka_post_plus/features/auth/data/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  Timer? _backgroundTimer;

  AuthBloc({required this.repository}) : super(const AuthState()) {
    // --- [BARU] Handler untuk Cek Status Login Otomatis ---
    on<AppStarted>(_onAppStarted);

    // --- Handler Lainnya ---
    on<CheckActivationStatusRequested>(_onCheckActivationStatus);
    on<ActivationRequested>(_onActivationRequested);
    on<FetchDeviceInfoRequested>(_onFetchDeviceInfo);
    on<LoginRequested>(_onLoginRequested);
    on<ValidatePinRequested>(_onValidatePinRequested);
    on<OpenShiftRequested>(_onOpenShiftRequested);
    on<CloseShiftRequested>(_onCloseShiftRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<BackgroundTicked>(_onBackgroundTicked);

    // Mulai timer untuk animasi background di halaman login
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

  // ===========================================================================
  // [BARU] HANDLER CEK TOKEN SAAT APLIKASI DIMULAI
  // ===========================================================================
  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    // Kita set status loading sebentar (opsional, bisa langsung cek)
    // emit(state.copyWith(status: AuthStatus.loading)); 

    try {
      // 1. Cek apakah device sudah diaktivasi (Penting!)
      final isActivated = await repository.checkActivationStatus();

      if (!isActivated) {
        // Jika belum aktivasi, arahkan ke halaman aktivasi
        emit(state.copyWith(
          status: AuthStatus.success, // Atau initial
          isActivated: false,
          isAuthenticated: false,
        ));
        return;
      }

      // 2. Jika sudah aktivasi, ambil Info Device (Cabang & Jadwal Shift)
      // Ini penting agar saat logout nanti data cabang tidak hilang
      Map<String, dynamic> deviceInfo = {};
      try {
        deviceInfo = await repository.getDeviceInfo();
      } catch (_) {
        // Abaikan jika gagal fetch info saat start (mungkin offline), lanjut cek token
      }

      // 3. Cek apakah User punya Token Login (Auto Login)
      final hasToken = await repository.hasToken();

      if (hasToken) {
        // STOP Timer Background karena user sudah masuk dashboard
        _backgroundTimer?.cancel();

        emit(state.copyWith(
          status: AuthStatus.authenticated, // Langsung ke Dashboard
          isActivated: true,
          isAuthenticated: true,
          // Isi data cabang jika berhasil fetch tadi
          branchName: deviceInfo['branch_name'] ?? state.branchName,
          schedules: deviceInfo['schedules'] ?? state.schedules,
        ));
      } else {
        // Jika tidak ada token, User harus Login
        emit(state.copyWith(
          status: AuthStatus.unauthenticated, // Ke Login Page
          isActivated: true,
          isAuthenticated: false,
          branchName: deviceInfo['branch_name'] ?? state.branchName,
          schedules: deviceInfo['schedules'] ?? state.schedules,
        ));
      }
    } catch (e) {
      // Jika terjadi error parah, reset ke unauthenticated
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        isActivated: true, // Asumsi activated agar tidak stuck di aktivasi
        isAuthenticated: false,
      ));
    }
  }

  // ===========================================================================
  // HANDLER LAINNYA (SAMA SEPERTI SEBELUMNYA)
  // ===========================================================================

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
      // Reset status ke success/initial agar UI tidak stuck loading
      emit(state.copyWith(status: AuthStatus.unauthenticated)); 
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
      // Kembalikan ke authenticated agar tidak keluar dari halaman dashboard (jika logic menghendaki)
      // Atau tetap di state error untuk dialog
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

  Future<void> _onCloseShiftRequested(
    CloseShiftRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await repository.closeShift();
      await repository.logout();
      _startBackgroundTimer();

      emit(AuthState(
        status: AuthStatus.unauthenticated, // Arahkan ke Login Page
        isActivated: true,
        isAuthenticated: false,
        isShiftOpen: false,
        isPinValidated: false,
        branchName: state.branchName, // Pertahankan Nama Cabang
        schedules: state.schedules,   // Pertahankan Jadwal Shift
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

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Logout manual (tombol logout)
    await repository.logout();
    _startBackgroundTimer();
    
    emit(AuthState(
      status: AuthStatus.unauthenticated, // Arahkan ke Login Page
      isActivated: true,
      isAuthenticated: false,
      isShiftOpen: false,
      isPinValidated: false,
      branchName: state.branchName, // Pertahankan Nama Cabang
      schedules: state.schedules,   // Pertahankan Jadwal Shift
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