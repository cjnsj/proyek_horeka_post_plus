// lib/features/dashboard/views/widgets/side_nav_rail.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';

class SideNavRail extends StatelessWidget {
  const SideNavRail({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  /// 0 = Dashboard, 1 = Laporan, 2 = Pengaturan
  final int selectedIndex;

  /// Dipanggil ketika item diklik, mengirim index ke DashboardPage
  final ValueChanged<int> onItemSelected;

  static const double _iconSize = 27.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,                    // LEBAR FIX – tidak berubah
      height: double.infinity,      // Tinggi mengikuti kolom kiri
      padding: const EdgeInsets.only(top: 96.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: Column(
        children: [

          // HOME / MENU UTAMA
          _buildNavIcon(
            'assets/icons/print.svg',
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),

          // LAPORAN PENJUALAN
          _buildNavIcon(
            'assets/icons/document.svg',
            isSelected: selectedIndex == 1,
            onTap: () => onItemSelected(1),
          ),

          // PENGATURAN / PRINTER SETTINGS
          _buildNavIcon(
            'assets/icons/settings.svg',
            customSize: 21.0,
            isSelected: selectedIndex == 2,
            onTap: () => onItemSelected(2),
          ),

          const Spacer(),

          // TOMBOL LOGOUT (statis, tanpa aksi dulu)
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

  // Widget ikon navigasi tunggal
  Widget _buildNavIcon(
    String svgAsset, {
    bool isSelected = false,
    double? customSize,
    VoidCallback? onTap,
  }) {
    final double size = customSize ?? _iconSize;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
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
