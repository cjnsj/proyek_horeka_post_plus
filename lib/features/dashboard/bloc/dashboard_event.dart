import 'package:equatable/equatable.dart';
import 'package:horeka_post_plus/features/dashboard/data/product_model.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class FetchMenuRequested extends DashboardEvent {}

class SelectCategory extends DashboardEvent {
  final String category;
  const SelectCategory(this.category);
  @override
  List<Object?> get props => [category];
}

class AddToCart extends DashboardEvent {
  final ProductModel product;
  const AddToCart(this.product);
  @override
  List<Object?> get props => [product];
}

class RemoveFromCart extends DashboardEvent {
  final ProductModel product;
  const RemoveFromCart(this.product);
  @override
  List<Object?> get props => [product];
}

class ClearCart extends DashboardEvent {}

class CreateTransactionRequested extends DashboardEvent {
  final String paymentMethod;
  final String? promoCode;

  const CreateTransactionRequested({
    required this.paymentMethod,
    this.promoCode,
  });

  @override
  List<Object?> get props => [paymentMethod, promoCode];
}

// [BARU] Event Catat Pengeluaran
class CreateExpenseRequested extends DashboardEvent {
  final String description;
  final int amount;

  const CreateExpenseRequested({
    required this.description,
    required this.amount,
  });

  @override
  List<Object?> get props => [description, amount];
}