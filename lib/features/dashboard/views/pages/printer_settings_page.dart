// Salin ke file baru:
// lib/features/dashboard/views/pages/printer_settings_page.dart

import 'package:flutter/material.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';

// Kita juga perlu import SideNavRail untuk menampilkannya
import 'package:horeka_post_plus/features/dashboard/views/widgets/side_nav_rail.dart';

class PrinterSettingsPage extends StatelessWidget {
  const PrinterSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      // 1. APP BAR (Header atas dengan Logo)
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 1,
        shadowColor: kBorderColor,
        automaticallyImplyLeading: false, // Menghilangkan tombol back
        titleSpacing: 24,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png', // Logo "H"
              height: 40,
            ),
            const SizedBox(width: 16),
            const Text(
              "Horeka Pos+",
              style: TextStyle(
                color: kBrandColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      // 2. BODY HALAMAN
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2a. SideNavRail (Navigasi Kiri)
            const SideNavRail(),
            const SizedBox(width: 24),
            
            // 2b. Panel Konten Utama (Printer Settings)
            Expanded(
              child: _buildSettingsPanel(),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET UNTUK PANEL KONTEN UTAMA
  Widget _buildSettingsPanel() {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      // Gunakan Clip.antiAlias agar header birunya pas
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Biru "Printer Settings"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: kBrandColor,
              // Radiusnya tidak perlu karena sudah di-clip parent
            ),
            child: const Text(
              "Printer Settings",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),

          // Konten di bawah header
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kolom Kiri: Save Printer
                  Expanded(
                    flex: 1,
                    child: _buildSavePrinterForm(),
                  ),
                  const SizedBox(width: 24),
                  
                  // Garis pemisah vertikal
                  const VerticalDivider(width: 1, thickness: 1, color: kBorderColor),
                  const SizedBox(width: 24),

                  // Kolom Kanan: Printer List
                  Expanded(
                    flex: 1,
                    child: _buildPrinterList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bagian Kiri: Form "Save Printer"
  Widget _buildSavePrinterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Save Printer",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkTextColor),
        ),
        const SizedBox(height: 24),
        _buildLabeledTextField("Nama Printer", "/dev/bus/usb/001/006"),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildLabeledTextField("Varian ID", "1305")),
            const SizedBox(width: 16),
            Expanded(child: _buildLabeledTextField("Product ID", "8211")),
          ],
        ),
        const SizedBox(height: 32),
        // Tombol-tombol
        Row(
          children: [
            // Tombol "Cancel"
            _buildButton("Cancel", const Color(0xFF797979), kWhiteColor),
            const SizedBox(width: 16),
            // Tombol "Printer Test"
            _buildButton("Printer Test", kBrandColor, kWhiteColor),
            const SizedBox(width: 16),
            // Tombol "Save Printer"
            _buildButton("Save Printer", kBrandColor, kWhiteColor),
          ],
        )
      ],
    );
  }
  
  // Bagian Kanan: "Printer List"
  Widget _buildPrinterList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         const Text(
          "Printer List",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkTextColor),
        ),
        const SizedBox(height: 24),
        // Printer for Receipt
        _buildPrinterListItem("Printer for Receipt", "Bluetooth Printer", true),
        const Divider(height: 32, color: kBorderColor),
        // Enable Kitchen Printer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Enable kitchen printer",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kDarkTextColor),
            ),
            Switch(
              value: false,
              onChanged: (val) {},
              activeColor: kBrandColor,
            )
          ],
        ),
        const SizedBox(height: 16),
        // Printer for Receipt (Kitchen)
        _buildPrinterListItem("Printer for Receipt", "Bluetooth Printer", false),
      ],
    );
  }

  // Widget helper untuk item di daftar printer
  Widget _buildPrinterListItem(String title, String subtitle, bool isFirst) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kDarkTextColor),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            "Choose Printer",
            style: TextStyle(color: kBrandColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Widget helper untuk Tombol (Cancel, Test, Save)
  Widget _buildButton(String text, Color bgColor, Color textColor) {
     return Expanded(
      child: SizedBox(
        height: 45,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            )
          ),
          child: Text(text),
        ),
      ),
    );
  }

  // Widget helper untuk Text Field
  Widget _buildLabeledTextField(String label, String hint) {
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
        SizedBox(
          height: 40,
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: kWhiteColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: kBorderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: kBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: kBrandColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}