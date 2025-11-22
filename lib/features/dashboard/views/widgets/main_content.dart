// lib/features/dashboard/views/widgets/main_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horeka_post_plus/models/cart_item.dart';
import 'package:horeka_post_plus/features/dashboard/controllers/cart_bloc/cart_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/controllers/cart_bloc/cart_event.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';
import 'package:horeka_post_plus/features/dashboard/views/pages/void_mode_page.dart';
import 'package:horeka_post_plus/features/dashboard/views/pages/print_receipt_page.dart';
import 'package:horeka_post_plus/features/dashboard/views/dialogs/expense_dialog.dart';
import 'package:horeka_post_plus/features/dashboard/views/pages/queue_list_page.dart';
import 'package:horeka_post_plus/features/dashboard/controllers/menu_bloc/menu_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/controllers/menu_bloc/menu_state.dart';

class MainContent extends StatefulWidget {
  const MainContent({super.key});

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  // Base URL untuk gambar (dari API Anda)
  final String _imageBaseUrl = "http://192.168.1.15:3001";

  // Kategori yang sedang dipilih (null = "All Menu")
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    const int columns = 4;
    const double cardAspectRatio = 1.3;

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
                  child: const Center(child: CircularProgressIndicator()),
                );
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

                // Ekstrak kategori unik dari products
                final List<String> categories = _extractCategories(state.products);

                // Filter produk sesuai kategori yang dipilih
                final List<dynamic> filteredProducts = _selectedCategory == null
                    ? state.products
                    : state.products
                        .where((p) => p['category'] == _selectedCategory)
                        .toList();

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
                      // HEADER UNGU + TAB KATEGORI
                      _buildCategoryTabs(categories),

                      const Divider(height: 1, thickness: 1, color: kBorderColor),

                      // GRID PRODUK
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
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
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

  /// Ekstrak kategori unik dari list produk
  List<String> _extractCategories(List<dynamic> products) {
    final Set<String> categorySet = {};
    for (var p in products) {
      final cat = p['category'];
      print('DEBUG CATEGORY: $cat'); // <-- TAMBAHKAN INI
      if (cat != null && cat.toString().isNotEmpty) {
        categorySet.add(cat.toString());
      }
    }
    return categorySet.toList()..sort();
  }

  /// Widget header ungu + tab kategori
  Widget _buildCategoryTabs(List<String> categories) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8.0),
      decoration: const BoxDecoration(
        color: kBrandColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(11),
          topRight: Radius.circular(11),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16.0),
        child: Row(
          children: [
            // Tab "All Menu"
            _buildCategoryTab(
              label: 'All Menu',
              isActive: _selectedCategory == null,
              onTap: () {
                setState(() {
                  _selectedCategory = null;
                });
              },
            ),
            const SizedBox(width: 16),

            // Tab kategori dinamis dari API
            ...categories.map((cat) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _buildCategoryTab(
                  label: cat,
                  isActive: _selectedCategory == cat,
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// Widget satu tab kategori
  Widget _buildCategoryTab({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? kWhiteColor : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? kDarkTextColor : kWhiteColor,
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
Widget _buildProductCard(dynamic product) {
  final String productId = product['product_id'] ?? '';
  final String productName = product['name'] ?? 'Produk';
  final String productPrice = product['price']?.toString() ?? '0';
  final String? imagePath = product['image_url'];
  final String? category = product['category'];

  String fullImageUrl = '';
  if (imagePath != null && imagePath.isNotEmpty) {
    final String cleanPath = imagePath.replaceAll(r'\', '/');
    fullImageUrl = '$_imageBaseUrl/$cleanPath';
  }

  Widget imageWidget;
  if (fullImageUrl.isEmpty) {
    imageWidget = Image.asset(
      'assets/images/nodata.png',
      fit: BoxFit.cover,
    );
  } else {
    imageWidget = Image.network(
      fullImageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
            child: CircularProgressIndicator(strokeWidth: 2));
      },
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/nodata.png',
          fit: BoxFit.cover,
        );
      },
    );
  }

  return GestureDetector(
    onTap: () {
      // TAMBAHKAN PRODUK KE CART
      final cartItem = CartItem(
        productId: productId,
        name: productName,
        price: productPrice,
        imageUrl: imagePath,
        category: category,
      );
      
      context.read<CartBloc>().add(AddToCartEvent(cartItem));
    },
    child: Card(
      elevation: 6.0,
      shadowColor: Colors.black.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 10,
            right: 10,
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
                          shadows: [
                            Shadow(
                                blurRadius: 2,
                                color: Colors.black54,
                                offset: Offset(1, 1))
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Rp. $productPrice",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          shadows: [
                            Shadow(
                                blurRadius: 1,
                                color: Colors.black54,
                                offset: Offset(1, 1))
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  'assets/icons/tambah.svg',
                  width: 18,
                  height: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  /// Widget footer dengan tombol aksi
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
                    builder: (context) => const PrintReceiptPage()),
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

  /// Widget satu tombol footer
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
              offset: const Offset(0, 2),
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
