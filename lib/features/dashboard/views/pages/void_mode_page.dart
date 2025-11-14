// Salin ke file baru:
// lib/features/dashboard/views/pages/void_mode_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';

class VoidModePage extends StatelessWidget {
  const VoidModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      // 1. APP BAR (HEADER)
      appBar: AppBar(
        backgroundColor: kWhiteColor, // Latar belakang putih
        elevation: 1, // Sedikit shadow
        shadowColor: kBorderColor,
        // Tombol Kembali (sesuai gambar)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kDarkTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Judul (sesuai gambar)
        title: const Text(
          "Void Mode",
          style: TextStyle(
            color: kDarkTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Tombol Print (sesuai gambar)
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/print_kedua.svg',
              width: 24, // Sesuaikan ukurannya jika perlu
              height: 24, // Sesuaikan ukurannya jika perlu
            ),
            onPressed: () {
              // TODO: Logika untuk print
            },
          ),
        ],
      ),
      // 2. BODY HALAMAN
      body: Padding(
        // Padding global seperti dashboard
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3. PANEL KIRI (LIST TRANSAKSI)
            Expanded(
              flex: 2, // Panel kiri lebih besar
              child: _buildTransactionListPanel(),
            ),
            const SizedBox(width: 24),
            // 4. PANEL KANAN (CART)
            Expanded(
              flex: 1, // Panel kanan lebih kecil
              child: _buildCartPanel(),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET UNTUK PANEL KIRI
  Widget _buildTransactionListPanel() {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Input "Enter transaction number"
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Enter transaction number",
                        filled: true,
                        fillColor: kBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Tombol "Search"
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Logika search
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandColor,
                      foregroundColor: kWhiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Search",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: kBorderColor),

          // List Transaksi
          Expanded(
            child: ListView(
              children: [
                // Ini adalah data dummy, ganti dengan data asli Anda
                _buildTransactionTile(
                  "TR0511202510001",
                  "05-11-2025 09:13:15",
                  "Rp. 18.000,00",
                ),
                _buildTransactionTile(
                  "TR0511202510001",
                  "05-11-2025 09:13:15",
                  "Rp. 18.000,00",
                ),
                _buildTransactionTile(
                  "TR0511202510001",
                  "05-11-2025 09:13:15",
                  "Rp. 18.000,00",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk satu item transaksi
  Widget _buildTransactionTile(String id, String dateTime, String price) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorderColor, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Info Teks (ID, Tanggal, Harga)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                id,
                style: const TextStyle(
                  color: kDarkTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    dateTime,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "•",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    price,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Tombol Hapus (Void)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              // TODO: Logika untuk void/hapus transaksi
            },
          ),
        ],
      ),
    );
  }

  // WIDGET UNTUK PANEL KANAN
  Widget _buildCartPanel() {
    return Container(
      height: double.infinity, // Memenuhi tinggi
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: Column(
        children: [
          // Header "Cart"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Cart",
                  style: TextStyle(
                    color: kDarkTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // (Anda bisa tambahkan ikon keranjang/hapus di sini jika perlu)
              ],
            ),
          ),
          const Divider(height: 1, color: kBorderColor),

          // Tampilan Kosong (sesuai gambar)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, color: kBrandColor, size: 25),
                  const SizedBox(height: 8),
                  Text(
                    "Please choose a transaction", // Teks sesuai gambar
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Total (Bagian bawah)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTotalRow("Discount", "-Rp.0,00"),
                _buildTotalRow("Subtotal", "Rp.0,00"),
                _buildTotalRow("Tax", "+Rp.0,00"),
                const Divider(height: 24),
                _buildTotalRow("Total", "Rp.0,00", isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk baris Total (dicopy dari cart_panel.dart)
  Widget _buildTotalRow(String title, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isTotal ? kDarkTextColor : Colors.grey.shade600,
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isTotal ? kDarkTextColor : Colors.grey.shade600,
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
