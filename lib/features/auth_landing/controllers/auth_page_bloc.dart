import 'dart:async';
import 'package:bloc/bloc.dart';
// Impor path yang benar
import 'package:horeka_post_plus/features/auth_landing/models/auth_page_state.dart';
import 'package:horeka_post_plus/features/auth_landing/controllers/auth_page_event.dart';

class AuthPageBloc extends Bloc<AuthPageEvent, AuthPageState> {
  // PERUBAHAN 1: Hapus 'Rectangle 4.png'.
  // List ini sekarang hanya berisi gambar carousel.
  static const List<String> backgroundImages = [
    'assets/images/Rectangle 5.png',
    'assets/images/Rectangle 6.png',
    'assets/images/Rectangle 7.png',
  ];

  // PERUBAHAN 2: Jumlah gambar adalah panjang list
  final int _imageCount = backgroundImages.length;

  Timer? _backgroundTimer;

  // PERUBAHAN 3: Update constructor
  AuthPageBloc() : super(const AuthPageState()) { // State awal: index 0 (Rectangle 5.png)
    on<StartPressed>(_onStartPressed);
    on<NextBackgroundTriggered>(_onNextBackgroundTriggered);

    // Langsung mulai timer saat BLoC dibuat
    _backgroundTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      add(NextBackgroundTriggered());
    });
  }

  @override
  Future<void> close() {
    _backgroundTimer?.cancel();
    return super.close();
  }

  // PERUBAHAN 4: Sederhanakan _onStartPressed
  void _onStartPressed(StartPressed event, Emitter<AuthPageState> emit) {
    // Timer dan background sudah berjalan.
    // Kita hanya perlu mengubah state UI untuk menampilkan login.
    emit(state.copyWith(isShowingLogin: true));
  }

  // PERUBAHAN 5: Sederhanakan logika looping
  void _onNextBackgroundTriggered(
      NextBackgroundTriggered event, Emitter<AuthPageState> emit) {
    
    // Logika loop sederhana: 0 -> 1 -> 2 -> 3 -> 0
    int nextBackgroundIndex = (state.backgroundIndex + 1) % _imageCount;

    emit(state.copyWith(backgroundIndex: nextBackgroundIndex));
  }
}