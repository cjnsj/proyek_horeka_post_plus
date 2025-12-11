import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_event.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_state.dart';
import 'package:horeka_post_plus/features/dashboard/data/dashboard_repository.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/cart_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/product_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/report_models.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc({required this.repository}) : super(const DashboardState()) {
    // --- Menu & Category ---
    on<FetchMenuRequested>(_onFetchMenuRequested);
    on<SelectCategory>(_onSelectCategory);

    // --- Cart ---
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);

    // --- Transaction & Expense ---
    on<CreateTransactionRequested>(_onCreateTransactionRequested);
    on<CreateExpenseRequested>(_onCreateExpenseRequested);

    // --- Queue ---
    on<SaveQueueRequested>(_onSaveQueueRequested);
    on<FetchQueueListRequested>(_onFetchQueueListRequested);
    on<LoadQueueRequested>(_onLoadQueueRequested);

    // --- Void Mode ---
    on<FetchCurrentShiftTransactions>(_onFetchCurrentShiftTransactions);
    on<RequestVoidTransaction>(_onRequestVoidTransaction);
    on<SelectTransactionForVoid>(_onSelectTransactionForVoid);
    on<SearchTransactionRequested>(_onSearchTransactionRequested);

    // --- Report ---
    on<FetchAllReportsRequested>(_onFetchAllReportsRequested);
    // [BARU] Handler Toggle Void Filter
    on<ToggleReportVoidFilter>(_onToggleReportVoidFilter);
  }

  // ================= MENU HANDLERS =================

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

  void _onSelectCategory(SelectCategory event, Emitter<DashboardState> emit) {
    final selected = event.category;
    List<ProductModel> filtered;

    if (selected == 'Semua') {
      filtered = List.from(state.products);
    } else {
      filtered = state.products.where((p) => p.category == selected).toList();
    }

    emit(state.copyWith(
      selectedCategory: selected,
      filteredProducts: filtered,
    ));
  }

  // ================= CART HANDLERS =================

  void _onAddToCart(AddToCart event, Emitter<DashboardState> emit) {
    final currentCart = List<CartItem>.from(state.cartItems);
    final index = currentCart.indexWhere(
      (item) => item.product.productId == event.product.productId,
    );

    if (index != -1) {
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
      (item) => item.product.productId == event.product.productId,
    );

    if (index != -1) {
      if (currentCart[index].quantity > 1) {
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
    emit(state.copyWith(
      cartItems: [],
      clearEditingQueue: true,
    ));
  }

  // ================= TRANSACTION & EXPENSE HANDLERS =================

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
        clearEditingQueue: true,
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
        imagePath: event.imagePath,
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

  // ================= QUEUE HANDLERS =================

  Future<void> _onSaveQueueRequested(
    SaveQueueRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.cartItems.isEmpty) return;

    emit(state.copyWith(status: DashboardStatus.loading));

    try {
      if (state.editingQueue != null) {
        // Update Existing Queue
        await repository.updateQueue(
          id: state.editingQueue!.id,
          items: state.cartItems,
          tableNumber: event.tableNumber,
          waiterName: event.waiterName,
          orderNotes: event.orderNotes,
        );
      } else {
        // Create New Queue
        await repository.saveQueue(
          items: state.cartItems,
          tableNumber: event.tableNumber,
          waiterName: event.waiterName,
          orderNotes: event.orderNotes,
        );
      }

      emit(state.copyWith(
        status: DashboardStatus.queueSuccess,
        cartItems: [],
        clearEditingQueue: true,
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

  Future<void> _onFetchQueueListRequested(
    FetchQueueListRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final queues = await repository.getQueueList();
      emit(state.copyWith(status: DashboardStatus.success, queueList: queues));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onLoadQueueRequested(
    LoadQueueRequested event,
    Emitter<DashboardState> emit,
  ) {
    final loadedItems = List<CartItem>.from(event.queue.items);
    emit(state.copyWith(
      cartItems: loadedItems,
      editingQueue: event.queue,
    ));
  }

  // ================= VOID MODE HANDLERS =================

  Future<void> _onFetchCurrentShiftTransactions(
    FetchCurrentShiftTransactions event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final transactions = await repository.getCurrentShiftTransactions();
      
      emit(state.copyWith(
        status: DashboardStatus.success,
        transactionList: transactions,
        // [PERBAIKAN UTAMA]
        // Paksa reset pilihan ke null agar panel kanan kosong saat awal buka
        selectedTransaction: null, 
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRequestVoidTransaction(
    RequestVoidTransaction event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      await repository.requestVoidTransaction(
        transactionId: event.transactionId,
        reason: event.reason,
      );

      // Refresh list to show updated status (e.g., VOID_REQUESTED)
      final updatedList = await repository.getCurrentShiftTransactions();

      emit(state.copyWith(
        status: DashboardStatus.transactionSuccess, // Trigger success snackbar
        transactionList: updatedList,
        selectedTransaction: null,
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

  void _onSelectTransactionForVoid(
    SelectTransactionForVoid event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(selectedTransaction: event.transaction));
  }

  Future<void> _onSearchTransactionRequested(
    SearchTransactionRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      // Use standard search or filter locally if needed
      final transactions = await repository.searchTransactions(event.query);
      emit(state.copyWith(
        status: DashboardStatus.success,
        transactionList: transactions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ================= REPORT HANDLER =================

  // ================= REPORT HANDLER =================

  Future<void> _onFetchAllReportsRequested(
    FetchAllReportsRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // Gunakan loading agar UI report page tahu sedang proses
    emit(state.copyWith(status: DashboardStatus.loading));
    
    try {
      // Panggil 3 endpoint secara paralel agar cepat
      final results = await Future.wait([
        // 1. Sales Report
        repository.getSalesReport(
          startDate: state.reportStartDate,
          endDate: state.reportEndDate,
        ),
        
        // 2. Item Report -- [PERHATIKAN BAGIAN INI]
        // Kita harus mengirim parameter 'onlyVoid' sesuai status checkbox di state
        repository.getItemReport(
          startDate: state.reportStartDate,
          endDate: state.reportEndDate,
          onlyVoid: state.isReportVoidFilter, // <--- INI KUNCINYA
        ),
        
        // 3. Expense Report
        repository.getExpenseReport(),
      ]);

      emit(state.copyWith(
        status: DashboardStatus.success,
        salesReport: results[0] as SalesReportModel,
        itemReport: results[1] as List<ItemReportModel>,
        expenseReport: results[2] as ExpenseReportModel,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  // [BARU] Implementasi Handler Toggle
  void _onToggleReportVoidFilter(
    ToggleReportVoidFilter event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(isReportVoidFilter: event.isVoid));
    // Kita tidak perlu fetch ulang API jika filtering dilakukan di sisi client (frontend).
    // Tapi jika ingin fetch ulang dengan parameter baru, tambahkan: add(FetchAllReportsRequested());
  }
}