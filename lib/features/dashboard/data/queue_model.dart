import 'package:horeka_post_plus/features/dashboard/data/model/cart_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/product_model.dart';

class QueueModel {
  final String id;
  final String customerName;
  final String note;
  final String createdAt;
  final List<CartItem> items;
  
  // Field Baru
  final String shiftName;
  final String cashierName;

  QueueModel({
    required this.id,
    required this.customerName,
    required this.note,
    required this.createdAt,
    required this.items,
    this.shiftName = '',
    this.cashierName = '',
  });

  factory QueueModel.fromJson(Map<String, dynamic> json) {
    // 1. Parsing Items (Aman dari null)
    var list = json['details'] ?? json['saved_order_items'] ?? [];
    List<CartItem> cartItemsList = [];

    if (list is List) {
      cartItemsList = list.map((i) {
        var p = i['product'] ?? {};
        
        // Parse Harga dengan aman (Handle String/Int/Double/Null)
        int parsedPrice = 0;
        var rawPrice = p['base_price'] ?? p['price'];
        if (rawPrice != null) {
           parsedPrice = double.tryParse(rawPrice.toString())?.toInt() ?? 0;
        }

        // Parse Qty dengan aman
        int parsedQty = int.tryParse(i['quantity']?.toString() ?? '1') ?? 1;

        ProductModel product = ProductModel(
          productId: i['product_id']?.toString() ?? '',
          name: p['product_name']?.toString() ?? 'Unknown Product', // Tambah toString()
          description: '', 
          imageUrl: '', 
          category: '', 
          price: parsedPrice, 
          isAvailable: true,
        );

        return CartItem(
          product: product,
          quantity: parsedQty,
          note: i['item_note']?.toString() ?? '', // Tambah toString()
        );
      }).toList();
    }

    return QueueModel(
      id: json['saved_order_id']?.toString() ?? '',
      
      // [PERBAIKAN] Gunakan toString() untuk jaga-jaga jika backend kirim Angka (Int)
      customerName: json['queue_name']?.toString() ?? json['customer_name']?.toString() ?? 'Tanpa Nama',
      
      note: json['order_notes']?.toString() ?? json['note']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      items: cartItemsList,
      
      // [PERBAIKAN] Ambil data Shift & Kasir dengan null check berlapis
      shiftName: json['shift_name']?.toString() ?? json['shift']?['name']?.toString() ?? '',
      
      cashierName: json['cashier']?['full_name']?.toString() ?? 
                   json['waiter_name']?.toString() ?? 
                   json['user']?['name']?.toString() ?? 
                   'Kasir',
    );
  }
}