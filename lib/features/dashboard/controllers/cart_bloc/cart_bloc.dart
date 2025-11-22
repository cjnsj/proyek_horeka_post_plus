// lib/features/dashboard/controllers/cart_bloc/cart_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horeka_post_plus/models/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartState()) {
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<ClearCartEvent>(_onClearCart);
    on<UpdateItemNoteEvent>(_onUpdateItemNote);
    on<SetPromoCodeEvent>(_onSetPromoCode);
  }

  // Tambah item ke cart
  void _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) {
    final List<CartItem> updatedItems = List.from(state.items);

    // Cek apakah item sudah ada di cart
    final existingIndex =
        updatedItems.indexWhere((item) => item.productId == event.item.productId);

    if (existingIndex != -1) {
      // Item sudah ada, tambah quantity
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + 1,
      );
    } else {
      // Item baru, tambahkan ke cart
      updatedItems.add(event.item);
    }

    emit(state.copyWith(items: updatedItems));
  }

  // Update quantity
  void _onUpdateQuantity(UpdateQuantityEvent event, Emitter<CartState> emit) {
    final List<CartItem> updatedItems = List.from(state.items);

    final index =
        updatedItems.indexWhere((item) => item.productId == event.productId);

    if (index != -1) {
      if (event.newQuantity > 0) {
        updatedItems[index] = updatedItems[index].copyWith(
          quantity: event.newQuantity,
        );
      } else {
        // Quantity 0, hapus item
        updatedItems.removeAt(index);
      }
    }

    emit(state.copyWith(items: updatedItems));
  }

  // Hapus item
  void _onRemoveFromCart(RemoveFromCartEvent event, Emitter<CartState> emit) {
    final List<CartItem> updatedItems = List.from(state.items);
    updatedItems.removeWhere((item) => item.productId == event.productId);
    emit(state.copyWith(items: updatedItems));
  }

  // Clear cart
  void _onClearCart(ClearCartEvent event, Emitter<CartState> emit) {
    emit(CartState()); // Reset ke state awal
  }

  // Update note
  void _onUpdateItemNote(UpdateItemNoteEvent event, Emitter<CartState> emit) {
    final List<CartItem> updatedItems = List.from(state.items);

    final index =
        updatedItems.indexWhere((item) => item.productId == event.productId);

    if (index != -1) {
      updatedItems[index] = updatedItems[index].copyWith(
        itemNote: event.note,
      );
    }

    emit(state.copyWith(items: updatedItems));
  }

  // Set promo code
  void _onSetPromoCode(SetPromoCodeEvent event, Emitter<CartState> emit) {
    // Untuk sekarang hanya simpan kode, diskon dan pajak dihitung backend
    emit(state.copyWith(promoCode: event.promoCode));
  }
}
