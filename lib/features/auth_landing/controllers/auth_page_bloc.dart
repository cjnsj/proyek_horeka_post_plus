import 'dart:async';
import 'dart:io'; 
import 'package:bloc/bloc.dart';
import 'package:horeka_post_plus/features/auth_landing/models/auth_page_state.dart';
import 'package:horeka_post_plus/features/auth_landing/controllers/auth_page_event.dart';
import 'package:horeka_post_plus/features/auth_landing/services/auth_api_service.dart';
import 'package:device_info_plus/device_info_plus.dart'; 

import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:uuid/uuid.dart'; 

class AuthPageBloc extends Bloc<AuthPageEvent, AuthPageState> {
  static const List<String> backgroundImages = [
    'assets/images/Rectangle 5.png',
    'assets/images/Rectangle 6.png',
    'assets/images/Rectangle 7.png',
  ];

  final int _imageCount = backgroundImages.length;
  Timer? _backgroundTimer;
  final AuthApiService _apiService;

  AuthPageBloc()
      : _apiService = AuthApiService(),
        super(const AuthPageState()) {
    
    on<ActivatePressed>(_onActivatePressed);
    on<NextBackgroundTriggered>(_onNextBackgroundTriggered);
    on<CheckActivationStatus>(_onCheckActivationStatus); 

    _backgroundTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      add(NextBackgroundTriggered());
    });
    
    add(CheckActivationStatus());
  }

  Future<void> _onCheckActivationStatus(
      CheckActivationStatus event, Emitter<AuthPageState> emit) async {
    final code = await _apiService.getSavedActivationCode();
    if (code != null) {
      emit(state.copyWith(isShowingLogin: true, status: AuthStatus.success));
    }
  }

  @override
  Future<void> close() {
    _backgroundTimer?.cancel();
    return super.close();
  }

  // --- FUNGSI HELPER INI DIMODIFIKASI ---
  Future<Map<String, String>> _getDeviceDetails() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = "unknown_id";
    String deviceName = "unknown_device";

    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        const String webDeviceIdKey = 'web_device_id';
        
        String? id = prefs.getString(webDeviceIdKey);
        if (id == null) {
          id = const Uuid().v4();
          await prefs.setString(webDeviceIdKey, id);
        }
        deviceId = id;

        WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
        deviceName = webInfo.browserName.toString().split('.').last; 

      } else if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id; // Ini adalah ANDROID_ID
        
        // --- PERUBAHAN DI SINI ---
        // Kita gabungkan Brand (merek) + Model
        // Hasilnya akan menjadi "Redmi 2405CRPFDG"
        deviceName = '${androidInfo.brand} ${androidInfo.model}';
        // --- AKHIR PERUBAHAN ---

      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'ios_id_unknown';
        deviceName = iosInfo.name; // Misal: "Budi's iPad"
      }
      
    } catch (e) {
      print("Failed to get device info: $e");
    }
    
    return {'id': deviceId, 'name': deviceName};
  }
  // --- AKHIR FUNGSI HELPER ---


  // --- FUNGSI INI DIUBAH UNTUK MENGHAPUS 'deviceName' DARI EVENT ---
  void _onActivatePressed(
      ActivatePressed event, Emitter<AuthPageState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      // 1. Panggil fungsi helper untuk dapat ID dan NAMA otomatis
      Map<String, String> deviceDetails = await _getDeviceDetails();
      String deviceId = deviceDetails['id']!;
      String deviceName = deviceDetails['name']!; // Sekarang berisi "Redmi 2405CRPFDG"
      
      // 2. Kirim data
      await _apiService.activateDevice(
        event.activationCode, // <-- Dari input pengguna
        deviceId,           // <-- Otomatis
        deviceName,         // <-- Otomatis
      );

      // Jika sukses, pindah ke halaman login
      emit(state.copyWith(isShowingLogin: true, status: AuthStatus.success));
    } catch (e) {
      emit(state.copyWith(
          status: AuthStatus.error, errorMessage: e.toString()));
      emit(state.copyWith(status: AuthStatus.initial));
    }
  }

  void _onNextBackgroundTriggered(
      NextBackgroundTriggered event, Emitter<AuthPageState> emit) {
    int nextBackgroundIndex = (state.backgroundIndex + 1) % _imageCount;
    emit(state.copyWith(backgroundIndex: nextBackgroundIndex));
  }
}