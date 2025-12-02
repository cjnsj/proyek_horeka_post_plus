import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckActivationStatusRequested extends AuthEvent {}

class ActivationRequested extends AuthEvent {
  final String activationCode;

  const ActivationRequested({required this.activationCode});

  @override
  List<Object?> get props => [activationCode];
}

class FetchDeviceInfoRequested extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  final String shiftId;

  const LoginRequested({
    required this.username,
    required this.password,
    required this.shiftId,
  });

  @override
  List<Object?> get props => [username, password, shiftId];
}

class LogoutRequested extends AuthEvent {}

// Event untuk menggerakkan carousel background
class BackgroundTicked extends AuthEvent {
  const BackgroundTicked();
}
