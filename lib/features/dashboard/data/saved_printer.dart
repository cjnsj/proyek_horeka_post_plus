import 'dart:convert';

enum SavedPrinterType { bluetooth, usb }

class SavedPrinter {
  final String id;
  final String name;
  final SavedPrinterType type;
  
  // Untuk Bluetooth
  final String? bluetoothAddress;
  
  // Untuk USB
  final int? vendorId;
  final int? productId;
  
  final DateTime addedAt;

  SavedPrinter({
    required this.id,
    required this.name,
    required this.type,
    this.bluetoothAddress,
    this.vendorId,
    this.productId,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  // Factory untuk Bluetooth Printer
  factory SavedPrinter.fromBluetooth({
    required String name,
    required String address,
  }) {
    return SavedPrinter(
      id: 'bt_$address',
      name: name,
      type: SavedPrinterType.bluetooth,
      bluetoothAddress: address,
    );
  }

  // Factory untuk USB Printer
  factory SavedPrinter.fromUsb({
    required String name,
    required int vendorId,
    required int productId,
  }) {
    return SavedPrinter(
      id: 'usb_${vendorId}_$productId',
      name: name,
      type: SavedPrinterType.usb,
      vendorId: vendorId,
      productId: productId,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'bluetoothAddress': bluetoothAddress,
      'vendorId': vendorId,
      'productId': productId,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory SavedPrinter.fromJson(Map<String, dynamic> json) {
    return SavedPrinter(
      id: json['id'],
      name: json['name'],
      type: SavedPrinterType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      bluetoothAddress: json['bluetoothAddress'],
      vendorId: json['vendorId'],
      productId: json['productId'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  // Display address based on type
  String get displayAddress {
    if (type == SavedPrinterType.bluetooth) {
      return bluetoothAddress ?? 'Unknown';
    } else {
      return 'USB (VID: $vendorId, PID: $productId)';
    }
  }

  // Encode list to JSON string
  static String encodeList(List<SavedPrinter> printers) {
    return jsonEncode(printers.map((p) => p.toJson()).toList());
  }

  // Decode JSON string to list
  static List<SavedPrinter> decodeList(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => SavedPrinter.fromJson(json)).toList();
  }
}
