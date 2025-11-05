import 'package:flutter/material.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_page.dart';

class SideNavRail extends StatelessWidget {
  const SideNavRail({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: double.infinity,
      color: kWhiteColor,
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          // Logo
          Image.asset(
            'assets/images/logo.png', // Pastikan path logo "H" benar
            height: 60,
          ),
          const SizedBox(height: 40),
          
          // Tombol Navigasi
          _buildNavIcon(Icons.print_outlined, isSelected: true),
          _buildNavIcon(Icons.description_outlined),
          _buildNavIcon(Icons.tune_outlined), // Ikon 'Settings'
          
          const Spacer(), // Mendorong item ke bawah
          
          // Tombol Logout
          _buildNavIcon(Icons.logout_outlined),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isSelected ? kBrandColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 30,
        color: isSelected ? kBrandColor : Colors.grey.shade600,
      ),
    );
  }
}