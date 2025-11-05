import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Impor path yang benar sesuai instruksi Anda
import 'package:horeka_post_plus/features/auth_landing/controllers/auth_page_bloc.dart';
import 'package:horeka_post_plus/features/auth_landing/controllers/auth_page_event.dart';

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding tetap di kiri atas, tapi konten akan lebih ke tengah
      padding: const EdgeInsets.only(top: 34.0, left: 64.0, right: 64.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 800, // Tetap batasi lebar
        ),
        child: Column(
          // Kali ini kita ratakan tengah semua isinya
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // Rata tengah
          children: [
            // Judul Utama
            const Text(
              'Welcome To Horeka Pos+',
              textAlign: TextAlign.center, // Rata tengah
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black54,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Sub-judul
            const Text(
              'POS app to simplify your business operations',
              textAlign: TextAlign.center, // Rata tengah
              style: TextStyle(
                fontSize: 20, // Sedikit lebih besar dari sebelumnya
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 8.0,
                    color: Colors.black54,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40), // Spasi lebih besar

            // Teks "Please enter the activation code"
            const Text(
              'Please enter the activation code',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70, // Sedikit redup
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black38,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // TextField untuk Activation Code
            Container(
              width: 300, // Lebar fixed untuk input field
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Enter the code here',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: Colors.white, // Latar belakang putih
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none, // Hilangkan border
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Activate
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A4FFB), // Warna ungu
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 16), // Padding lebih besar
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                // TODO: Tambahkan logika untuk memproses kode aktivasi
                // Untuk sementara, kita masih akan beralih ke LoginWidget
                context.read<AuthPageBloc>().add(StartPressed());
              },
              child: const Text('Activate'), // Ubah teks tombol
            ),
          ],
        ),
      ),
    );
  }
}