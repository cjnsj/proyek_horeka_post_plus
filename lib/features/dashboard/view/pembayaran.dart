import 'package:flutter/material.dart';
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

  // Sample data - nanti ganti dengan data dari cart
  final List<Map<String, dynamic>> cartItems = [
    {'name': 'Mie', 'category': 'BSS', 'price': 18000.0, 'quantity': 1},
  ];

  double get subtotal => cartItems.fold(
    0,
    (sum, item) => sum + (item['price'] * item['quantity']),
  );
  double get discount => 0.0;
  double get tax => 0.0;
  double get total => subtotal - discount + tax;

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
        _paymentController.text += value;
      }
    });
  }

 void _showQrisDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: kBrandColor.withOpacity(0.5), // Tambahkan barrier semi-transparan
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white, // Pastikan background putih
        child: Container(
          padding: const EdgeInsets.all(32),
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white, // Background card putih
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

              // QR Code Icon (placeholder - nanti ganti dengan QR code generator)
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white, // Background QR putih
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

              // Total Amount
              Text(
                total.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
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
                        // TODO: Refresh QRIS
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
                                          'BSS',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'BSS',
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

                            // Item details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Baris pertama: Mie, Qty, Total harga
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Mie di kiri
                                        const Expanded(
                                          child: Text(
                                            'Mie',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        // Qty
                                        const Text(
                                          'Qty',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 24),

                                        // Total harga di paling kanan (diturunkan sedikit)
                                        Transform.translate(
                                          offset: const Offset(0, 10),
                                          child: const Text(
                                            'Rp. 18.000,00',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Baris kedua: Harga satuan, angka 1
                                    Row(
                                      children: [
                                        // Harga satuan di kiri
                                        Expanded(
                                          child: Text(
                                            'Rp.18.000,00',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                        // Angka 1 (sejajar dengan Qty di atas)
                                        const Text(
                                          '1',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 42),
                                        // Space kosong untuk sejajar dengan total harga
                                        const SizedBox(width: 100),
                                      ],
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            ),

                            // Thank You Section
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32,
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Thank You',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Welcome Back',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
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
                            // Summary
                            _buildSummaryRow(
                              'Discount',
                              discount,
                              isNegative: true,
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryRow('Subtotal', subtotal),
                            const SizedBox(height: 16),
                            _buildSummaryRow('Tax', tax, isPositive: true),
                            const SizedBox(height: 16),
                            _buildSummaryRow('Total', total, isBold: true),

                            const Spacer(flex: 12),

                            // Payment Method Buttons
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
                                  child: _buildPaymentMethodButton(
                                    'Debit/Credit',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildPaymentMethodButton(
                                    'Cash + Debit/Credit',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

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
                                color: Colors.grey.shade400,
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

                            // Print Receipt Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Process payment & print receipt
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A3AA0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
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

                    // Right Section - Numpad (1/3) - DIPERBAIKI
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Hitung aspect ratio berdasarkan ruang yang tersedia
                          final cellWidth = constraints.maxWidth / 3;
                          final cellHeight =
                              constraints.maxHeight / 4; // 4 baris
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
  }

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
        });

        // Show QRIS dialog jika method adalah Qris
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
