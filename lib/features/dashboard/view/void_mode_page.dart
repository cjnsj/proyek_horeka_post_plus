import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:horeka_post_plus/core/utils/toast_utils.dart';
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
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, size: 24),
            color: Colors.black,
          ),
          const SizedBox(width: 4),
          const Text(
            'Void Mode',
            style: TextStyle(
              color: kBrandColor,
              fontSize: 20,
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
          height: 68,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // 1. BAGIAN KIRI (Info Resi & Tanggal)
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        receiptNumber,
                        style: TextStyle(
                          color: kTextDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration:
                              isVoided ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: kTextGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. BAGIAN TENGAH (Harga - Rata Tengah)
                Expanded(
                  flex: 5,
                  child: Center(
                    child: Text(
                      currencyFormatter.format(totalAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isVoided ? kTextDark : kTextDark,
                        decoration:
                            isVoided ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ),

                // 3. BAGIAN KANAN (Status / Tombol -> RATA TENGAH VERTIKAL & HORIZONTAL)
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center, // Rata tengah horizontal
                    mainAxisAlignment: MainAxisAlignment.center,   // [PERUBAHAN] Rata tengah vertikal (Sejajar Harga)
                    children: [
                      // --- STATUS ---
                      if (isVoided)
                        _buildStatusLabel('VOIDED', Colors.red)
                      else if (isRequested)
                        _buildStatusLabel('WAITING', Colors.orange),

                      // --- TOMBOL DELETE ---
                      // Karena tombol ini hanya muncul jika TIDAK ADA status (else),
                      // maka MainAxisAlignment.center akan menaruhnya tepat di tengah.
                      if (!isVoided && !isRequested)
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              barrierColor: kBrandColor.withOpacity(0.5),
                              builder: (_) => BlocProvider.value(
                                value: context.read<DashboardBloc>(),
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
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
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
        
        final receiptNumber = selected['receipt_number'] ?? '';
        final rawAmount = selected['total_amount'].toString();
        final totalAmount =
            int.tryParse(rawAmount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

        final rawTax = selected['total_tax'] ?? selected['tax_amount'] ?? '0';
        final taxAmount = 
            int.tryParse(rawTax.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

        final subtotalAmount = totalAmount - taxAmount;

        final status = selected['status'];
        final isVoided = status == 'VOIDED';
        final isRequested = status == 'VOID_REQUESTED';

        return Column(
          children: [
            _buildHeader(
              isVoided
                  ? 'Transaction Detail '
                  : (isRequested ? 'Transaction Detail' : 'Transaction Detail'),
            ),
            const Divider(height: 1, thickness: 1, color: kBorderColor),

            Expanded(
              child: ListView.separated(
                // [ATUR JARAK ATAS BAWAH LIST ITEM DISINI]
                // Ubah nilai top dan bottom sesuai keinginan
                padding: const EdgeInsets.only(top: 2, bottom:2), 
                
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: kBorderColor,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final productName = item['product_name'] ??
                      item['product']?['product_name'] ?? 'Item';
                  final qty = item['quantity'] ?? 0;
                  final priceRaw =
                      item['price_at_transaction'] ?? item['unit_price'] ?? 0;
                  final price = int.tryParse(priceRaw.toString()) ?? 0;
                  final subtotal = qty * price;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
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
                          padding: const EdgeInsets.only(right: 165.0),
                          child: SizedBox(
                            width: 40,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Qty',
                                  style: TextStyle(
                                      fontSize: 11, color: kTextDark),
                                ),
                                Text(
                                  '$qty',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isVoided ? Colors.red : kTextDark,
                                    decoration: isVoided
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          child: Text(
                            currencyFormatter.format(subtotal),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isVoided ? Colors.red : kTextDark,
                              decoration: isVoided
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // SUMMARY PANEL
            Container(
              // Padding horizontal 0 agar divider full width
              padding: const EdgeInsets.only(top: 12, bottom: 16),
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
                  
                  _row(
                    'Subtotal', 
                    currencyFormatter.format(subtotalAmount),
                    isRed: isVoided
                  ),

                  if (taxAmount > 0)
                    _row(
                      'Tax', 
                      '+${currencyFormatter.format(taxAmount)}',
                      isRed: isVoided 
                    ),

                  const SizedBox(height: 8),
                  
                  const Divider(thickness: 1, height: 1, color: Colors.grey),
                  const SizedBox(height: 8),
                  
                  _row(
                    isVoided ? 'Total (VOID)' : 'Total',
                    currencyFormatter.format(totalAmount),
                    isBold: true,
                    isRed: isVoided,
                    fontSize: 14,
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
      height: 68, // Tinggi fix header
      // [PENTING] Alignment ini memastikan teks ada di tengah vertikal (atas-bawah)
      alignment: Alignment.centerLeft, 
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: kTextDark,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _row(String l, String v, {
    bool isBold = false, 
    bool isRed = false,
    double fontSize = 12,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: TextStyle(color: kTextGrey, fontSize: fontSize)),
          Text(
            v,
            style: TextStyle(
              color: isRed ? Colors.red : kTextDark,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
                          ToastUtils.showErrorToast('Please enter cancellation notes!');
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
                        ToastUtils.showSuccessToast(
                          'Void request sent for ${widget.receiptNumber}',
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
