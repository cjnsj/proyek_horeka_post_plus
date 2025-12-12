// lib/features/dashboard/data/model/report_models.dart

class SalesReportModel {
  final int totalSales;
  final int transactionCount;
  final List<dynamic> transactions;

  SalesReportModel({
    required this.totalSales,
    required this.transactionCount,
    required this.transactions,
  });

  factory SalesReportModel.fromJson(dynamic json) {
    List<dynamic> data = [];

    // Logika Fleksibel: Menerima List langsung atau Object
    if (json is List) {
      data = json;
    } else if (json is Map<String, dynamic>) {
      // Backend Anda mengirim key 'data'
      if (json.containsKey('data') && json['data'] is List) {
        data = json['data'];
      }
    }

    // Hitung Manual (Backup jika summary backend tidak sesuai harapan)
    int total = 0;
    for (var tx in data) {
      if (tx is Map) {
        // Backend field: total_amount
        final rawAmount = tx['total_amount']?.toString() ?? '0';
        final cleanAmount = rawAmount.replaceAll(RegExp(r'[^0-9]'), '');
        total += int.tryParse(cleanAmount) ?? 0;
      }
    }

    return SalesReportModel(
      totalSales: total,
      transactionCount: data.length,
      transactions: data,
    );
  }
}

class ItemReportModel {
  final String productName;
  final int quantitySold;

  ItemReportModel({required this.productName, required this.quantitySold});

  factory ItemReportModel.fromJson(Map<String, dynamic> json) {
    return ItemReportModel(
      // Backend mengirim { product_name: "...", quantity_sold: ... }
      productName: json['product_name'] ?? 'Unknown Item',
      quantitySold: int.tryParse(json['quantity_sold'].toString()) ?? 0,
    );
  }
}

class ExpenseReportModel {
  final int totalExpense;
  final List<dynamic> expenses;

  ExpenseReportModel({required this.totalExpense, required this.expenses});

  factory ExpenseReportModel.fromJson(dynamic json) {
    List<dynamic> list = [];

    if (json is List) {
      list = json;
    } else if (json is Map && json.containsKey('data')) {
      list = json['data'];
    }

    int total = 0;
    for (var item in list) {
      final rawAmount = item['amount']?.toString() ?? '0';
      final cleanAmount = rawAmount.replaceAll(RegExp(r'[^0-9]'), '');
      total += int.tryParse(cleanAmount) ?? 0;
    }

    return ExpenseReportModel(totalExpense: total, expenses: list);
  }
}
