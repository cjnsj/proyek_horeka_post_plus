import 'package:equatable/equatable.dart';
import 'package:horeka_post_plus/features/dashboard/data/product_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/cart_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/queue_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/report_models.dart';

enum DashboardStatus { 
  initial, loading, success, error, 
  transactionSuccess, expenseSuccess, queueSuccess 
}

class DashboardState extends Equatable {
  final DashboardStatus status;       // Status Global (Login, Transaksi, Menu)
  final DashboardStatus reportStatus; // Status Khusus Laporan
  
  // --- Session State ---
  final bool isPinEntered;
  final bool hasStartingBalance;

  // --- Master Data ---
  final List<ProductModel> products;
  final List<ProductModel> filteredProducts;
  final List<String> categories;
  final String selectedCategory;
  
  // --- Cart State ---
  final List<CartItem> cartItems;

  // --- Promo Code State ---
  final int discountAmount;
  final String? appliedPromoCode;

  // --- Tax State [BARU] ---
  final double taxPercentage; // Persen Pajak (misal: 11.0)
  final String taxName;       // Nama Pajak (misal: PPN)
  final bool isTaxActive;     // Status aktif
  
  // --- Queue State ---
  final List<QueueModel> queueList;
  final QueueModel? editingQueue;
  
  // --- Void Mode State ---
  final List<dynamic> transactionList;
  final Map<String, dynamic>? selectedTransaction;

  // --- Report State ---
  final SalesReportModel? salesReport;
  final List<ItemReportModel> itemReport;
  final ExpenseReportModel? expenseReport;

  // Filter Laporan
  final DateTime? reportStartDate;
  final DateTime? reportEndDate;
  final bool isReportVoidFilter;

  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.reportStatus = DashboardStatus.initial,
    this.isPinEntered = false,
    this.hasStartingBalance = false,
    this.products = const [],
    this.filteredProducts = const [],
    this.categories = const ['Semua'],
    this.selectedCategory = 'Semua',
    this.cartItems = const [],
    this.discountAmount = 0,
    this.appliedPromoCode,
    this.taxPercentage = 0.0, // [BARU] Default 0%
    this.taxName = '',        // [BARU] Default kosong
    this.isTaxActive = false, // [BARU] Default nonaktif
    this.queueList = const [],
    this.editingQueue,
    this.transactionList = const [],
    this.selectedTransaction,
    this.salesReport,
    this.itemReport = const [],
    this.expenseReport,
    this.reportStartDate,
    this.reportEndDate,
    this.isReportVoidFilter = false,
    this.errorMessage,
  });

  // Getter 1: Total Belanja (Subtotal)
  int get totalAmount => cartItems.fold(0, (sum, item) => sum + item.subtotal);

  // Getter 2: Nominal Diskon Aman (Tidak boleh > Subtotal)
  int get safeDiscountAmount => discountAmount > totalAmount ? totalAmount : discountAmount;

  // Getter 3: Nominal Pajak (Dihitung dari Harga Setelah Diskon)
  // [BARU] Tax = (Subtotal - Diskon) * PersenPajak
  double get taxValue {
    final taxableAmount = totalAmount - safeDiscountAmount;
    if (taxableAmount <= 0) return 0.0;
    return taxableAmount * (taxPercentage / 100);
  }

  // Getter 4: Total Bayar Akhir
  // [BARU] Final = (Subtotal - Diskon) + Pajak
  int get finalTotalAmount {
    final taxableAmount = totalAmount - safeDiscountAmount;
    final tax = taxableAmount * (taxPercentage / 100);
    return (taxableAmount + tax).round(); // Pembulatan ke int terdekat
  }

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardStatus? reportStatus,
    bool? isPinEntered,
    bool? hasStartingBalance,
    List<ProductModel>? products,
    List<ProductModel>? filteredProducts,
    List<String>? categories,
    String? selectedCategory,
    List<CartItem>? cartItems,
    int? discountAmount,
    String? appliedPromoCode,
    bool clearPromo = false,
    double? taxPercentage, // [BARU]
    String? taxName,       // [BARU]
    bool? isTaxActive,     // [BARU]
    List<QueueModel>? queueList,
    QueueModel? editingQueue,
    bool clearEditingQueue = false,
    List<dynamic>? transactionList,
    Map<String, dynamic>? selectedTransaction,
    SalesReportModel? salesReport,
    List<ItemReportModel>? itemReport,
    ExpenseReportModel? expenseReport,
    DateTime? reportStartDate,
    DateTime? reportEndDate,
    bool? isReportVoidFilter,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      reportStatus: reportStatus ?? this.reportStatus,
      isPinEntered: isPinEntered ?? this.isPinEntered,
      hasStartingBalance: hasStartingBalance ?? this.hasStartingBalance,
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      cartItems: cartItems ?? this.cartItems,
      discountAmount: clearPromo ? 0 : (discountAmount ?? this.discountAmount),
      appliedPromoCode: clearPromo ? null : (appliedPromoCode ?? this.appliedPromoCode),
      // [BARU] Update state pajak
      taxPercentage: taxPercentage ?? this.taxPercentage,
      taxName: taxName ?? this.taxName,
      isTaxActive: isTaxActive ?? this.isTaxActive,
      queueList: queueList ?? this.queueList,
      editingQueue: clearEditingQueue ? null : (editingQueue ?? this.editingQueue),
      transactionList: transactionList ?? this.transactionList,
      selectedTransaction: selectedTransaction ?? this.selectedTransaction,
      salesReport: salesReport ?? this.salesReport,
      itemReport: itemReport ?? this.itemReport,
      expenseReport: expenseReport ?? this.expenseReport,
      reportStartDate: reportStartDate ?? this.reportStartDate,
      reportEndDate: reportEndDate ?? this.reportEndDate,
      isReportVoidFilter: isReportVoidFilter ?? this.isReportVoidFilter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        reportStatus,
        isPinEntered,
        hasStartingBalance,
        products,
        filteredProducts,
        categories,
        selectedCategory,
        cartItems,
        discountAmount,
        appliedPromoCode,
        taxPercentage, // [BARU]
        taxName,       // [BARU]
        isTaxActive,   // [BARU]
        queueList,
        editingQueue,
        transactionList,
        selectedTransaction,
        salesReport,
        itemReport,
        expenseReport,
        reportStartDate,
        reportEndDate,
        isReportVoidFilter,
        errorMessage,
      ];
}