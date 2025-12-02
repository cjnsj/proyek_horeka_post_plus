import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, success, error, authenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final bool isActivated;
  final bool isAuthenticated;
  final String? username;

  // Device info
  final String branchName;
  final List<Map<String, dynamic>> schedules;

  // Carousel background index
  final int backgroundIndex;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.isActivated = false,
    this.isAuthenticated = false,
    this.username,
    this.branchName = '',
    this.schedules = const [],
    this.backgroundIndex = 0,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool? isActivated,
    bool? isAuthenticated,
    String? username,
    String? branchName,
    List<Map<String, dynamic>>? schedules,
    int? backgroundIndex,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isActivated: isActivated ?? this.isActivated,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      branchName: branchName ?? this.branchName,
      schedules: schedules ?? this.schedules,
      backgroundIndex: backgroundIndex ?? this.backgroundIndex,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        isActivated,
        isAuthenticated,
        username,
        branchName,
        schedules,
        backgroundIndex,
      ];
}
