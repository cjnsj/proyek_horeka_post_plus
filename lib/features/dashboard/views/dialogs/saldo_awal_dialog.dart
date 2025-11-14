// Salin dan Gantikan seluruh isi file:
// lib/features/dashboard/views/dialogs/saldo_awal_dialog.dart

import 'package:flutter/material.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';

// ⭐️ 1. IMPORT DIALOG KONFIRMASI BARU ⭐️
import 'package:horeka_post_plus/features/dashboard/views/dialogs/konfirmasi_saldo_dialog.dart';

class SaldoAwalDialog extends StatelessWidget {
  const SaldoAwalDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent, 

      // Container pembungkus untuk shadow 3D
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
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul
              const Text(
                "Please enter the starting balance :",
                style: TextStyle(
                  color: kDarkTextColor,
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // TextField 3D (Timbul)
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
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter the balance amount",
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
                      borderSide: const BorderSide(color: kBrandColor, width: 1.5),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol 3D (Timbul)
              InkWell(
                onTap: () {
                 
                  Navigator.of(context).pop();

                  // 2. Panggil dialog Konfirmasi (dengan overlay ungu)
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    barrierColor: const Color(0xFF4C45B5).withOpacity(0.4),
                    builder: (BuildContext dialogContext) {
                      return const KonfirmasiSaldoDialog(); // Memanggil dialog baru
                    },
                  );
                  // ===========================================
                },
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