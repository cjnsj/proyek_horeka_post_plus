import 'package:equatable/equatable.dart';

class AuthPageState extends Equatable {
  final bool isShowingLogin;
  final int backgroundIndex;

  const AuthPageState({
    this.isShowingLogin = false,
    this.backgroundIndex = 0,
  });

  AuthPageState copyWith({
    bool? isShowingLogin,
    int? backgroundIndex,
  }) {
    return AuthPageState(
      isShowingLogin: isShowingLogin ?? this.isShowingLogin,
      backgroundIndex: backgroundIndex ?? this.backgroundIndex,
    );
  }

  @override
  List<Object> get props => [isShowingLogin, backgroundIndex];
}