import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_event.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_state.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';

class VoidModePage extends StatefulWidget {
  const VoidModePage({super.key});

  @override
  State<VoidModePage> createState() => _VoidModePageState();
}

class _VoidModePageState extends State<VoidModePage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(FetchCurrentShiftTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      // [PERBAIKAN] Tambahkan ini agar background tidak gerak saat keyboard muncul
      resizeToAvoidBottomInset: false, 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: kWhiteColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: kCardShadow,
            ),
            child: Column(
              children: const [
                _VoidHeaderBar(),
                Divider(height: 1, thickness: 1, color: kBorderColor),
                Expanded(child: _VoidBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VoidHeaderBar extends StatelessWidget {
  const _VoidHeaderBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: kBrandColor,
          ),
          const SizedBox(width: 4),
          const Text(
            'Void Mode',
            style: TextStyle(
              color: kBrandColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state.status == DashboardStatus.loading) {
                return const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kBrandColor,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _VoidBody extends StatelessWidget {
  const _VoidBody();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(flex: 48, child: _LeftTransactionList()),
        VerticalDivider(width: 1, thickness: 1, color: kBorderColor),
        Expanded(flex: 52, child: _RightCartPreview()),
      ],
    );
  }
}

// ================== DAFTAR TRANSAKSI (KIRI) ==================

class _LeftTransactionList extends StatelessWidget {
  const _LeftTransactionList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SearchBar(),
        const Divider(height: 1, thickness: 1, color: kBorderColor),
        Expanded(
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state.transactionList.isEmpty) {
                return const Center(
                  child: Text(
                    'No transactions found in this shift',
                    style: TextStyle(color: kTextGrey),
                  ),
                );
              }

              return ListView.separated(
                itemCount: state.transactionList.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: kBorderColor),
                itemBuilder: (context, index) {
                  final transaction = state.transactionList[index];
                  return _TransactionItem(transaction: transaction);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorderColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: const Text(
          "Current Shift Transactions",
          style: TextStyle(color: kTextGrey),
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final dynamic transaction;
  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final receiptNumber = transaction['receipt_number'] ?? '-';
    final rawAmount = transaction['total_amount'].toString();
    final totalAmount =
        int.tryParse(rawAmount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final status = transaction['status'];
    final isVoided = status == 'VOIDED';
    final isRequested = status == 'VOID_REQUESTED';

    String formattedDate = '';
    try {
      final dateString = transaction['transaction_time'] ?? '';
      if (dateString.isNotEmpty) {
        final date = DateTime.parse(dateString);
        formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(date.toLocal());
      }
    } catch (_) {}

    return Material(
      color: kWhiteColor,
      child: InkWell(
        onTap: () {
          context.read<DashboardBloc>().add(
                SelectTransactionForVoid(transaction),
              );
        },
        child: SizedBox(
          height: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receiptNumber,
                        style: TextStyle(
                          color: isVoided
                              ? Colors.red
                              : (isRequested ? Colors.orange : kTextDark),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          decoration: isVoided
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: kTextGrey,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            currencyFormatter.format(totalAmount),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: isVoided ? Colors.red : kTextDark,
                              decoration: isVoided
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ],
                      ),

                      if (isVoided)
                        const Text(
                          'VOIDED',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else if (isRequested)
                        const Text(
                          'WAITING APPROVAL',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!isVoided && !isRequested)
                      InkWell(
                        onTap: () {
                          // Tampilkan Dialog dengan Barrier Ungu
                          showDialog(
                            context: context,
                            barrierDismissible: false, // Tidak bisa klik luar
                            barrierColor: kBrandColor.withOpacity(0.5), // Warna Ungu Transparan
                            builder: (_) => BlocProvider.value(
                              value: context.read<DashboardBloc>(), // Teruskan BLoC
                              child: _VoidRequestDialog(
                                transactionId: transaction['transaction_id'],
                                receiptNumber: receiptNumber,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F0FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: kBrandColor,
                            size: 18,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 32, width: 32),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================== DETAIL TRANSAKSI (KANAN) ==================

class _RightCartPreview extends StatelessWidget {
  const _RightCartPreview();

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final selected = state.selectedTransaction;

        if (selected == null) {
          return Column(
            children: [
              _buildHeader('Transaction Detail'),
              const Divider(height: 1, thickness: 1, color: kBorderColor),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Select a transaction to view details',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kTextGrey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        final items =
            (selected['items'] ?? selected['transaction_details'] ?? [])
                as List<dynamic>;
        final rawAmount = selected['total_amount'].toString();
        final totalAmount =
            int.tryParse(rawAmount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final receiptNumber = selected['receipt_number'] ?? '';

        final status = selected['status'];
        final isVoided = status == 'VOIDED';
        final isRequested = status == 'VOID_REQUESTED';

        return Column(
          children: [
            _buildHeader(
              isVoided
                  ? 'Detail (VOIDED)'
                  : (isRequested ? 'Detail (REQUESTED)' : 'Transaction Detail'),
            ),
            const Divider(height: 1, thickness: 1, color: kBorderColor),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final productName =
                      item['product_name'] ??
                      item['product']?['product_name'] ??
                      'Item';
                  final qty = item['quantity'] ?? 0;
                  final priceRaw =
                      item['price_at_transaction'] ?? item['unit_price'] ?? 0;
                  final price = int.tryParse(priceRaw.toString()) ?? 0;
                  final subtotal = qty * price;

                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: isVoided ? Colors.grey : kTextDark,
                                decoration: isVoided
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            Text(
                              ' ${currencyFormatter.format(price)}',
                              style: const TextStyle(
                                color: kTextGrey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Qty',
                              style: TextStyle(fontSize: 10, color: kTextGrey),
                            ),
                            Text(
                              '$qty',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isVoided ? Colors.red : kTextDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        currencyFormatter.format(subtotal),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isVoided ? Colors.red : kTextDark,
                          decoration: isVoided
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              color: isVoided
                  ? const Color(0xFFFFF0F0)
                  : (isRequested
                      ? const Color(0xFFFFF8E1)
                      : Colors.grey.shade50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _row('Receipt No', receiptNumber),
                  _row('Payment', selected['payment_method'] ?? '-'),
                  if (isVoided || isRequested)
                    _row(
                      'Reason',
                      selected['void_reason'] ?? '-',
                      isBold: true,
                    ),
                  const SizedBox(height: 8),
                  const Divider(),
                  _row(
                    isVoided ? 'Total (VOID)' : 'Total',
                    currencyFormatter.format(totalAmount),
                    isBold: true,
                    isRed: isVoided,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      height: 48,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: kTextDark,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _row(String l, String v, {bool isBold = false, bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: const TextStyle(color: kTextGrey, fontSize: 12)),
          Text(
            v,
            style: TextStyle(
              color: isRed ? Colors.red : kTextDark,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
              decoration: isRed && l != 'Reason'
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ================== DIALOG REQUEST VOID (FIXED OVERFLOW) ==================

class _VoidRequestDialog extends StatefulWidget {
  final String transactionId;
  final String receiptNumber;

  const _VoidRequestDialog({
    required this.transactionId,
    required this.receiptNumber,
  });

  @override
  State<_VoidRequestDialog> createState() => _VoidRequestDialogState();
}

class _VoidRequestDialogState extends State<_VoidRequestDialog> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        // Bungkus konten dengan SingleChildScrollView
        // agar tidak error "Bottom overflowed" saat keyboard muncul
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Could you request deletion from the administrator?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Please enter cancellation notes for the transaction ${widget.receiptNumber} !',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Text Field
              TextField(
                controller: _notesController,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Enter the notes',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF5E5CE6),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final notes = _notesController.text.trim();

                        if (notes.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter cancellation notes!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Send Request Event
                        context.read<DashboardBloc>().add(
                              RequestVoidTransaction(
                                transactionId: widget.transactionId,
                                reason: notes,
                              ),
                            );

                        Navigator.of(context).pop();

                        // Tampilkan feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Void request sent for ${widget.receiptNumber}',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E5CE6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}