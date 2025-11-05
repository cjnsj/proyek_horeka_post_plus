import 'dart:async';
import 'package:bloc/bloc.dart';
// Impor file Model dan Event kita
import 'package:horeka_post_plus/features/auth_landing/models/auth_page_state.dart';
import 'package:horeka_post_plus/features/auth_landing/controllers/auth_page_event.dart';

class AuthPageBloc extends Bloc<AuthPageEvent, AuthPageState> {
  // Daftar gambar, saya ganti ke .png sesuai screenshot Anda
  static const List<String> backgroundImages = [
    'assets/images/Rectangle 4.png',
    'assets/images/Rectangle 5.png',
    'assets/images/Rectangle 6.png',
    'assets/images/Rectangle 7.png',
    'assets/images/Rectangle 8.png',
  ];

  final int _loginImageCount = backgroundImages.length - 1;
  Timer? _backgroundTimer;

  // State awal sekarang di-supply dari file model
  AuthPageBloc() : super(const AuthPageState()) {
    on<StartPressed>(_onStartPressed);
    on<NextBackgroundTriggered>(_onNextBackgroundTriggered);
  }

  @override
  Future<void> close() {
    _backgroundTimer?.cancel();
    return super.close();
  }

  void _onStartPressed(StartPressed event, Emitter<AuthPageState> emit) {
    _backgroundTimer?.cancel();

    emit(state.copyWith(
      isShowingLogin: true,
      backgroundIndex: 1,
    ));

    _backgroundTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      add(NextBackgroundTriggered()); // Gunakan event publik
    });
  }

  void _onNextBackgroundTriggered(
      NextBackgroundTriggered event, Emitter<AuthPageState> emit) {
    int currentLoginImageIndex = state.backgroundIndex - 1;
    int nextLoginImageIndex = (currentLoginImageIndex + 1) % _loginImageCount;
    int nextBackgroundIndex = nextLoginImageIndex + 1;

    emit(state.copyWith(backgroundIndex: nextBackgroundIndex));
  }
}