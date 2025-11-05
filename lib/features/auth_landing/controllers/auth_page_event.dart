import 'package:equatable/equatable.dart';

abstract class AuthPageEvent extends Equatable {
  const AuthPageEvent();
  @override
  List<Object> get props => [];
}

// Event saat tombol 'Start' di welcome screen ditekan
class StartPressed extends AuthPageEvent {}

// Event internal untuk BLoC, dipicu oleh Timer
// (Kita buat publik karena tidak lagi menggunakan 'part of')
class NextBackgroundTriggered extends AuthPageEvent {}