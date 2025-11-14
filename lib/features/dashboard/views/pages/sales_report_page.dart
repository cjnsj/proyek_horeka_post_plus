// Salin ke file baru:
// lib/features/dashboard/views/pages/sales_report_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';

class SalesReportPage extends StatelessWidget {
  const SalesReportPage({super.key});

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
        // Judul disembunyikan, karena tab akan menggantikannya
        title: const Text(""), // Kosong
        flexibleSpace: _buildTabs(), // Menggunakan Tab sebagai pengganti judul
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/print_kedua.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                kBrandColor, // Warna ungu
                BlendMode.srcIn,
              ),
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
            // 4. PANEL KANAN (DETAIL)
            Expanded(
              flex: 1, // Panel kanan lebih kecil
              child: _buildDetailsPanel(),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET UNTUK TAB DI APPBAR
  Widget _buildTabs() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        color: kWhiteColor,
        padding: const EdgeInsets.only(top: 40.0, left: 56.0), // Beri jarak untuk back button
        child: Row(
          children: [
            // Tab Aktif: Sales report
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: const BoxDecoration(
                color: kBrandColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: const Text(
                "Sales report",
                style: TextStyle(
                  color: kWhiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Tab Tidak Aktif
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: kWhiteColor,
                border: Border(
                  bottom: BorderSide(color: kBrandColor, width: 2),
                ),
              ),
              child: Text(
                "Item report",
                style: TextStyle(
                  color: kDarkTextColor.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Tab Tidak Aktif
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: kWhiteColor,
                border: Border(
                  bottom: BorderSide(color: kBrandColor, width: 2),
                ),
              ),
              child: Text(
                "Expenditure report",
                style: TextStyle(
                  color: kDarkTextColor.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          // Area Filter Tanggal & Void
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildDatePicker("Start date", "04-11-2025"),
                const SizedBox(width: 16),
                _buildDatePicker("Start date", "05-11-2025"), // Di gambar "Start date" lagi?
                const Spacer(),
                Checkbox(
                  value: false,
                  onChanged: (val) {},
                  activeColor: kBrandColor,
                ),
                const Text(
                  "Only void",
                  style: TextStyle(color: kDarkTextColor),
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
              ],
            ),
          ),
          
          const Divider(height: 1, color: kBorderColor),

          // Footer Total & Tombol Print
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Total
                Row(
                  children: [
                    Text(
                      "Total sales amount",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Rp.18.000,00",
                      style: TextStyle(
                        color: kDarkTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Tombol "Print sales report"
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Logika print report
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
                    child: const Text("Print sales report"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper untuk Date Picker palsu
  Widget _buildDatePicker(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kDarkTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w500
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 150,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kBorderColor)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(color: kDarkTextColor, fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.calendar_today_outlined, size: 18, color: kDarkTextColor),
            ],
          ),
        ),
      ],
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
          // Info Teks (ID, Tanggal)
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
              Text(
                dateTime,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          // Harga
          Text(
            price,
            style: const TextStyle(
              color: kDarkTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET UNTUK PANEL KANAN
  Widget _buildDetailsPanel() {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: Column(
        children: [
          // Header "Sales details"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Sales details",
                  style: TextStyle(
                      color: kDarkTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
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
                    "Please select a transaction", // Teks sesuai gambar
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          
          const Divider(height: 1, color: kBorderColor),

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
                child: const Text("Print receipt"),
              ),
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