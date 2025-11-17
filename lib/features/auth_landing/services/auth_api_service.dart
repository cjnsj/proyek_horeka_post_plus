import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthApiService {
  // Ganti dengan Base URL Anda
  final String _baseUrl = "http://192.168.1.15:3001/api";

  // Kunci untuk penyimpanan lokal
  static const String _activationCodeKey = 'activation_code';
  static const String _jwtTokenKey = 'jwt_token';

  // --- Penyimpanan Lokal ---

  Future<void> _saveActivationCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activationCodeKey, code);
  }

  Future<String?> getSavedActivationCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activationCodeKey);
  }

  Future<void> saveJwtToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jwtTokenKey, token);
  }

  Future<String?> getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jwtTokenKey);
  }

  // --- Panggilan API ---

  /// 1. API Aktivasi Perangkat
  Future<Map<String, dynamic>> activateDevice(
      String activationCode, String deviceId, String deviceName) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/license/activate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "activation_code": activationCode,
        "device_id": deviceId, // Anda perlu cara untuk mendapatkan device_id unik
        "device_name": deviceName, // Anda bisa gunakan 'Kasir 1' atau nama lain
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Jika sukses, simpan kodenya
      await _saveActivationCode(activationCode);
      return data;
    } else {
      // Jika gagal, lempar pesan error dari server
      throw Exception(data['message'] ?? 'Failed to activate device');
    }
  }

  /// 2. API Dapatkan Info Login (Langkah 0)
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final code = await getSavedActivationCode();
    if (code == null) {
      throw Exception('Device not activated. No activation code found.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/auth/device-info?code=$code'),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to get device info');
    }
  }

  /// 3. API Login (Langkah 1)
  Future<Map<String, dynamic>> login(
      String username, String password, String shiftScheduleId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": username,
        "password": password,
        "shift_schedule_id": shiftScheduleId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Jika login sukses, simpan tokennya
      await saveJwtToken(data['token']);
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }
}