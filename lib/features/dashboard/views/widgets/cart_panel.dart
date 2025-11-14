// Salin dan Gantikan seluruh isi file
// lib/features/dashboard/views/widgets/cart_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // <--- IMPORT BARU

// ⭐️ PERUBAHAN: Ganti import 'dashboard_page.dart' dengan 'dashboard_constants.dart' ⭐️
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';

class CartPanel extends StatelessWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        // Border abu-abu
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: Column(
        children: [
          // Header Keranjang
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
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/delete.svg',
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Garis Divider abu-abu
          const Divider(height: 1, color: kBorderColor),

          // Konten Keranjang (Kosong)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline,
                      color: kBrandColor, size: 25),
                  const SizedBox(height: 8),
                  const Text(
                    "New Order",
                    style: TextStyle(
                        color: kDarkTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Total
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Discount/Promo Code Button
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), // Padding di sekitar TextButton
                    decoration: BoxDecoration(
                      color: kWhiteColor, // Latar belakang putih
                      borderRadius: BorderRadius.circular(8), // Sudut membulat
                      border: Border.all(color: kBorderColor, width: 1), // Outline abu-abu
                    ),
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        'assets/icons/promocode.svg',
                        width: 16,
                        height: 16,
                      ),
                      label: const Text(
                        "Promo Code", // Mengganti "Discount" menjadi "Promo Code"
                        style: TextStyle(color: kDarkTextColor),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, // Menghilangkan padding default TextButton
                        minimumSize: Size.zero, // Mengurangi ukuran minimum
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Membuat area tap sesuai konten
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildTotalRow("Discount", "-Rp.0,00"),
                _buildTotalRow("Subtotal", "Rp.0,00"),
                _buildTotalRow("Tax", "+Rp.0,00"),
                const Divider(height: 24),
                _buildTotalRow("Total", "Rp.0,00", isTotal: true),
              ],
            ),
          ),

          // Tombol Bayar
          Padding(
            // Padding luar untuk merampingkan tombol
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: Row(
              children: [
                // Tombol "Save Queue"
                _buildFooterButton(
                  "Save Queue",
                  backgroundColor: Colors.grey.shade600,
                  textColor: kWhiteColor,
                ),
                const SizedBox(width: 16),
                // Tombol "Pay Now"
                _buildFooterButton(
                  "Pay Now",
                  backgroundColor: kBrandColor,
                  textColor: kWhiteColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi ini meniru style 3D dari tombol "Void Mode"
  Widget _buildFooterButton(
    String text, {
    required Color backgroundColor,
    required Color textColor,
    bool pressed = false,
  }) {
    // Logika shadow 3D
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
              offset: const Offset(0, 2), 
            )
          ];

    return Expanded(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          // Padding dalam untuk tinggi tombol
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: boxShadow,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold, // Dibuat BOLD
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi _buildTotalRow tidak berubah
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