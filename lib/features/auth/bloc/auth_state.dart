import 'package:equatable/equatable.dart';

// [PERBAIKAN] Menambahkan 'unauthenticated' ke dalam enum
enum AuthStatus {
  initial,
  loading,
  success,
  error,
  authenticated,
  unauthenticated, // <--- Opsi ini WAJIB ada untuk fitur Auto Login
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final bool isActivated;
  final bool isAuthenticated;

  final bool isShiftOpen; // Status Shift (Langkah 2 sukses)
  final bool isPinValidated; // Status Validasi PIN (Langkah 1 sukses)

  final String? username;
  final String branchName;

  // Menggunakan List<dynamic> agar lebih aman saat menerima data JSON dari BLoC
  final List<dynamic> schedules;

  final int backgroundIndex;

  // Data sementara setelah validasi PIN berhasil
  final String? tempCashierId;
  final String? tempCashierName;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.isActivated = false,
    this.isAuthenticated = false,
    this.isShiftOpen = false,
    this.isPinValidated = false,
    this.username,
    this.branchName = '',
    this.schedules = const [],
    this.backgroundIndex = 0,
    this.tempCashierId,
    this.tempCashierName,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool? isActivated,
    bool? isAuthenticated,
    bool? isShiftOpen,
    bool? isPinValidated,
    String? username,
    String? branchName,
    List<dynamic>? schedules,
    int? backgroundIndex,
    String? tempCashierId,
    String? tempCashierName,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isActivated: isActivated ?? this.isActivated,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isShiftOpen: isShiftOpen ?? this.isShiftOpen,
      isPinValidated: isPinValidated ?? this.isPinValidated,
      username: username ?? this.username,
      branchName: branchName ?? this.branchName,
      schedules: schedules ?? this.schedules,
      backgroundIndex: backgroundIndex ?? this.backgroundIndex,
      tempCashierId: tempCashierId ?? this.tempCashierId,
      tempCashierName: tempCashierName ?? this.tempCashierName,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    isActivated,
    isAuthenticated,
    isShiftOpen,
    isPinValidated,
    username,
    branchName,
    schedules,
    backgroundIndex,
    tempCashierId,
    tempCashierName,
  ];
}
