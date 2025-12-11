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
  final DashboardStatus status;
  
  // --- Master Data ---
  final List<ProductModel> products;
  final List<ProductModel> filteredProducts;
  final List<String> categories;
  final String selectedCategory;
  
  // --- Cart State ---
  final List<CartItem> cartItems;
  
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
  final bool isReportVoidFilter; // [BARU] Status Checkbox Only Void

  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.products = const [],
    this.filteredProducts = const [],
    this.categories = const ['Semua'],
    this.selectedCategory = 'Semua',
    this.cartItems = const [],
    this.queueList = const [],
    this.editingQueue,
    this.transactionList = const [],
    this.selectedTransaction,
    this.salesReport,
    this.itemReport = const [],
    this.expenseReport,
    this.reportStartDate,
    this.reportEndDate,
    this.isReportVoidFilter = false, // [BARU] Default false
    this.errorMessage,
  });

  // Getter total belanja cart
  int get totalAmount => cartItems.fold(0, (sum, item) => sum + item.subtotal);

  DashboardState copyWith({
    DashboardStatus? status,
    List<ProductModel>? products,
    List<ProductModel>? filteredProducts,
    List<String>? categories,
    String? selectedCategory,
    List<CartItem>? cartItems,
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
    bool? isReportVoidFilter, // [BARU]
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      cartItems: cartItems ?? this.cartItems,
      queueList: queueList ?? this.queueList,
      editingQueue: clearEditingQueue ? null : (editingQueue ?? this.editingQueue),
      transactionList: transactionList ?? this.transactionList,
      selectedTransaction: selectedTransaction ?? this.selectedTransaction,
      salesReport: salesReport ?? this.salesReport,
      itemReport: itemReport ?? this.itemReport,
      expenseReport: expenseReport ?? this.expenseReport,
      reportStartDate: reportStartDate ?? this.reportStartDate,
      reportEndDate: reportEndDate ?? this.reportEndDate,
      isReportVoidFilter: isReportVoidFilter ?? this.isReportVoidFilter, // [BARU]
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
        queueList,
        editingQueue,
        transactionList,
        selectedTransaction,
        salesReport,
        itemReport,
        expenseReport,
        reportStartDate,
        reportEndDate,
        isReportVoidFilter, // [BARU]
        errorMessage,
      ];
}