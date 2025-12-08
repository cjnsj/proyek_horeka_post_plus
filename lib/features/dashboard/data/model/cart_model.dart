import 'package:horeka_post_plus/features/dashboard/data/product_model.dart';

class CartItem {
  final ProductModel product;
  final int quantity; // Sekarang final (immutable)
  final String note;  // Sekarang final (immutable)

  CartItem({
    required this.product,
    this.quantity = 1,
    this.note = '',
  });

  // Getter untuk menghitung subtotal
  int get subtotal => product.price * quantity;

  // Konversi ke JSON untuk dikirim ke API
  Map<String, dynamic> toJson() {
    return {
      "product_id": product.productId,
      "quantity": quantity,
      "item_note": note,
    };
  }

  // Method copyWith: Membuat object baru dengan data yang diperbarui
  CartItem copyWith({
    ProductModel? product,
    int? quantity,
    String? note,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }
}