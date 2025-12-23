import 'dart:async';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:horeka_post_plus/core/utils/toast_utils.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_event.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_state.dart';
import 'package:horeka_post_plus/features/dashboard/data/saved_printer.dart';
import 'package:horeka_post_plus/features/dashboard/services/printer_storage_service.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';
import 'package:intl/intl.dart';

class PrintReceiptPage extends StatefulWidget {
  const PrintReceiptPage({super.key});

  @override
  State<PrintReceiptPage> createState() => _PrintReceiptPageState();
}

class _PrintReceiptPageState extends State<PrintReceiptPage> {
  @override
  void initState() {
    super.initState();
    // Reset pilihan saat halaman dibuka
    context.read<DashboardBloc>().add(ResetReportSelection());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
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
            child: const Column(
              children: [
                _PrintReceiptHeaderBar(),
                Divider(height: 1, thickness: 1, color: kBorderColor),
                Expanded(child: _PrintReceiptBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrintReceiptHeaderBar extends StatefulWidget {
  const _PrintReceiptHeaderBar();

  @override
  State<_PrintReceiptHeaderBar> createState() => _PrintReceiptHeaderBarState();
}

class _PrintReceiptHeaderBarState extends State<_PrintReceiptHeaderBar> {
  final PrinterStorageService _printerStorage = PrinterStorageService();
  bool _isPrinterReady = false;

  @override
  void initState() {
    super.initState();
    _checkPrinterStatus();
  }

  Future<void> _checkPrinterStatus() async {
    final selectedId = await _printerStorage.loadSelectedPrinter();
    if (mounted) {
      setState(() {
        _isPrinterReady = selectedId != null;
      });
    }
  }

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
            'Print Receipt',
            style: TextStyle(
              color: kBrandColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              _checkPrinterStatus();
              if (_isPrinterReady) {
                ToastUtils.showSuccessToast('Printer is ready!');
              } else {
                ToastUtils.showErrorToast('No printer selected. Please go to Settings.');
              }
            },
            icon: Icon(
              Icons.print,
              color: _isPrinterReady ? Colors.green : Colors.red,
              size: 22,
            ),
            tooltip: _isPrinterReady ? "Printer Ready" : "No Printer Selected",
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _PrintReceiptBody extends StatelessWidget {
  const _PrintReceiptBody();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 48, child: _LeftTransactionList()),
        VerticalDivider(width: 1, thickness: 1, color: kBorderColor),
        Expanded(flex: 52, child: _RightCartDetail()),
      ],
    );
  }
}

// ======================= LEFT SIDE (SEARCH & LIST) =======================

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
              if (state.status == DashboardStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(color: kBrandColor),
                );
              }

              // [LOGIKA BARU] Filter Hanya Status 'COMPLETED' di UI Saja
              final completedTransactions = state.transactionList.where((t) {
                final status = t['status']?.toString().toUpperCase();
                // Jika status tidak ada (null), anggap completed agar aman, atau sesuaikan
                return status == 'COMPLETED';
              }).toList();

              if (completedTransactions.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 48, color: kTextGrey),
                      SizedBox(height: 8),
                      Text(
                        "No completed transactions found",
                        style: TextStyle(color: kTextGrey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: completedTransactions
                    .length, // Gunakan list yang sudah difilter
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, thickness: 1, color: kBorderColor),
                itemBuilder: (context, index) {
                  final transaction =
                      completedTransactions[index]; // Ambil dari list filter

                  final transId =
                      transaction['receipt_number'] ??
                      transaction['transaction_number'];
                  final selectedId =
                      state.selectedReportTransaction?['receipt_number'] ??
                      state.selectedReportTransaction?['transaction_number'];

                  final isSelected = transId != null && transId == selectedId;

                  return _TransactionItem(
                    transaction: transaction,
                    isSelected: isSelected,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _searchController = TextEditingController();

  void _performSearch() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      context.read<DashboardBloc>().add(SearchTransactionRequested(query));
    } else {
      context.read<DashboardBloc>().add(FetchCurrentShiftTransactions());
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(FetchCurrentShiftTransactions());
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _performSearch(),
                decoration: InputDecoration(
                  hintText: 'Enter transaction number',
                  hintStyle: const TextStyle(color: kTextGrey, fontSize: 13),
                  filled: true,
                  fillColor: kWhiteColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kBorderColor),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: kBrandColor, width: 2),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            size: 18,
                            color: kTextGrey,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            context.read<DashboardBloc>().add(
                              FetchCurrentShiftTransactions(),
                            );
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 44,
            width: 100,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandColor,
                foregroundColor: kWhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _performSearch,
              child: const Text(
                'Search',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final bool isSelected;

  const _TransactionItem({
    super.key,
    required this.transaction,
    required this.isSelected,
  });

  // Helper untuk mencari data tanggal dari berbagai kemungkinan key
  String _getDate() {
    final raw =
        transaction['transaction_time'] ??
        transaction['created_at'] ??
        transaction['date'] ??
        transaction['transaction_date'];

    if (raw == null) return '-';

    try {
      final DateTime parsed = DateTime.parse(raw.toString());
      return DateFormat('dd-MM-yyyy HH:mm').format(parsed.toLocal());
    } catch (e) {
      return raw.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );

    // Prioritaskan receipt_number (sesuai Void Mode)
    final String transNo =
        transaction['receipt_number'] ??
        transaction['transaction_number'] ??
        '-';

    final String date = _getDate();

    final double total =
        double.tryParse((transaction['total_amount'] ?? '0').toString()) ?? 0;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Nomor Transaksi (Atas)
                Text(
                  transNo,
                  style: const TextStyle(
                    color: kTextDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),

                // 2. Baris Bawah: Tanggal [Jarak] Harga (Berdekatan)
                Row(
                  // HAPUS MainAxisAlignment.spaceBetween agar rata kiri (berdekatan)
                  children: [
                    // Tanggal
                    Text(
                      date,
                      style: const TextStyle(color: kTextGrey, fontSize: 11),
                    ),

                    const SizedBox(width: 12), // Berikan jarak 12 pixel
                    // Harga (Di sebelah tanggal)
                    Text(
                      formatter.format(total),
                      style: const TextStyle(color: kTextGrey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Tombol View Receipt dengan visual feedback
          SizedBox(
            height: 32,
            width: 110,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: isSelected ? kBrandColor : Colors.transparent,
                side: BorderSide(color: isSelected ? kBrandColor : kTextGrey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                context.read<DashboardBloc>().add(
                  SelectReportTransaction(transaction),
                );
              },
              child: Text(
                'View receipt',
                style: TextStyle(
                  color: isSelected ? kWhiteColor : kTextGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ======================= RIGHT SIDE (DETAIL & PRINT) =======================

class _RightCartDetail extends StatefulWidget {
  const _RightCartDetail();

  @override
  State<_RightCartDetail> createState() => _RightCartDetailState();
}

class _RightCartDetailState extends State<_RightCartDetail> {
  final PrinterStorageService _printerStorage = PrinterStorageService();
  bool _isPrinting = false;

  Future<void> _handlePrintReceipt(Map<String, dynamic> transaction) async {
    setState(() => _isPrinting = true);

    try {
      final savedPrinters = await _printerStorage.loadPrinters();
      final selectedId = await _printerStorage.loadSelectedPrinter();

      if (savedPrinters.isEmpty || selectedId == null) {
        if (!mounted) return;
        ToastUtils.showWarningToast('No printer selected. Go to Settings.');
        return;
      }

      final printer = savedPrinters.firstWhere(
        (p) => p.id == selectedId,
        orElse: () => savedPrinters.first,
      );
      final printerManager = PrinterManager.instance;
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);

      PrinterType type = (printer.type == SavedPrinterType.bluetooth)
          ? PrinterType.bluetooth
          : PrinterType.usb;
      dynamic model;

      if (printer.type == SavedPrinterType.bluetooth) {
        model = BluetoothPrinterInput(
          name: printer.name,
          address: printer.bluetoothAddress ?? '',
        );
      } else {
        model = UsbPrinterInput(
          name: printer.name,
          vendorId: printer.vendorId?.toString(),
          productId: printer.productId?.toString(),
        );
      }

      await printerManager.connect(type: type, model: model);

      List<int> bytes = [];
      bytes += generator.text(
        'HOREKA POS+',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.emptyLines(1);

      // [PERBAIKAN] Key untuk header receipt
      final transNo =
          transaction['receipt_number'] ??
          transaction['transaction_number'] ??
          '-';
      final rawDate =
          transaction['transaction_time'] ?? transaction['created_at'];
      String date = '-';
      if (rawDate != null) {
        try {
          date = DateFormat(
            'dd-MM-yyyy HH:mm',
          ).format(DateTime.parse(rawDate.toString()));
        } catch (_) {
          date = rawDate.toString();
        }
      }

      bytes += generator.text(
        transNo,
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        date,
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.emptyLines(1);
      bytes += generator.hr();

      // [PERBAIKAN] Key untuk items sesuai VoidModePage (items ATAU transaction_details)
      final List<dynamic> items =
          transaction['items'] ?? transaction['transaction_details'] ?? [];

      final formatter = NumberFormat.decimalPattern('id');

      for (var item in items) {
        // [PERBAIKAN] Parsing item sesuai VoidModePage
        // Nama bisa ada di root atau di dalam object 'product'
        String name =
            item['product_name'] ?? item['product']?['product_name'] ?? 'Item';

        int qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;

        // Harga bisa 'price_at_transaction' atau 'unit_price' atau 'price'
        double price =
            double.tryParse(
              (item['price_at_transaction'] ??
                      item['unit_price'] ??
                      item['price'] ??
                      '0')
                  .toString(),
            ) ??
            0;

        double subtotal = price * qty;

        bytes += generator.row([
          PosColumn(text: name, width: 6),
          PosColumn(
            text: 'x$qty',
            width: 2,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: formatter.format(subtotal),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
      bytes += generator.hr();

      // Total calculation
      // 1. Ambil Total
      double total =
          double.tryParse((transaction['total_amount'] ?? '0').toString()) ?? 0;

      // 2. Ambil Tax & Discount Langsung
      double tax =
          double.tryParse(
            (transaction['total_tax'] ?? transaction['tax_amount'] ?? '0')
                .toString(),
          ) ??
          0;
      double discount =
          double.tryParse(
            (transaction['total_discount'] ??
                    transaction['discount_amount'] ??
                    '0')
                .toString(),
          ) ??
          0;

      // 3. Hitung Subtotal Mundur
      double subtotalCalc = total - tax + discount;

      bytes += generator.row([
        PosColumn(text: 'Subtotal', width: 6),
        PosColumn(
          text: formatter.format(subtotalCalc),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      if (discount > 0) {
        bytes += generator.row([
          PosColumn(text: 'Discount', width: 6),
          PosColumn(
            text: '-${formatter.format(discount)}',
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      if (tax > 0) {
        bytes += generator.row([
          PosColumn(text: 'Tax', width: 6),
          PosColumn(
            text: formatter.format(tax),
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      bytes += generator.emptyLines(1);
      bytes += generator.row([
        PosColumn(
          text: 'TOTAL',
          width: 5,
          styles: const PosStyles(bold: true, height: PosTextSize.size2),
        ),
        PosColumn(
          text: formatter.format(total),
          width: 7,
          styles: const PosStyles(
            align: PosAlign.right,
            bold: true,
            height: PosTextSize.size2,
          ),
        ),
      ]);

      bytes += generator.emptyLines(2);
      bytes += generator.text(
        'Thank you!',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.cut();

      await printerManager.send(type: type, bytes: bytes);

      if (!mounted) return;
      ToastUtils.showSuccessToast('Receipt sent');
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showErrorToast('Print failed: $e');
    } finally {
      setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final transaction = state.selectedReportTransaction;

        if (transaction == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt, size: 64, color: kBorderColor),
                SizedBox(height: 16),
                Text(
                  'Select a transaction to view receipt',
                  style: TextStyle(color: kTextGrey),
                ),
              ],
            ),
          );
        }

        // [PERBAIKAN] Menggunakan key items yang sama dengan VoidModePage
        final List<dynamic> items =
            transaction['items'] ?? transaction['transaction_details'] ?? [];

        return Column(
          children: [
            Container(
              height: 48,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Cart',
                style: TextStyle(
                  color: kTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
             const SizedBox(height: 20),
            const Divider(height: 1, thickness: 1, color: kBorderColor),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: items.isEmpty
                        ? const Center(child: Text("No item details found"))
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return _CartItem(item: items[index]);
                            },
                          ),
                  ),
                  _SummaryPanel(transaction: transaction),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrandColor,
                          foregroundColor: kWhiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isPrinting
                            ? null
                            : () => _handlePrintReceipt(transaction),
                        child: _isPrinting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: kWhiteColor,
                                ),
                              )
                            : const Text(
                                'Print Receipt',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CartItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const _CartItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );

    // [PERBAIKAN] Parsing sesuai VoidModePage
    // 1. Nama Product (bisa nested di object product)
    final name =
        item['product_name'] ?? item['product']?['product_name'] ?? 'Unknown';

    // 2. Quantity
    final qty = item['quantity']?.toString() ?? '1';

    // 3. Harga (bisa price_at_transaction, unit_price, atau price)
    final priceRaw =
        item['price_at_transaction'] ??
        item['unit_price'] ??
        item['price'] ??
        0;
    final price = double.tryParse(priceRaw.toString()) ?? 0;

    final subtotal = price * int.parse(qty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorderColor, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              name,
              style: const TextStyle(color: kTextDark, fontSize: 13),
            ),
          ),
          // 2. Quantity dengan Label "Qty" di atasnya
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const Text(
                  "Qty", 
                  style: TextStyle(
                    color: kTextGrey, 
                    fontSize: 11, // Ukuran font label kecil
                    fontWeight: FontWeight.w500
                  )
                ),
                const SizedBox(height: 2), // Jarak kecil
                Text(
                  qty, 
                  textAlign: TextAlign.center, 
                  style: const TextStyle(
                    color: kTextDark, 
                    fontSize: 13,
                    fontWeight: FontWeight.w600
                  )
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatter.format(subtotal),
                  style: const TextStyle(
                    color: kTextDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const _SummaryPanel({required this.transaction});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil Total
    final double total =
        double.tryParse((transaction['total_amount'] ?? '0').toString()) ?? 0;

    // 2. Ambil Tax & Discount Langsung dari Backend (Key: total_tax, total_discount)
    // Kita tetap pasang fallback key lain untuk keamanan
    final double tax =
        double.tryParse(
          (transaction['total_tax'] ?? transaction['tax_amount'] ?? '0')
              .toString(),
        ) ??
        0;
    final double discount =
        double.tryParse(
          (transaction['total_discount'] ??
                  transaction['discount_amount'] ??
                  '0')
              .toString(),
        ) ??
        0;

    // 3. Hitung Subtotal Mundur (Total - Pajak + Diskon)
    // Ini lebih aman daripada menjumlahkan item satu per satu
    final double subtotal = total - tax + discount;

    // Label Promo
    final String? promoCode = transaction['promo_code'];
    final String discountLabel = (promoCode != null && promoCode.isNotEmpty)
        ? 'Promo ($promoCode)'
        : 'Discount';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // 1. Subtotal
              _buildSummaryRow('Subtotal', subtotal),

              // 2. Discount (Hijau, Minus) - Muncul jika ada nilai
              if (discount > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _buildSummaryRow(
                    discountLabel,
                    discount,
                    isNegative: true,
                    color: kTextGrey,
                  ),
                ),

              // 3. Tax (Merah, Plus) - Muncul jika ada nilai
              if (tax > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _buildSummaryRow(
                    'Tax',
                    tax,
                    isPositive: true,
                    color: kTextGrey,
                  ),
                ),
            ],
          ),
        ),

       

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildSummaryRow('Total', total, isBold: true),
        ),

        const Divider(height: 1, thickness: 1, color: kBorderColor),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isNegative = false,
    bool isPositive = false,
    bool isBold = false,
    Color? color,
  }) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );
    String prefix = '';
    if (isNegative && amount > 0) prefix = '-';
    if (isPositive && amount > 0) prefix = '+';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: color ?? (isBold ? kTextDark : kTextGrey),
          ),
        ),
        Text(
          '$prefix${formatter.format(amount)}',
          style: TextStyle(
            fontSize: isBold ? 16 : 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: color ?? (isBold ? kTextDark : kTextGrey),
          ),
        ),
      ],
    );
  }
}
