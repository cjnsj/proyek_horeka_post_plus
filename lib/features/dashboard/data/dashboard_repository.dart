import 'dart:convert';
import 'package:horeka_post_plus/features/dashboard/data/model/report_models.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:horeka_post_plus/core/constants/app_constants.dart';
import 'package:horeka_post_plus/features/dashboard/data/product_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/cart_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/category_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/queue_model.dart';

class DashboardRepository {
  // 1. Ambil Menu Produk
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

  // 2. Ambil Kategori Master
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

  // 3. Buat Transaksi (Langsung Bayar)
  Future<void> createTransaction({
    required List<CartItem> items,
    required String paymentMethod,
    String? promoCode,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      final localTabletId =
          prefs.getString('local_tablet_id') ?? 'ID_KOSONG_DARI_PREFS';

      if (token == null) throw Exception('Token not found.');

      final url = '${AppConstants.apiBaseUrl}/transaction';

      final body = {
        "items": items.map((e) => e.toJson()).toList(),
        "payment_method": paymentMethod,
        "local_tablet_id": localTabletId,
        if (promoCode != null && promoCode.isNotEmpty) "promo_code": promoCode,
      };

      print("🚀 [REPO] Create Transaction Body: ${jsonEncode(body)}");

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

  // 4. Catat Pengeluaran (Expense)
  Future<void> createExpense({
    required String description,
    required int amount,
    String? imagePath,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw Exception('Token not found.');

      final uri = Uri.parse('${AppConstants.apiBaseUrl}/expense');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({'Authorization': 'Bearer $token'});
      request.fields['amount'] = amount.toString();
      request.fields['description'] = description;

      final String today = DateTime.now().toIso8601String().split('T')[0];
      request.fields['expense_date'] = today;

      if (imagePath != null && imagePath.isNotEmpty) {
        print("📂 [REPO] Uploading image: $imagePath");
        MediaType contentType = MediaType('image', 'jpeg');
        if (imagePath.toLowerCase().endsWith('.png')) {
          contentType = MediaType('image', 'png');
        }
        request.files.add(
          await http.MultipartFile.fromPath(
            'proof_image',
            imagePath,
            contentType: contentType,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return;
      } else {
        if (response.body.trim().startsWith('<')) {
          throw Exception('Server Error (HTML). Status: ${response.statusCode}');
        }
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Gagal mencatat pengeluaran');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 5. Simpan Antrian (Save Queue)
  Future<void> saveQueue({
    required List<CartItem> items,
    required String tableNumber,
    String? waiterName,
    String? orderNotes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw Exception('Token not found.');

      final url = '${AppConstants.apiBaseUrl}/queue';

      final body = {
        "queue_name": tableNumber,
        "waiter_name": waiterName ?? "",
        "order_notes": orderNotes ?? "",
        "items": items.map((e) => e.toJson()).toList(),
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Gagal menyimpan antrian');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 6. Ambil Daftar Antrian
  Future<List<QueueModel>> getQueueList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw Exception('Token not found.');

      final url = '${AppConstants.apiBaseUrl}/queue';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = (body is Map && body.containsKey('data'))
            ? body['data']
            : (body is List ? body : []);
        return data.map((json) => QueueModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat antrian: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 7. Update Antrian
  Future<void> updateQueue({
    required String id,
    required List<CartItem> items,
    required String tableNumber,
    String? waiterName,
    String? orderNotes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw Exception('Token not found.');

      final url = '${AppConstants.apiBaseUrl}/queue/$id';

      final body = {
        "queue_name": tableNumber,
        "waiter_name": waiterName ?? "",
        "order_notes": orderNotes ?? "",
        "items": items.map((e) => e.toJson()).toList(),
      };

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Gagal mengupdate antrian');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 8. Cari Transaksi (Void Mode - Search Manual)
  // [METODE YANG HILANG SEBELUMNYA]
  Future<List<dynamic>> searchTransactions(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw Exception('Token not found.');

      final url = '${AppConstants.apiBaseUrl}/transaction?search=$query';
      
      print("🔍 [REPO] Search Transactions: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // Handle format response {data: [...]} atau [...]
        final List<dynamic> data = (body is Map && body.containsKey('data')) 
            ? body['data'] 
            : (body is List ? body : []);
        return data;
      } else {
        throw Exception('Gagal load transaksi. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ [REPO] Error: $e");
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 9. Ambil Transaksi Shift Saat Ini (Void Mode - Auto Load)
  // [METODE YANG DIBUTUHKAN BLOC]
  Future<List<dynamic>> getCurrentShiftTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw Exception('Token not found.');

      final url = '${AppConstants.apiBaseUrl}/transaction/current-shift';
      
      print("🔍 [REPO] Get Current Shift: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = (body is Map && body.containsKey('data')) 
            ? body['data'] 
            : (body is List ? body : []);
        return data;
      } else {
        print("⚠️ [REPO] Gagal load current shift: ${response.body}");
        return [];
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 10. Request Void Transaksi (Pengajuan)
  // [METODE YANG DIBUTUHKAN BLOC - NAMA DISESUAIKAN]
  Future<void> requestVoidTransaction({
    required String transactionId,
    required String reason,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw Exception('Token not found.');

      // Endpoint Backend: POST /api/transaction/:id/void-request
      final url = '${AppConstants.apiBaseUrl}/transaction/$transactionId/void-request';

      final body = {"reason": reason};

      print("🚀 [REPO] Request Void: $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      // Backend bisa mengembalikan 200 atau 202
      if (response.statusCode == 200 || response.statusCode == 202) {
        return; 
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Gagal mengajukan void');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }


// ==================== FITUR REPORT (BARU) ====================

  // ---------------------------------------------------------------------------
  // 11. Get Sales Report (UPDATE: Kirim cashierId)
  // ---------------------------------------------------------------------------
  Future<SalesReportModel> getSalesReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      // [PENTING] Ambil ID Kasir yang login via PIN
      final cashierId = prefs.getString('user_id'); // Pastikan key-nya sesuai saat login

      String url = '${AppConstants.apiBaseUrl}/report/sales';

      List<String> params = [];
      if (startDate != null && endDate != null) {
        final startStr = startDate.toIso8601String().split('T')[0];
        final endStr = endDate.toIso8601String().split('T')[0];
        params.add('tanggalMulai=$startStr');
        params.add('tanggalSelesai=$endStr');
      }

      // [UPDATE] Kirim cashierId ke Backend
      if (cashierId != null) {
        params.add('cashierId=$cashierId');
      }

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SalesReportModel.fromJson(data);
      }
      throw Exception('Failed to load sales report');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // 12. Get Item Report (UPDATE: Kirim cashierId)
  // ---------------------------------------------------------------------------
  Future<List<ItemReportModel>> getItemReport({
    DateTime? startDate,
    DateTime? endDate,
    bool onlyVoid = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      final cashierId = prefs.getString('user_id'); // [PENTING]

      String url = '${AppConstants.apiBaseUrl}/report/items';

      List<String> params = [];
      if (startDate != null && endDate != null) {
        final startStr = startDate.toIso8601String().split('T')[0];
        final endStr = endDate.toIso8601String().split('T')[0];
        params.add('tanggalMulai=$startStr');
        params.add('tanggalSelesai=$endStr');
      }

      if (onlyVoid) {
        params.add('status=VOIDED');
      } else {
        params.add('status=COMPLETED');
      }

      // [UPDATE] Kirim cashierId
      if (cashierId != null) {
        params.add('cashierId=$cashierId');
      }

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => ItemReportModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // 13. Get Expense Report (UPDATE: Kirim cashierId)
  // ---------------------------------------------------------------------------
  Future<ExpenseReportModel> getExpenseReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      final cashierId = prefs.getString('user_id'); // [PENTING]

      String url = '${AppConstants.apiBaseUrl}/report/expenses';

      List<String> params = [];
      if (startDate != null && endDate != null) {
        final startStr = startDate.toIso8601String().split('T')[0];
        final endStr = endDate.toIso8601String().split('T')[0];
        params.add('tanggalMulai=$startStr');
        params.add('tanggalSelesai=$endStr');
      }

      // [UPDATE] Kirim cashierId
      if (cashierId != null) {
        params.add('cashierId=$cashierId');
      }

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ExpenseReportModel.fromJson(data);
      }
      throw Exception('Failed to load expense report');
    } catch (e) {
      throw Exception(e.toString());
    }
  } 
  
}