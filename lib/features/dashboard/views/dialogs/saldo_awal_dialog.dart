// Salin dan Gantikan seluruh isi file:
// lib/features/dashboard/views/dialogs/saldo_awal_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import untuk FilteringTextInputFormatter
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';
import 'package:horeka_post_plus/features/dashboard/views/dialogs/konfirmasi_saldo_dialog.dart';

// UBAH MENJADI STATEFULWIDGET
class SaldoAwalDialog extends StatefulWidget {
  // TAMBAHKAN INI: Terima PIN dari dialog sebelumnya
  final String operatorPin;

  const SaldoAwalDialog({
    super.key,
    required this.operatorPin, // Wajibkan PIN
  });

  @override
  State<SaldoAwalDialog> createState() => _SaldoAwalDialogState();
}

class _SaldoAwalDialogState extends State<SaldoAwalDialog> {
  // TAMBAHKAN INI: Controller untuk saldo
  final _saldoController = TextEditingController();

  @override
  void dispose() {
    _saldoController.dispose();
    super.dispose();
  }

  // TAMBAHKAN INI: Helper untuk error
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // TAMBAHKAN INI: Logika submit
  void _submitSaldo() {
    final String saldoString = _saldoController.text;

    // Validasi Saldo
    if (saldoString.isEmpty) {
      _showError("Please enter the starting balance.");
      return;
    }

    final int? openingCash = int.tryParse(saldoString);
    if (openingCash == null) {
      _showError("Invalid balance amount.");
      return;
    }

    // 1. Tutup dialog saldo ini
    Navigator.of(context).pop();

    // 2. Panggil dialog Konfirmasi (dengan overlay ungu)
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xFF4C45B5).withOpacity(0.4),
      builder: (BuildContext dialogContext) {
        // KIRIM PIN & SALDO KE DIALOG BERIKUTNYA
        return KonfirmasiSaldoDialog(
          operatorPin: widget.operatorPin,
          openingCash: openingCash,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Please enter the starting balance :",
                style: TextStyle(
                  color: kDarkTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: kWhiteColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: TextField(
                  // HUBUNGKAN CONTROLLER
                  controller: _saldoController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ], // Hanya izinkan angka
                  
                  // --- INI ADALAH PERUBAHANNYA ---
                  style: const TextStyle(
                    color: kDarkTextColor, // Warna teks inputan jadi gelap
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  // --- AKHIR PERUBAHAN ---

                  decoration: InputDecoration(
                    hintText: "Enter the balance amount",
                    
                    // --- TAMBAHAN UNTUK HINT ---
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400, // Warna hint
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    // --- AKHIR TAMBAHAN ---
                    
                    filled: true,
                    fillColor: kWhiteColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: kBrandColor, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap:
                    _submitSaldo, // Panggil fungsi submit
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: kBrandColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: kBrandColor.withOpacity(0.6),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Save and open cashier", // Teks dari gambar
                      style: TextStyle(
                        color: kWhiteColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}