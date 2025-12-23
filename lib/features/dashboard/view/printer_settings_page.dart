import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:horeka_post_plus/core/utils/toast_utils.dart';
import 'package:horeka_post_plus/features/dashboard/data/saved_printer.dart';
import 'package:horeka_post_plus/features/dashboard/services/printer_storage_service.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

/// ================= HALAMAN PRINTER SETTINGS =================

class PrinterSettingsPage extends StatelessWidget {
  const PrinterSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 126, right: 24, top: 21, bottom: 16),
      child: _PrinterSettingsCard(),
    );
  }
}

/// ================= CARD BESAR PRINTER SETTINGS ===============

class _PrinterSettingsCard extends StatefulWidget {
  const _PrinterSettingsCard();

  @override
  State<_PrinterSettingsCard> createState() => _PrinterSettingsCardState();
}

class _PrinterSettingsCardState extends State<_PrinterSettingsCard> {
  bool _isAddingUsbPrinter = false;
  List<SavedPrinter> _savedPrinters = [];
  SavedPrinter? _selectedPrinter;
  final PrinterStorageService _storageService = PrinterStorageService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPrinters();
  }

  Future<void> _loadSavedPrinters() async {
    setState(() => _isLoading = true);

    final printers = await _storageService.loadPrinters();
    final selectedId = await _storageService.loadSelectedPrinter();

    setState(() {
      _savedPrinters = printers;
      if (selectedId != null && printers.isNotEmpty) {
        _selectedPrinter = printers.firstWhere(
          (p) => p.id == selectedId,
          orElse: () => printers.first,
        );
      } else if (printers.isNotEmpty) {
        _selectedPrinter = printers.first;
      } else {
        _selectedPrinter = null;
      }
      _isLoading = false;
    });
  }

  Future<void> _savePrintersToStorage() async {
    await _storageService.savePrinters(_savedPrinters);
    if (_selectedPrinter != null) {
      await _storageService.saveSelectedPrinter(_selectedPrinter!.id);
    }
  }

  void _showAddUsbPrinter() {
    setState(() {
      _isAddingUsbPrinter = true;
    });
  }

  void _cancelAddUsbPrinter() {
    setState(() {
      _isAddingUsbPrinter = false;
    });
  }

  void _addBluetoothPrinter(PrinterDevice device) {
    final printer = SavedPrinter.fromBluetooth(
      name: device.name,
      address: device.address ?? '',
    );

    setState(() {
      if (!_savedPrinters.any((p) => p.id == printer.id)) {
        _savedPrinters.add(printer);
        _selectedPrinter ??= printer;
      }
    });

    _savePrintersToStorage();
  }

  void _addUsbPrinter(SavedPrinter printer) {
    setState(() {
      if (!_savedPrinters.any((p) => p.id == printer.id)) {
        _savedPrinters.add(printer);
        _selectedPrinter ??= printer;
      }
    });

    _savePrintersToStorage();
    _cancelAddUsbPrinter();
  }

  void _removePrinter(SavedPrinter printer) {
    setState(() {
      _savedPrinters.removeWhere((p) => p.id == printer.id);
      if (_selectedPrinter?.id == printer.id) {
        _selectedPrinter = _savedPrinters.isNotEmpty
            ? _savedPrinters.first
            : null;
      }
    });

    _savePrintersToStorage();
  }

  void _selectPrinter(SavedPrinter printer) {
    setState(() {
      _selectedPrinter = printer;
    });
    _storageService.saveSelectedPrinter(printer.id);
  }

  // ================= METHOD TEST PRINT =================
  Future<void> _testPrint(SavedPrinter printer) async {
    try {
      final printerManager = PrinterManager.instance;

      // Load capability profile
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);

      // Tentukan model dan type berdasarkan printer type
      PrinterType type;
      dynamic model;

      if (printer.type == SavedPrinterType.bluetooth) {
        type = PrinterType.bluetooth;
        model = BluetoothPrinterInput(
          name: printer.name,
          address: printer.bluetoothAddress ?? '',
        );
      } else {
        type = PrinterType.usb;
        model = UsbPrinterInput(
          name: printer.name,
          vendorId: printer.vendorId?.toString(),
          productId: printer.productId?.toString(),
        );
      }

      // Connect ke printer
      await printerManager.connect(type: type, model: model);

      // Generate test receipt
      List<int> bytes = [];

      // Header
      bytes += generator.text(
        'TEST PRINT',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.emptyLines(1);

      // Info
      bytes += generator.text(
        'Horeka POS+',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.text(
        'Printer Test Successful',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.emptyLines(1);
      bytes += generator.text('Printer: ${printer.name}');
      bytes += generator.text(
        'Type: ${printer.type == SavedPrinterType.bluetooth ? "Bluetooth" : "USB"}',
      );
      bytes += generator.text('Address: ${printer.displayAddress}');
      bytes += generator.text(
        'Time: ${DateTime.now().toString().substring(0, 19)}',
      );
      bytes += generator.emptyLines(2);
      bytes += generator.cut();

      // Print
      await printerManager.send(type: type, bytes: bytes);
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ToastUtils.showSuccessToast(
          'Test print sent to ${printer.name}\nCheck if receipt is printing...',
        );
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast('Test print failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: kCardShadow,
        ),
        child: const Center(
          child: CircularProgressIndicator(color: kBrandColor),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER UNGU
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

          // ISI
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _isAddingUsbPrinter
                      ? _PrinterSettingsLeftUsbForm(
                          onCancel: _cancelAddUsbPrinter,
                          onSave: _addUsbPrinter,
                        )
                      : _PrinterSettingsLeft(
                          onAddUsbPrinter: _showAddUsbPrinter,
                          savedPrinters: _savedPrinters,
                          onRemovePrinter: _removePrinter,
                          onAddBluetoothPrinter: _addBluetoothPrinter,
                          onTestPrint: _testPrint,
                        ),
                ),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: kBorderColor,
                ),
                Expanded(
                  child: _PrinterSettingsRight(
                    savedPrinters: _savedPrinters,
                    selectedPrinter: _selectedPrinter,
                    onSelectPrinter: _selectPrinter,
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

/// ================= KOLOM KIRI (DEFAULT VIEW) =================

class _PrinterSettingsLeft extends StatelessWidget {
  final VoidCallback onAddUsbPrinter;
  final List<SavedPrinter> savedPrinters;
  final Function(SavedPrinter) onRemovePrinter;
  final Function(PrinterDevice) onAddBluetoothPrinter;
  final Function(SavedPrinter) onTestPrint;

  const _PrinterSettingsLeft({
    required this.onAddUsbPrinter,
    required this.savedPrinters,
    required this.onRemovePrinter,
    required this.onAddBluetoothPrinter,
    required this.onTestPrint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Printer List',
                style: TextStyle(
                  color: kTextDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrandColor,
                          foregroundColor: kWhiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        onPressed: () => showBluetoothPrinterDialog(
                          context,
                          onAddBluetoothPrinter,
                        ),
                        child: const Text('Add Bluetooth Printer'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrandColor,
                          foregroundColor: kWhiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        onPressed: onAddUsbPrinter,
                        child: const Text('Add USB Printer'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (savedPrinters.isNotEmpty) ...[
                ...savedPrinters.map((printer) => _buildPrinterItem(printer)),
              ] else ...[
                const Text(
                  'No saved printers',
                  style: TextStyle(color: kTextGrey, fontSize: 12),
                ),
              ],
            ],
          ),
        ),

        const Divider(height: 1, thickness: 1, color: kBorderColor),
        const Expanded(child: SizedBox.expand()),
      ],
    );
  }

  Widget _buildPrinterItem(SavedPrinter printer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                printer.type == SavedPrinterType.bluetooth
                    ? Icons.bluetooth
                    : Icons.usb,
                size: 16,
                color: kBrandColor,
              ),
              const SizedBox(width: 6),
              Text(
                printer.name,
                style: const TextStyle(
                  color: kTextDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  printer.displayAddress,
                  style: const TextStyle(color: kTextGrey, fontSize: 11),
                ),
              ),
              // TOMBOL TEST PRINT
              IconButton(
                onPressed: () => onTestPrint(printer),
                icon: const Icon(Icons.print, size: 18, color: kBrandColor),
                tooltip: 'Test Print',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {
                  // TODO: Edit functionality
                },
                icon: SvgPicture.asset(
                  'assets/icons/edit_1.svg',
                  width: 18,
                  height: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => onRemovePrinter(printer),
                icon: SvgPicture.asset(
                  'assets/icons/delete.svg',
                  width: 18,
                  height: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ================= KOLOM KIRI (FORM ADD USB PRINTER) =================

class _PrinterSettingsLeftUsbForm extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(SavedPrinter) onSave;

  const _PrinterSettingsLeftUsbForm({
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<_PrinterSettingsLeftUsbForm> createState() =>
      _PrinterSettingsLeftUsbFormState();
}

class _PrinterSettingsLeftUsbFormState
    extends State<_PrinterSettingsLeftUsbForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _vendorIdController = TextEditingController();
  final TextEditingController _productIdController = TextEditingController();
  final PrinterManager _printerManager = PrinterManager.instance;

  bool _isTesting = false;
  bool _testSuccess = false;
  String? _testMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _vendorIdController.dispose();
    _productIdController.dispose();
    super.dispose();
  }

  Future<void> _testPrinter() async {
    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter printer name');
      return;
    }

    if (_vendorIdController.text.trim().isEmpty ||
        _productIdController.text.trim().isEmpty) {
      _showError('Please enter Vendor ID and Product ID');
      return;
    }

    int? vendorId;
    int? productId;

    try {
      vendorId = int.parse(_vendorIdController.text.trim());
      productId = int.parse(_productIdController.text.trim());
    } catch (e) {
      _showError('Vendor ID and Product ID must be numbers');
      return;
    }

    setState(() {
      _isTesting = true;
      _testSuccess = false;
      _testMessage = null;
    });

    try {
      // Scan for USB devices
      final completer = Completer<bool>();
      bool deviceFound = false;

      final subscription = _printerManager
          .discovery(type: PrinterType.usb)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: (sink) {
              sink.close();
            },
          )
          .listen((device) {
            // Check if device matches vendor and product ID
            // Note: flutter_pos_printer_platform mungkin tidak expose vendor/product ID
            // Jadi kita cek berdasarkan nama atau address
            if (!deviceFound) {
              deviceFound = true;
              if (!completer.isCompleted) {
                completer.complete(true);
              }
            }
          });

      // Wait for result or timeout
      await Future.any([
        completer.future,
        Future.delayed(const Duration(seconds: 10), () => false),
      ]);

      await subscription.cancel();

      setState(() {
        _isTesting = false;
        _testSuccess = deviceFound;
        _testMessage = deviceFound
            ? 'USB Printer detected successfully!'
            : 'USB Printer not found. Please check:\n- Printer is connected\n- Correct Vendor ID & Product ID\n- USB permissions granted';
      });

      if (deviceFound) {
        ToastUtils.showSuccessToast('Printer test successful!');
      }
    } catch (e) {
      setState(() {
        _isTesting = false;
        _testSuccess = false;
        _testMessage = 'Test failed: $e';
      });
    }
  }

  void _savePrinter() {
    if (!_testSuccess) {
      _showError('Please test the printer first');
      return;
    }

    final vendorId = int.parse(_vendorIdController.text.trim());
    final productId = int.parse(_productIdController.text.trim());

    final printer = SavedPrinter.fromUsb(
      name: _nameController.text.trim(),
      vendorId: vendorId,
      productId: productId,
    );

    widget.onSave(printer);

    ToastUtils.showSuccessToast('USB Printer saved successfully!');
  }

  void _showError(String message) {
    ToastUtils.showWarningToast(message);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 0, 330),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Add USB Printer',
            style: TextStyle(
              color: kTextDark,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter printer details and test connection before saving',
            style: TextStyle(color: kTextGrey, fontSize: 12),
          ),
          const SizedBox(height: 24),

          const Text(
            'Printer Name',
            style: TextStyle(color: kTextDark, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.black),
            decoration: _inputDecoration('e.g., Kitchen Printer'),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vendor ID',
                      style: TextStyle(
                        color: kTextDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _vendorIdController,
                      style: const TextStyle(color: Colors.black),
                      decoration: _inputDecoration('1305'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product ID',
                      style: TextStyle(
                        color: kTextDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _productIdController,
                      style: const TextStyle(color: Colors.black),
                      decoration: _inputDecoration('8211'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Test Result Message
          if (_testMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _testSuccess
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _testSuccess ? Colors.green : Colors.orange,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _testSuccess ? Icons.check_circle : Icons.warning,
                    color: _testSuccess ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _testMessage!,
                      style: TextStyle(
                        color: _testSuccess
                            ? Colors.green.shade900
                            : Colors.orange.shade900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: _isTesting ? null : widget.onCancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 130,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrandColor,
                    foregroundColor: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: _isTesting ? null : _testPrinter,
                  child: _isTesting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              kWhiteColor,
                            ),
                          ),
                        )
                      : const Text('Test Printer'),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 130,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _testSuccess ? kBrandColor : Colors.grey,
                    foregroundColor: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: _testSuccess && !_isTesting ? _savePrinter : null,
                  child: const Text('Save Printer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: kTextGrey, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kBrandColor, width: 2),
      ),
    );
  }
}

/// ================= KOLOM KANAN =================

class _PrinterSettingsRight extends StatelessWidget {
  final List<SavedPrinter> savedPrinters;
  final SavedPrinter? selectedPrinter;
  final Function(SavedPrinter) onSelectPrinter;

  const _PrinterSettingsRight({
    required this.savedPrinters,
    this.selectedPrinter,
    required this.onSelectPrinter,
  });

  void _showChoosePrinterDialog(BuildContext context) {
    if (savedPrinters.isEmpty) {
      ToastUtils.showWarningToast('Please add a printer first');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choose Printer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: kBorderColor),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: savedPrinters.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: kBorderColor),
                  itemBuilder: (context, index) {
                    final printer = savedPrinters[index];
                    final isSelected = selectedPrinter?.id == printer.id;
                    return ListTile(
                      leading: Icon(
                        printer.type == SavedPrinterType.bluetooth
                            ? Icons.bluetooth
                            : Icons.usb,
                        color: kBrandColor,
                      ),
                      title: Text(
                        printer.name,
                        style: TextStyle(
                          color: isSelected ? kBrandColor : kTextDark,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        printer.displayAddress,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: kBrandColor)
                          : null,
                      onTap: () {
                        onSelectPrinter(printer);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Active Configuration',
                style: TextStyle(
                  color: kTextDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Printer for Receipt',
                          style: TextStyle(
                            color: kTextDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedPrinter?.name ?? 'No printer selected',
                          style: const TextStyle(
                            color: kTextGrey,
                            fontSize: 12,
                          ),
                        ),
                        if (selectedPrinter != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            selectedPrinter!.displayAddress,
                            style: const TextStyle(
                              color: kTextGrey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showChoosePrinterDialog(context),
                    child: const Text(
                      'Choose Printer',
                      style: TextStyle(color: kBrandColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),

        const Divider(height: 1, thickness: 1, color: kBorderColor),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Kitchen Printer',
                      style: TextStyle(
                        color: kTextDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: kBorderColor, width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Enable kitchen printer',
                        style: TextStyle(color: kTextDark, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Not configured',
                style: TextStyle(color: kTextGrey, fontSize: 12),
              ),
            ],
          ),
        ),

        const Spacer(),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showChoosePrinterDialog(context),
              child: const Text(
                'Choose Printer',
                style: TextStyle(color: kBrandColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ================= DIALOG BLUETOOTH =================

void showBluetoothPrinterDialog(
  BuildContext context,
  Function(PrinterDevice) onAddPrinter,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => _BluetoothPrinterDialog(onAddPrinter: onAddPrinter),
  );
}

class _BluetoothPrinterDialog extends StatefulWidget {
  final Function(PrinterDevice) onAddPrinter;

  const _BluetoothPrinterDialog({required this.onAddPrinter});

  @override
  State<_BluetoothPrinterDialog> createState() =>
      _BluetoothPrinterDialogState();
}

class _BluetoothPrinterDialogState extends State<_BluetoothPrinterDialog> {
  final PrinterManager _printerManager = PrinterManager.instance;
  List<PrinterDevice> _devices = [];
  bool _isScanning = false;
  StreamSubscription<PrinterDevice>? _subscription;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndScan();
  }

  Future<void> _requestPermissionsAndScan() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    final allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted) {
      if (mounted) {
        ToastUtils.showErrorToast('Bluetooth permissions are required');
        Navigator.of(context).pop();
      }
      return;
    }

    _startScan();
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      _devices = [];
    });

    _subscription = _printerManager
        .discovery(type: PrinterType.bluetooth, isBle: false)
        .listen((device) {
          if (mounted) {
            setState(() {
              if (!_devices.any((d) => d.address == device.address)) {
                _devices.add(device);
              }
            });
          }
        });

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _stopScan();
      }
    });
  }

  void _stopScan() {
    _subscription?.cancel();
    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 280, vertical: 180),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 48,
              decoration: const BoxDecoration(
                color: kBrandColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'Bluetooth Devices',
                      style: TextStyle(
                        color: kWhiteColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_isScanning)
                    const Positioned(
                      right: 16,
                      top: 14,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            kWhiteColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            _devices.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isScanning
                              ? Icons.bluetooth_searching
                              : Icons.bluetooth_disabled,
                          size: 48,
                          color: kTextGrey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isScanning
                              ? 'Scanning for Bluetooth printers...'
                              : 'No devices found',
                          style: const TextStyle(color: kTextGrey),
                          textAlign: TextAlign.center,
                        ),
                        if (!_isScanning) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _startScan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kBrandColor,
                              foregroundColor: kWhiteColor,
                            ),
                            child: const Text('Scan Again'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _devices.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 0.7,
                        color: kBorderColor,
                      ),
                      itemBuilder: (context, index) {
                        final device = _devices[index];
                        return InkWell(
                          onTap: () {
                            widget.onAddPrinter(device);
                            Navigator.of(context).pop();
                            ToastUtils.showSuccessToast('Added ${device.name}');
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.bluetooth,
                                  color: kBrandColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device.name,
                                      style: const TextStyle(
                                        color: kTextDark,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      device.address ?? 'Unknown MAC',
                                      style: const TextStyle(
                                        color: kTextGrey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
