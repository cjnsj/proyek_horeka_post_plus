// lib/features/dashboard/views/widgets/cart_panel.dart
// Salin dan Gantikan seluruh isi file ini

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';

// Cart BLoC
import 'package:horeka_post_plus/features/dashboard/controllers/cart_bloc/cart_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/controllers/cart_bloc/cart_state.dart';
import 'package:horeka_post_plus/features/dashboard/controllers/cart_bloc/cart_event.dart';

class CartPanel extends StatelessWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          return Column(
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/delete.svg',
                        width: 24,
                        height: 24,
                      ),
                      onPressed: cartState.isEmpty
                          ? null
                          : () {
                              context.read<CartBloc>().add(ClearCartEvent());
                            },
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: kBorderColor),

              // Konten Keranjang
              Expanded(
                child: cartState.isEmpty
                    ? _buildEmptyCart()
                    : _buildCartContent(context, cartState),
              ),

              // Bagian total + promo + tombol footer
              _buildTotalSection(context, cartState),
              _buildFooterButtons(context, cartState),
            ],
          );
        },
      ),
    );
  }

  // ================== STATE KOSONG ==================

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_circle_outline, color: kBrandColor, size: 25),
          SizedBox(height: 8),
          Text(
            "New Order",
            style: TextStyle(
              color: kDarkTextColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================== LIST ITEM CART ==================

  Widget _buildCartContent(BuildContext context, CartState cartState) {
    return Column(
      children: [
        const SizedBox(height: 4),
        const Divider(height: 1, color: kBorderColor),

        Expanded(
          child: ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: cartState.items.length,
            itemBuilder: (context, index) {
              final item = cartState.items[index];
              return _buildCartItemRow(context, item);
            },
          ),
        ),
      ],
    );
  }

  // Satu baris item cart (ikon + & - vertikal, Qty, Total)
 // Satu baris item cart (ikon + & - vertikal, Qty di atas angka, Total)
Widget _buildCartItemRow(BuildContext context, dynamic item) {
  final double itemTotal = item.totalPrice;

  return Column(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom ikon + dan - (vertikal)
          Column(
            children: [
              // Ikon tambah qty (BIRU)
              InkWell(
                onTap: () {
                  context.read<CartBloc>().add(
                        UpdateQuantityEvent(
                          item.productId,
                          item.quantity + 1,
                        ),
                      );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: kWhiteColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: kBrandColor,  // PLUS biru
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 16,
                    color: kBrandColor,  // PLUS biru
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Ikon kurang qty (MERAH, di bawah plus)
              InkWell(
                onTap: () {
                  if (item.quantity > 1) {
                    context.read<CartBloc>().add(
                          UpdateQuantityEvent(
                            item.productId,
                            item.quantity - 1,
                          ),
                        );
                  } else {
                    // Kalau quantity 1 dan dikurangi, hapus item dari cart
                    context
                        .read<CartBloc>()
                        .add(RemoveFromCartEvent(item.productId));
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: kWhiteColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red, // MINUS merah
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.remove,
                    size: 16,
                    color: Colors.red, // MINUS merah
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Nama + harga satuan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: kDarkTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Rp.${item.price}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Qty di atas angka (VERTIKAL)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Qty',
                style: TextStyle(
                  color: kDarkTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.quantity}',
                style: const TextStyle(
                  color: kDarkTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),

          // Total per item
          Text(
            'Rp. ${itemTotal.toStringAsFixed(2).replaceAll('.00', ',00')}',
            style: const TextStyle(
              color: kDarkTextColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Divider(height: 1, color: kBorderColor),
    ],
  );
}


  // ================== TOTAL & PROMO ==================

  Widget _buildTotalSection(BuildContext context, CartState cartState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Promo Code
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kBorderColor, width: 1),
              ),
              child: TextButton.icon(
                onPressed: cartState.isEmpty
                    ? null
                    : () {
                        _showPromoDialog(context);
                      },
                icon: SvgPicture.asset(
                  'assets/icons/promocode.svg',
                  width: 16,
                  height: 16,
                ),
                label: Text(
                  cartState.promoCode ?? "Promo Code",
                  style: const TextStyle(color: kDarkTextColor),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildTotalRow(
            "Discount",
            "-Rp.${cartState.discount.toStringAsFixed(2).replaceAll('.00', ',00')}",
          ),
          _buildTotalRow(
            "Subtotal",
            "Rp.${cartState.subtotal.toStringAsFixed(2).replaceAll('.00', ',00')}",
          ),
          _buildTotalRow(
            "Tax",
            "+Rp.${cartState.tax.toStringAsFixed(2).replaceAll('.00', ',00')}",
          ),
          const Divider(height: 24),
          _buildTotalRow(
            "Total",
            "Rp.${cartState.total.toStringAsFixed(2).replaceAll('.00', ',00')}",
            isTotal: true,
          ),
        ],
      ),
    );
  }

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

  void _showPromoDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Promo Code'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g., LOKAL123',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                context.read<CartBloc>().add(SetPromoCodeEvent(code));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  // ================== TOMBOL FOOTER ==================

  Widget _buildFooterButtons(BuildContext context, CartState cartState) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      child: Row(
        children: [
          _buildFooterButton(
            "Save Queue",
            backgroundColor:
                cartState.isEmpty ? Colors.grey.shade400 : Colors.grey.shade600,
            textColor: kWhiteColor,
            onTap: cartState.isEmpty
                ? null
                : () {
                    // TODO: implement Save Queue
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Save Queue: coming soon'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
          ),
          const SizedBox(width: 16),
          _buildFooterButton(
            "Pay Now",
            backgroundColor:
                cartState.isEmpty ? Colors.grey.shade400 : kBrandColor,
            textColor: kWhiteColor,
            onTap: cartState.isEmpty
                ? null
                : () {
                    // TODO: implement Pay Now (Step berikutnya)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pay Now: coming soon'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(
    String text, {
    required Color backgroundColor,
    required Color textColor,
    VoidCallback? onTap,
    bool pressed = false,
  }) {
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
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
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
