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
  String selectedPaymentMethod = 'Cash';

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp.',
    decimalDigits: 0,
  );

  // --- LOGIKA NUMPAD (TIDAK BERUBAH) ---
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

  // --- [BARU] LOGIKA PROSES BAYAR ---
  void _processPayment(BuildContext context, double totalAmount) {
    if (selectedPaymentMethod == 'Cash') {
      // Validasi Uang Tunai
      final cleanAmount = _paymentController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final inputCash = int.tryParse(cleanAmount) ?? 0;

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
      // Kirim Event Transaksi Non-Tunai (QRIS, dll)
      String methodApi = selectedPaymentMethod.toUpperCase();
      // Handle penamaan khusus jika ada
      if (methodApi.contains("QRIS")) methodApi = "QRIS";
      
      context.read<DashboardBloc>().add(
            CreateTransactionRequested(paymentMethod: methodApi),
          );
    }
  }

  // --- [UPDATE] DIALOG QRIS (MENGHUBUNGKAN TOMBOL REFRESH/CHECK) ---
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

                // NMID
                const Text(
                  'NMID : ID83764643838283',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),

                // Total Label
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                // Total Amount (Ambil dari State Bloc nanti saat dipanggil, disini placeholder visual)
                BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    return Text(
                      currencyFormat.format(state.totalAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    );
                  }
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
                          // [LOGIC] Refresh QRIS / Check Status -> Anggap Sukses & Kirim Transaksi
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
                          'Refresh QRIS',
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
    // [INTEGRASI] Menggunakan BlocConsumer untuk Data Real & Listener
    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
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
        if (state.status == DashboardStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Gagal'), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        // [DATA ASLI] Mengambil data dari State
        final cartItems = state.cartItems;
        final totalAmount = state.totalAmount.toDouble();
        final discount = 0.0; // Bisa diupdate jika ada logika diskon
        final tax = 0.0;      // Bisa diupdate jika ada logika pajak
        // Total kalkulasi akhir (jika ada logic tambahan, sesuaikan disini)
        final total = totalAmount - discount + tax;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 35,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Column(
                children: [
                  // Header dengan Back Button, Title, dan Print Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 24,
                          ),
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
                          icon: const Icon(
                            Icons.print,
                            color: Colors.green,
                            size: 28,
                          ),
                          onPressed: () {
                            // TODO: Print receipt
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // Content - 3 kolom
                  Expanded(
                    child: Row(
                      children: [
                        // Left Section - Cart Items (1/3)
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Header kategori & item
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Item', // Disederhanakan dari BSS
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Detail Pesanan',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Item details [DATA ASLI]
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Nama Produk
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.product.name,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  Text(
                                                    currencyFormat.format(item.product.price),
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Qty
                                            Text(
                                              'x${item.quantity}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(width: 24),
                                            // Total harga per item
                                            Expanded(
                                              child: Text(
                                                currencyFormat.format(item.subtotal),
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
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

                        // Middle Section - Payment Summary (1/3)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Summary [DATA ASLI]
                                _buildSummaryRow(
                                  'Discount',
                                  discount,
                                  isNegative: true,
                                ),
                                const SizedBox(height: 16),
                                _buildSummaryRow('Subtotal', totalAmount),
                                const SizedBox(height: 16),
                                _buildSummaryRow('Tax', tax, isPositive: true),
                                const SizedBox(height: 16),
                                _buildSummaryRow('Total', total, isBold: true),

                                const Spacer(flex: 12),

                                // Payment Method Buttons (TETAP SAMA)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildPaymentMethodButton('Cash'),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildPaymentMethodButton('Qris'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildPaymentMethodButton('Debit/Credit'),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildPaymentMethodButton('Cash + Debit/Credit'),
                                    ),
                                  ],
                                ),

                                const Spacer(flex: 2),

                                // Payment Input
                                Text(
                                  selectedPaymentMethod,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _paymentController,
                                  readOnly: true,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade800, // Sedikit lebih gelap agar terbaca
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Total to Pay',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 15,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                                const Spacer(),

                                // Print Receipt Button (Tombol Proses)
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: state.status == DashboardStatus.loading 
                                        ? null 
                                        : () => _processPayment(context, total),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4A3AA0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: state.status == DashboardStatus.loading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text(
                                            'Print Receipt',
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
                          ),
                        ),

                        // Right Section - Numpad (1/3) - (TETAP SAMA)
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
                                  _buildNumpadButton('1'),
                                  _buildNumpadButton('2'),
                                  _buildNumpadButton('3'),
                                  _buildNumpadButton('4'),
                                  _buildNumpadButton('5'),
                                  _buildNumpadButton('6'),
                                  _buildNumpadButton('7'),
                                  _buildNumpadButton('8'),
                                  _buildNumpadButton('9'),
                                  _buildNumpadButton(''), // Kosong
                                  _buildNumpadButton('0'),
                                  _buildNumpadButton('⌫'),
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

  // --- WIDGET HELPER (TIDAK BERUBAH SECARA VISUAL) ---

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isNegative = false,
    bool isPositive = false,
    bool isBold = false,
  }) {
    String prefix = '';
    if (isNegative && amount > 0) prefix = '-';
    if (isPositive && amount > 0) prefix = '+';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          '$prefix${currencyFormat.format(amount)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodButton(String method) {
    final isSelected = selectedPaymentMethod == method;
    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
          // Reset input jika pindah metode agar tidak bingung
          _paymentController.clear();
        });

        if (method == 'Qris') {
          _showQrisDialog();
        }
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE57373) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFFE57373) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            method,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
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
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
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