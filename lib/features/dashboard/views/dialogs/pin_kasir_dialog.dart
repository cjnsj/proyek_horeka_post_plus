// Salin dan Gantikan seluruh isi file:
// lib/features/dashboard/views/dialogs/pin_kasir_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';
import 'package:horeka_post_plus/features/dashboard/views/dialogs/saldo_awal_dialog.dart';

class PinKasirDialog extends StatefulWidget {
  const PinKasirDialog({super.key});

  @override
  State<PinKasirDialog> createState() => _PinKasirDialogState();
}

class _PinKasirDialogState extends State<PinKasirDialog> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 4; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < 3) {
          FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Widget _buildPinBox(int index) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4), 
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            obscureText: true,
            obscuringCharacter: '•',
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kDarkTextColor,
              height: 1.1 
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent, 
              border: InputBorder.none, 
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.only(bottom: 12.0), 
            ),
          ),
          Positioned(
            bottom: 12, 
            child: Container(
              width: 25, 
              height: 2, 
              color: Colors.grey.shade400, 
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 450,
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
              "Enter cashier PIN :",
              style: TextStyle(
                color: kDarkTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPinBox(0),
                const SizedBox(width: 20),
                _buildPinBox(1),
                const SizedBox(width: 20),
                _buildPinBox(2),
                const SizedBox(width: 20),
                _buildPinBox(3),
              ],
            ),
            const SizedBox(height: 24),

            InkWell(
              onTap: () {
                // TODO: Tambahkan logika validasi PIN di sini
                
                // 1. Tutup dialog PIN ini
                Navigator.of(context).pop(); 

                // ===========================================
                // ⭐️ PERBAIKANNYA ADA DI SINI ⭐️
                // ===========================================
                showDialog(
                  context: context,
                  barrierDismissible: false, 
                  
                  // ⭐️ TAMBAHKAN BARIS INI UNTUK OVERLAY UNGU ⭐️
                  barrierColor: const Color(0xFF4C45B5).withOpacity(0.4),

                  builder: (BuildContext dialogContext) {
                    return const SaldoAwalDialog();
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
                      color: kBrandColor.withOpacity(0.5), 
                      blurRadius: 8,
                      offset: const Offset(0, 4), 
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Enter",
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
    );
  }
}