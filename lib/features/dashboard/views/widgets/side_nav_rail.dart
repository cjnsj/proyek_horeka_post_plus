// Salin dan Gantikan seluruh isi file
// lib/features/dashboard/views/widgets/side_nav_rail.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';
import 'package:horeka_post_plus/features/dashboard/views/pages/sales_report_page.dart';
import 'package:horeka_post_plus/features/dashboard/views/pages/printer_settings_page.dart';

class SideNavRail extends StatelessWidget {
  const SideNavRail({super.key});

  static const double _iconSize = 27.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: double.infinity,
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: Column(
        children: [
          const SizedBox(height: 64), 

          // Tombol Navigasi
          _buildNavIcon(
            'assets/icons/print.svg',
            onTap: () {
              // TODO: Tentukan navigasi untuk tombol "Print"
            }
          ),
          
          // ⭐️ 2. TAMBAHKAN AKSI ONTAP DI SINI ⭐️
          _buildNavIcon(
            'assets/icons/document.svg', // Ikon Laporan
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SalesReportPage()),
              );
            }
          ),
          
          _buildNavIcon(
            'assets/icons/settings.svg',
            customSize: 21.0,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrinterSettingsPage()),
              );
            }
          ),
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
              width: _iconSize,
              height: _iconSize,
            ),
          ),
          
        ],
      ),
    );
  }

  // ⭐️ 3. MODIFIKASI FUNGSI INI AGAR BISA DI-KLIK ⭐️
  Widget _buildNavIcon(String svgAsset, {
    bool isSelected = false, 
    double? customSize,
    VoidCallback? onTap, // Tambahkan parameter onTap
  }) {
    
    final double size = customSize ?? _iconSize;

    // Bungkus dengan InkWell agar bisa di-klik
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10), // Untuk efek ripple
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected ? kBrandColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(
          svgAsset,
          width: size,
          height: size,
        ),
      ),
    );
  }
}