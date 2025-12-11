import 'package:equatable/equatable.dart';
import 'package:horeka_post_plus/features/dashboard/data/product_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/queue_model.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

// ================= SESSION / LIFECYCLE =================

// Event dipanggil saat Dashboard (HomePage) pertama kali dibuka
class DashboardStarted extends DashboardEvent {}

// Event dipanggil setelah PIN dan Saldo Awal berhasil diinput
class SaveDashboardSession extends DashboardEvent {}


// ================= REPORT =================

class FetchAllReportsRequested extends DashboardEvent {}

class ReportDateChanged extends DashboardEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const ReportDateChanged({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class ToggleReportVoidFilter extends DashboardEvent {
  final bool isVoid;
  const ToggleReportVoidFilter(this.isVoid);

  @override
  List<Object?> get props => [isVoid];
}


// ================= MENU =================

class FetchMenuRequested extends DashboardEvent {}

class SelectCategory extends DashboardEvent {
  final String category;
  const SelectCategory(this.category);

  @override
  List<Object?> get props => [category];
}


// ================= CART =================

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


// ================= PROMO CODE =================

class ApplyPromoCode extends DashboardEvent {
  final String promoCode;
  const ApplyPromoCode(this.promoCode);

  @override
  List<Object?> get props => [promoCode];
}

class RemovePromoCode extends DashboardEvent {}


// ================= TRANSACTION =================

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


// ================= EXPENSE =================

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


// ================= QUEUE =================

class SaveQueueRequested extends DashboardEvent {
  final String tableNumber;
  final String waiterName; // Sesuai input Anda (required)
  final String orderNotes; // Sesuai input Anda (required)

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


// ================= VOID MODE =================

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

class SearchTransactionRequested extends DashboardEvent {
  final String query;
  const SearchTransactionRequested(this.query);

  @override
  List<Object?> get props => [query];
}


// ================= TAX SETTINGS [READ ONLY] =================

// Hanya event ini yang dibutuhkan untuk memuat data pajak saat aplikasi mulai
class FetchTaxSettingsRequested extends DashboardEvent {}

