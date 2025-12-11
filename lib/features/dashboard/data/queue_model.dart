import 'package:horeka_post_plus/features/dashboard/data/model/cart_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/product_model.dart';

class QueueModel {
  final String id;
  final String customerName;
  final String note;
  final String createdAt;
  final List<CartItem> items;

  QueueModel({
    required this.id,
    required this.customerName,
    required this.note,
    required this.createdAt,
    required this.items,
  });

  factory QueueModel.fromJson(Map<String, dynamic> json) {
    // Ambil list item dari 'details' (sesuai JSON Anda) atau fallback ke 'saved_order_items'
    var list = json['details'] ?? json['saved_order_items'] ?? [];
    
    List<CartItem> cartItemsList = [];

    if (list is List) {
      cartItemsList = list.map((i) {
        // Ambil objek product
        var p = i['product'] ?? {};

        // --- DEBUGGING HARGA ---
        // print("DEBUG PRODUCT: ${p['product_name']} | RAW PRICE: ${p['base_price']} | TYPE: ${p['base_price'].runtimeType}");

        // Parsing Harga Lebih Kuat (Handle String "3000", Int 3000, Double 3000.0)
        int parsedPrice = 0;
        var rawPrice = p['base_price'] ?? p['price']; // Cek kedua key

        if (rawPrice != null) {
           // Konversi ke String dulu -> Parse Double -> Ambil Int
           // Cara ini paling aman untuk menangani "3000", "3000.00", atau 3000
           parsedPrice = double.tryParse(rawPrice.toString())?.toInt() ?? 0;
        }

        // Parsing Quantity
        int parsedQty = int.tryParse(i['quantity']?.toString() ?? '1') ?? 1;

        // Mapping ke ProductModel
        ProductModel product = ProductModel(
          productId: i['product_id']?.toString() ?? '',
          name: p['product_name'] ?? 'Unknown Product',
          description: '', 
          imageUrl: '', 
          category: '', 
          price: parsedPrice, // Gunakan harga yang sudah diparsing
          isAvailable: true,
        );

        return CartItem(
          product: product,
          quantity: parsedQty,
          note: i['item_note'] ?? '',
        );
      }).toList();
    }

    return QueueModel(
      id: json['saved_order_id']?.toString() ?? '',
      customerName: json['queue_name'] ?? json['customer_name'] ?? 'Tanpa Nama',
      note: json['order_notes'] ?? json['note'] ?? '',
      createdAt: json['created_at'] ?? '',
      items: cartItemsList,
    );
  }
}