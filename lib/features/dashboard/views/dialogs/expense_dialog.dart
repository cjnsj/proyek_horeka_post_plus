// Salin kode ini ke file baru:
// lib/features/dashboard/views/dialogs/expense_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';

class ExpenseDialog extends StatelessWidget {
  const ExpenseDialog({super.key});

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
          width: 450, // Dibuat sedikit lebih lebar
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Field 1: Description
              _buildLabeledTextField(
                "Description",
                "Enter description...",
              ),
              const SizedBox(height: 16),
              
              // Field 2: Amount
              _buildLabeledTextField(
                "Amount of expenditure (Rp)",
                "Enter amount...",
                isNumeric: true,
              ),
              const SizedBox(height: 24),
              
              // Baris untuk Tombol
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tombol "Cancel" (Abu-abu, #797979)
                  Expanded(
                    child: _buildDialogButton(
                      context: context,
                      text: "Cancel",
                      backgroundColor: const Color(0xFF797979), 
                      shadowColor: const Color(0xFF797979).withOpacity(0.5),
                      isSave: false,
                    ),
                  ),
                  
                  const SizedBox(width: 16), // Jarak antar tombol

                  // Tombol "Save" (Biru, #4C45B5)
                  Expanded(
                    child: _buildDialogButton(
                      context: context,
                      text: "Save",
                      backgroundColor: const Color(0xFF4C45B5), 
                      shadowColor: const Color(0xFF4C45B5).withOpacity(0.5),
                      isSave: true, 
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

  // Helper untuk Tombol 3D (Sama besar)
  Widget _buildDialogButton({
    required BuildContext context,
    required String text,
    required Color backgroundColor,
    required Color shadowColor,
    required bool isSave,
  }) {
    return InkWell(
      onTap: () {
        if (isSave) {
          // TODO: Tambahkan logika untuk menyimpan data expense
        }
        // Tutup dialog
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
            style: const TextStyle(
              color: kWhiteColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Helper untuk TextField 3D (Gaya Saldo Awal)
  Widget _buildLabeledTextField(String label, String hintText, {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kDarkTextColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
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
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            inputFormatters: isNumeric 
                ? [FilteringTextInputFormatter.digitsOnly] 
                : [],
            decoration: InputDecoration(
              hintText: hintText,
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
      ],
    );
  }
}