import 'dart:convert';
import 'package:http/http.dart' as http;
// Impor AuthApiService untuk mengambil token
import 'package:horeka_post_plus/features/auth_landing/services/auth_api_service.dart';

class ShiftApiService {
  // Ganti dengan Base URL Anda
  final String _baseUrl = "http://192.168.1.15:3001/api";
  final AuthApiService _authApiService = AuthApiService();

  /// Langkah 2: Buka Sesi & Identifikasi Operator
  Future<Map<String, dynamic>> openShift(
      String operatorPin, int openingCash) async {
    // 1. Dapatkan JWT token yang disimpan saat login
    final token = await _authApiService.getJwtToken();
    if (token == null) {
      throw Exception('Login token not found. Please log in again.');
    }

    // 2. Lakukan panggilan API
    final response = await http.post(
      Uri.parse('$_baseUrl/shift/open'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Kirim token di header
      },
      body: jsonEncode({
        "operator_pin": operatorPin,
        "opening_cash": openingCash,
      }),
    );

    final data = jsonDecode(response.body);

    // API mengembalikan 201 Created jika sukses
    if (response.statusCode == 201) {
      return data;
    } else {
      // Tangani error (PIN salah, Shift sudah diambil, dll)
      throw Exception(data['message'] ?? 'Failed to open shift');
    }
  }
}