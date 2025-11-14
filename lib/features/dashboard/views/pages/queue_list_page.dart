// Salin ke file baru:
// lib/features/dashboard/views/pages/queue_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';

class QueueListPage extends StatelessWidget {
  const QueueListPage({super.key});

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
          "Queue List",
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
            // 3. PANEL KIRI (LIST ANTRIAN)
            Expanded(
              flex: 2, // Panel kiri lebih besar
              child: _buildQueueListPanel(),
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
  Widget _buildQueueListPanel() {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // Menggunakan GridView seperti di gambar
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, // Perkiraan jumlah kolom
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5, // Kartu dibuat agak lebar
          ),
          itemCount: 1, // Hanya 1 item dummy
          itemBuilder: (context, index) {
            return _buildQueueTile("09", "Rp.18.000,00");
          },
        ),
      ),
    );
  }

  // Widget untuk satu item antrian
  Widget _buildQueueTile(String queueNumber, String price) {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            queueNumber,
            style: const TextStyle(
              color: kDarkTextColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
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

          // Tombol di paling bawah (Add/Edit & Pay Now)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Tombol "Add/Edit Item"
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Logika Add/Edit Item
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF797979), // Abu-abu
                        foregroundColor: kWhiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                      child: const Text("Add/Edit Item"),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Tombol "Pay Now"
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Logika Pay Now
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrandColor, // Biru
                        foregroundColor: kWhiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                      child: const Text("Pay Now"),
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