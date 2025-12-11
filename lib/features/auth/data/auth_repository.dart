import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:horeka_post_plus/core/constants/app_constants.dart';
import 'package:horeka_post_plus/core/utils/device_info_helper.dart';

class AuthRepository {
  // --- [LANGKAH 1] Validasi PIN (DENGAN PENYIMPANAN ID) ---
  // --- [LANGKAH 1] Validasi PIN (DENGAN PENANGANAN ERROR SESI AKTIF) ---
  Future<Map<String, dynamic>> validatePin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      if (token == null) {
        throw Exception('Token not found. Please login again.');
      }

      final url = '${AppConstants.apiBaseUrl}/shift/validate-pin';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'operator_pin': pin,
        }),
      );

      // Cek error HTML
      if (response.body.trim().startsWith('<')) {
        throw Exception('Server Error: Mendapat respon HTML (${response.statusCode}).');
      }

      final body = jsonDecode(response.body);

      // --- [HANDLE ERROR SPESIFIK] ---
      if (response.statusCode == 200) {
        // SUKSES
        final data = body['data'];
        
        // Simpan ID
        if (data['cashier_id'] != null) {
           await prefs.setString('user_id', data['cashier_id'].toString());
        } else if (data['user_id'] != null) {
           await prefs.setString('user_id', data['user_id'].toString());
        }

        return data;
      } 
      // [UPDATE] Tangkap Error 403 (Sesi Aktif / Akses Ditolak)
      else if (response.statusCode == 403) {
        // Pesan dari backend: "Akses Ditolak: [Nama] sedang aktif di sesi lain..."
        // Kita lempar sebagai Exception agar UI bisa menampilkannya
        throw Exception(body['message'] ?? 'PIN ini sedang aktif di sesi lain.');
      }
      // Error Lainnya (401 PIN Salah, dll)
      else {
        throw Exception(body['message'] ?? 'PIN Salah');
      }

    } catch (e) {
      // Bersihkan prefix "Exception: " agar pesan di UI bersih
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
  // --- [LANGKAH 2] Buka Shift (Tanpa /v1) ---
  Future<void> openShift(String cashierId, int openingCash) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      if (token == null) {
        throw Exception('Token not found.');
      }

      final url = '${AppConstants.apiBaseUrl}/shift/open';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'cashier_id': cashierId,
          'opening_cash': openingCash,
        }),
      );

      if (response.body.trim().startsWith('<')) {
        throw Exception('Server Error: Mendapat respon HTML (${response.statusCode}).');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return; // Sukses
      } else {
        throw Exception(data['message'] ?? 'Gagal membuka shift');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // --- [LANGKAH 3] Tutup Shift (Tanpa /v1) ---
  Future<void> closeShift() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      if (token == null) throw Exception('Token not found.');

      final url = '${AppConstants.apiBaseUrl}/shift/close';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.body.trim().startsWith('<')) {
        throw Exception('Server Error: HTML response during close shift.');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return; // Sukses tutup shift
      } else {
        throw Exception(data['message'] ?? 'Gagal menutup shift');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // --- Cek Status Aktivasi ---
  Future<bool> checkActivationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(AppConstants.activationCodeKey);
      return code != null && code.isNotEmpty;
    } catch (e) {
      throw Exception('Gagal mengecek status aktivasi: $e');
    }
  }

  // --- Aktivasi Perangkat ---
  Future<void> activateDevice(String activationCode) async {
    try {
      final deviceInfo = await DeviceInfoHelper.getDeviceInfo();
      
      // Ambil device ID untuk disimpan nanti
      final deviceId = deviceInfo['id'];
      
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/license/activate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'activation_code': activationCode,
          'device_id': deviceId,
          'device_name': deviceInfo['name'],
        }),
      );

      if (response.body.trim().startsWith('<')) {
        throw Exception('Server Error: HTML response during activation.');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.activationCodeKey, activationCode);
        
        // [PERBAIKAN] Simpan ID Tablet agar bisa dipakai saat Transaksi
        if (deviceId != null) {
          await prefs.setString('local_tablet_id', deviceId);
        }
        
      } else {
        throw Exception(data['message'] ?? 'Kode aktivasi tidak valid');
      }
    } catch (e) {
      throw Exception('Gagal aktivasi device: $e');
    }
  }

  // --- Ambil Info Device ---
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activationCode = prefs.getString(AppConstants.activationCodeKey);

      if (activationCode == null) {
        throw Exception('Device not activated.');
      }

      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/device-info?code=$activationCode'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.body.trim().startsWith('<')) {
        throw Exception('Server Error: HTML response getting device info.');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'branch_name': data['branch_name'] ?? '',
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

  // --- Login ---
  // [UPDATE] Fungsi Login dengan Debugging & Paksa Simpan ID
  Future<String> login(String username, String password, String shiftId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'shift_schedule_id': shiftId,
        }),
      );

      if (response.body.trim().startsWith('<')) {
        throw Exception('Server Error: HTML response during login.');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'] ?? '';
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token);
        await prefs.setString(AppConstants.usernameKey, username);
        
        // --- [LOGIKA BARU LEBIH KUAT] ---
        // 1. Coba ambil dari DeviceInfoHelper (ID Fisik Device)
        try {
          final deviceInfo = await DeviceInfoHelper.getDeviceInfo();
          final deviceId = deviceInfo['id'] ?? 'UNKNOWN-DEVICE-ID';
          
          // 2. Paksa simpan ke SharedPreferences
          await prefs.setString('local_tablet_id', deviceId);
          
          // 3. PRINT DEBUG (Cek di Console Anda nanti)
          print("✅ [AUTH DEBUG] Berhasil simpan local_tablet_id: $deviceId");
        } catch (e) {
          print("❌ [AUTH DEBUG] Gagal ambil device info: $e");
          // Fallback ID jika gagal
          await prefs.setString('local_tablet_id', 'FALLBACK-ID-001');
        }
        
        return username;
      } else {
        throw Exception(data['message'] ?? 'Username atau password salah');
      }
    } catch (e) {
      throw Exception('Gagal login: $e');
    }
  }
  // --- Logout ---
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.usernameKey);
      await prefs.remove(AppConstants.tokenKey);
      // Jangan hapus local_tablet_id agar tidak perlu aktivasi ulang
    } catch (e) {
      throw Exception('Gagal logout: $e');
    }
  }

// --- [BARU] Cek apakah user sudah login ---
  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    // Kembalikan true jika token ada dan tidak kosong
    return token != null && token.isNotEmpty;
  }

}