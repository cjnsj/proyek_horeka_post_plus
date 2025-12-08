import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:horeka_post_plus/core/constants/app_constants.dart';
import 'package:horeka_post_plus/features/dashboard/data/product_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/cart_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/category_model.dart';

class DashboardRepository {
  // Ambil Menu Produk
  Future<List<ProductModel>> getMenu() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw Exception('Token not found.');

      final url = '${AppConstants.apiBaseUrl}/cashier/menu';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat menu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching menu: $e');
    }
  }

  // Ambil Kategori Master
  Future<List<CategoryModel>> getCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw Exception('Token not found.');

      final url = '${AppConstants.apiBaseUrl}/category';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  // Buat Transaksi
  Future<void> createTransaction({
    required List<CartItem> items,
    required String paymentMethod,
    String? promoCode,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw Exception('Token not found.');

      final url = '${AppConstants.apiBaseUrl}/transaction';

      final body = {
        "items": items.map((e) => e.toJson()).toList(),
        "payment_method": paymentMethod,
        if (promoCode != null && promoCode.isNotEmpty) "promo_code": promoCode,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Transaksi gagal');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // [BARU] Catat Pengeluaran (Expense)
  Future<void> createExpense({
    required String description,
    required int amount,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw Exception('Token not found.');

      // Endpoint: /expense (tanpa /v1 sesuai repository auth sebelumnya)
      final url = '${AppConstants.apiBaseUrl}/expense';
      
      // Format tanggal YYYY-MM-DD (Opsional jika backend otomatis pakai NOW())
      // final String today = DateTime.now().toIso8601String().split('T')[0];

      final body = {
        "amount": amount,
        "description": description,
        // "expense_date": today, // Uncomment jika backend butuh tanggal manual
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return; // Sukses
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Gagal mencatat pengeluaran');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}