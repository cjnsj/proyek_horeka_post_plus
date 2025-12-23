class SoldItem {
  final String name;
  final int qty;

  SoldItem({required this.name, required this.qty});

  factory SoldItem.fromJson(Map<String, dynamic> json) {
    return SoldItem(
      name: json['name'] ?? '',
      qty: int.tryParse(json['qty'].toString()) ?? 0,
    );
  }
}

class ShiftReceiptModel {
  final String branchName;
  final String shiftName;
  final String cashierName;
  final String startTime;
  final String endTime;
  final int totalTransactions;
  
  final double openingCash;
  final double totalSales;
  final double totalExpenses;
  final double expectedCash;
  
  final List<SoldItem> soldItems;

  ShiftReceiptModel({
    required this.branchName,
    required this.shiftName,
    required this.cashierName,
    required this.startTime,
    required this.endTime,
    required this.totalTransactions,
    required this.openingCash,
    required this.totalSales,
    required this.totalExpenses,
    required this.expectedCash,
    required this.soldItems,
  });

  factory ShiftReceiptModel.fromJson(Map<String, dynamic> json) {
    var list = json['sold_items'] as List? ?? [];
    List<SoldItem> itemsList = list.map((i) => SoldItem.fromJson(i)).toList();

    return ShiftReceiptModel(
      branchName: json['branch_name'] ?? 'Toko',
      shiftName: json['shift_name'] ?? '-',
      cashierName: json['cashier_name'] ?? '-',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      totalTransactions: int.tryParse(json['total_transactions'].toString()) ?? 0,
      openingCash: double.tryParse(json['opening_cash'].toString()) ?? 0,
      totalSales: double.tryParse(json['total_sales'].toString()) ?? 0,
      totalExpenses: double.tryParse(json['total_expenses'].toString()) ?? 0,
      expectedCash: double.tryParse(json['expected_cash'].toString()) ?? 0,
      soldItems: itemsList,
    );
  }
}