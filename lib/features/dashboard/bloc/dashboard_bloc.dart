import 'dart:async'; // [PENTING] Untuk StreamSubscription
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart'; // [PENTING] Untuk BTStatus
import 'package:horeka_post_plus/features/dashboard/services/printer_service.dart';
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

  // [INTEGRASI PRINTER]
  final PrinterService printerService = PrinterService();
  StreamSubscription? _printerSubscription; // Untuk memantau status koneksi

  DashboardBloc({required this.repository})
      : super(
          DashboardState(
            reportStartDate: DateTime.now().subtract(const Duration(days: 30)),
            reportEndDate: DateTime.now(),
          ),
        ) {
    // --- Session / Lifecycle ---
    on<DashboardStarted>(_onDashboardStarted);
    on<SaveDashboardSession>(_onSaveDashboardSession);

    // --- Menu & Category ---
    on<FetchMenuRequested>(_onFetchMenuRequested);
    on<SelectCategory>(_onSelectCategory);
    on<SearchMenuChanged>(_onSearchMenuChanged);

    // --- Cart ---
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);

    // --- Promo Code & Calculation ---
    on<ApplyPromoCodeRequested>(_onApplyPromoCode);
    on<RemovePromoCodeRequested>(_onRemovePromoCode);
    on<CalculateTransactionRequested>(_onCalculateTransaction);

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
    on<ResetReportState>(_onResetReportState);
    on<ToggleReportVoidFilter>(_onToggleReportVoidFilter);
    on<ReportDateChanged>(_onReportDateChanged);
    on<SelectReportTransaction>(_onSelectReportTransaction);
    on<ResetReportSelection>(_onResetReportSelection);

    // --- Tax Settings ---
    on<FetchTaxSettingsRequested>(_onFetchTaxSettings);

    // --- Store Profile (Header/Footer Struk) ---
    on<FetchStoreProfileRequested>(_onFetchStoreProfile);

    // --- Payment Methods ---
    on<FetchPaymentMethodsRequested>(_onFetchPaymentMethodsRequested);

    // --- Printer Handlers ---
    on<PrintReceiptRequested>(_onPrintReceiptRequested);
    on<ReprintTransactionRequested>(_onReprintTransactionRequested);

    // [RESET HANDLER]
    on<ResetDashboard>(_onResetDashboard);

    // Handler untuk update status koneksi printer (Hijau/Merah)
    on<PrinterConnectionUpdated>((event, emit) {
      emit(state.copyWith(isPrinterConnected: event.isConnected));
    });

    // Mulai mendengarkan status printer saat Bloc dibuat
    _initPrinterListener();
  }

  // ================= PRINTER LISTENER & METHODS =================

  void _initPrinterListener() {
    _printerSubscription = printerService.bluetoothStatusStream.listen((
      status,
    ) {
      final isConnected = (status == BTStatus.connected);
      add(PrinterConnectionUpdated(isConnected));
    });
  }

  @override
  Future<void> close() {
    _printerSubscription?.cancel();
    return super.close();
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
      // [KASUS 1] Sesi Aktif (Restart App saat Login)
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          isPinEntered: true,
          hasStartingBalance: true,
        ),
      );

      // Load Data karena PIN dianggap sudah tembus sebelumnya
      add(FetchMenuRequested());
      add(FetchTaxSettingsRequested());
      add(FetchStoreProfileRequested());
    } else {
      // [KASUS 2] Sesi Baru (Logout / Login Baru)
      // Gunakan DashboardState() baru agar bersih total.
      emit(
        DashboardState(
          status: DashboardStatus.success, 
          isPinEntered: false,             
          hasStartingBalance: false,
          
          // Tanggal laporan default
          reportStartDate: DateTime.now().subtract(const Duration(days: 30)),
          reportEndDate: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _onSaveDashboardSession(
    SaveDashboardSession event,
    Emitter<DashboardState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dashboard_session_active', true);

    emit(state.copyWith(isPinEntered: true, hasStartingBalance: true));

    // [PENTING] Load data SETELAH PIN Sukses
    add(FetchMenuRequested());
    add(FetchTaxSettingsRequested());
    add(FetchStoreProfileRequested());
  }

  Future<void> _onResetDashboard(
    ResetDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    // 1. Hapus Status Sesi di Memory
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('dashboard_session_active');

    // 2. HARD RESET STATE
    emit(DashboardState(
      reportStartDate: DateTime.now().subtract(const Duration(days: 30)),
      reportEndDate: DateTime.now(),
    ));
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

      final List<ProductModel> finalProducts = productsList
          .map((e) => e as ProductModel)
          .toList();

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          products: finalProducts,
          filteredProducts: finalProducts,
          categories: categoryNames,
          selectedCategory: 'Semua',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DashboardStatus.error,
          errorMessage: e.toString(),
        ),
      );
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

    emit(
      state.copyWith(selectedCategory: selected, filteredProducts: filtered),
    );
  }

  void _onSearchMenuChanged(
    SearchMenuChanged event,
    Emitter<DashboardState> emit,
  ) {
    final query = event.query.toLowerCase();
    final category = state.selectedCategory;

    List<ProductModel> baseList;
    if (category == 'Semua') {
      baseList = state.products;
    } else {
      baseList = state.products.where((p) => p.category == category).toList();
    }

    if (query.isEmpty) {
      emit(state.copyWith(filteredProducts: baseList));
    } else {
      final filtered = baseList.where((p) {
        return p.name.toLowerCase().contains(query);
      }).toList();
      emit(state.copyWith(filteredProducts: filtered));
    }
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
    add(CalculateTransactionRequested());
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
      add(CalculateTransactionRequested());
    }
  }

  void _onClearCart(ClearCart event, Emitter<DashboardState> emit) {
    emit(
      state.copyWith(
        cartItems: [],
        clearEditingQueue: true,
        clearPromoCode: true,
        subtotal: 0,
        autoDiscount: 0,
        manualDiscount: 0,
        taxValue: 0,
        finalTotalAmount: 0,
        appliedPromos: [],
      ),
    );
  }

  // ================= PROMO CODE & CALCULATION HANDLERS =================

  void _onApplyPromoCode(
    ApplyPromoCodeRequested event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(appliedPromoCode: event.promoCode));
    add(CalculateTransactionRequested());
  }

  void _onRemovePromoCode(
    RemovePromoCodeRequested event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(clearPromoCode: true));
    add(CalculateTransactionRequested());
  }

  Future<void> _onCalculateTransaction(
    CalculateTransactionRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.cartItems.isEmpty) return;

    try {
      final result = await repository.calculateTransaction(
        items: state.cartItems,
        promoCode: state.appliedPromoCode,
      );

      emit(
        state.copyWith(
          subtotal: result.subtotal,
          autoDiscount: result.totalDiscount,
          manualDiscount: 0,
          taxValue: result.totalTax,
          finalTotalAmount: result.totalAmount,
          appliedPromos: result.appliedPromos,
          status: DashboardStatus.success,
        ),
      );
    } catch (e) {
      if (state.appliedPromoCode != null) {
        emit(
          state.copyWith(
            status: DashboardStatus.error,
            errorMessage: e.toString().replaceAll("", ""),
            appliedPromoCode: null,
            clearPromoCode: true,
          ),
        );
        emit(
          state.copyWith(status: DashboardStatus.success, errorMessage: null),
        );
        add(CalculateTransactionRequested());
      } else {
        print("Error calculating: $e");
      }
    }
  }

  // ================= TRANSACTION & EXPENSE HANDLERS =================

  Future<void> _onCreateTransactionRequested(
    CreateTransactionRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // [VALIDASI SHIFT]
    if (!state.isShiftOpen) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: "Toko sedang tutup. Silakan Buka Shift dulu.",
      ));
      emit(state.copyWith(status: DashboardStatus.success, errorMessage: null));
      return;
    }

    if (state.cartItems.isEmpty) return;

    emit(state.copyWith(status: DashboardStatus.loading));

    try {
      // 1. Simpan Transaksi
      await repository.createTransaction(
        items: state.cartItems,
        paymentMethod: event.paymentMethod,
        promoCode: state.appliedPromoCode,
      );

      // 2. AUTO PRINT
      if (state.isPrinterConnected) {
        try {
          int total = state.finalTotalAmount;
          int paid = event.amountPaid ?? total;
          int change = paid - total;

          // Fetch Profil Terbaru (Auto Update)
          Map<String, dynamic> freshProfile = {};
          try {
            freshProfile = await repository.fetchStoreProfile();
          } catch (_) {}

          final pName = freshProfile['partner_name'] ?? state.partnerName;
          final sName = freshProfile['branch_name'] ?? state.storeName;
          final sAddr = freshProfile['address'] ?? state.storeAddress;
          final sPhone = freshProfile['phone_number'] ?? state.storePhone;
          final rHead = freshProfile['receipt_header'] ?? state.receiptHeader;
          final rFoot = freshProfile['receipt_footer'] ?? state.receiptFooter;
          final tName = freshProfile['tax_name'] ?? state.taxName;
          
          String opName = freshProfile['current_operator']?['name'] ?? state.currentOperatorName;
          String sNameShift = freshProfile['current_shift']?['shift_name'] ?? state.shiftName;

          final bytes = await printerService.generateReceipt(
            items: state.cartItems,
            subtotal: state.subtotal,
            tax: state.taxValue,
            taxPercentage: state.taxPercentage,
            discount: state.autoDiscount + state.manualDiscount,
            promoCode: state.appliedPromoCode,
            total: total,
            partnerName: pName,
            storeName: sName,
            storeAddress: sAddr,
            storePhone: sPhone,
            receiptHeader: rHead,
            receiptFooter: rFoot,
            taxName: tName,
            shiftName: sNameShift,
            cashierName: opName,
            transactionId: "TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}",
            paymentMethod: event.paymentMethod,
            amountPaid: paid,
            change: change,
          );

          await printerService.printReceipt(bytes);
        } catch (e) {
          print("⚠️ Gagal Auto Print: $e");
        }
      }

      if (state.editingQueue != null) {
        try {
          await repository.deleteQueue(state.editingQueue!.id);
        } catch (_) {}
      }

      emit(
        state.copyWith(
          status: DashboardStatus.transactionSuccess,
          cartItems: [],
          clearEditingQueue: true,
          clearPromoCode: true,
          subtotal: 0,
          autoDiscount: 0,
          manualDiscount: 0,
          taxValue: 0,
          finalTotalAmount: 0,
          appliedPromos: [],
        ),
      );

      emit(state.copyWith(status: DashboardStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: DashboardStatus.error,
          errorMessage: e.toString(),
        ),
      );
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
      emit(
        state.copyWith(
          status: DashboardStatus.error,
          errorMessage: e.toString(),
        ),
      );
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

      emit(
        state.copyWith(
          status: DashboardStatus.queueSuccess,
          cartItems: [],
          clearEditingQueue: true,
          clearPromoCode: true,
          subtotal: 0,
          autoDiscount: 0,
          manualDiscount: 0,
          taxValue: 0,
          finalTotalAmount: 0,
          appliedPromos: [],
        ),
      );

      emit(state.copyWith(status: DashboardStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: DashboardStatus.error,
          errorMessage: e.toString(),
        ),
      );
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
      emit(
        state.copyWith(
          status: DashboardStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onLoadQueueRequested(
    LoadQueueRequested event,
    Emitter<DashboardState> emit,
  ) {
    final loadedItems = List<CartItem>.from(event.queue.items);
    emit(
      state.copyWith(
        cartItems: loadedItems,
        editingQueue: event.queue,
        appliedPromoCode: null, // Reset promo jika load queue
        clearPromoCode: true,
      ),
    );
    add(CalculateTransactionRequested());
  }

  // ================= VOID MODE HANDLERS =================

  Future<void> _onFetchCurrentShiftTransactions(
    FetchCurrentShiftTransactions event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final transactions = await repository.getCurrentShiftTransactions();
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          transactionList: transactions,
          selectedTransaction: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DashboardStatus.error,
          errorMessage: e.toString(),
        ),
      );
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

      emit(
        state.copyWith(
          status: DashboardStatus.transactionSuccess,
          transactionList: updatedList,
          selectedTransaction: null,
        ),
      );

      emit(state.copyWith(status: DashboardStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: DashboardStatus.error,
          errorMessage: e.toString(),
        ),
      );
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
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          transactionList: transactions,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DashboardStatus.error,
          errorMessage: e.toString(),
        ),
      );
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
        repository.getExpenseReport(
          startDate: state.reportStartDate,
          endDate: state.reportEndDate,
        ),
      ]);

      emit(
        state.copyWith(
          reportStatus: DashboardStatus.success,
          salesReport: results[0] as SalesReportModel,
          itemReport: results[1] as List<ItemReportModel>,
          expenseReport: results[2] as ExpenseReportModel,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          reportStatus: DashboardStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onToggleReportVoidFilter(
    ToggleReportVoidFilter event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(isReportVoidFilter: event.isVoid));
  }

  void _onReportDateChanged(
    ReportDateChanged event,
    Emitter<DashboardState> emit,
  ) {
    emit(
      state.copyWith(
        reportStartDate: event.startDate,
        reportEndDate: event.endDate,
      ),
    );
    // Trigger ulang fetch data dengan tanggal baru
    add(FetchAllReportsRequested());
  }

  // ================= TAX & PROFILE HANDLERS =================

  Future<void> _onFetchTaxSettings(
    FetchTaxSettingsRequested event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final data = await repository.getTaxSettings();

      final isActive = data['is_active'] ?? false;
      final percent = (data['tax_percentage'] ?? 0).toDouble();

      emit(
        state.copyWith(
          taxPercentage: isActive ? percent : 0.0,
          taxName: data['tax_name'] ?? '',
          isTaxActive: isActive,
        ),
      );
    } catch (e) {
      print("⚠️ Gagal load pajak: $e");
    }
  }

  // [UPDATE SESUAI DOKUMENTASI v5.0] Fetch Profil Toko
  Future<void> _onFetchStoreProfile(
    FetchStoreProfileRequested event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final profileData = await repository.fetchStoreProfile();
      print("📦 DATA PROFIL TOKO DARI API: $profileData");

      // 1. Header Info
      final pName = profileData['partner_name'] ?? ''; 
      final sName = profileData['branch_name'] ?? '';
      final sAddress = profileData['address'] ?? '';
      final sPhone = profileData['phone_number'] ?? '';
      final rHeader = profileData['receipt_header'] ?? '';
      final rFooter = profileData['receipt_footer'] ?? '';

      // 2. Tax Info
      final tName = profileData['tax_name'] ?? state.taxName;
      final tPercent = double.tryParse(profileData['tax_percentage']?.toString() ?? '0') ?? 0.0;

      // 3. Operator & Shift Info
      String opName = 'Kasir';
      if (profileData['current_operator'] != null && profileData['current_operator'] is Map) {
        opName = profileData['current_operator']['name'] ?? 'Kasir';
      }

      bool shiftOpen = false;
      String sNameShift = '-'; 

      if (profileData['current_shift'] != null && profileData['current_shift'] is Map) {
        shiftOpen = profileData['current_shift']['is_open'] ?? false;
        sNameShift = profileData['current_shift']['shift_name'] ?? '-'; 
      }

      // 4. Update State
      emit(
        state.copyWith(
          partnerName: pName,
          storeName: sName,
          storeAddress: sAddress,
          storePhone: sPhone,
          receiptHeader: rHeader,
          receiptFooter: rFooter,
          taxName: tName,
          taxPercentage: tPercent,
          isTaxActive: tPercent > 0,
          currentOperatorName: opName,
          shiftName: sNameShift, 
          isShiftOpen: shiftOpen,
        ),
      );
    } catch (e) {
      print("⚠️ Gagal load profil toko: $e");
    }
  }

  Future<void> _onFetchPaymentMethodsRequested(
    FetchPaymentMethodsRequested event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final methods = await repository.getPaymentMethods();
      emit(state.copyWith(paymentMethods: methods));
    } catch (e) {
      print("Failed to load payment methods: $e");
    }
  }

  void _onSelectReportTransaction(
    SelectReportTransaction event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(selectedReportTransaction: event.transaction));
  }

  void _onResetReportSelection(
    ResetReportSelection event,
    Emitter<DashboardState> emit,
  ) {
    // Set selectedReportTransaction menjadi null agar UI kembali ke placeholder
    emit(state.copyWith(selectedReportTransaction: null));
  }

  // Handler untuk ResetReportState
  void _onResetReportState(
    ResetReportState event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(resetReportData: true));
    add(FetchAllReportsRequested());
  }

  // Method Handler: Print Receipt (MANUAL REPRINT - DRAFT)
  Future<void> _onPrintReceiptRequested(
    PrintReceiptRequested event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      int total = state.finalTotalAmount;

      // [SOLUSI AUTO UPDATE] Fetch data terbaru dulu sebelum print
      Map<String, dynamic> freshProfile = {};
      try {
        freshProfile = await repository.fetchStoreProfile();
      } catch (e) {
        print("⚠️ Gagal refresh profil saat print, pakai data lama: $e");
      }

      final pName = freshProfile['partner_name'] ?? state.partnerName;
      final sName = freshProfile['branch_name'] ?? state.storeName;
      final sAddr = freshProfile['address'] ?? state.storeAddress;
      final sPhone = freshProfile['phone_number'] ?? state.storePhone;
      final rHead = freshProfile['receipt_header'] ?? state.receiptHeader;
      final rFoot = freshProfile['receipt_footer'] ?? state.receiptFooter;
      final tName = freshProfile['tax_name'] ?? state.taxName;

      String opName = freshProfile['current_operator']?['name'] ?? state.currentOperatorName;
      String sNameShift = freshProfile['current_shift']?['shift_name'] ?? state.shiftName;

      final bytes = await printerService.generateReceipt(
        items: state.cartItems,
        subtotal: state.subtotal,
        tax: state.taxValue,
        taxPercentage: state.taxPercentage,
        discount: state.autoDiscount + state.manualDiscount,
        promoCode: state.appliedPromoCode,
        total: total,
        cashierName: opName,
        shiftName: sNameShift,
        partnerName: pName,
        storeName: sName,
        storeAddress: sAddr,
        storePhone: sPhone,
        receiptHeader: rHead,
        receiptFooter: rFoot,
        taxName: tName,
        transactionId: "TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}",
        paymentMethod: "Draft",
        amountPaid: total,
        change: 0,
      );

      await printerService.printReceipt(bytes);
    } catch (e) {
      print("Print Error: $e");
    }
  }

  // Method Handler: Reprint Receipt (HISTORY)
  Future<void> _onReprintTransactionRequested(
    ReprintTransactionRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (!state.isPrinterConnected) {
      print("⚠️ Printer belum terhubung");
      return;
    }

    try {
      final tx = event.transaction;

      Map<String, dynamic> freshProfile = {};
      try {
        freshProfile = await repository.fetchStoreProfile();
      } catch (_) {}

      final pName = freshProfile['partner_name'] ?? state.partnerName;
      final sName = freshProfile['branch_name'] ?? state.storeName;
      final sAddr = freshProfile['address'] ?? state.storeAddress;
      final sPhone = freshProfile['phone_number'] ?? state.storePhone;
      final rHead = freshProfile['receipt_header'] ?? state.receiptHeader;
      final rFoot = freshProfile['receipt_footer'] ?? state.receiptFooter;
      final tName = freshProfile['tax_name'] ?? state.taxName;

      final List<dynamic> rawItems = (tx['items'] ?? tx['transaction_details'] ?? []) as List<dynamic>;
      List<CartItem> cartItems = [];

      for (var item in rawItems) {
        if (item is! Map) continue;
        String name = item['product_name']?.toString() ?? item['product']?['product_name']?.toString() ?? 'Item';
        int qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
        double price = double.tryParse((item['price_at_transaction'] ?? item['unit_price'] ?? item['price'] ?? 0).toString()) ?? 0;

        final product = ProductModel(
          productId: '0',
          name: name,
          price: price.toInt(),
          description: '-',
          imageUrl: '',
          category: 'General',
          isAvailable: true,
        );
        cartItems.add(CartItem(product: product, quantity: qty));
      }

      double safeParse(dynamic value) => value == null ? 0.0 : double.tryParse(value.toString()) ?? 0.0;
      final double total = safeParse(tx['total_amount']);
      final double tax = safeParse(tx['total_tax'] ?? tx['tax_amount']);
      final double discount = safeParse(tx['total_discount'] ?? tx['discount_amount']);
      final double subtotal = total - tax + discount;

      final String receiptNo = (tx['receipt_number'] ?? tx['transaction_number'] ?? '-').toString();
      final String paymentMethod = (tx['payment_method'] ?? 'CASH').toString();
      final String promoCode = (tx['promo_code'] ?? '').toString();

      String cashierName = state.currentOperatorName;
      if (tx['shift'] != null && tx['shift'] is Map && tx['shift']['cashier'] != null && tx['shift']['cashier']['full_name'] != null) {
        cashierName = tx['shift']['cashier']['full_name'].toString();
      } else if (tx['cashier_name'] != null) {
        cashierName = tx['cashier_name'].toString();
      } else if (tx['user'] != null && tx['user'] is Map && tx['user']['full_name'] != null) {
        cashierName = tx['user']['full_name'].toString();
      }

      String shiftNameReprint = freshProfile['current_shift']?['shift_name'] ?? state.shiftName;

      final bytes = await printerService.generateReceipt(
        items: cartItems,
        subtotal: subtotal.toInt(),
        tax: tax.toInt(),
        taxPercentage: state.taxPercentage,
        discount: discount.toInt(),
        promoCode: promoCode.isNotEmpty ? promoCode : null,
        total: total.toInt(),
        partnerName: pName,
        storeName: sName,
        storeAddress: sAddr,
        storePhone: sPhone,
        receiptHeader: rHead,
        receiptFooter: rFoot,
        taxName: tName,
        shiftName: shiftNameReprint,
        cashierName: cashierName,
        transactionId: receiptNo,
        paymentMethod: "$paymentMethod (Reprint)",
        amountPaid: total.toInt(),
        change: 0,
      );

      await printerService.printReceipt(bytes);
    } catch (e, stackTrace) {
      print("❌ Gagal Reprint: $e");
      print(stackTrace);
    }
  }
}