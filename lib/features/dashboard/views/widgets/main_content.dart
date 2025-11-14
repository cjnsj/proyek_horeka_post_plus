// Salin dan Gantikan seluruh isi file
// lib/features/dashboard/views/widgets/main_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';
import 'package:horeka_post_plus/features/dashboard/views/pages/void_mode_page.dart';
import 'package:horeka_post_plus/features/dashboard/views/pages/print_receipt_page.dart';
import 'package:horeka_post_plus/features/dashboard/views/dialogs/expense_dialog.dart';
import 'package:horeka_post_plus/features/dashboard/views/pages/queue_list_page.dart';

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Pengaturan Grid (biarkan)
    const int columns = 4;
    const double cardAspectRatio = 1.3;

    return Column(
      children: [
        // Panel Konten
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: kWhiteColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorderColor, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tab "Makanan"
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8.0),
                  decoration: const BoxDecoration(
                    color: kBrandColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(11),
                      topRight: Radius.circular(11),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 16.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        decoration: const BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Makanan",
                          style: TextStyle(
                            color: kDarkTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Outline di bawah tab
                const Divider(height: 1, thickness: 1, color: kBorderColor),

                // Grid Menu
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: cardAspectRatio,
                          ),
                      itemCount: 1,
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

        // ⭐️ 2. KIRIM CONTEXT KE FUNGSI INI ⭐️
        _buildFooterButtons(context), // Kirim context
        // Memberi jarak 16px di bawah tombol footer
        const SizedBox(height: 16),
      ],
    );
  }

  // KARTU PRODUK (Tidak berubah)
  Widget _buildProductCard() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/Rectangle 5.png', // Ganti dengan path gambar Mie
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                stops: const [0.0, 0.8],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Mie",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Rp.18.000,00",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/icons/tambah.svg', // Pastikan path ini benar
                    width: 18, // Ukuran diubah agar mudah di-tap
                    height: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFooterButtons(BuildContext context) {
    // Terima context
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol "Void Mode" sekarang punya aksi
          _buildFooterButton(
            "Void Mode",
            onPressed: () {
              // Navigasi ke halaman baru
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VoidModePage()),
              );
            },
          ),
          _buildFooterButton(
            "Print Receipt",
            onPressed: () {
              // ⭐️ NAVIGASI BARU DITAMBAHKAN DI SINI ⭐️
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrintReceiptPage(),
                ),
              );
            },
          ),
          _buildFooterButton(
            "Expense",
            onPressed: () {
              // ⭐️ INI ADALAH LOGIKA BARU ⭐️
              showDialog(
                context: context,
                barrierDismissible: false,
                barrierColor: const Color(0xFF4C45B5).withOpacity(0.4),
                builder: (BuildContext dialogContext) {
                  return const ExpenseDialog();
                },
              );
            },
          ),
          _buildFooterButton(
            "Queue List",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QueueListPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ===========================================
  // ⭐️ FUNGSI INI JUGA DIPERBARUI (Menerima onPressed) ⭐️
  // ===========================================
  Widget _buildFooterButton(
    String text, {
    required VoidCallback onPressed,
    bool pressed = false,
  }) {
    final Color bgColor = pressed ? const Color(0xFFEFEFEF) : kWhiteColor;

    final List<BoxShadow> boxShadow = pressed
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              blurRadius: 1,
              offset: const Offset(0, 2), // Shadow 3D
            ),
          ];

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: InkWell(
          onTap: onPressed, // Gunakan callback onPressed
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kBorderColor, width: 1),
              boxShadow: boxShadow,
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: pressed
                      ? kDarkTextColor.withOpacity(0.7)
                      : kDarkTextColor,
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
