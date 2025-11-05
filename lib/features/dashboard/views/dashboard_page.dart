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
    // Panggil dialog "Masukkan Saldo Awal" setelah frame pertama selesai di-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSaldoAwalDialog(context);
    });
  }

  // Fungsi untuk menampilkan dialog
  void _showSaldoAwalDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Mencegah dialog ditutup dengan klik di luar
      builder: (BuildContext dialogContext) {
        return const SaldoAwalDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Side Navigation Rail (Kiri)
          const SideNavRail(),
          
          // Garis pemisah vertikal
          VerticalDivider(width: 1, color: Colors.grey.shade300),

          // 2. Konten Utama (Kanan)
          Expanded(
            child: Column(
              children: [
                // 2a. Top Bar (Search)
                _buildTopBar(),
                
                // 2b. Area Konten (Menu dan Keranjang)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Menu (Tengah)
                        const Expanded(
                          flex: 2,
                          child: MainContent(),
                        ),
                        const SizedBox(width: 24),
                        // Keranjang (Kanan)
                        const Expanded(
                          flex: 1,
                          child: CartPanel(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk Top Bar (Search)
  Widget _buildTopBar() {
    return Container(
      height: 80, // Tinggi AppBar
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: kWhiteColor,
        border: Border(
          bottom: BorderSide(color: kLightGreyColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Search Bar
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Find menu",
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                filled: true,
                fillColor: kBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}