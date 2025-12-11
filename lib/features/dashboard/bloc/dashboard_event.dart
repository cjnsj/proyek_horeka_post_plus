import 'package:equatable/equatable.dart';
import 'package:horeka_post_plus/features/dashboard/data/product_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/queue_model.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

// [BARU] Event untuk mengambil data laporan
class FetchAllReportsRequested extends DashboardEvent {}

// --- Menu ---
class FetchMenuRequested extends DashboardEvent {}

class SelectCategory extends DashboardEvent {
  final String category;
  const SelectCategory(this.category);
  @override
  List<Object?> get props => [category];
}

// --- Cart ---
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

// --- Transaction ---
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

// --- Expense ---
class CreateExpenseRequested extends DashboardEvent {
  final String description;
  final int amount;
  final String? imagePath;

  const CreateExpenseRequested({
    required this.description,
    required this.amount,
    this.imagePath,
  });

  @override
  List<Object?> get props => [description, amount, imagePath];
}

// --- Queue ---
class SaveQueueRequested extends DashboardEvent {
  final String tableNumber;
  final String waiterName;
  final String orderNotes;

  const SaveQueueRequested({
    required this.tableNumber,
    required this.waiterName,
    required this.orderNotes,
  });

  @override
  List<Object?> get props => [tableNumber, waiterName, orderNotes];
}

class FetchQueueListRequested extends DashboardEvent {}

class LoadQueueRequested extends DashboardEvent {
  final QueueModel queue;
  const LoadQueueRequested(this.queue);
  @override
  List<Object?> get props => [queue];
}

// --- VOID MODE (PERBAIKAN) ---

// Ini yang sebelumnya hilang dan bikin error
class FetchCurrentShiftTransactions extends DashboardEvent {}

class RequestVoidTransaction extends DashboardEvent {
  final String transactionId;
  final String reason;

  const RequestVoidTransaction({
    required this.transactionId,
    required this.reason,
  });

  @override
  List<Object?> get props => [transactionId, reason];
}

class SelectTransactionForVoid extends DashboardEvent {
  final Map<String, dynamic>? transaction;
  const SelectTransactionForVoid(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

// Opsional: Search manual jika nanti dibutuhkan
class SearchTransactionRequested extends DashboardEvent {
  final String query;
  const SearchTransactionRequested(this.query);
  @override
  List<Object?> get props => [query];
}

// [BARU] Event Ganti Tanggal Laporan
class ReportDateChanged extends DashboardEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const ReportDateChanged({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}


// [BARU] Event Toggle Filter Void di Laporan
class ToggleReportVoidFilter extends DashboardEvent {
  final bool isVoid;
  const ToggleReportVoidFilter(this.isVoid);

  @override
  List<Object?> get props => [isVoid];
}
