class PaymentMethodModel {
  final String id;
  final String name;
  final String code; // Contoh: CASH, QRIS, DEBIT
  final bool isActive;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}