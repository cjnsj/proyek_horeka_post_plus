// Salin ke file baru:
// lib/features/dashboard/views/pages/print_receipt_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';

class PrintReceiptPage extends StatelessWidget {
  const PrintReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      // 1. APP BAR (HEADER)
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 1,
        shadowColor: kBorderColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kDarkTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Print Receipt",
          style: TextStyle(
            color: kDarkTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/print_kedua.svg', // Menggunakan SVG
              width: 24,
              height: 24,
            ),
            onPressed: () {
              // TODO: Logika untuk print
            },
          ),
        ],
      ),
      // 2. BODY HALAMAN
      body: Padding(
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
                // Ini adalah data dummy
                _buildTransactionTile(
                  "TR0511202510001", "05-11-2025 09:13:15", "Rp. 18.000,00"),
                // Tambahkan data dummy lain jika perlu
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk satu item transaksi (dengan tombol "View receipt")
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
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
          // Tombol "View receipt"
          OutlinedButton(
            onPressed: () {
              // TODO: Logika untuk menampilkan detail cart
            },
            child: const Text(
              "View receipt",
              style: TextStyle(color: kDarkTextColor, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kBorderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET UNTUK PANEL KANAN
  Widget _buildCartPanel() {
    return Container(
      height: double.infinity,
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
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: kBorderColor),

          // Daftar item di keranjang (Sesuai gambar)
          Expanded(
            child: Column(
              children: [
                // Item "Mie" (Data dummy)
                _buildCartItemTile("Mie", "Rp.18.000,00", 1, "Rp. 18.000,00"),
                // Tambahkan item lain jika perlu
                const Spacer(), // Mendorong total ke bawah
                // Total (Bagian bawah)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTotalRow("Discount", "-Rp.0,00"),
                      _buildTotalRow("Subtotal", "Rp.18.000,00"),
                      _buildTotalRow("Tax", "+Rp.0,00"),
                      const Divider(height: 24),
                      _buildTotalRow("Total", "Rp.18.000,00", isTotal: true),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tombol "Print Receipt" di paling bawah
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Logika print final
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandColor,
                  foregroundColor: kWhiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )
                ),
                child: const Text("Print Receipt"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk item di keranjang (Panel Kanan)
  Widget _buildCartItemTile(String name, String price, int qty, String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nama & Harga
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: kDarkTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          // Qty
          Text(
            "Qty\n$qty",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              height: 1.4
            ),
          ),
          // Total Harga Item
          Text(
            total,
            style: const TextStyle(
              color: kDarkTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk baris Total
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