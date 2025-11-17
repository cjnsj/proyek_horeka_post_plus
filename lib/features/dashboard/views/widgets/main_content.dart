// Salin dan Gantikan seluruh isi file
// lib/features/dashboard/views/widgets/main_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';
import 'package:horeka_post_plus/features/dashboard/views/pages/void_mode_page.dart';
import 'package:horeka_post_plus/features/dashboard/views/pages/print_receipt_page.dart';
import 'package:horeka_post_plus/features/dashboard/views/dialogs/expense_dialog.dart';
import 'package:horeka_post_plus/features/dashboard/views/pages/queue_list_page.dart';

import 'package:horeka_post_plus/features/dashboard/controllers/menu_bloc/menu_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/controllers/menu_bloc/menu_state.dart';

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  // Base URL untuk gambar (dari API Anda)
  final String _imageBaseUrl = "http://192.168.1.15:3001";

  @override
  Widget build(BuildContext context) {
    const int columns = 4;
    
    // Menggunakan rasio aspek 1.2 (sedikit lebih tinggi)
    const double cardAspectRatio = 1.2; 

    return Column(
      children: [
        Expanded(
          child: BlocBuilder<MenuBloc, MenuState>(
            builder: (context, state) {
              if (state is MenuLoading || state is MenuInitial) {
                return Container(
                    decoration: BoxDecoration(
                      color: kWhiteColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorderColor, width: 1),
                    ),
                    child: const Center(child: CircularProgressIndicator()));
              }

              if (state is MenuError) {
                return Container(
                  decoration: BoxDecoration(
                    color: kWhiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorderColor, width: 1),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Failed to load menu: ${state.message}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                );
              }

              if (state is MenuLoaded) {
                if (state.products.isEmpty) {
                  return Container(
                    decoration: BoxDecoration(
                      color: kWhiteColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorderColor, width: 1),
                    ),
                    child: const Center(
                      child: Text("No menu items available."),
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: kWhiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorderColor, width: 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                "All Menu",
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
                      const Divider(
                          height: 1, thickness: 1, color: kBorderColor),
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
                            itemCount: state.products.length,
                            itemBuilder: (context, index) {
                              final product = state.products[index];
                              return _buildProductCard(product);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const Center(child: Text("Unknown state."));
            },
          ),
        ),
        _buildFooterButtons(context),
        const SizedBox(height: 16),
      ],
    );
  }

  // --- FUNGSI _buildProductCard SESUAI KODE YANG ANDA BERIKAN ---
  Widget _buildProductCard(dynamic product) {
    final String productName = product['name'] ?? 'Produk';
    final String productPrice = product['price']?.toString() ?? '0';
    
    // Asumsikan key-nya 'image_url'
    final String? imagePath = product['image_url']; 
    
    String fullImageUrl = '';
    
    if (imagePath != null && imagePath.isNotEmpty) {
      // Ganti backslash (\) menjadi forward slash (/)
      final String cleanPath = imagePath.replaceAll(r'\', '/');
      
      // Tambahkan '/' secara manual di antara base URL dan path
      fullImageUrl = '$_imageBaseUrl/$cleanPath';
    }
    
    Widget imageWidget;
    if (fullImageUrl.isEmpty) {
      // Jika tidak ada URL, gunakan placeholder
      imageWidget = Image.asset(
        'assets/images/nodata.png', // Gambar dummy/placeholder
        fit: BoxFit.cover,
      );
    } else {
      // Jika ada URL, coba muat dari jaringan
      imageWidget = Image.network(
        fullImageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child; 
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (context, error, stackTrace) {
          // Kita sudah print dari log, tapi ini baik untuk safety
          print("Gagal memuat gambar: $fullImageUrl, Error: $error");
          return Image.asset(
            'assets/images/nodata.png', // Gambar dummy/placeholder
            fit: BoxFit.cover,
          );
        },
      );
    }

    // Menggunakan desain Card dari kode yang Anda berikan
    return Card(
      elevation: 2.0, // <-- Desain bayangan Anda
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageWidget,
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
                color: Colors.black.withOpacity(0.65), // <-- Desain kontainer teks Anda
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
                          productName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Rp. $productPrice",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset( // <-- Desain tombol tambah Anda
                    'assets/icons/tambah.svg',
                    width: 18,
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
  // --- AKHIR FUNGSI _buildProductCard ---


  Widget _buildFooterButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFooterButton(
            "Void Mode",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VoidModePage()),
              );
            },
          ),
          _buildFooterButton(
            "Print Receipt",
            onPressed: () {
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
          onTap: onPressed,
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