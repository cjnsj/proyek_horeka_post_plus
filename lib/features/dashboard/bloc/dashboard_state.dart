import 'package:equatable/equatable.dart';
import 'package:horeka_post_plus/features/dashboard/data/product_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/cart_model.dart';

// [UPDATE] Tambahkan 'expenseSuccess'
enum DashboardStatus { initial, loading, success, error, transactionSuccess, expenseSuccess }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final List<ProductModel> products;
  final List<ProductModel> filteredProducts;
  final List<String> categories;
  final String selectedCategory;
  final List<CartItem> cartItems;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.products = const [],
    this.filteredProducts = const [],
    this.categories = const ['Semua'],
    this.selectedCategory = 'Semua',
    this.cartItems = const [],
    this.errorMessage,
  });

  int get totalAmount => cartItems.fold(0, (sum, item) => sum + item.subtotal);

  DashboardState copyWith({
    DashboardStatus? status,
    List<ProductModel>? products,
    List<ProductModel>? filteredProducts,
    List<String>? categories,
    String? selectedCategory,
    List<CartItem>? cartItems,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      cartItems: cartItems ?? this.cartItems,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        filteredProducts,
        categories,
        selectedCategory,
        cartItems,
        errorMessage,
      ];
}