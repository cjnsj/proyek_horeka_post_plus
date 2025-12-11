import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_event.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_state.dart';
import 'package:horeka_post_plus/features/dashboard/data/queue_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/cart_model.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';
import 'package:horeka_post_plus/features/dashboard/view/pembayaran.dart'; // [BARU] Import PaymentPage
import 'package:intl/intl.dart';

class QueueListPage extends StatefulWidget {
  const QueueListPage({super.key});

  @override
  State<QueueListPage> createState() => _QueueListPageState();
}

class _QueueListPageState extends State<QueueListPage> {
  QueueModel? _selectedQueue;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(FetchQueueListRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: kWhiteColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: kCardShadow,
            ),
            child: Column(
              children: [
                const _QueueHeaderBar(),
                const Divider(height: 1, thickness: 1, color: kBorderColor),
                Expanded(
                  child: _QueueBody(
                    selectedQueue: _selectedQueue,
                    onQueueSelected: (queue) {
                      setState(() {
                        _selectedQueue = queue;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QueueHeaderBar extends StatelessWidget {
  const _QueueHeaderBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, size: 24),
            color: Colors.black,
          ),
          const SizedBox(width: 8),
          const Text(
            'Queue List',
            style: TextStyle(
              color: kBrandColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              context.read<DashboardBloc>().add(FetchQueueListRequested());
            },
            icon: const Icon(Icons.print, color: Colors.green, size: 28),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _QueueBody extends StatelessWidget {
  final QueueModel? selectedQueue;
  final Function(QueueModel) onQueueSelected;

  const _QueueBody({
    required this.selectedQueue,
    required this.onQueueSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // KIRI: DAFTAR ANTRIAN
        Expanded(
          flex: 48,
          child: _LeftQueueList(
            selectedQueue: selectedQueue,
            onQueueSelected: onQueueSelected,
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1, color: kBorderColor),
        // KANAN: DETAIL ANTRIAN (Style CART)
        Expanded(
          flex: 52,
          child: _RightCartArea(selectedQueue: selectedQueue),
        ),
      ],
    );
  }
}

// ================== BAGIAN KIRI (LIST) ==================

class _LeftQueueList extends StatelessWidget {
  final QueueModel? selectedQueue;
  final Function(QueueModel) onQueueSelected;

  const _LeftQueueList({
    required this.selectedQueue,
    required this.onQueueSelected,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp.', decimalDigits: 2);

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state.status == DashboardStatus.loading) {
          return const Center(child: CircularProgressIndicator(color: kBrandColor));
        }
        
        if (state.queueList.isEmpty) {
          return const Center(
            child: Text('Belum ada antrian tersimpan', style: TextStyle(color: kTextGrey)),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: state.queueList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final queue = state.queueList[index];
            final isSelected = selectedQueue?.id == queue.id;
            
            // Hitung total manual dari items
            int total = queue.items.fold(0, (sum, item) => sum + item.subtotal);

            return _QueueCard(
              customerName: queue.customerName,
              amount: formatter.format(total),
              note: queue.note,
              isSelected: isSelected,
              onTap: () => onQueueSelected(queue),
            );
          },
        );
      },
    );
  }
}

class _QueueCard extends StatelessWidget {
  final String customerName;
  final String amount;
  final String note;
  final bool isSelected;
  final VoidCallback onTap;

  const _QueueCard({
    required this.customerName,
    required this.amount,
    required this.note,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? kBrandColor : kBorderColor;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customerName,
              style: const TextStyle(
                color: kTextDark,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: const TextStyle(
                color: kTextGrey,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                "Note: $note",
                style: const TextStyle(color: kTextGrey, fontSize: 12),
                maxLines: 1, 
                overflow: TextOverflow.ellipsis,
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// ================== BAGIAN KANAN (DETAIL SEPERTI CART) ==================

class _RightCartArea extends StatelessWidget {
  final QueueModel? selectedQueue;

  const _RightCartArea({required this.selectedQueue});

  @override
  Widget build(BuildContext context) {
    if (selectedQueue == null) {
      return Column(
        children: [
          Container(
            height: 48,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text('Cart', style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const Divider(height: 1, thickness: 1, color: kBorderColor),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app_outlined, size: 48, color: kTextGrey),
                  SizedBox(height: 12),
                  Text('Pilih antrian di kiri untuk melihat detail', style: TextStyle(color: kTextGrey)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final items = selectedQueue!.items;
    int subtotal = items.fold(0, (sum, item) => sum + item.subtotal);
    
    double discount = 0;
    double tax = 0;
    double total = subtotal - discount + tax;

    return Column(
      children: [
        // Header "Cart"
        Container(
          height: 48,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Text(
            'Cart',
            style: TextStyle(
              color: kTextDark,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: kBorderColor),
        
        // List Item
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _QueueItemRow(item: items[index]);
            },
          ),
        ),

        // Summary & Buttons
        _SummaryPanel(
          subtotal: subtotal.toDouble(),
          discount: discount,
          tax: tax,
          total: total,
        ),
        _BottomButtonsBar(selectedQueue: selectedQueue!),
      ],
    );
  }
}

class _QueueItemRow extends StatelessWidget {
  final CartItem item;

  const _QueueItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 2);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kiri: Nama Produk & Harga Satuan
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: kTextDark
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatter.format(item.product.price),
                style: const TextStyle(fontSize: 12, color: kTextGrey),
              ),
            ],
          ),
        ),
        
        // Tengah: Qty Label & Value
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Qty",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark),
              ),
              const SizedBox(height: 4),
              Text(
                "${item.quantity}",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kTextDark),
              ),
            ],
          ),
        ),

        // Kanan: Total Harga
        Expanded(
          flex: 3,
          child: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(top: 0), 
            child: Text(
              formatter.format(item.subtotal),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: kTextDark),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double tax;
  final double total;

  const _SummaryPanel({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: kBorderColor, width: 1)),
      ),
      child: Column(
        children: [
          _summaryRow("Discount", "-${formatter.format(discount)}"),
          const SizedBox(height: 8),
          _summaryRow("Subtotal", formatter.format(subtotal)),
          const SizedBox(height: 8),
          _summaryRow("Tax", "+${formatter.format(tax)}"),
          const SizedBox(height: 8),
          _summaryRow("Total", formatter.format(total), isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label, 
          style: TextStyle(
            fontSize: 14, 
            color: kTextDark,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400
          )
        ),
        Text(
          value, 
          style: TextStyle(
            fontSize: 14, 
            color: isTotal ? kTextDark : kTextGrey,
             fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400
          )
        ),
      ],
    );
  }
}

class _BottomButtonsBar extends StatelessWidget {
  final QueueModel selectedQueue;

  const _BottomButtonsBar({required this.selectedQueue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          // Tombol Add/Edit Item (Abu-abu)
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600, // Warna abu-abu
                  foregroundColor: kWhiteColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Load ke keranjang (Dashboard) untuk diedit
                  context.read<DashboardBloc>().add(
                        LoadQueueRequested(selectedQueue),
                      );
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item dimuat ke keranjang untuk diedit.'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text(
                  'Add/Edit Item',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Tombol Pay Now (Ungu / Brand Color)
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandColor, // Warna Ungu
                  foregroundColor: kWhiteColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // [MODIFIKASI] Navigasi Langsung ke Halaman Pembayaran
                onPressed: () {
                  // 1. Load data antrian ke State Cart (Bloc)
                  context.read<DashboardBloc>().add(
                        LoadQueueRequested(selectedQueue),
                      );
                  
                  // 2. Pindah Halaman: Ganti QueueList dengan PaymentPage
                  // Menggunakan pushReplacement agar user tidak kembali ke list antrian saat back
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentPage(),
                    ),
                  );
                },
                child: const Text(
                  'Pay Now',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}