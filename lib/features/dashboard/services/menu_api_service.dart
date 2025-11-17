import 'dart:convert';
import 'package:http/http.dart' as http;
// Impor AuthApiService untuk mengambil token
import 'package:horeka_post_plus/features/auth_landing/services/auth_api_service.dart';

class MenuApiService {
  // Ganti dengan Base URL Anda
  final String _baseUrl = "http://192.168.1.15:3001/api";
  final AuthApiService _authApiService = AuthApiService();

  /// GET /api/cashier/menu
  /// Mendapatkan daftar produk (menu) untuk dijual
  Future<List<dynamic>> getMenu() async {
    // 1. Dapatkan JWT token yang disimpan saat login
    final token = await _authApiService.getJwtToken();
    if (token == null) {
      throw Exception('Login token not found. Please log in again.');
    }

    // 2. Lakukan panggilan API
    final response = await http.get(
      Uri.parse('$_baseUrl/cashier/menu'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Kirim token di header
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Sesuai dokumentasi, API sukses mengembalikan array
      // Jika API Anda membungkusnya dalam 'data', ganti ini menjadi 'data['data']'
      return data; 
    } else {
      // Tangani error
      throw Exception(data['message'] ?? 'Failed to load menu');
    }
  }
}