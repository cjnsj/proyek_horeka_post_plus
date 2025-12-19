import 'package:equatable/equatable.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/payment_method_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/product_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/cart_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/queue_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/report_models.dart';
import 'package:horeka_post_plus/features/dashboard/data/dashboard_repository.dart'; // Import Model AppliedPromo

enum DashboardStatus {
  initial,
  loading,
  success,
  error,
  transactionSuccess,
  expenseSuccess,
  queueSuccess,
}

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardStatus reportStatus;

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

  // --- Calculation State (Server Side) ---
  final int subtotal;
  final int autoDiscount;
  final int manualDiscount;
  final int taxValue;
  final int finalTotalAmount;

  // --- Promo Code State ---
  final String? appliedPromoCode;
  final List<AppliedPromo> appliedPromos;

  // --- Tax Settings (Info Only) ---
  final double taxPercentage;
  final String taxName;
  final bool isTaxActive;

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

  // --- Payment State ---
  final List<PaymentMethodModel> paymentMethods;

  // [TAMBAHKAN FIELD INI]
  final Map<String, dynamic>? selectedReportTransaction;

  // [BARU: Status Koneksi Printer]
  final bool isPrinterConnected; 

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

    // Default Calculation
    this.subtotal = 0,
    this.autoDiscount = 0,
    this.manualDiscount = 0,
    this.taxValue = 0,
    this.finalTotalAmount = 0,

    this.appliedPromoCode,
    this.appliedPromos = const [],

    this.taxPercentage = 0.0,
    this.taxName = '',
    this.isTaxActive = false,
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
    this.paymentMethods = const [],
    this.selectedReportTransaction, 
    this.isPrinterConnected = false, // Default Merah (Belum konek)
    this.errorMessage,
  });

  // [PERBAIKAN] Menambahkan getter discountAmount untuk backward compatibility
  int get discountAmount => autoDiscount + manualDiscount;

  int get totalDiscount => autoDiscount + manualDiscount;
  int get totalAmount => subtotal;

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

    // Calculation
    int? subtotal,
    int? autoDiscount,
    int? manualDiscount,
    int? taxValue,
    int? finalTotalAmount,

    String? appliedPromoCode,
    bool clearPromoCode = false,
    List<AppliedPromo>? appliedPromos,

    double? taxPercentage,
    String? taxName,
    bool? isTaxActive,
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
    List<PaymentMethodModel>? paymentMethods,
    Map<String, dynamic>? selectedReportTransaction,
    
    // Parameter Printer
    bool? isPrinterConnected,
    
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

      subtotal: subtotal ?? this.subtotal,
      autoDiscount: autoDiscount ?? this.autoDiscount,
      manualDiscount: manualDiscount ?? this.manualDiscount,
      taxValue: taxValue ?? this.taxValue,
      finalTotalAmount: finalTotalAmount ?? this.finalTotalAmount,

      appliedPromoCode: clearPromoCode
          ? null
          : (appliedPromoCode ?? this.appliedPromoCode),
      appliedPromos: appliedPromos ?? this.appliedPromos,

      taxPercentage: taxPercentage ?? this.taxPercentage,
      taxName: taxName ?? this.taxName,
      isTaxActive: isTaxActive ?? this.isTaxActive,
      queueList: queueList ?? this.queueList,
      editingQueue: clearEditingQueue
          ? null
          : (editingQueue ?? this.editingQueue),
      transactionList: transactionList ?? this.transactionList,
      selectedTransaction: selectedTransaction ?? this.selectedTransaction,
      salesReport: salesReport ?? this.salesReport,
      itemReport: itemReport ?? this.itemReport,
      expenseReport: expenseReport ?? this.expenseReport,
      reportStartDate: reportStartDate ?? this.reportStartDate,
      reportEndDate: reportEndDate ?? this.reportEndDate,
      isReportVoidFilter: isReportVoidFilter ?? this.isReportVoidFilter,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedReportTransaction: selectedReportTransaction ?? this.selectedReportTransaction,
      isPrinterConnected: isPrinterConnected ?? this.isPrinterConnected,
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
    subtotal,
    autoDiscount,
    manualDiscount,
    taxValue,
    finalTotalAmount,
    appliedPromoCode,
    appliedPromos,
    taxPercentage,
    taxName,
    isTaxActive,
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
    paymentMethods,
    selectedReportTransaction, 
    isPrinterConnected, // [JANGAN LUPA: Tambahkan ke Props]
    errorMessage,
  ];
}