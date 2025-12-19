import 'package:flutter/material.dart';
import 'package:horeka_post_plus/features/dashboard/services/printer_service.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  final PrinterService _service = PrinterService();

  // List lokal untuk menampung hasil scan
  List<PrinterDevice> _devices = [];
  bool _isScanning = false;

  void _scan() {
    setState(() {
      _isScanning = true;
      _devices.clear(); // Bersihkan list lama sebelum scan baru
    });

    // Listen stream: setiap ada device ditemukan, tambahkan ke list
    _service.scanPrinters().listen((device) {
      // Cek apakah device sudah ada di list (berdasarkan alamat mac address)
      // agar tidak muncul duplikat di layar
      if (!_devices.any((d) => d.address == device.address)) {
        setState(() {
          _devices.add(device);
        });
      }
    });

    // Opsional: Matikan status scanning setelah 10 detik (karena stream discovery tidak berhenti sendiri)
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Printer')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isScanning ? null : _scan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A3AA0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  _isScanning ? 'Sedang Mencari...' : 'Scan Printer Bluetooth',
                ),
              ),
            ),
          ),
          Expanded(
            child: _devices.isEmpty
                ? const Center(child: Text("Belum ada printer ditemukan"))
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return ListTile(
                        leading: const Icon(Icons.print, color: Colors.grey),
                        title: Text(device.name ?? "Unknown Device"),
                        subtitle: Text(device.address ?? "No Address"),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Menghubungkan...")),
                            );

                            bool connected = await _service.connectPrinter(
                              device,
                            );

                            if (mounted) {
                              if (connected) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Berhasil Terhubung!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(
                                  context,
                                ); // Kembali ke dashboard jika sukses
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Gagal Terhubung"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Connect'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
