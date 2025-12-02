import 'package:horeka_post_plus/core/utils/device_info_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthRepository {
  static const String _activationCodeKey = 'activation_code';
  static const String _usernameKey = 'username';
  static const String _tokenKey = 'jwt_token';
  
  static const String _baseUrl = 'http://192.168.1.16:3001/api';
  
  // Cek apakah device sudah diaktivasi
  Future<bool> checkActivationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_activationCodeKey);
      return code != null && code.isNotEmpty;
    } catch (e) {
      throw Exception('Gagal mengecek status aktivasi: $e');
    }
  }

  // Aktivasi device dengan kode
  Future<void> activateDevice(String activationCode) async {
    try {
      final deviceInfo = await DeviceInfoHelper.getDeviceInfo();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/license/activate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'activation_code': activationCode,
          'device_id': deviceInfo['id'],
          'device_name': deviceInfo['name'],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_activationCodeKey, activationCode);
      } else {
        throw Exception(data['message'] ?? 'Kode aktivasi tidak valid');
      }
    } catch (e) {
      throw Exception('Gagal aktivasi device: $e');
    }
  }

  // Fetch device info (branch name & shifts)
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activationCode = prefs.getString(_activationCodeKey);

      if (activationCode == null) {
        throw Exception('Device not activated. No activation code found.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/device-info?code=$activationCode'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'branch_name': data['branch_name'] ?? data['branch']?['name'] ?? '',
          'schedules': (data['schedules'] as List<dynamic>? ?? [])
              .map((e) => {
                    'id': e['id'].toString(),
                    'name': e['name'].toString(),
                  })
              .toList(),
        };
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil informasi device');
      }
    } catch (e) {
      throw Exception('Gagal fetch device info: $e');
    }
  }

  // Login user dengan shift
  Future<String> login(String username, String password, String shiftId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'shift_schedule_id': shiftId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'] ?? '';
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_usernameKey, username);
        
        return username;
      } else {
        throw Exception(data['message'] ?? 'Username atau password salah');
      }
    } catch (e) {
      throw Exception('Gagal login: $e');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usernameKey);
      await prefs.remove(_tokenKey);
    } catch (e) {
      throw Exception('Gagal logout: $e');
    }
  }

  // Get JWT Token
  Future<String?> getJwtToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }
}
