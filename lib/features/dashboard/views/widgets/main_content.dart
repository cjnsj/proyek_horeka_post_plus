// Salin dan Gantikan seluruh isi file
// lib/features/dashboard/views/widgets/main_content.dart

import 'package:flutter/material.dart';
// ⭐️ PERUBAHAN 1: Import dashboard_page.dart untuk kBorderColor ⭐️
import 'package:horeka_post_plus/features/dashboard/views/dashboard_page.dart';

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Panel Konten
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: kWhiteColor,
              borderRadius: BorderRadius.circular(12),
              // ⭐️ PERUBAHAN 2: Menggunakan kBorderColor ⭐️
              border: Border.all(color: kBorderColor, width: 1), // Diubah dari Colors.black
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tab "Makanan"
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    color: kBrandColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        "Makanan",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
                // Grid Menu
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: 1, // Hanya 1 item "Mie"
                      itemBuilder: (context, index) {
                        return _buildProductCard();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Tombol Footer
        _buildFooterButtons(),

        // Memberi jarak 16px di bawah tombol footer
        const SizedBox(height: 16),
      ],
    );
  }

  // Card untuk "Mie"
  Widget _buildProductCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // ⭐️ PERUBAHAN 3: Menggunakan kBorderColor ⭐️
        side: const BorderSide(color: kBorderColor, width: 1), // Diubah dari Colors.black
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/Rectangle 5.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Rp.18.000,00",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: kBrandColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Mie",
              style: TextStyle(
                  color: kDarkTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Tombol di bawah panel menu
  Widget _buildFooterButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFooterButton("Void Mode"),
          _buildFooterButton("Print Receipt"),
          _buildFooterButton("Expense"),
          _buildFooterButton("Queue List"),
        ],
      ),
    );
  }

  Widget _buildFooterButton(String text, {bool pressed = false}) {
    final Color bgColor = pressed ? const Color(0xFFEFEFEF) : kWhiteColor;
    
    final List<BoxShadow> boxShadow = pressed
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 1,
              offset: const Offset(0, 1),
            )
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              blurRadius: 1,
              offset: const Offset(0, 2), // Shadow 3D
            )
          ];

    return Expanded(
      child: Padding(
        // Kita tambahkan padding horizontal yang lebih besar (misal 16)
        // 4.0 (spasi antar tombol) + 12.0 (padding tambahan) = 16.0
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Diubah dari 4.0
        child: InkWell(
          onTap: () {
            // Logika klik bisa ditambahkan di sini
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              // ⭐️ PERUBAHAN 4: Menggunakan kBorderColor ⭐️
              border: Border.all(color: kBorderColor, width: 1), // Diubah dari Colors.black
              boxShadow: boxShadow,
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: pressed ? kDarkTextColor.withOpacity(0.7) : kDarkTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}