import 'dart:convert';
import 'package:horeka_post_plus/features/dashboard/data/model/shift_receipt_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:horeka_post_plus/core/constants/app_constants.dart';
import 'package:horeka_post_plus/core/utils/device_info_helper.dart';

class AuthRepository {
  // ===========================================================================
  // 1. VALIDASI PIN KASIR
  // ===========================================================================
  Future<Map<String, dynamic>> validatePin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      if (token == null) {
        throw ('Token not found. Please login again.');
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
      ).timeout(const Duration(seconds: 10)); // [SAFETY] Timeout 10 detik

      // Cek error HTML (Server Down/Salah URL)
      if (response.body.trim().startsWith('<')) {
        throw ('Server Error: Mendapat respon HTML (${response.statusCode}).');
      }

      final body = jsonDecode(response.body);

      // --- HANDLE ERROR SPESIFIK ---
      if (response.statusCode == 200) {
        // SUKSES
        final data = body['data'];

        // Simpan ID User/Kasir untuk keperluan log
        if (data['cashier_id'] != null) {
          await prefs.setString('user_id', data['cashier_id'].toString());
        } else if (data['user_id'] != null) {
          await prefs.setString('user_id', data['user_id'].toString());
        }

        return data;
      }
      // Tangkap Error 403 (Sesi Aktif / Akses Ditolak)
      else if (response.statusCode == 403) {
        throw (body['message'] ?? 'PIN ini sedang aktif di sesi lain.');
      }
      // Error Lainnya (401 PIN Salah, dll)
      else {
        throw (body['message'] ?? 'PIN Salah');
      }
    } catch (e) {
      // Bersihkan prefix "Exception:" agar pesan di UI bersih
      throw (e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ===========================================================================
  // 2. BUKA SHIFT
  // ===========================================================================
  Future<void> openShift(String cashierId, int openingCash) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      if (token == null) {
        throw ('Token not found.');
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
      ).timeout(const Duration(seconds: 10)); // [SAFETY] Timeout

      if (response.body.trim().startsWith('<')) {
        throw ('Server Error: Mendapat respon HTML (${response.statusCode}).');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return; // Sukses
      } else {
        throw (data['message'] ?? 'Gagal membuka shift');
      }
    } catch (e) {
      throw (e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ===========================================================================
  // 3. TUTUP SHIFT (SYSTEM CLOSE)
  // ===========================================================================
  Future<ShiftReceiptModel?> closeShift() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      if (token == null) throw ('Token not found.');

      final url = '${AppConstants.apiBaseUrl}/shift/close';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.body.trim().startsWith('<')) {
        throw ('Server Error: HTML response during close shift.');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // [UPDATE] Mengembalikan Model Data
        if (data['receipt'] != null) {
          return ShiftReceiptModel.fromJson(data['receipt']);
        }
        return null;
      } else {
        throw (data['message'] ?? 'Gagal menutup shift');
      }
    } catch (e) {
      throw (e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ===========================================================================
  // CEK STATUS AKTIVASI DEVICE
  // ===========================================================================
  Future<bool> checkActivationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(AppConstants.activationCodeKey);
      return code != null && code.isNotEmpty;
    } catch (e) {
      throw ('Gagal mengecek status aktivasi: $e');
    }
  }

  // ===========================================================================
  // AKTIVASI PERANGKAT
  // ===========================================================================
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
      ).timeout(const Duration(seconds: 10));

      if (response.body.trim().startsWith('<')) {
        throw ('Server Error: HTML response during activation.');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.activationCodeKey, activationCode);

        // Simpan ID Tablet agar bisa dipakai saat Transaksi
        if (deviceId != null) {
          await prefs.setString('local_tablet_id', deviceId);
        }
      } else {
        throw (data['message'] ?? 'Kode aktivasi tidak valid');
      }
    } catch (e) {
      throw ('Gagal aktivasi device: $e');
    }
  }

  // ===========================================================================
  // AMBIL INFO DEVICE
  // ===========================================================================
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activationCode = prefs.getString(AppConstants.activationCodeKey);

      if (activationCode == null) {
        throw ('Device not activated.');
      }

      final response = await http.get(
        Uri.parse(
            '${AppConstants.apiBaseUrl}/auth/device-info?code=$activationCode'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.body.trim().startsWith('<')) {
        throw ('Server Error: HTML response getting device info.');
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
        throw (data['message'] ?? 'Gagal mengambil informasi device');
      }
    } catch (e) {
      throw ('Gagal fetch device info: $e');
    }
  }

  // ===========================================================================
  // LOGIN (DENGAN TIMEOUT FIX)
  // ===========================================================================
  Future<String> login(String username, String password, String shiftId) async {
    try {
      final url = '${AppConstants.apiBaseUrl}/auth/login';
      print("🚀 [REPO] Login Request ke: $url"); // Log URL

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'shift_schedule_id': shiftId,
        }),
      ).timeout(const Duration(seconds: 10)); // [SAFETY] Timeout agar tidak macet

      if (response.body.trim().startsWith('<')) {
        throw ('Server Error: HTML response during login.');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'] ?? '';

        final prefs = await SharedPreferences.getInstance();
        // 1. Simpan Token dan Username (Wajib untuk Login Otomatis)
        await prefs.setString(AppConstants.tokenKey, token);
        await prefs.setString(AppConstants.usernameKey, username);

        // --- [LOGIKA DEVICE ID] ---
        try {
          final deviceInfo = await DeviceInfoHelper.getDeviceInfo();
          final deviceId = deviceInfo['id'] ?? 'UNKNOWN-DEVICE-ID';
          await prefs.setString('local_tablet_id', deviceId);
          print("✅ [AUTH DEBUG] Berhasil simpan local_tablet_id: $deviceId");
        } catch (e) {
          print("❌ [AUTH DEBUG] Gagal ambil device info: $e");
          await prefs.setString('local_tablet_id', 'FALLBACK-ID-001');
        }

        return username;
      } else {
        throw (data['message'] ?? 'Username atau password salah');
      }
    } catch (e) {
      print("❌ [REPO LOGIN ERROR] $e"); // Log Error
      throw (e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ===========================================================================
  // LOGOUT (SERVER KILL & CLEAN UP)
  // ===========================================================================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);

    // 1. Panggil API Logout ke Server (Server Side Kill)
    if (token != null) {
      try {
        final url = Uri.parse('${AppConstants.apiBaseUrl}/auth/logout');
        
        print("🚀 [REPO] Logout Request ke: $url");

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 5)); // Timeout pendek biar cepat

        if (response.statusCode == 200) {
          print("✅ [REPO] Logout Server Berhasil");
        } else {
          print("⚠️ [REPO] Logout Server Gagal (Code ${response.statusCode})");
        }
      } catch (e) {
        // Abaikan error jaringan saat logout, yang penting lokal terhapus
        print("⚠️ [REPO] Gagal menghubungi server saat logout (tetap hapus lokal): $e");
      }
    }

    // 2. Hapus Data Lokal (Client Side Clean Up)
    try {
      await prefs.remove(AppConstants.usernameKey);
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove('user_id'); // Hapus ID user juga
      
      // [PENTING] Hapus Sesi Dashboard (Agar user berikutnya diminta PIN lagi)
      await prefs.remove('dashboard_session_active');

      // Catatan: Jangan hapus local_tablet_id/activation agar tidak perlu aktivasi ulang
      print("✅ [REPO] Data Lokal Berhasil Dihapus.");
    } catch (e) {
      throw ('Gagal hapus data lokal: $e');
    }
  }

  // ===========================================================================
  // CEK TOKEN LOKAL (UNTUK AUTO LOGIN)
  // ===========================================================================
  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    // Kembalikan true jika token ada dan tidak kosong
    return token != null && token.isNotEmpty;
  }
}