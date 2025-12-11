import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_event.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_state.dart';
import 'package:horeka_post_plus/features/dashboard/data/dashboard_repository.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/cart_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/product_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/report_models.dart';
import 'package:horeka_post_plus/features/dashboard/data/queue_model.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc({required this.repository}) : super(const DashboardState()) {
    // --- Session / Lifecycle ---
    on<DashboardStarted>(_onDashboardStarted);
    on<SaveDashboardSession>(_onSaveDashboardSession);

    // --- Menu & Category ---
    on<FetchMenuRequested>(_onFetchMenuRequested);
    on<SelectCategory>(_onSelectCategory);

    // --- Cart ---
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);

    // --- Promo Code ---
    on<ApplyPromoCode>(_onApplyPromoCode);
    on<RemovePromoCode>(_onRemovePromoCode);

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
    on<ToggleReportVoidFilter>(_onToggleReportVoidFilter);

    // --- Tax Settings [BARU] ---
    // Jangan lupa daftarkan handler ini!
    on<FetchTaxSettingsRequested>(_onFetchTaxSettings);
   
  }

  // ================= SESSION HANDLERS =================

  Future<void> _onDashboardStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));

    final prefs = await SharedPreferences.getInstance();
    final isSessionActive = prefs.getBool('dashboard_session_active') ?? false;

    if (isSessionActive) {
      emit(state.copyWith(
        status: DashboardStatus.success,
        isPinEntered: true,
        hasStartingBalance: true,
      ));
      
      // Load Menu & Pajak secara bersamaan
      add(FetchMenuRequested());
      add(FetchTaxSettingsRequested()); // [PENTING] Load pajak saat start
    } else {
      emit(state.copyWith(
        status: DashboardStatus.success, 
        isPinEntered: false,
      ));
    }
  }

  Future<void> _onSaveDashboardSession(
    SaveDashboardSession event,
    Emitter<DashboardState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dashboard_session_active', true);

    emit(state.copyWith(isPinEntered: true, hasStartingBalance: true));
  }

  // ================= MENU HANDLERS =================

  Future<void> _onFetchMenuRequested(
    FetchMenuRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.products.isEmpty) {
      emit(state.copyWith(status: DashboardStatus.loading));
    }

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

    // Reset promo code saat cart berubah agar validasi ulang
    emit(state.copyWith(cartItems: currentCart, clearPromo: true));
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

      // Reset promo code saat cart berubah
      emit(state.copyWith(cartItems: currentCart, clearPromo: true));
    }
  }

  void _onClearCart(ClearCart event, Emitter<DashboardState> emit) {
    emit(state.copyWith(
      cartItems: [],
      clearEditingQueue: true,
      clearPromo: true, // Reset promo saat cart dibersihkan
    ));
  }

  // ================= PROMO CODE HANDLERS =================

  Future<void> _onApplyPromoCode(
    ApplyPromoCode event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.cartItems.isEmpty) return;

    emit(state.copyWith(status: DashboardStatus.loading));

    try {
      final resultData = await repository.calculateDiscount(
        items: state.cartItems,
        promoCode: event.promoCode,
      );

      final discountVal =
          int.tryParse(resultData['total_discount'].toString()) ?? 0;

      if (discountVal == 0) {
        throw Exception(
          "Kode valid, namun syarat transaksi belum terpenuhi (Diskon Rp 0).",
        );
      }

      emit(state.copyWith(
        status: DashboardStatus.success,
        discountAmount: discountVal,
        appliedPromoCode: event.promoCode,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      ));
      emit(state.copyWith(status: DashboardStatus.success));
    }
  }

  void _onRemovePromoCode(
    RemovePromoCode event, 
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(clearPromo: true));
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
        promoCode: state.appliedPromoCode,
      );

      List<QueueModel> currentQueueList = List.from(state.queueList);

      if (state.editingQueue != null) {
        try {
          final String queueId = state.editingQueue!.id;
          if (queueId.isNotEmpty) {
            await repository.deleteQueue(queueId);
            currentQueueList.removeWhere((q) => q.id == queueId);
          }
        } catch (e) {
          print("⚠️ Gagal hapus antrian otomatis: $e");
        }
      }

      emit(state.copyWith(
        status: DashboardStatus.transactionSuccess,
        cartItems: [],
        clearEditingQueue: true,
        clearPromo: true,
        queueList: currentQueueList,
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
        await repository.updateQueue(
          id: state.editingQueue!.id,
          items: state.cartItems,
          tableNumber: event.tableNumber,
          waiterName: event.waiterName,
          orderNotes: event.orderNotes,
        );
      } else {
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
        clearPromo: true,
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
      clearPromo: true,
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

      final updatedList = await repository.getCurrentShiftTransactions();

      emit(state.copyWith(
        status: DashboardStatus.transactionSuccess,
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

  Future<void> _onFetchAllReportsRequested(
    FetchAllReportsRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(reportStatus: DashboardStatus.loading));

    try {
      final results = await Future.wait([
        repository.getSalesReport(
          startDate: state.reportStartDate,
          endDate: state.reportEndDate,
        ),
        repository.getItemReport(
          startDate: state.reportStartDate,
          endDate: state.reportEndDate,
          onlyVoid: state.isReportVoidFilter,
        ),
        repository.getExpenseReport(),
      ]);

      emit(state.copyWith(
        reportStatus: DashboardStatus.success,
        salesReport: results[0] as SalesReportModel,
        itemReport: results[1] as List<ItemReportModel>,
        expenseReport: results[2] as ExpenseReportModel,
      ));
    } catch (e) {
      emit(state.copyWith(
        reportStatus: DashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onToggleReportVoidFilter(
    ToggleReportVoidFilter event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(isReportVoidFilter: event.isVoid));
  }

  // ================= TAX SETTINGS HANDLERS [READ ONLY] =================

  Future<void> _onFetchTaxSettings(
    FetchTaxSettingsRequested event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final data = await repository.getTaxSettings();
      
      // Backend return: { "tax_percentage": 11, "is_active": true, ... }
      final isActive = data['is_active'] ?? false;
      final percent = (data['tax_percentage'] ?? 0).toDouble();

      emit(state.copyWith(
        taxPercentage: isActive ? percent : 0.0,
        taxName: data['tax_name'] ?? '',
        isTaxActive: isActive,
      ));
    } catch (e) {
      print("⚠️ Gagal load pajak: $e");
      // Silent error agar tidak mengganggu kasir
    }
  }
}