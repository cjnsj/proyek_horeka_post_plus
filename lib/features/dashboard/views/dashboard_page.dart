// Salin dan Gantikan seluruh isi file
// lib/features/dashboard/views/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // <--- IMPORT BARU
import 'package:horeka_post_plus/features/dashboard/views/dialogs/saldo_awal_dialog.dart';
import 'package:horeka_post_plus/features/dashboard/views/widgets/cart_panel.dart';
import 'package:horeka_post_plus/features/dashboard/views/widgets/main_content.dart';
import 'package:horeka_post_plus/features/dashboard/views/widgets/side_nav_rail.dart';

// Warna yang akan sering kita gunakan
const kBrandColor = Color(0xFF5A4FFB);
const kBackgroundColor = Color(0xFFF7F8FC);
const kWhiteColor = Colors.white;
const kLightGreyColor = Color(0xFFEFEFEF);
const kDarkTextColor = Color(0xFF333333);

// ⭐️ PERUBAHAN 1: Menambahkan warna border baru "agak bening" ⭐️
const kBorderColor = Color(0xFFE0E0E0); // Ini adalah Colors.grey.shade300

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Panggil dialog "Masukkan Saldo Awal"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSaldoAwalDialog(context);
    });
  }

  // Fungsi untuk menampilkan dialog
  void _showSaldoAwalDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const SaldoAwalDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      // ⭐️ PERUBAHAN 2: Menambahkan layout statis (hardcode)
      resizeToAvoidBottomInset: false,
      // Seluruh body dibungkus Padding untuk jarak global
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KOLOM UTAMA (Kiri & Tengah digabung)
            Expanded(
              flex: 2, // Fleksibilitas gabungan untuk Nav dan Main
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1a. KARTU HEADER ATAS (Hanya di atas Nav & Main)
                  _buildGlobalTopBar(),

                  // Jarak
                  const SizedBox(height: 24),

                  // 1b. ROW INTERNAL (Untuk Nav & Main agar sejajar)
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1b-i. SideNavRail
                        // Tingginya sekarang dibatasi oleh Row internal ini
                        const SideNavRail(),

                        const SizedBox(width: 24),

                        // 1b-ii. Panel Menu
                        // Expanded di sini agar mengisi sisa Row internal
                        const Expanded(
                          child: MainContent(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // 2. PANEL KERANJANG (Tetap Full Height)
            const Expanded(
              flex: 1,
              child: CartPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        // ⭐️ PERUBAHAN 3: Menggunakan kBorderColor ⭐️
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Kiri: Logo dan Judul
          Row(
            children: [
              Image.asset(
                'assets/images/logo.png', // Logo "H"
                height: 40,
              ),
              const SizedBox(width: 16),
              const Text(
                "Horeka Pos+",
                style: TextStyle(
                  color: kBrandColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Kanan: Search Bar
          SizedBox(
            width: 300,
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Find menu",
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                // PERUBAHAN DI SINI: Menggunakan SVG
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(10.0), // Beri sedikit padding
                  child: SvgPicture.asset(
                    'assets/icons/search.svg',
                  ),
                ),
                filled: true,
                fillColor: kWhiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  // ⭐️ PERUBAHAN 4: Menggunakan kBorderColor ⭐️
                  borderSide: const BorderSide(color: kBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  // ⭐️ PERUBAHAN 5: Menggunakan kBorderColor ⭐️
                  borderSide: const BorderSide(color: kBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kBrandColor, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}