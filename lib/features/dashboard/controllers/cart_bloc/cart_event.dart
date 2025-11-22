// lib/features/dashboard/controllers/cart_bloc/cart_event.dart

import 'package:horeka_post_plus/models/cart_item.dart';

abstract class CartEvent {}

// Tambah item ke cart
class AddToCartEvent extends CartEvent {
  final CartItem item;
  AddToCartEvent(this.item);
}

// Update quantity item
class UpdateQuantityEvent extends CartEvent {
  final String productId;
  final int newQuantity;
  UpdateQuantityEvent(this.productId, this.newQuantity);
}

// Hapus item dari cart
class RemoveFromCartEvent extends CartEvent {
  final String productId;
  RemoveFromCartEvent(this.productId);
}

// Clear seluruh cart
class ClearCartEvent extends CartEvent {}

// Update note item
class UpdateItemNoteEvent extends CartEvent {
  final String productId;
  final String note;
  UpdateItemNoteEvent(this.productId, this.note);
}

// Set promo code
class SetPromoCodeEvent extends CartEvent {
  final String promoCode;
  SetPromoCodeEvent(this.promoCode);
}
