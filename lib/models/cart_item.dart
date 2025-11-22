// lib/models/cart_item.dart

class CartItem {
  final String productId;
  final String name;
  final String price;
  final String? imageUrl;
  final String? category;
  int quantity;
  String? itemNote; // Catatan khusus (misal: "Less sugar")

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.category,
    this.quantity = 1,
    this.itemNote,
  });

  // Hitung total harga item ini (price x quantity)
  double get totalPrice {
    final priceValue = double.tryParse(price) ?? 0.0;
    return priceValue * quantity;
  }

  // Convert ke JSON untuk dikirim ke API
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      if (itemNote != null && itemNote!.isNotEmpty) 'item_note': itemNote,
    };
  }

  // Copy with untuk update quantity/note
  CartItem copyWith({
    int? quantity,
    String? itemNote,
  }) {
    return CartItem(
      productId: productId,
      name: name,
      price: price,
      imageUrl: imageUrl,
      category: category,
      quantity: quantity ?? this.quantity,
      itemNote: itemNote ?? this.itemNote,
    );
  }
}
