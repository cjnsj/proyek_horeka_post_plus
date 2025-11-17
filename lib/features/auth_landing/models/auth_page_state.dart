import 'package:equatable/equatable.dart';

// TAMBAHKAN ENUM INI
enum AuthStatus { initial, loading, success, error }

class AuthPageState extends Equatable {
  final bool isShowingLogin;
  final int backgroundIndex;
  // TAMBAHKAN DUA BARIS INI
  final AuthStatus status;
  final String? errorMessage;

  const AuthPageState({
    this.isShowingLogin = false,
    this.backgroundIndex = 0,
    // TAMBAHKAN INI
    this.status = AuthStatus.initial,
    this.errorMessage,
  });

  AuthPageState copyWith({
    bool? isShowingLogin,
    int? backgroundIndex,
    // TAMBAHKAN INI
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthPageState(
      isShowingLogin: isShowingLogin ?? this.isShowingLogin,
      backgroundIndex: backgroundIndex ?? this.backgroundIndex,
      // TAMBAHKAN INI
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  // TAMBAHKAN INI
  List<Object?> get props => [isShowingLogin, backgroundIndex, status, errorMessage];
}