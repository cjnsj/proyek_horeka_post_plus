
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/cart_model.dart';

class PrinterService {
  final PrinterManager _printerManager = PrinterManager.instance;

  // [PERBAIKAN] Mengembalikan Stream<PrinterDevice> (Device tunggal yang terus mengalir)
  Stream<PrinterDevice> scanPrinters() {
    return _printerManager.discovery(type: PrinterType.bluetooth);
  }

  // Stream status koneksi
  Stream<BTStatus> get bluetoothStatusStream {
    return _printerManager.stateBluetooth;
  }

  // Koneksi ke Printer
  Future<bool> connectPrinter(PrinterDevice device) async {
    try {
      await _printerManager.connect(
          type: PrinterType.bluetooth,
          model: BluetoothPrinterInput(
            name: device.name,
            address: device.address!,
            isBle: false, 
            autoConnect: true,
          ));
      return true;
    } catch (e) {
      print("Gagal konek printer: $e");
      return false;
    }
  }

  // Putus Koneksi
  Future<void> disconnectPrinter() async {
    await _printerManager.disconnect(type: PrinterType.bluetooth);
  }

  // Generate Bytes Struk
  Future<List<int>> generateReceipt({
    required List<CartItem> items,
    required int subtotal,
    required int tax,
    required int discount,
    required int total,
    required String cashierName,
    String? transactionId,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Header
    bytes += generator.text('HOREKA POS+',
        styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size2, width: PosTextSize.size2));
    bytes += generator.text('Jl. Contoh No. 123, Jakarta', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr();

    // Info Transaksi
    bytes += generator.text('No: ${transactionId ?? "-"}');
    bytes += generator.text('Kasir: $cashierName');
    bytes += generator.text('Tgl: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}');
    bytes += generator.hr();

    // Items
    for (var item in items) {
      bytes += generator.text(item.product.name, styles: const PosStyles(align: PosAlign.left, bold: true));
      bytes += generator.row([
        PosColumn(
          text: '${item.quantity} x ${formatter.format(item.product.price)}',
          width: 7,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: formatter.format(item.subtotal),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    // Total
    bytes += generator.row([
      PosColumn(text: 'Subtotal', width: 6),
      PosColumn(text: formatter.format(subtotal), width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    
    if (discount > 0) {
      bytes += generator.row([
        PosColumn(text: 'Diskon', width: 6),
        PosColumn(text: '-${formatter.format(discount)}', width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]);
    }

    bytes += generator.row([
      PosColumn(text: 'Pajak', width: 6),
      PosColumn(text: formatter.format(tax), width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.hr(ch: '=');

    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true, height: PosTextSize.size2)),
      PosColumn(text: formatter.format(total), width: 6, styles: const PosStyles(align: PosAlign.right, bold: true, height: PosTextSize.size2)),
    ]);

    bytes += generator.hr(ch: '=');

    // Footer
    bytes += generator.text('Terima Kasih', styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.feed(2);
    // bytes += generator.cut(); // Cut paper jika printer support

    return bytes;
  }

  // Kirim Perintah Cetak
  Future<void> printReceipt(List<int> bytes) async {
    await _printerManager.send(type: PrinterType.bluetooth, bytes: bytes);
  }
}