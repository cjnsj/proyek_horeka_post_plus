import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_event.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_state.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _paymentController = TextEditingController();
  
  String selectedPaymentMethodName = '';
  String selectedPaymentMethodCode = '';

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp.',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    // Panggil API Payment Methods saat halaman dibuka
    context.read<DashboardBloc>().add(FetchPaymentMethodsRequested());
  }

  // --- LOGIKA NUMPAD ---
  void _onNumberPressed(String value) {
    setState(() {
      if (value == '⌫') {
        if (_paymentController.text.isNotEmpty) {
          _paymentController.text = _paymentController.text.substring(
            0,
            _paymentController.text.length - 1,
          );
        }
      } else {
        // Cegah input 0 di awal
        if (_paymentController.text == '0' && value != '.') {
          _paymentController.text = value;
        } else {
          _paymentController.text += value;
        }
      }
    });
  }

  // --- LOGIKA PROSES BAYAR ---
  void _processPayment(BuildContext context, int totalAmount) {
    // 1. Validasi Metode Pembayaran
    if (selectedPaymentMethodCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Logic Pembayaran Tunai
    if (selectedPaymentMethodCode == 'CASH') {
      final cleanAmount = _paymentController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final inputCash = int.tryParse(cleanAmount) ?? 0;

      // Cek apakah uang tunai kurang
      if (inputCash < totalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uang tunai kurang!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Kirim Event Transaksi CASH
      context.read<DashboardBloc>().add(
            const CreateTransactionRequested(paymentMethod: "CASH"),
          );
    } else {
      // 3. Logic Pembayaran Non-Tunai (QRIS, DEBIT, dll)
      context.read<DashboardBloc>().add(
            CreateTransactionRequested(paymentMethod: selectedPaymentMethodCode),
          );
    }
  }

  // --- DIALOG QRIS ---
  void _showQrisDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: kBrandColor.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(32),
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'QRIS Payment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // QR Code Icon
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.qr_code_2,
                    size: 120,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'NMID : ID83764643838283',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                // Total Amount untuk QRIS
                BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    return Text(
                      currencyFormat.format(state.finalTotalAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.read<DashboardBloc>().add(
                            const CreateTransactionRequested(paymentMethod: "QRIS"),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A3AA0),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Check Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        // Handle Sukses
        if (state.status == DashboardStatus.transactionSuccess) {
           showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
              content: const Text(
                'Pembayaran Berhasil!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop(); // Kembali ke Dashboard
                  },
                  child: const Text('OK'),
                )
              ],
            ),
          );
        }
        // Handle Error
        if (state.status == DashboardStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Gagal'), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        // [DATA DARI HOME PAGE / BLOC STATE]
        // Kita mengambil data yang sudah dihitung oleh Server dan disimpan di State
        final cartItems = state.cartItems;
        final subtotal = state.subtotal;
        final tax = state.taxValue;      
        final total = state.finalTotalAmount; // Total Akhir (Int)
        final promos = state.appliedPromos;   // List Promo (Auto + Manual)

        return Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(
              left: 20, right: 20, top: 20, bottom: 35,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Column(
                children: [
                  // HEADER
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Pembayaran',
                          style: TextStyle(
                            color: Color(0xFF4A3AA0),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.print, color: Colors.green, size: 28),
                          onPressed: () {
                            // TODO: Print receipt logic
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // CONTENT
                  Expanded(
                    child: Row(
                      children: [
                        // LEFT: ITEM LIST
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.grey.shade300, width: 1),
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Item',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Detail Pesanan',
                                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: cartItems.length,
                                    separatorBuilder: (_, __) => const Divider(),
                                    itemBuilder: (context, index) {
                                      final item = cartItems[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.product.name,
                                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                                                  ),
                                                  Text(
                                                    currencyFormat.format(item.product.price),
                                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              'x${item.quantity}',
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                                            ),
                                            const SizedBox(width: 24),
                                            Expanded(
                                              child: Text(
                                                currencyFormat.format(item.subtotal),
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // MIDDLE: SUMMARY & PAYMENT METHOD
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.grey.shade300, width: 1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // [UPDATE] Tampilan Rincian Harga agar sama dengan Home Page
                                _buildSummaryRow('Subtotal', subtotal.toDouble()),
                                const SizedBox(height: 16),

                                // Loop Diskon (Combo)
                                if (promos.isNotEmpty) ...[
                                  ...promos.map((promo) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildSummaryRow(
                                      promo.name,
                                      promo.amount.toDouble(),
                                      isNegative: true,
                                      color: Colors.green,
                                    ),
                                  )),
                                ] else if (state.discountAmount > 0) ...[
                                  // Fallback support
                                  _buildSummaryRow(
                                    'Discount',
                                    state.discountAmount.toDouble(),
                                    isNegative: true,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                _buildSummaryRow(
                                  state.taxPercentage > 0 
                                      ? 'Tax (${state.taxPercentage.toStringAsFixed(0)}%)'
                                      : 'Tax',
                                  tax.toDouble(),
                                  isPositive: true,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),

                                _buildSummaryRow('Total', total.toDouble(), isBold: true),

                                const Spacer(flex: 12),

                                // [MODIFIKASI] Bagian Render Button Dinamis (Fixed Layout 2x2)
                                const Text(
                                  "Metode Pembayaran",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),

                                if (state.paymentMethods.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Memuat metode...", 
                                      style: TextStyle(color: Colors.grey, fontSize: 12)
                                    ),
                                  )
                                else
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final double spacing = 12.0;
                                      final double runSpacing = 12.0;
                                      final int columns = 2;
                                      final double itemWidth = (constraints.maxWidth - (spacing * (columns - 1))) / columns;

                                      return Wrap(
                                        spacing: spacing,
                                        runSpacing: runSpacing,
                                        children: state.paymentMethods.map((method) {
                                          return SizedBox(
                                            width: itemWidth, 
                                            child: _buildDynamicPaymentButton(
                                              name: method.name,
                                              code: method.code,
                                              isActive: method.isActive,
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                  
                                const Spacer(flex: 2),

                                Text(
                                  selectedPaymentMethodName.isEmpty 
                                      ? 'Pilih Metode' 
                                      : selectedPaymentMethodName,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _paymentController,
                                  readOnly: true,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey.shade800),
                                  decoration: InputDecoration(
                                    hintText: 'Total to Pay',
                                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                ),
                                const Spacer(),

                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: state.status == DashboardStatus.loading 
                                        ? null 
                                        : () => _processPayment(context, total),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4A3AA0),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                    child: state.status == DashboardStatus.loading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text(
                                            'Print Receipt',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // RIGHT: NUMPAD
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final cellWidth = constraints.maxWidth / 3;
                              final cellHeight = constraints.maxHeight / 4;
                              final aspectRatio = cellWidth / cellHeight;

                              return GridView.count(
                                crossAxisCount: 3,
                                mainAxisSpacing: 1,
                                crossAxisSpacing: 1,
                                padding: EdgeInsets.zero,
                                childAspectRatio: aspectRatio,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _buildNumpadButton('1'), _buildNumpadButton('2'), _buildNumpadButton('3'),
                                  _buildNumpadButton('4'), _buildNumpadButton('5'), _buildNumpadButton('6'),
                                  _buildNumpadButton('7'), _buildNumpadButton('8'), _buildNumpadButton('9'),
                                  _buildNumpadButton(''), _buildNumpadButton('0'), _buildNumpadButton('⌫'),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildSummaryRow(String label, double amount, {bool isNegative = false, bool isPositive = false, bool isBold = false, Color? color}) {
    String prefix = '';
    if (isNegative && amount > 0) prefix = '-';
    if (isPositive && amount > 0) prefix = '+';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: isBold ? 18 : 16, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: Colors.black87),
        ),
        Text(
          '$prefix${currencyFormat.format(amount)}',
          style: TextStyle(fontSize: isBold ? 18 : 16, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: color ?? Colors.black87),
        ),
      ],
    );
  }

  // Widget Helper Baru untuk Tombol Dinamis
  Widget _buildDynamicPaymentButton({required String name, required String code, required bool isActive}) {
    // Cek seleksi berdasarkan CODE & Active Status
    final isSelected = selectedPaymentMethodCode == code && isActive;
    
    // Warna Disabled
    final backgroundColor = !isActive 
        ? Colors.grey.shade100 
        : (isSelected ? const Color(0xFFE57373) : Colors.white);

    final borderColor = !isActive
        ? Colors.grey.shade300
        : (isSelected ? const Color(0xFFE57373) : Colors.grey.shade300);

    final textColor = !isActive
        ? Colors.grey.shade400
        : (isSelected ? Colors.white : Colors.black87);

    return InkWell(
      onTap: !isActive 
          ? null 
          : () {
              setState(() {
                selectedPaymentMethodCode = code; 
                selectedPaymentMethodName = name; 
                _paymentController.clear();
              });
              
              if (code == 'QRIS') {
                _showQrisDialog();
              }
            },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: borderColor, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          name,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildNumpadButton(String value) {
    if (value.isEmpty) return Container(color: Colors.grey.shade50);
    return InkWell(
      onTap: () => _onNumberPressed(value),
      child: Container(
        margin: const EdgeInsets.all(1),
        color: Colors.grey.shade100,
        child: Center(
          child: Text(
            value,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }
}