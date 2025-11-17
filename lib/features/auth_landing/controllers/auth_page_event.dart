import 'package:equatable/equatable.dart';

abstract class AuthPageEvent extends Equatable {
  const AuthPageEvent();
  @override
  List<Object> get props => [];
}

class CheckActivationStatus extends AuthPageEvent {}

class ActivatePressed extends AuthPageEvent {
  final String activationCode;

  const ActivatePressed(this.activationCode); // <-- Kembalikan seperti ini

  @override
  List<Object> get props => [activationCode];
}

class NextBackgroundTriggered extends AuthPageEvent {}