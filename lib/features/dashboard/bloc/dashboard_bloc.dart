import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_event.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_state.dart';
import 'package:horeka_post_plus/features/dashboard/data/dashboard_repository.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/cart_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/product_model.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc({required this.repository}) : super(const DashboardState()) {
    on<FetchMenuRequested>(_onFetchMenuRequested);
    on<SelectCategory>(_onSelectCategory);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
    on<CreateTransactionRequested>(_onCreateTransactionRequested);
    on<CreateExpenseRequested>(_onCreateExpenseRequested);
  }

  Future<void> _onFetchMenuRequested(
    FetchMenuRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final results = await Future.wait([
        repository.getMenu(),
        repository.getCategories(),
      ]);

      final productsList = results[0] as List<dynamic>;
      final categoriesList = results[1] as List<dynamic>;

      final List<String> categoryNames = ['Semua'];
      for (var cat in categoriesList) {
        categoryNames.add((cat as dynamic).name.toString());
      }

      if (categoryNames.length == 1 && productsList.isNotEmpty) {
        final Set<String> fallbackSet = {'Semua'};
        for (var p in productsList) {
          fallbackSet.add((p as dynamic).category.toString());
        }
        categoryNames.clear();
        categoryNames.addAll(fallbackSet);
      }

      final List<ProductModel> finalProducts =
          productsList.map((e) => e as ProductModel).toList();

      emit(state.copyWith(
        status: DashboardStatus.success,
        products: finalProducts,
        filteredProducts: finalProducts,
        categories: categoryNames,
        selectedCategory: 'Semua',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSelectCategory(
    SelectCategory event,
    Emitter<DashboardState> emit,
  ) {
    final selected = event.category;
    List<ProductModel> filtered;

    if (selected == 'Semua') {
      filtered = List.from(state.products);
    } else {
      filtered = state.products
          .where((p) => p.category == selected)
          .toList();
    }

    emit(state.copyWith(
      selectedCategory: selected,
      filteredProducts: filtered,
    ));
  }

  void _onAddToCart(AddToCart event, Emitter<DashboardState> emit) {
    final currentCart = List<CartItem>.from(state.cartItems);
    final index = currentCart.indexWhere(
        (item) => item.product.productId == event.product.productId);

    if (index != -1) {
      // [PERBAIKAN] Gunakan copyWith, jangan currentCart[index].quantity++
      currentCart[index] = currentCart[index].copyWith(
        quantity: currentCart[index].quantity + 1,
      );
    } else {
      currentCart.add(CartItem(product: event.product));
    }
    emit(state.copyWith(cartItems: currentCart));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<DashboardState> emit) {
    final currentCart = List<CartItem>.from(state.cartItems);
    final index = currentCart.indexWhere(
        (item) => item.product.productId == event.product.productId);

    if (index != -1) {
      if (currentCart[index].quantity > 1) {
        // [PERBAIKAN] Hapus baris 'quantity--;' dan gunakan copyWith
        currentCart[index] = currentCart[index].copyWith(
          quantity: currentCart[index].quantity - 1,
        );
      } else {
        currentCart.removeAt(index);
      }
      emit(state.copyWith(cartItems: currentCart));
    }
  }

  void _onClearCart(ClearCart event, Emitter<DashboardState> emit) {
    emit(state.copyWith(cartItems: []));
  }

  Future<void> _onCreateTransactionRequested(
    CreateTransactionRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.cartItems.isEmpty) return;

    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      await repository.createTransaction(
        items: state.cartItems,
        paymentMethod: event.paymentMethod,
        promoCode: event.promoCode,
      );

      emit(state.copyWith(
        status: DashboardStatus.transactionSuccess,
        cartItems: [],
      ));

      emit(state.copyWith(status: DashboardStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      ));
      emit(state.copyWith(status: DashboardStatus.success));
    }
  }

  Future<void> _onCreateExpenseRequested(
    CreateExpenseRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      await repository.createExpense(
        description: event.description,
        amount: event.amount,
      );

      emit(state.copyWith(status: DashboardStatus.expenseSuccess));
      emit(state.copyWith(status: DashboardStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      ));
      emit(state.copyWith(status: DashboardStatus.success));
    }
  }
}