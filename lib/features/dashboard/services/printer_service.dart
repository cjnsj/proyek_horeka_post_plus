import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/shift_receipt_model.dart';
import 'package:intl/intl.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class PrinterService {
  final PrinterManager _printerManager = PrinterManager.instance;

  // Key untuk SharedPreferences
  static const String _keyPrinterName = 'saved_printer_name';
  static const String _keyPrinterAddress = 'saved_printer_address';

  // Stream Device
  Stream<PrinterDevice> scanPrinters() {
    return _printerManager.discovery(type: PrinterType.bluetooth);
  }

  // Stream Status
  Stream<BTStatus> get bluetoothStatusStream {
    return _printerManager.stateBluetooth;
  }

  // [BARU] Scan dengan timeout
  Future<List<PrinterDevice>> scanPrintersWithTimeout(int timeoutMs) async {
    print("🔍 [SERVICE] Scanning printers for ${timeoutMs}ms...");
    final completer = Completer<List<PrinterDevice>>();
    final devices = <PrinterDevice>[];
    
    final subscription = scanPrinters().listen(
      (device) {
        if (!devices.any((d) => d.address == device.address)) {
          devices.add(device);
          print("📱 [SERVICE] Found: ${device.name}");
        }
      },
      onDone: () => completer.complete(devices),
      onError: (e) => completer.completeError(e),
    );
    
    // Timeout
    Timer(Duration(milliseconds: timeoutMs), () {
      subscription.cancel();
      completer.complete(devices);
    });
    
    return completer.future;
  }

  // [BARU] Test print otomatis
  Future<void> printReceiptTest() async {
    print("🖨️ [SERVICE] Printing test receipt...");
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];
    
    bytes += generator.reset();
    bytes += generator.text('HOREKA POS+ AUTO-SETUP', 
      styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Printer terhubung otomatis!');
    bytes += generator.text('${DateTime.now().toString().substring(0, 19)}');
    bytes += generator.cut();
    
    await printReceipt(bytes);
  }

  // [FIX] Auto-setup printer (scan + connect + save + test)
  Future<bool> autoSetupPrinter() async {
    print("🔍 [SERVICE] Starting auto-setup...");
    
    try {
      // Scan 8 detik
      final devices = await scanPrintersWithTimeout(8000);
      
      if (devices.isEmpty) {
        print("❌ [SERVICE] No devices found");
        return false;
      }
      
      print("📱 [SERVICE] Found ${devices.length} devices");
      
      // Connect ke printer pertama
      final success = await connectPrinter(devices.first);
      
      if (success) {
        // Test print
        await printReceiptTest();
        print("✅ [SERVICE] Auto-setup COMPLETE!");
        return true;
      }
      
      return false;
    } catch (e) {
      print("❌ [SERVICE] Auto-setup failed: $e");
      return false;
    }
  }

  // [BARU] Save Printer ke Storage
  Future<void> savePrinterDevice(PrinterDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPrinterName, device.name);
    await prefs.setString(_keyPrinterAddress, device.address ?? '');
    print("✅ Printer tersimpan: ${device.name} (${device.address})");
  }

  // [BARU] Load Printer dari Storage
  Future<Map<String, String>?> loadSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyPrinterName);
    final address = prefs.getString(_keyPrinterAddress);

    if (name != null && address != null && address.isNotEmpty) {
      print("💾 [SERVICE] Loaded saved printer: $name");
      return {'name': name, 'address': address};
    }
    print("⚠️ [SERVICE] No saved printer found");
    return null;
  }

  // [BARU] Hapus Printer dari Storage
  Future<void> deleteSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPrinterName);
    await prefs.remove(_keyPrinterAddress);
    print("🗑️ Printer dihapus dari storage");
  }

  // [BARU] Auto-Connect ke Printer yang Tersimpan
  Future<bool> autoConnectSavedPrinter() async {
    try {
      final savedPrinter = await loadSavedPrinter();
      if (savedPrinter == null) {
        print("⚠️ Tidak ada printer tersimpan, skip auto-connect");
        return false;
      }

      print("🔄 Mencoba auto-connect ke: ${savedPrinter['name']}...");

      await _printerManager.connect(
        type: PrinterType.bluetooth,
        model: BluetoothPrinterInput(
          name: savedPrinter['name']!,
          address: savedPrinter['address']!,
          isBle: false,
          autoConnect: true,
        ),
      );

      print("✅ Auto-connect berhasil!");
      return true;
    } catch (e) {
      print("❌ Auto-connect gagal: $e");
      return false;
    }
  }

  // Connect (WITH AUTO-SAVE)
  Future<bool> connectPrinter(PrinterDevice device) async {
    try {
      await _printerManager.connect(
        type: PrinterType.bluetooth,
        model: BluetoothPrinterInput(
          name: device.name,
          address: device.address!,
          isBle: false,
          autoConnect: true,
        ),
      );

      // [BARU] Simpan printer setelah connect berhasil
      await savePrinterDevice(device);

      return true;
    } catch (e) {
      print("❌ Gagal konek printer: $e");
      return false;
    }
  }

  // Disconnect (TIDAK HAPUS DARI STORAGE)
  Future<void> disconnectPrinter() async {
    await _printerManager.disconnect(type: PrinterType.bluetooth);
    print("🔌 Printer disconnected (masih tersimpan)");
  }

  // [BARU] Disconnect & Hapus dari Storage
  Future<void> deletePrinter() async {
    await disconnectPrinter();
    await deleteSavedPrinter();
    print("🗑️ Printer dihapus total!");
  }

  // Kirim Perintah Cetak
  Future<void> printReceipt(List<int> bytes) async {
    await _printerManager.send(type: PrinterType.bluetooth, bytes: bytes);
  }

  // [FORMAT V4.0 + SMART HEADER + FIX POTONGAN ATAS]
  Future<List<int>> generateReceipt({
    required List<CartItem> items,
    required int subtotal,
    required int tax,
    required double taxPercentage,
    required int discount,
    String? promoCode,
    required int total,
    required String cashierName,
    String? transactionId,
    required String paymentMethod,
    required int amountPaid,
    required int change,
    String partnerName = '',
    String storeName = '',
    String? storeAddress,
    String? storePhone,
    String? receiptHeader,
    String? receiptFooter,
    String taxName = 'Tax',
    String shiftName = '-',
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    final formatter = NumberFormat('#,###', 'id_ID');

    bytes += generator.reset();
    bytes += generator.emptyLines(1);

    String headerTitle = 'HOREKA POS';
    String? subTitle;

    if (partnerName.isNotEmpty) {
      headerTitle = partnerName;
      if (storeName.isNotEmpty) subTitle = storeName;
    } else if (storeName.isNotEmpty) {
      headerTitle = storeName;
      subTitle = null;
    }

    bytes += generator.text(
      headerTitle,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    if (subTitle != null) {
      bytes += generator.text(
        subTitle,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
    }

    if (storeAddress != null && storeAddress.isNotEmpty) {
      bytes += generator.text(
        'Alamat: $storeAddress',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    if (storePhone != null && storePhone.isNotEmpty) {
      bytes += generator.text(
        'Telp: $storePhone',
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    bytes += generator.emptyLines(1);
    if (receiptHeader != null && receiptHeader.isNotEmpty) {
      final lines = receiptHeader.split(RegExp(r'\\n|\n'));
      for (var line in lines) {
        if (line.trim().isNotEmpty) {
          bytes += generator.text(
            line.trim(),
            styles: const PosStyles(align: PosAlign.center),
          );
        }
      }
      bytes += generator.hr(ch: '-');
    }

    bytes += generator.text('Kasir    : $cashierName');
    bytes += generator.text('Shift    : $shiftName');
    bytes += generator.text(
      'Waktu    : ${DateFormat('dd/MM/yy HH:mm').format(DateTime.now())}',
    );
    bytes += generator.text('No Trans : ${transactionId ?? "-"}');

    bytes += generator.hr(ch: '-');

    for (var item in items) {
      String name = item.product.name;
      int qty = item.quantity;
      int price = item.product.price;
      int itemSubtotal = item.subtotal;

      bytes += generator.text(name, styles: const PosStyles(bold: true));

      bytes += generator.row([
        PosColumn(
          text: '$qty x ${formatter.format(price)}',
          width: 7,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: formatter.format(itemSubtotal),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      if (item.note != null && item.note!.isNotEmpty) {
        bytes += generator.text(
          '(${item.note})',
          styles: const PosStyles(fontType: PosFontType.fontB),
        );
      }
    }

    bytes += generator.hr(ch: '-');

    bytes += generator.row([
      PosColumn(text: 'Subtotal', width: 6),
      PosColumn(
        text: formatter.format(subtotal),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if (discount > 0) {
      String discountLabel = 'Diskon';
      if (promoCode != null && promoCode.isNotEmpty)
        discountLabel += ' ($promoCode)';

      bytes += generator.row([
        PosColumn(text: discountLabel, width: 6),
        PosColumn(
          text: '-${formatter.format(discount)}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    if (tax > 0) {
      bytes += generator.row([
        PosColumn(
          text: '$taxName (${taxPercentage.toStringAsFixed(0)}%)',
          width: 6,
        ),
        PosColumn(
          text: formatter.format(tax),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr(ch: '-');

    bytes += generator.row([
      PosColumn(
        text: 'TOTAL',
        width: 6,
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size1,
        ),
      ),
      PosColumn(
        text: formatter.format(total),
        width: 6,
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size1,
        ),
      ),
    ]);

    bytes += generator.hr(ch: '-');

    String paymentLabel = (paymentMethod == 'CASH') ? 'Tunai' : paymentMethod;

    bytes += generator.row([
      PosColumn(text: paymentLabel, width: 6),
      PosColumn(
        text: formatter.format(amountPaid),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Kembali', width: 6),
      PosColumn(
        text: formatter.format(change),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.emptyLines(1);

    if (receiptFooter != null && receiptFooter.isNotEmpty) {
      final lines = receiptFooter.split(RegExp(r'\\n|\n'));
      for (var line in lines) {
        if (line.trim().isNotEmpty) {
          bytes += generator.text(
            line.trim(),
            styles: const PosStyles(align: PosAlign.center),
          );
        }
      }
    } else {
      bytes += generator.text(
        'Terima Kasih',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.emptyLines(1);
    bytes += generator.text(
      'Powered by Horeka POS',
      styles: const PosStyles(
        align: PosAlign.center,
        fontType: PosFontType.fontB,
      ),
    );
    return bytes;
  }

  Future<void> printShiftReport(ShiftReceiptModel data) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    String formatRupiah(double amount) => currencyFormatter.format(amount);

    // Format waktu ISO → dd/MM HH:mm
    String formatTime(String isoDate) {
      try {
        final date = DateTime.parse(isoDate);
        return DateFormat('dd/MM HH:mm').format(date);
      } catch (e) {
        return '-';
      }
    }

    // === 1. RESET & HEADER ===
    bytes += generator.reset();
    bytes += generator.emptyLines(1);

    bytes += generator.text(
      data.branchName,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );

     bytes += generator.emptyLines(1);

    bytes += generator.text(
      'LAPORAN TUTUP SHIFT',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.text('--------------------------------');

    // === 2. INFO SHIFT ===
    bytes += generator.text('Kasir     : ${data.cashierName}');
    bytes += generator.text('Shift     : ${data.shiftName}');
    bytes += generator.text('Mulai     : ${formatTime(data.startTime)}');
    bytes += generator.text('Selesai   : ${formatTime(data.endTime)}');

    bytes += generator.text('--------------------------------');

    // === 3. RINGKASAN KEUANGAN ===
    bytes += generator.text('Modal Awal   : ${formatRupiah(data.openingCash)}');
    bytes += generator.text(
      'Total Penjualan : ${formatRupiah(data.totalSales)}',
    );
    bytes += generator.text(
      'Pengeluaran  : - ${formatRupiah(data.totalExpenses)}',
    );

    bytes += generator.text('--------------------------------');

    // === 4. TOTAL SETORAN (BOLD BESAR) ===
    bytes += generator.text(
      'TOTAL SETORAN : ${formatRupiah(data.expectedCash)}',
      styles: const PosStyles(bold: true, height: PosTextSize.size2),
    );

    bytes += generator.text('--------------------------------');

    // === 5. RINGKASAN ITEM ===
    bytes += generator.text('Ringkasan Item:');

    if (data.soldItems.isNotEmpty) {
      for (var item in data.soldItems) {
        // Nama item dipotong agar muat (max 20 char)
        final name = item.name.length > 20
            ? '${item.name.substring(0, 17)}...'
            : item.name;
        bytes += generator.text(
          '$name${' ' * (23 - name.length)}x ${item.qty}',
        );
      }
    }

    bytes += generator.text('--------------------------------');

    // === 6. TOTAL TRANSAKSI ===
    bytes += generator.text('Total Transaksi : ${data.totalTransactions}');

    // === 7. FOOTER WAKTU CETAK ===
    bytes += generator.emptyLines(1);
    bytes += generator.text(
      ' Dicetak: ${DateFormat('dd/MM HH:mm').format(DateTime.now())} ',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(2);

    await printReceipt(bytes);
  }
}
