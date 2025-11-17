// Salin kode ini ke file baru:
// lib/features/dashboard/views/dialogs/konfirmasi_saldo_dialog.dart

import 'package:flutter/material.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';
// Import dialog saldo awal (untuk tombol "Retry")
import 'package:horeka_post_plus/features/dashboard/views/dialogs/saldo_awal_dialog.dart';
// IMPORT SERVICE BARU
import 'package:horeka_post_plus/features/dashboard/services/shift_api_service.dart';

// UBAH MENJADI STATEFULWIDGET
class KonfirmasiSaldoDialog extends StatefulWidget {
  // TAMBAHKAN INI: Terima PIN dan Saldo
  final String operatorPin;
  final int openingCash;

  const KonfirmasiSaldoDialog({
    super.key,
    required this.operatorPin,
    required this.openingCash,
  });

  @override
  State<KonfirmasiSaldoDialog> createState() => _KonfirmasiSaldoDialogState();
}

class _KonfirmasiSaldoDialogState extends State<KonfirmasiSaldoDialog> {
  // TAMBAHKAN INI: State untuk loading & service
  bool _isLoading = false;
  final _shiftApiService = ShiftApiService();

  // TAMBAHKAN INI: Helper untuk error
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $message"),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // TAMBAHKAN INI: Logika untuk memanggil API
  Future<void> _openShift() async {
    setState(() => _isLoading = true);

    try {
      // Panggil API
      await _shiftApiService.openShift(
        widget.operatorPin,
        widget.openingCash,
      );

      // Jika sukses, tutup dialog ini. Selesai.
      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog konfirmasi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Shift opened successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Jika gagal (PIN salah, dll)
      if (mounted) {
        // Tutup dialog konfirmasi
        Navigator.of(context).pop();
        // Tampilkan error
        _showError(e.toString());

        // Setelah error, kita harus memunculkan lagi dialog PIN
        // agar pengguna bisa mencoba lagi dari awal.
        // Kita panggil dialog PIN dari DashboardPage,
        // jadi kita biarkan user menutup snackbar error
        // dan DashboardPage akan memicu ulang alur jika diperlukan.
        // Untuk alur yang lebih baik, kita bisa panggil ulang dialog PIN di sini:
        /*
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: const Color(0xFF4C45B5).withOpacity(0.4),
          builder: (BuildContext dialogContext) {
            return const PinKasirDialog(); // Mulai lagi dari PIN
          },
        );
        */
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFCFCFCF),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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

              // TAMBAHKAN INI: Tampilkan loading jika sedang proses
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: CircularProgressIndicator(),
                )
              else
                // Sembunyikan tombol jika sedang loading
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
        // MODIFIKASI LOGIKA TAP
        if (isRetry) {
          // 1. Selalu tutup dialog konfirmasi ini
          Navigator.of(context).pop();

          // 2. Jika "No, Retry", panggil Ulang dialog Saldo Awal
          showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: const Color(0xFF4C45B5).withOpacity(0.4),
            builder: (BuildContext dialogContext) {
              // KIRIM PIN YANG SAMA KEMBALI
              return SaldoAwalDialog(operatorPin: widget.operatorPin);
            },
          );
        } else {
          // 3. Jika "Yes", panggil API untuk buka shift
          _openShift();
        }
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