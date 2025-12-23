import 'dart:async';
import 'package:flutter/material.dart';
import 'package:horeka_post_plus/core/utils/toast_utils.dart';
import 'package:horeka_post_plus/features/dashboard/services/printer_service.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

/// ================= HALAMAN PRINTER SETTINGS =================

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  final PrinterService _service = PrinterService();
  
  // Printer yang tersimpan
  Map<String, String>? _savedPrinter;
  
  // List scan hasil
  List<PrinterDevice> _devices = [];
  bool _isScanning = false;
  bool _isConnected = false;
  bool _isLoading = true;
  
  StreamSubscription<BTStatus>? _statusSubscription;

  @override
  void initState() {
    super.initState();
    _loadSavedPrinter();
    _listenConnectionStatus();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  // [1] Load Printer yang Tersimpan
  Future<void> _loadSavedPrinter() async {
    setState(() => _isLoading = true);
    
    final saved = await _service.loadSavedPrinter();
    
    setState(() {
      _savedPrinter = saved;
      _isLoading = false;
    });

    // [AUTO-CONNECT] Jika ada printer tersimpan, langsung connect
    if (saved != null) {
      _autoConnect();
    }
  }

  // [2] Listen Status Koneksi Bluetooth
  void _listenConnectionStatus() {
    _statusSubscription = _service.bluetoothStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _isConnected = (status == BTStatus.connected);
        });
      }
    });
  }

  // [3] Auto-Connect ke Printer Tersimpan
  Future<void> _autoConnect() async {
    if (_savedPrinter == null) return;

    print("🔄 Auto-connecting to ${_savedPrinter!['name']}...");
    
    final success = await _service.autoConnectSavedPrinter();
    
    if (mounted) {
      if (success) {
        setState(() => _isConnected = true);
        ToastUtils.showSuccessToast(
          'Printer "${_savedPrinter!['name']}" terhubung otomatis',
        );
      } else {
        setState(() => _isConnected = false);
        ToastUtils.showWarningToast(
          'Gagal auto-connect. Pastikan printer menyala.',
        );
      }
    }
  }

  // [4] Scan Bluetooth Printers
  Future<void> _scanPrinters() async {
    // Request Permissions
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    final allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted) {
      ToastUtils.showErrorToast('Izin Bluetooth diperlukan');
      return;
    }

    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    // Listen to discovery stream
    _service.scanPrinters().listen(
      (device) {
        if (mounted && !_devices.any((d) => d.address == device.address)) {
          setState(() => _devices.add(device));
        }
      },
      onError: (error) {
        if (mounted) {
          ToastUtils.showErrorToast('Scan error: $error');
          setState(() => _isScanning = false);
        }
      },
    );

    // Auto-stop scanning after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    });
  }

  // [5] Connect & Save Printer (WITH AUTO TEST PRINT)
  Future<void> _connectAndSavePrinter(PrinterDevice device) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: kBrandColor),
        ),
      );

      // Connect
      final connected = await _service.connectPrinter(device);

      if (!connected) {
        if (mounted) Navigator.pop(context); // Close loading
        ToastUtils.showErrorToast('Gagal terhubung ke printer');
        return;
      }

      // [AUTO TEST PRINT]
      await _performTestPrint(device);

      // Close loading
      if (mounted) Navigator.pop(context);

      // Update UI
      setState(() {
        _savedPrinter = {
          'name': device.name,
          'address': device.address ?? '',
        };
        _isConnected = true;
      });

      ToastUtils.showSuccessToast(
        'Printer "${device.name}" berhasil ditambahkan!\nTest print sedang dicetak...',
      );
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading if error
      ToastUtils.showErrorToast('Error: $e');
    }
  }

  // [6] Test Print Otomatis
  Future<void> _performTestPrint(PrinterDevice device) async {
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      // Header
      bytes += generator.reset();
      bytes += generator.emptyLines(1);

      bytes += generator.text(
        'TEST PRINT',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );

      bytes += generator.emptyLines(1);

      bytes += generator.text(
        'Horeka POS+',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );

      bytes += generator.text(
        'Printer Setup Successful!',
        styles: const PosStyles(align: PosAlign.center),
      );

      bytes += generator.hr(ch: '-');

      bytes += generator.text('Printer  : ${device.name}');
      bytes += generator.text('Address  : ${device.address}');
      bytes += generator.text(
        'Time     : ${DateTime.now().toString().substring(0, 19)}',
      );

      bytes += generator.hr(ch: '-');

      bytes += generator.emptyLines(1);

      bytes += generator.text(
        'Printer siap digunakan!',
        styles: const PosStyles(align: PosAlign.center),
      );

      bytes += generator.text(
        'Tidak perlu setup ulang.',
        styles: const PosStyles(align: PosAlign.center),
      );

      bytes += generator.emptyLines(2);
      bytes += generator.cut();

      // Send to printer
      await _service.printReceipt(bytes);

      // Wait for print to complete
      await Future.delayed(const Duration(milliseconds: 800));
    } catch (e) {
      print('⚠️ Test print failed: $e');
    }
  }

  // [7] Delete Saved Printer
  Future<void> _deletePrinter() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Printer?'),
        content: Text(
          'Printer "${_savedPrinter!['name']}" akan dihapus.\nAnda perlu setup ulang jika ingin menggunakan printer ini lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.deletePrinter();
      
      setState(() {
        _savedPrinter = null;
        _isConnected = false;
      });

      ToastUtils.showSuccessToast('Printer berhasil dihapus');
    }
  }

  // [8] Reconnect Manual
  Future<void> _reconnect() async {
    if (_savedPrinter == null) return;

    ToastUtils.showInfoToast('Menghubungkan ulang...');
    
    final success = await _service.autoConnectSavedPrinter();

    if (mounted) {
      if (success) {
        setState(() => _isConnected = true);
        ToastUtils.showSuccessToast('Printer terhubung kembali');
      } else {
        ToastUtils.showErrorToast('Gagal terhubung. Pastikan printer menyala.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: kBrandColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(left: 126, right: 24, top: 21, bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: kCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER
              Container(
                height: 60,
                decoration: const BoxDecoration(
                  color: kBrandColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: const BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Printer Settings',
                        style: TextStyle(
                          color: kBrandColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // BODY
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SAVED PRINTER SECTION
                      _buildSavedPrinterSection(),

                      const SizedBox(height: 32),
                      const Divider(color: kBorderColor),
                      const SizedBox(height: 24),

                      // ADD PRINTER SECTION
                      if (_savedPrinter == null) ...[
                        _buildAddPrinterSection(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === SAVED PRINTER CARD ===
  Widget _buildSavedPrinterSection() {
    if (_savedPrinter == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Belum ada printer yang tersimpan.\nTambahkan printer di bawah.',
                style: TextStyle(color: kTextGrey, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isConnected ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isConnected ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bluetooth_connected,
                color: _isConnected ? Colors.green : Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _savedPrinter!['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kTextDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _savedPrinter!['address'] ?? '-',
                      style: const TextStyle(
                        fontSize: 12,
                        color: kTextGrey,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isConnected ? 'Terhubung' : 'Terputus',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              if (!_isConnected) ...[
                ElevatedButton.icon(
                  onPressed: _reconnect,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Hubungkan Ulang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrandColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              OutlinedButton.icon(
                onPressed: _deletePrinter,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Hapus Printer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // === ADD PRINTER SECTION ===
  Widget _buildAddPrinterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tambah Printer Baru',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: kTextDark,
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: 250,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isScanning ? null : _scanPrinters,
            icon: _isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.bluetooth_searching),
            label: Text(_isScanning ? 'Mencari...' : 'Scan Bluetooth Printer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kBrandColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // DEVICE LIST
        if (_devices.isEmpty && !_isScanning)
          const Text(
            'Belum ada printer ditemukan. Klik tombol di atas untuk scan.',
            style: TextStyle(color: kTextGrey, fontSize: 13),
          )
        else if (_devices.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              border: Border.all(color: kBorderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _devices.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: kBorderColor,
              ),
              itemBuilder: (context, index) {
                final device = _devices[index];
                return ListTile(
                  leading: const Icon(Icons.bluetooth, color: kBrandColor),
                  title: Text(
                    device.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    device.address ?? 'Unknown Address',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _connectAndSavePrinter(device),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Connect'),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
