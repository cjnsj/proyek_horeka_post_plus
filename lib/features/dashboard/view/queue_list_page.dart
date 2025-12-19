import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horeka_post_plus/core/utils/toast_utils.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_event.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_state.dart';
import 'package:horeka_post_plus/features/dashboard/data/queue_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/cart_model.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';
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
    // Fetch data terbaru saat halaman dibuka
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
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

// ================== BAGIAN KIRI (LIST ANTRIAN) ==================

class _LeftQueueList extends StatelessWidget {
  final QueueModel? selectedQueue;
  final Function(QueueModel) onQueueSelected;

  const _LeftQueueList({
    super.key, // [Opsional] Tambahkan super.key best practice
    required this.selectedQueue,
    required this.onQueueSelected,
  });

  // --- [LOGIKA FORMAT SHIFT DARI ANDA] ---
  String _formatShiftName(String apiName) {
    if (apiName.isEmpty) return "";
    
    String lowerApiName = apiName.toLowerCase();
    
    // Logika mapping manual
    if (lowerApiName.contains('shift 1') || lowerApiName.contains('pagi')) {
      return "Shift 1";
    }
    if (lowerApiName.contains('shift 2') || lowerApiName.contains('siang')) {
      return "Shift 2";
    }
    if (lowerApiName.contains('shift 3') || lowerApiName.contains('sore')) {
      return "Shift 3";
    }
    if (lowerApiName.contains('shift 4') || lowerApiName.contains('malam')) {
      return "Shift 4";
    }
    
    // Default: Ambil kata sebelum tanda kurung (jika ada)
    return apiName.split('(').first.trim();
  }

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
            
            int total = queue.items.fold(0, (sum, item) => sum + item.subtotal);

            // [PERUBAHAN DISINI]
            // 1. Format dulu nama shiftnya
            String cleanShiftName = _formatShiftName(queue.shiftName);
            
            // 2. Gabungkan dengan nama kasir (Format: Shift 1_Rinta)
            // Jika shift kosong, tampilkan nama kasir saja. Jika kasir kosong, tampilkan shift saja.
            String shiftInfo = "";
            if (cleanShiftName.isNotEmpty && queue.cashierName.isNotEmpty) {
             shiftInfo = "$cleanShiftName\n${queue.cashierName}";
            } else {
               shiftInfo = cleanShiftName + queue.cashierName; // Salah satu pasti kosong atau keduanya isi
            }
            
            // Fallback jika keduanya kosong
            if (shiftInfo.trim().isEmpty) shiftInfo = "No Info";

            return _QueueCard(
              queueNumber: queue.customerName,
              amount: formatter.format(total),
              shiftInfo: shiftInfo, // Hasil gabungan yang sudah diformat
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
  final String queueNumber;
  final String amount;
  final String shiftInfo;
  final bool isSelected;
  final VoidCallback onTap;

  const _QueueCard({
    required this.queueNumber,
    required this.amount,
    required this.shiftInfo,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Kiri: Nomor Antrian & Total Harga
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  queueNumber, 
                  style: const TextStyle(
                    color: kTextDark,
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  amount, 
                  style: const TextStyle(
                    color: kTextGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            
            // Kanan: Info Shift (Shift 1_Rinta)
            Text(
              shiftInfo,
              textAlign: TextAlign.center, // <--- UBAH JADI CENTER
              style: const TextStyle(
                color: kTextGrey, 
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.2, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== BAGIAN KANAN (DETAIL CART) ==================

class _RightCartArea extends StatelessWidget {
  final QueueModel? selectedQueue;

  const _RightCartArea({required this.selectedQueue});

  @override
  Widget build(BuildContext context) {
    // Tampilan Saat Belum Ada Antrian Dipilih
    if (selectedQueue == null) {
      return Column(
        children: [
          _buildHeader("Cart"),
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
    int total = items.fold(0, (sum, item) => sum + item.subtotal);
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader("Cart"),
        const Divider(height: 1, thickness: 1, color: kBorderColor),

        // Bagian Note (Tampil di atas list item seperti gambar)
        // Bagian Note (Scrollable)
        if (selectedQueue!.note.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kBorderColor)),
            ),
            width: double.infinity, 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Note :", 
                  style: TextStyle(
                    color: kTextDark, 
                    fontWeight: FontWeight.w600, 
                    fontSize: 14
                  )
                ),
                const SizedBox(height: 8),
                
                // --- PERUBAHAN DI SINI ---
                Container(
                  // Batasi tinggi maksimal sekitar 60px (cukup untuk ~2.5 baris)
                  // Jika teks lebih dari 2 baris, user bisa scroll di dalam kotak ini.
                  constraints: const BoxConstraints(
                    maxHeight: 60, 
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      selectedQueue!.note,
                      style: const TextStyle(
                        color: kTextGrey, 
                        fontSize: 14, 
                        height: 1.5 // Jarak antar baris agar mudah dibaca
                      ),
                    ),
                  ),
                ),
                // -------------------------
              ],
            ),
          ),
        // List Item
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              return _QueueItemRow(item: items[index]);
            },
          ),
        ),

        // Total
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: kBorderColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total", style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600, fontSize: 16)),
              Text(formatter.format(total), style: const TextStyle(color: Colors.black,fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
        ),
        
        // Tombol Aksi
        _BottomButtonsBar(selectedQueue: selectedQueue!),
      ],
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      height: 60,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        title,
        style: const TextStyle(
          color: kTextDark,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
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
        // Nama Produk
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
              // Menampilkan Harga Satuan kecil di bawah nama
              Text(
                formatter.format(item.product.price),
                style: const TextStyle(fontSize: 12, color: kTextGrey),
              ),
            ],
          ),
        ),
        
        // Qty
        // Qty (Tengah)
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Label "Qty" di atas
              const Text(
                "Qty",
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold, 
                  color: kTextDark
                ),
              ),
              const SizedBox(height: 4), // Jarak sedikit
              // Nilai Quantity
              Text(
                "${item.quantity}",
                style: const TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w500, 
                  color: kTextDark
                ),
              ),
            ],
          ),
        ),
        // Subtotal Item
        Expanded(
          flex: 3,
          child: Container(
            alignment: Alignment.centerRight,
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
                  backgroundColor: kBrandColor,
                  foregroundColor: kWhiteColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  context.read<DashboardBloc>().add(LoadQueueRequested(selectedQueue));
                  Navigator.of(context).pop();
                  ToastUtils.showInfoToast('Item dimuat ke keranjang.');
                },
                child: const Text('Add/Edit Item', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Tombol Pay Now (Brand Color)
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandColor,
                  foregroundColor: kWhiteColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Load item ke dashboard dan tutup dialog queue
                  context.read<DashboardBloc>().add(LoadQueueRequested(selectedQueue));
                  Navigator.of(context).pop();
                },
                child: const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
