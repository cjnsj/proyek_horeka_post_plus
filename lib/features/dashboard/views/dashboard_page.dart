import 'package:flutter/material.dart';
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
      // Seluruh body dibungkus Padding untuk jarak global
      body: Padding(
        padding: const EdgeInsets.all(24.0), 
        // ⭐️ KEMBALI KE LAYOUT COLUMN: Header di atas, Row di bawahnya
        child: Column( 
          children: [
            // 1. KARTU HEADER ATAS (Ini sekarang "full kiri")
            _buildGlobalTopBar(),

            // Jarak
            const SizedBox(height: 24),

            // 2. KONTEN UTAMA (Baris berisi Nav | Menu | Cart)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2a. SideNavRail (Sekarang di bawah header)
                  const SideNavRail(),

                  const SizedBox(width: 24), // Jarak antar kartu

                  // 2b. Panel Menu
                  const Expanded(
                    flex: 2,
                    child: MainContent(),
                  ),

                  const SizedBox(width: 24),

                  // 2c. Panel Keranjang
                  const Expanded(
                    flex: 1,
                    child: CartPanel(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐️ FUNGSI INI TIDAK DIUBAH SAMA SEKALI
  Widget _buildGlobalTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: Colors.black, width: 1), 
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Logo kiri, Search kanan
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
                  color: kDarkTextColor,
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
                suffixIcon: const Icon(Icons.search, color: kBrandColor), 
                filled: true,
                fillColor: kWhiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kBrandColor, width: 1.5), 
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}