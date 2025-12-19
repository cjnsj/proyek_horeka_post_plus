import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart'; // [IMPORT WAJIB] Untuk TextInputFormatter
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
    symbol: 'Rp. ', // Ada spasi agar rapi
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(FetchPaymentMethodsRequested());
  }

  // --- LOGIKA NUMPAD DENGAN FORMAT RUPIAH ---
  void _onNumberPressed(String value) {
    setState(() {
      // 1. Ambil text saat ini & hapus semua karakter non-angka
      String cleanText = _paymentController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      // 2. Modifikasi string angka (Tambah / Hapus)
      if (value == '⌫') {
        if (cleanText.isNotEmpty) {
          cleanText = cleanText.substring(0, cleanText.length - 1);
        }
      } else {
        // Cegah input 0 di paling awal (misal: 01)
        if (cleanText == '0') {
          cleanText = value;
        } else {
          cleanText += value;
        }
      }

      // 3. Format kembali ke Rupiah & Set ke Controller
      if (cleanText.isEmpty) {
        _paymentController.clear();
      } else {
        double numberValue = double.tryParse(cleanText) ?? 0;
        _paymentController.text = currencyFormat.format(numberValue);
      }
    });
  }

  // --- LOGIKA PROSES BAYAR ---
  void _processPayment(BuildContext context, int totalAmount) {
    if (selectedPaymentMethodCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final cleanAmount = _paymentController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final inputCash = int.tryParse(cleanAmount) ?? 0;

    // Logic Tunai
    if (selectedPaymentMethodCode == 'CASH') {
      // Validasi tetap ada agar tidak bisa submit jika uang kurang
      if (inputCash < totalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uang tunai kurang!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      context.read<DashboardBloc>().add(
        const CreateTransactionRequested(paymentMethod: "CASH"),
      );
    } else {
      // Logic Non-Tunai
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
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(32),
            width: 400,
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
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(12),
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
                  style: TextStyle(fontSize: 14, color: Colors.black87),
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
                Row(
                  children: [
                   Expanded(
  child: ElevatedButton(
    onPressed: () => Navigator.of(context).pop(),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,  // [UBAH INI] dari Colors.black87 menjadi Colors.red
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    ),
    child: const Text(
      'Cancel',
      style: TextStyle(color: Colors.white),
    ),
  ),
),

                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.read<DashboardBloc>().add(
                            const CreateTransactionRequested(
                              paymentMethod: "QRIS",
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrandColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Check Status',
                          style: TextStyle(color: Colors.white),
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
        if (state.status == DashboardStatus.transactionSuccess) {
          // [TAMBAHAN] Trigger Print Otomatis saat Transaksi Sukses
          context.read<DashboardBloc>().add(const PrintReceiptRequested());

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaksi Berhasil! Mencetak struk...'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: Colors.white, // Tambahkan ini
              title: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              content: const Text(
                'Pembayaran Berhasil!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Tambahkan ini
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: kBrandColor), // Tambahkan ini
                  ),
                ),
              ],
            ),
          );
        }
        if (state.status == DashboardStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Gagal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final subtotal = state.subtotal;
        final tax = state.taxValue;
        final total = state.finalTotalAmount;
        final promos = state.appliedPromos;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 45,
              bottom: 24,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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
                            color:kBrandColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        // [MODIFIKASI] Indikator Status Printer (Hijau/Merah)
                        BlocBuilder<DashboardBloc, DashboardState>(
                          buildWhen: (previous, current) =>
                              previous.isPrinterConnected !=
                              current.isPrinterConnected,
                          builder: (context, state) {
                            return IconButton(
                              icon: Icon(
                                Icons.print,
                                // Warna berubah otomatis sesuai state koneksi
                                color: state.isPrinterConnected
                                    ? Colors.green
                                    : Colors.red,
                                size: 28,
                              ),
                              onPressed: () {
                                // Jika merah, beri tahu user
                                if (!state.isPrinterConnected) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Printer belum terhubung!'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            );
                          },
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
                                right: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Header "Detail Pesanan"
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
                                  child: const Center(
                                    child: Text(
                                      'Detail Pesanan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),

                                // List Item
                                Expanded(
                                  child: ListView.separated(
                                    // [PENTING] Hapus padding horizontal di ListView agar garis mentok
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    itemCount: state.cartItems.length,

                                    // [PENTING] Garis pemisah full width
                                    separatorBuilder: (_, __) => Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Colors.grey.shade300,
                                      indent: 0,
                                      endIndent: 0,
                                    ),

                                    itemBuilder: (context, index) {
                                      final item = state.cartItems[index];
                                      return Padding(
                                        // Beri padding di sini agar teks tidak nempel pinggir,
                                        // tapi garis tetap memanjang
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal: 16.0,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // 1. Nama Menu & Harga Satuan
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.product.name,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    currencyFormat.format(
                                                      item.product.price,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // 2. Qty (TURUN SEDIKIT KE BAWAH)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 6.0,
                                              ), // <--- INI YANG MENURUNKAN POSISI
                                              child: SizedBox(
                                                width: 40,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const Text(
                                                      "Qty",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'x${item.quantity}',
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            // Jarak antar Qty dan Subtotal
                                            const SizedBox(width: 65),
                                            // 3. Subtotal (Dengan Lebar Tetap agar Rata Kanan)
                                            SizedBox(
                                              width: 90, // Lebar tetap
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  // Spacer dummy agar sejajar dengan angka qty (opsional)
                                                  const SizedBox(height: 14),
                                                  Text(
                                                    currencyFormat.format(
                                                      item.subtotal,
                                                    ),
                                                    textAlign: TextAlign.right,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
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
                                right: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. SUBTOTAL
                                _buildSummaryRow(
                                  'Subtotal',
                                  subtotal.toDouble(),
                                ),
                                const SizedBox(height: 8),

                               // 2. PROMO (AUTO DARI SERVER)
                              if (promos.isNotEmpty)
                                ...promos.map(
                                  (promo) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildSummaryRow(
                                      '', // Kosongkan label biasa
                                      promo.amount.toDouble(),
                                      isNegative: true,
                                      // [LOGIC WARNA-WARNI]
                                      customLabel: Text.rich(
                                        TextSpan(
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: 'Discount ',
                                              style: TextStyle(color: Colors.black87), // Hitam
                                            ),
                                            TextSpan(
                                              text: '(${promo.name})',
                                              style: const TextStyle(color: Colors.green), // Hijau
                                            ),
                                          ],
                                        ),
                                      ),
                                      valueColor: Colors.black, // Harga Hijau
                                    ),
                                  ),
                                )
                              // 3. MANUAL DISCOUNT
                              else if (state.discountAmount > 0)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildSummaryRow(
                                    'Discount',
                                    state.discountAmount.toDouble(),
                                    isNegative: true,
                                    labelColor: Colors.black87, // Label Hitam
                                    valueColor: Colors.black,   // Harga Hijau
                                  ),
                                ),

                              // 4. TAX (PAJAK)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 0),
                                child: state.taxPercentage > 0
                                    ? _buildSummaryRow(
                                        '', // Kosongkan label string
                                        tax.toDouble(),
                                        isPositive: true,
                                        customLabel: Text.rich(
                                          TextSpan(
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            children: [
                                              const TextSpan(
                                                text: 'Tax ',
                                                style: TextStyle(color: Colors.black), // Hitam
                                              ),
                                              TextSpan(
                                                text: '(${state.taxPercentage.toStringAsFixed(0)}%)',
                                                style: const TextStyle(color: Colors.black), // Hijau
                                              ),
                                            ],
                                          ),
                                        ),
                                        valueColor: Colors.black, // Harga Hijau
                                      )
                                    : _buildSummaryRow(
                                        'Tax',
                                        tax.toDouble(),
                                        isPositive: true,
                                        labelColor: Colors.black,
                                        valueColor: Colors.black
                                      ),
                              ),


                              // ===========================================
                              // MASUKKAN KODE TOTAL DI SINI
                              // ===========================================
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                'Total',
                                total.toDouble(),
                                isBold: true,
                                labelColor: Colors.black87,
                                valueColor: Colors.black87,
                              ),
                                /// ==========================================
                              // [TAMBAHAN] TOTAL PAID & CHANGES JIKA CASH
                              // ==========================================
                              if (selectedPaymentMethodCode == 'CASH') ...[
                                const SizedBox(height: 12),
                                Builder(
                                  builder: (context) {
                                    // Ambil input uang dari controller
                                    String cleanText = _paymentController.text
                                        .replaceAll(RegExp(r'[^0-9]'), '');
                                    double inputCash =
                                        double.tryParse(cleanText) ?? 0;

                                    // [LOGIC KEMBALIAN]
                                    double change =
                                        (inputCash < total.toDouble())
                                            ? 0
                                            : (inputCash - total.toDouble());
                                    
                                    // Logic warna kembalian (Merah jika kurang, Hijau jika pas/lebih)
                                    final isMoneyEnough = inputCash >= total.toDouble();

                                    return Column(
                                      children: [
                                        // 1. TOTAL PAID
                                        _buildSummaryRow(
                                          'Total Paid',
                                          inputCash,
                                          labelColor: Colors.black87, // Label Hitam
                                          valueColor: kBrandColor,    // Harga Biru Brand
                                        ),
                                        
                                        const SizedBox(height: 8),
                                        
                                        // 2. CHANGES
                                        _buildSummaryRow(
                                          'Changes',
                                          change,
                                          labelColor: Colors.black87, // Label Hitam
                                          valueColor: isMoneyEnough 
                                              ? Colors.red  // Hijau jika uang cukup
                                              : Colors.red,   // Merah jika uang kurang (opsional)
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],

                                // ==========================================
                                const Spacer(flex: 12),

                                const SizedBox(height: 10),
                                if (state.paymentMethods.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Memuat metode...",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                else
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final double spacing = 12.0;
                                      final double runSpacing = 12.0;
                                      final int columns = 2;
                                      final double itemWidth =
                                          (constraints.maxWidth -
                                              (spacing * (columns - 1))) /
                                          columns;

                                      return Wrap(
                                        spacing: spacing,
                                        runSpacing: runSpacing,
                                        children: state.paymentMethods.map((
                                          method,
                                        ) {
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
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // TEXT FIELD INPUT
                                TextField(
                                  controller: _paymentController,
                                  readOnly: true,
                                  showCursor: true,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.right,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    CurrencyInputFormatter(),
                                  ],
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade800,
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
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Center(
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed:
                                          state.status ==
                                              DashboardStatus.loading
                                          ? null
                                          : () =>
                                                _processPayment(context, total),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kBrandColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child:
                                          state.status ==
                                              DashboardStatus.loading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
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
                                  _buildNumpadButton('1'),
                                  _buildNumpadButton('2'),
                                  _buildNumpadButton('3'),
                                  _buildNumpadButton('4'),
                                  _buildNumpadButton('5'),
                                  _buildNumpadButton('6'),
                                  _buildNumpadButton('7'),
                                  _buildNumpadButton('8'),
                                  _buildNumpadButton('9'),
                                  _buildNumpadButton(''),
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

  // --- WIDGET HELPER ---

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isNegative = false,
    bool isPositive = false,
    bool isBold = false,
    Widget? customLabel, // [BARU] Untuk teks kombinasi warna
    Color? labelColor,   // [BARU] Warna default label
    Color? valueColor,   // [BARU] Warna khusus untuk harga
  }) {
    String prefix = '';
    if (isNegative && amount > 0) prefix = '- ';
    if (isPositive && amount > 0) prefix = '+ ';

    // Style dasar
    final baseStyle = TextStyle(
      fontSize: isBold ? 18 : 16,
      fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
      color: Colors.black87,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // BAGIAN KIRI (LABEL)
        // Jika ada customLabel (RichText), pakai itu. Jika tidak, pakai Text biasa.
        customLabel ??
            Text(
              label,
              style: baseStyle.copyWith(
                color: labelColor ?? Colors.black87,
              ),
            ),

        // BAGIAN KANAN (HARGA)
        Text(
          '$prefix${currencyFormat.format(amount)}',
          style: baseStyle.copyWith(
            color: valueColor ?? Colors.black87, // Gunakan warna khusus jika ada
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicPaymentButton({
    required String name,
    required String code,
    required bool isActive,
  }) {
    final isSelected = selectedPaymentMethodCode == code && isActive;

    final backgroundColor = !isActive
        ? Colors.grey.shade100
        : (isSelected ? Colors.green : Colors.white);

    final borderColor = !isActive
        ? Colors.grey.shade300
        : (isSelected ? Colors.green : Colors.grey.shade300);

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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
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

// ================= [TAMBAHAN CLASS FORMATTER] =================

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.parse(
      newValue.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );

    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
