// Salin kode ini ke file baru:
// lib/features/dashboard/views/dialogs/konfirmasi_saldo_dialog.dart

import 'package:flutter/material.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';
// Import dialog saldo awal (untuk tombol "Retry")
import 'package:horeka_post_plus/features/dashboard/views/dialogs/saldo_awal_dialog.dart';

class KonfirmasiSaldoDialog extends StatelessWidget {
  const KonfirmasiSaldoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,

      // Container untuk shadow 3D
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
        // Konten dialog
        child: Container( 
          width: 400, 
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            // Sesuai permintaan: Warna #FFFFFF
            color: const Color(0xFFFFFFFF), 
            borderRadius: BorderRadius.circular(20),
            // Sesuai permintaan: Border #CFCFCF
            border: Border.all(
              color: const Color(0xFFCFCFCF), 
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Judul
              const Text(
                "Is the balance correct?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kDarkTextColor,
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Baris untuk Tombol
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ===========================================
                  // ⭐️ PERUBAHAN: Tombol dibungkus Expanded
                  // ===========================================
                  // Tombol "No, Retry" (Biru, sesuai TEKS)
                  Expanded(
                    child: _buildDialogButton(
                      context: context,
                      text: "No, Retry",
                      backgroundColor: const Color(0xFF4C45B5), 
                      shadowColor: const Color(0xFF4C45B5).withOpacity(0.5),
                      textColor: kWhiteColor,
                      isRetry: true,
                    ),
                  ),
                  
                  const SizedBox(width: 16), // Jarak antar tombol

                  // Tombol "Yes" (Abu-abu, sesuai TEKS)
                  Expanded(
                    child: _buildDialogButton(
                      context: context,
                      text: "Yes",
                      backgroundColor: const Color(0xFF797979), 
                      shadowColor: const Color(0xFF797979).withOpacity(0.5),
                      textColor: kWhiteColor,
                      isRetry: false,
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

  // Helper widget untuk membuat tombol 3D
  Widget _buildDialogButton({
    required BuildContext context,
    required String text,
    required Color backgroundColor,
    required Color shadowColor,
    required Color textColor,
    required bool isRetry,
  }) {
    return InkWell(
      onTap: () {
        // 1. Selalu tutup dialog konfirmasi ini
        Navigator.of(context).pop();

        if (isRetry) {
          // 2. Jika "No, Retry", panggil Ulang dialog Saldo Awal
          showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: const Color(0xFF4C45B5).withOpacity(0.4),
            builder: (BuildContext dialogContext) {
              return const SaldoAwalDialog();
            },
          );
        }
        // 3. Jika "Yes", alur selesai.
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
    
        padding: const EdgeInsets.symmetric(vertical: 12), // Tinggi tombol
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: shadowColor, 
              blurRadius: 8,
              offset: const Offset(0, 4), 
            )
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}