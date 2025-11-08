// Salin dan Gantikan seluruh isi file
// lib/features/dashboard/views/widgets/side_nav_rail.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_page.dart';

class SideNavRail extends StatelessWidget {
  const SideNavRail({super.key});

  // Ukuran default untuk semua ikon
  static const double _iconSize = 25.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        children: [
          // Jarak dari atas
          const SizedBox(height: 64), 

          // Tombol Navigasi
          _buildNavIcon('assets/icons/print.svg'),
          _buildNavIcon('assets/icons/document.svg'),
          
          // Kita berikan ukuran khusus yang lebih kecil untuk 'settings'
          _buildNavIcon('assets/icons/settings.svg', customSize: 20.0), // <--- Dikecilkan

          const Spacer(), // Mendorong item ke bawah
          Container(
            margin: const EdgeInsets.only(top: 34.0, bottom: 0.0), 
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(
              'assets/icons/logout.svg',
              width: _iconSize, // <--- Tetap 30
              height: _iconSize, // <--- Tetap 30
            ),
          ),
          
        ],
      ),
    );
  }

  // ⭐️ PERUBAHAN DI SINI ⭐️
  // Fungsi ini diubah untuk menerima 'customSize'
  Widget _buildNavIcon(String svgAsset, {bool isSelected = false, double? customSize}) {
    
    // Gunakan customSize jika ada, jika tidak, pakai _iconSize
    final double size = customSize ?? _iconSize;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isSelected ? kBrandColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SvgPicture.asset(
        svgAsset,
        // ⭐️ Menggunakan 'size' ⭐️
        width: size,
        height: size,
      ),
    );
  }
}