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

  factory SalesReportModel.fromJson(Map<String, dynamic> json) {
    // Sesuaikan parsing dengan struktur JSON dari backend Anda
    final summary = json['summary'] ?? {};
    final data = json['data'] ?? [];

    return SalesReportModel(
      totalSales: int.tryParse(summary['total_sales'].toString()) ?? 0,
      transactionCount: int.tryParse(summary['transaction_count'].toString()) ?? 0,
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
    // Handle jika backend mengirim List langsung atau Object {data: []}
    if (json is List) {
      list = json;
    } else if (json is Map && json.containsKey('data')) {
      list = json['data'];
    }

    int total = 0;
    for (var item in list) {
      total += int.tryParse(item['amount'].toString()) ?? 0;
    }

    return ExpenseReportModel(
      totalExpense: total,
      expenses: list,
    );
  }
}