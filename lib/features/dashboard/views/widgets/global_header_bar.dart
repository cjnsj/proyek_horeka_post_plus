// lib/features/dashboard/views/widgets/global_header_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';

class GlobalHeaderBar extends StatelessWidget {
  /// true  -> mode dashboard (card lebar, logo + teks + search)
  /// false -> mode laporan/pengaturan (card kecil persegi, hanya logo)
  final bool isExpandedMode;
  final ValueChanged<String>? onSearch;

  const GlobalHeaderBar({
    super.key,
    required this.isExpandedMode,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    // MODE LAPORAN/PENGATURAN: card kecil persegi, hanya logo
    if (!isExpandedMode) {
      return Align(
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: 75,
          height: 72,
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderColor, width: 1),
          ),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }

    // MODE DASHBOARD: card horizontal lebar (logo + teks + search)
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo + Teks Horeka Pos+
          Row(
            children: [
              Image.asset('assets/images/logo.png', height: 40),
              const SizedBox(width: 16),
              const Text(
                'Horeka Pos+',
                style: TextStyle(
                  color: kBrandColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Search bar
          SizedBox(
            width: 300,
            height: 40,
            child: TextField(
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Find menu',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SvgPicture.asset('assets/icons/search.svg'),
                ),
                filled: true,
                fillColor: kWhiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: kBrandColor,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
