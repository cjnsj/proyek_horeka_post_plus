import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart'; // Wajib import ini
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart'; // Wajib import ini
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_state.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';
import 'package:intl/intl.dart';

class SaveQueueDialog extends StatefulWidget {
  const SaveQueueDialog({Key? key}) : super(key: key);

  @override
  State<SaveQueueDialog> createState() => _SaveQueueDialogState();
}

class _SaveQueueDialogState extends State<SaveQueueDialog> {
  final TextEditingController _tableNumberController = TextEditingController();
  final TextEditingController _waiterNameController = TextEditingController();
  final TextEditingController _orderNotesController = TextEditingController();

  @override
  void dispose() {
    _tableNumberController.dispose();
    _waiterNameController.dispose();
    _orderNotesController.dispose();
    super.dispose();
  }

  // --- LOGIKA PRINT STRUK PESANAN (KITCHEN TICKET) ---
  Future<void> _printQueueTicket(BuildContext context) async {
    final bloc = context.read<DashboardBloc>();
    final state = bloc.state;

    // 1. Cek Koneksi
    if (!state.isPrinterConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Printer tidak terhubung!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // 2. Siapkan Data
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      // 3. Buat Layout Struk
      // Header
      bytes += generator.text(
        'ORDER TICKET',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.emptyLines(1);

      // Info Meja & Waiter (FONT BESAR UNTUK MEJA)
      if (_tableNumberController.text.isNotEmpty) {
        bytes += generator.text(
          'MEJA: ${_tableNumberController.text}',
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        );
      }

      bytes += generator.emptyLines(1);

      bytes += generator.text(
        'Waiter: ${_waiterNameController.text.isNotEmpty ? _waiterNameController.text : "-"}',
      );
      bytes += generator.text(
        'Waktu : ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}',
      );
      bytes += generator.hr();

      // List Item
      for (var item in state.cartItems) {
        bytes += generator.text(
          item.product.name,
          styles: const PosStyles(bold: true),
        );
        bytes += generator.row([
          PosColumn(text: 'Qty: ${item.quantity}', width: 6),
          PosColumn(
            text: '',
            width: 6,
          ), // Harga tidak perlu ditampilkan di struk dapur
        ]);

        // Catatan Item (Jika ada)
        if (item.note != null && item.note!.isNotEmpty) {
          bytes += generator.text(
            'Note: ${item.note}',
            styles: const PosStyles(fontType: PosFontType.fontB),
          );
        }
        bytes += generator.hr(ch: '-');
      }

      // Catatan Pesanan Global
      if (_orderNotesController.text.isNotEmpty) {
        bytes += generator.emptyLines(1);
        bytes += generator.text(
          'CATATAN PESANAN:',
          styles: const PosStyles(bold: true),
        );
        bytes += generator.text(_orderNotesController.text);
      }

      bytes += generator.emptyLines(2);
      bytes += generator.cut();

      // 4. Kirim ke Printer via Service di BLoC
      await bloc.printerService.printReceipt(bytes);
    } catch (e) {
      print("Gagal print antrian: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 400,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header dengan Indikator Printer ---
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Ubah ke spaceBetween agar rapi
                children: [
                  const Text(
                    "Simpan Pesanan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                    ),
                  ),

                  // [INDIKATOR PRINTER]
                  BlocBuilder<DashboardBloc, DashboardState>(
                    buildWhen: (previous, current) =>
                        previous.isPrinterConnected !=
                        current.isPrinterConnected,
                    builder: (context, state) {
                      return IconButton(
                        icon: Icon(
                          Icons.print,
                          // Hijau jika connect, Merah jika putus
                          color: state.isPrinterConnected
                              ? Colors.green
                              : Colors.red,
                          size: 28,
                        ),
                        onPressed: () {
                          // Jika ditekan iconnya saja, coba print test / struk saat ini
                          _printQueueTicket(context);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: state.isPrinterConnected
                            ? 'Printer Ready'
                            : 'Printer Disconnected',
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Field 1: Table Number/Customer Name
              const Text(
                'Table Number / Customer Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tableNumberController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF4A3AA0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Field 2: Waiter Name
              const Text(
                'Waiter Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _waiterNameController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF4A3AA0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Field 3: Order Notes
              const Text(
                'Order Notes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _orderNotesController,
                style: const TextStyle(color: Colors.black),
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF4A3AA0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                        backgroundColor: Colors.red,
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

                  // [TOMBOL SAVE & PRINT]
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // 1. Validasi Sederhana
                        if (_tableNumberController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Table Number wajib diisi!'),
                            ),
                          );
                          return;
                        }

                        // 2. Print Dulu
                        await _printQueueTicket(context);

                        if (!mounted) return;

                        // 3. Return data ke parent untuk disimpan ke Database (API)
                        Navigator.of(context).pop({
                          'tableNumber': _tableNumberController.text,
                          'waiterName': _waiterNameController.text,
                          'orderNotes': _orderNotesController.text,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrandColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save & Print',
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
      ),
    );
  }
}
