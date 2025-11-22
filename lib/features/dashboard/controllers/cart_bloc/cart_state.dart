// lib/features/dashboard/controllers/cart_bloc/cart_state.dart

import 'package:horeka_post_plus/models/cart_item.dart';

class CartState {
  final List<CartItem> items;
  final String? promoCode;
  final double discount;
  final double tax;

  CartState({
    this.items = const [],
    this.promoCode,
    this.discount = 0.0,
    this.tax = 0.0,
  });

  // Hitung subtotal (sebelum diskon & pajak)
  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Total akhir (subtotal - diskon + pajak)
  double get total {
    return subtotal - discount + tax;
  }

  // Total item di cart
  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Check apakah cart kosong
  bool get isEmpty {
    return items.isEmpty;
  }

  // Copy with
  CartState copyWith({
    List<CartItem>? items,
    String? promoCode,
    double? discount,
    double? tax,
  }) {
    return CartState(
      items: items ?? this.items,
      promoCode: promoCode ?? this.promoCode,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
    );
  }
}
