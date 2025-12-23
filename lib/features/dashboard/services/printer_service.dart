import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/shift_receipt_model.dart';
import 'package:intl/intl.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/cart_model.dart';

class PrinterService {
  final PrinterManager _printerManager = PrinterManager.instance;

  // Stream Device
  Stream<PrinterDevice> scanPrinters() {
    return _printerManager.discovery(type: PrinterType.bluetooth);
  }

  // Stream Status
  Stream<BTStatus> get bluetoothStatusStream {
    return _printerManager.stateBluetooth;
  }

  // Connect
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
      return true;
    } catch (e) {
      print("Gagal konek printer: $e");
      return false;
    }
  }

  // Disconnect
  Future<void> disconnectPrinter() async {
    await _printerManager.disconnect(type: PrinterType.bluetooth);
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

    // Parameter Profil Toko
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

    // [PENTING] 1. Reset Printer & Margin Atas
    // Ini wajib agar baris pertama tidak hilang/glitch dan style kereset
    bytes += generator.reset();
    bytes += generator.emptyLines(1);

    // [PENTING] 2. Logika Smart Header (Agar Header Utama tidak kosong)
    // Prioritas: Partner Name -> Store Name -> Default "HOREKA POS"
    
    String headerTitle = 'HOREKA POS'; // Default Judul Besar
    String? subTitle;                  // Judul Kecil (Sub Header)

    if (partnerName.isNotEmpty) {
      // Skenario A: Ada Partner Name (BSS Corp) -> Jadi Judul Besar
      headerTitle = partnerName;
      // Store Name jadi sub judul (Cabang X)
      if (storeName.isNotEmpty) subTitle = storeName;
    } else if (storeName.isNotEmpty) {
      // Skenario B: Partner Kosong -> Store Name naik jadi Judul Besar
      headerTitle = storeName;
      subTitle = null; // Tidak ada sub title agar tidak duplikat
    }

    // === CETAK HEADER UTAMA (BOLD BESAR) ===
    bytes += generator.text(
      headerTitle,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2, // Tinggi x2
        width: PosTextSize.size2,  // Lebar x2
      ),
    );

    // === CETAK SUB HEADER (BOLD NORMAL) ===
    if (subTitle != null) {
      bytes += generator.text(
        subTitle,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
    }

    // === INFO ALAMAT & TELP ===
    if (storeAddress != null && storeAddress.isNotEmpty) {
      bytes += generator.text(
        'Alamat : $storeAddress', // Hapus prefix 'Alamat :' agar lebih singkat/muat
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    if (storePhone != null && storePhone.isNotEmpty) {
      bytes += generator.text(
        'Telp: $storePhone',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    // === CUSTOM RECEIPT HEADER (Pesan Sambutan) ===
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

    // === INFO META (KASIR, SHIFT, WAKTU) ===
    bytes += generator.text('Kasir    : $cashierName');
    bytes += generator.text('Shift    : $shiftName');
    bytes += generator.text(
      'Waktu    : ${DateFormat('dd/MM/yy HH:mm').format(DateTime.now())}',
    );
    bytes += generator.text('No Trans : ${transactionId ?? "-"}');

    bytes += generator.hr(ch: '-');

    // === ITEM LIST (LAYOUT 2 BARIS - FIX TAMPILAN) ===
    for (var item in items) {
      String name = item.product.name;
      int qty = item.quantity;
      int price = item.product.price;
      int itemSubtotal = item.subtotal;

      // Baris 1: Nama Produk (Bold)
      bytes += generator.text(name, styles: const PosStyles(bold: true));

      // Baris 2: Qty x Harga ..... Total
      // Menggunakan pembagian kolom 7 (kiri) dan 5 (kanan)
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

      // Catatan Item
      if (item.note != null && item.note!.isNotEmpty) {
        bytes += generator.text(
          '(${item.note})',
          styles: const PosStyles(fontType: PosFontType.fontB),
        );
      }
    }

    bytes += generator.hr(ch: '-');

    // === SUBTOTAL & TAX ===
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

    // === TOTAL BESAR ===
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

    // === PEMBAYARAN ===
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

    // === FOOTER (Custom atau Default) ===
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
    bytes += generator.cut();
    return bytes;
  }


  Future<void> printShiftReport(ShiftReceiptModel data) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    String formatRupiah(double amount) => currencyFormatter.format(amount);
    
    // Header
    bytes += generator.text(data.branchName, styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2));
    bytes += generator.text('LAPORAN TUTUP SHIFT', styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.hr();

    // Info
    bytes += generator.text('Kasir : ${data.cashierName}');
    bytes += generator.text('Shift : ${data.shiftName}');
    bytes += generator.hr();

    // Keuangan
    bytes += generator.row([PosColumn(text: 'Modal Awal', width: 6), PosColumn(text: formatRupiah(data.openingCash), width: 6, styles: const PosStyles(align: PosAlign.right))]);
    bytes += generator.row([PosColumn(text: 'Penjualan', width: 6), PosColumn(text: formatRupiah(data.totalSales), width: 6, styles: const PosStyles(align: PosAlign.right))]);
    bytes += generator.row([PosColumn(text: 'Pengeluaran', width: 6), PosColumn(text: '- ${formatRupiah(data.totalExpenses)}', width: 6, styles: const PosStyles(align: PosAlign.right))]);
    bytes += generator.hr();

    // Total Setoran
    bytes += generator.text('TOTAL SETORAN', styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text(formatRupiah(data.expectedCash), styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2));
    bytes += generator.hr();

    // Item
    bytes += generator.text('Ringkasan Item:', styles: const PosStyles(bold: true));
    if (data.soldItems.isNotEmpty) {
      for (var item in data.soldItems) {
        bytes += generator.row([PosColumn(text: item.name, width: 9), PosColumn(text: 'x${item.qty}', width: 3, styles: const PosStyles(align: PosAlign.right))]);
      }
    } else {
      bytes += generator.text('- Tidak ada item -');
    }
    
    bytes += generator.feed(2);
    bytes += generator.cut();
    await printReceipt(bytes);
  }
}