import 'dart:convert';
import 'package:horeka_post_plus/features/dashboard/data/model/payment_method_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:horeka_post_plus/core/constants/app_constants.dart';
import 'package:horeka_post_plus/features/dashboard/data/product_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/cart_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/category_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/queue_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/report_models.dart';

class DashboardRepository {
  // 1. Ambil Menu Produk
  Future<List<ProductModel>> getMenu() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw ('Token not found.');

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
        throw ('Gagal memuat menu: ${response.statusCode}');
      }
    } catch (e) {
      throw ('Error fetching menu: $e');
    }
  }

  // 2. Ambil Kategori Master
  Future<List<CategoryModel>> getCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw ('Token not found.');

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
  // [PERBAIKAN] Ubah dari Future<void> menjadi Future<Map<String, dynamic>>
  Future<Map<String, dynamic>> createTransaction({
    required List<CartItem> items,
    required String paymentMethod,
    String? promoCode,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      final localTabletId =
          prefs.getString('local_tablet_id') ?? 'unknown-device';

      final url = '${AppConstants.apiBaseUrl}/transaction';

      final body = {
        "items": items
            .map(
              (item) => {
                "product_id": item.product.productId,
                "quantity": item.quantity,
                "item_note": item.note,
              },
            )
            .toList(),
        "payment_method": paymentMethod,
        "local_tablet_id": localTabletId,

        // Kirim promo code jika ada
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

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print(
          "✅ [REPO] Transaction Success: ${responseData['data']['receipt_number']}",
        );
        // [PERBAIKAN] Return data response dari backend
        return responseData['data'] as Map<String, dynamic>;
      } else {
        throw (responseData['message'] ?? 'Gagal memproses transaksi');
      }
    } catch (e) {
      throw (e.toString().replaceAll('', ''));
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
      if (token == null) throw ('Token not found.');

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
          throw (
            'Server Error (HTML). Status: ${response.statusCode}',
          );
        }
        final data = jsonDecode(response.body);
        throw (data['message'] ?? 'Gagal mencatat pengeluaran');
      }
    } catch (e) {
      throw (e.toString().replaceAll('', ''));
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
      if (token == null) throw ('Token not found.');

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
        throw (data['message'] ?? 'Gagal menyimpan antrian');
      }
    } catch (e) {
      throw (e.toString().replaceAll('', ''));
    }
  }

  // 6. Ambil Daftar Antrian
  Future<List<QueueModel>> getQueueList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw ('Token not found.');

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
        throw ('Gagal memuat antrian: ${response.statusCode}');
      }
    } catch (e) {
      throw (e.toString().replaceAll('', ''));
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
      if (token == null) throw ('Token not found.');

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
        throw (data['message'] ?? 'Gagal mengupdate antrian');
      }
    } catch (e) {
      throw (e.toString().replaceAll('', ''));
    }
  }

  // 8. Cari Transaksi (Void Mode - Search Manual)
  Future<List<dynamic>> searchTransactions(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw ('Token not found.');

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
        final List<dynamic> data = (body is Map && body.containsKey('data'))
            ? body['data']
            : (body is List ? body : []);
        return data;
      } else {
        throw ('Gagal load transaksi. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ [REPO] Error: $e");
      throw (e.toString().replaceAll('', ''));
    }
  }

  // 9. Ambil Transaksi Shift Saat Ini (Void Mode - Auto Load)
  Future<List<dynamic>> getCurrentShiftTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw ('Token not found.');

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
      throw (e.toString().replaceAll('', ''));
    }
  }

  // 10. Request Void Transaksi (Pengajuan)
  Future<void> requestVoidTransaction({
    required String transactionId,
    required String reason,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw ('Token not found.');

      final url =
          '${AppConstants.apiBaseUrl}/transaction/$transactionId/void-request';

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

      if (response.statusCode == 200 || response.statusCode == 202) {
        return;
      } else {
        final data = jsonDecode(response.body);
        throw (data['message'] ?? 'Gagal mengajukan void');
      }
    } catch (e) {
      throw (e.toString().replaceAll(' ', ''));
    }
  }

  // ==================== FITUR REPORT (SESUAI BACKEND) ====================

  // 11. Get Sales Report (WAJIB KIRIM CASHIER ID)
  Future<SalesReportModel> getSalesReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      // [WAJIB] Ambil cashierId (biasanya disimpan sbg user_id saat login)
      final cashierId = prefs.getString('user_id');

      String url = '${AppConstants.apiBaseUrl}/report/sales';

      List<String> params = [];
      if (startDate != null && endDate != null) {
        final startStr = startDate.toIso8601String().split('T')[0];
        // [PERBAIKAN] Tambahkan jam akhir hari agar transaksi hari ini terbaca
        final endStr = "${endDate.toIso8601String().split('T')[0]} 23:59:59";
        params.add('tanggalMulai=$startStr');
        params.add('tanggalSelesai=$endStr');
      }

      // [WAJIB] Kirim cashierId ke Backend agar lolos validasi kasir
      if (cashierId != null) {
        params.add('cashierId=$cashierId');
      }

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print("🔍 [REPO-SALES] Request ke: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("📥 [REPO-SALES] Status: ${response.statusCode}");
      print("📦 [REPO-SALES] Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend mengirim { summary: ..., data: ... }
        return SalesReportModel.fromJson(data);
      }
      throw ('Failed to load sales report: ${response.statusCode}');
    } catch (e) {
      print("❌ [REPO-SALES ERROR] $e");
      throw (e.toString());
    }
  }

  // 12. Get Item Report (WAJIB KIRIM CASHIER ID)
  Future<List<ItemReportModel>> getItemReport({
    DateTime? startDate,
    DateTime? endDate,
    bool onlyVoid = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      final cashierId = prefs.getString('user_id');

      String url = '${AppConstants.apiBaseUrl}/report/items';
      List<String> params = [];

      if (startDate != null && endDate != null) {
        final startStr = startDate.toIso8601String().split('T')[0];
        // [PERBAIKAN] Tambahkan jam akhir
        final endStr = "${endDate.toIso8601String().split('T')[0]} 23:59:59";
        params.add('tanggalMulai=$startStr');
        params.add('tanggalSelesai=$endStr');
      }

      if (onlyVoid) {
        params.add('status=VOIDED,VOID_REQUESTED');
      } else {
        params.add('status=COMPLETED');
      }

      // [WAJIB] Kirim cashierId
      if (cashierId != null) {
        params.add('cashierId=$cashierId');
      }

      if (params.isNotEmpty) url += '?${params.join('&')}';

      print("🔍 [REPO-ITEM] Request ke: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("📥 [REPO-ITEM] Status: ${response.statusCode}");
      // Uncomment baris ini untuk melihat bentuk asli data dari backend di debug console
      // print("📦 [REPO-ITEM] Body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic body = jsonDecode(response.body);

        // [PERBAIKAN UTAMA DI SINI]
        // Cek apakah data dibungkus dalam key 'data' atau langsung List
        final List<dynamic> data = (body is Map && body.containsKey('data'))
            ? body['data']
            : (body is List ? body : []);

        return data.map((e) => ItemReportModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("❌ [REPO-ITEM ERROR] $e");
      return [];
    }
  }

  // 13. Get Expense Report (WAJIB KIRIM CASHIER ID)
  Future<ExpenseReportModel> getExpenseReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      final cashierId = prefs.getString('user_id');

      String url = '${AppConstants.apiBaseUrl}/report/expenses';
      List<String> params = [];

      if (startDate != null && endDate != null) {
        final startStr = startDate.toIso8601String().split('T')[0];
        final endStr = "${endDate.toIso8601String().split('T')[0]} 23:59:59";
        params.add('tanggalMulai=$startStr');
        params.add('tanggalSelesai=$endStr');
      }

      // [WAJIB] Kirim cashierId
      if (cashierId != null) {
        params.add('cashierId=$cashierId');
      }

      if (params.isNotEmpty) url += '?${params.join('&')}';

      print("🔍 [REPO-EXPENSE] Request ke: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("📥 [REPO-EXPENSE] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ExpenseReportModel.fromJson(data);
      }
      throw ('Failed to load expense report');
    } catch (e) {
      print("❌ [REPO-EXPENSE ERROR] $e");
      throw (e.toString());
    }
  }

  // 14. Hapus Antrian
  Future<void> deleteQueue(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      final response = await http.delete(
        Uri.parse('${AppConstants.apiBaseUrl}/queue/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw ('Gagal menghapus antrian');
      }
    } catch (e) {
      throw (e.toString());
    }
  }

  // 15. Hitung Diskon (Opsional)
  Future<Map<String, dynamic>> calculateDiscount({
    required List<CartItem> items,
    required String promoCode,
  }) async {
    return {};
  }

  // 16. Ambil Pengaturan Pajak
  Future<Map<String, dynamic>> getTaxSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      final url = '${AppConstants.apiBaseUrl}/branch/tax';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ('Gagal memuat pengaturan pajak');
      }
    } catch (e) {
      throw (e.toString().replaceAll(' ', ''));
    }
  }

  // 17. Ambil Metode Pembayaran
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      final url = '${AppConstants.apiBaseUrl}/payment';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PaymentMethodModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching payment methods: $e");
      return [];
    }
  }

  // 18. Hitung Transaksi Lengkap
  Future<TransactionCalculationModel> calculateTransaction({
    required List<CartItem> items,
    String? promoCode,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw ('Token not found.');

      final url = '${AppConstants.apiBaseUrl}/transaction/calculate';

      final body = {
        "items": items
            .map(
              (e) => {
                "product_id": e.product.productId,
                "quantity": e.quantity,
                "item_note": e.note,
              },
            )
            .toList(),
        "promo_code": promoCode,
      };

      print("🚀 [REPO] Calculating Transaction: $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return TransactionCalculationModel.fromJson(jsonResponse['data']);
      } else {
        final errorBody = jsonDecode(response.body);
        throw (errorBody['message'] ?? "Gagal menghitung transaksi");
      }
    } catch (e) {
      throw (e.toString().replaceAll('', ''));
    }
  }

// 19. Ambil Profil Toko & Header Struk [UPDATE: API /branch/receipt]
  Future<Map<String, dynamic>> fetchStoreProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) throw ('Token not found.');

      // [PERBAIKAN PENTING] 
      // Sesuai dokumentasi Backend v5.0, endpointnya adalah /branch/receipt
      final url = '${AppConstants.apiBaseUrl}/branch/receipt'; 

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // API ini mengembalikan data langsung (flat)
        return jsonDecode(response.body);
      } else {
        throw ('Gagal memuat profil toko: ${response.statusCode}');
      }
    } catch (e) {
      throw ('Error fetchStoreProfile: $e');
    }
  }
}

// ================== MODEL CLASSSES ==================

class TransactionCalculationModel {
  final int subtotal;
  final int totalDiscount;
  final int totalTax;
  final int totalAmount;
  final List<AppliedPromo> appliedPromos;

  TransactionCalculationModel({
    required this.subtotal,
    required this.totalDiscount,
    required this.totalTax,
    required this.totalAmount,
    required this.appliedPromos,
  });

  factory TransactionCalculationModel.fromJson(Map<String, dynamic> json) {
    return TransactionCalculationModel(
      subtotal: int.parse(json['subtotal'] ?? "0"),
      totalDiscount: int.parse(json['total_discount'] ?? "0"),
      totalTax: int.parse(json['total_tax'] ?? "0"),
      totalAmount: int.parse(json['total_amount'] ?? "0"),
      appliedPromos: (json['applied_promos'] as List? ?? [])
          .map((e) => AppliedPromo.fromJson(e))
          .toList(),
    );
  }
}

class AppliedPromo {
  final String name;
  final int amount;

  AppliedPromo({required this.name, required this.amount});

  factory AppliedPromo.fromJson(Map<String, dynamic> json) {
    return AppliedPromo(
      name: json['discount_name'] ?? 'Diskon',
      amount: int.parse(json['amount'] ?? "0"),
    );
  }
}