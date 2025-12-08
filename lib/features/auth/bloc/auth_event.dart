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

class ValidatePinRequested extends AuthEvent {
  final String pin;

  const ValidatePinRequested({required this.pin});

  @override
  List<Object?> get props => [pin];
}

class OpenShiftRequested extends AuthEvent {
  final String cashierId;
  final int openingCash;

  const OpenShiftRequested({
    required this.cashierId,
    required this.openingCash,
  });

  @override
  List<Object?> get props => [cashierId, openingCash];
}

// [BARU] Event untuk menutup shift
class CloseShiftRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class BackgroundTicked extends AuthEvent {
  const BackgroundTicked();
}