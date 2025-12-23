class ReceiptSettings {
  final String branchName;
  final String address;
  final String phoneNumber;
  final String receiptHeader;
  final String receiptFooter;
  final String taxName;
  final int taxPercentage;

  ReceiptSettings({
    required this.branchName,
    required this.address,
    required this.phoneNumber,
    required this.receiptHeader,
    required this.receiptFooter,
    required this.taxName,
    required this.taxPercentage,
  });

  factory ReceiptSettings.fromJson(Map<String, dynamic> json) {
    return ReceiptSettings(
      branchName: json['branch_name'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      receiptHeader: json['receipt_header'] ?? '',
      receiptFooter: json['receipt_footer'] ?? '',
      taxName: json['tax_name'] ?? 'Tax',
      taxPercentage: json['tax_percentage'] ?? 0,
    );
  }

  // Helper untuk memproses \n di header/footer
  String get formattedHeader => receiptHeader.replaceAll('\\n', '\n');
  String get formattedFooter => receiptFooter.replaceAll('\\n', '\n');
}
