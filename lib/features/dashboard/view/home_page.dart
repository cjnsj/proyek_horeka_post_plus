import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:horeka_post_plus/core/constants/app_constants.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_bloc.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_event.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_state.dart';
import 'package:horeka_post_plus/features/auth/view/auth_page.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_event.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_state.dart';
import 'package:horeka_post_plus/features/dashboard/data/model/cart_model.dart';
import 'package:horeka_post_plus/features/dashboard/data/product_model.dart';
import 'package:horeka_post_plus/features/dashboard/dialogs/expense_dialog.dart';
import 'package:horeka_post_plus/features/dashboard/dialogs/pin_kasir_dialog.dart';
import 'package:horeka_post_plus/features/dashboard/dialogs/promo_code_dialog.dart';
import 'package:horeka_post_plus/features/dashboard/dialogs/save_queue_dialog.dart';
import 'package:horeka_post_plus/features/dashboard/dialogs/starting_balance_dialog.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';
import 'package:horeka_post_plus/features/dashboard/view/pembayaran.dart';
import 'package:horeka_post_plus/features/dashboard/view/print_receipt_page.dart';
import 'package:horeka_post_plus/features/dashboard/view/printer_settings_page.dart';
import 'package:horeka_post_plus/features/dashboard/view/queue_list_page.dart';
import 'package:horeka_post_plus/features/dashboard/view/report_page.dart';
import 'package:horeka_post_plus/features/dashboard/view/void_mode_page.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  // [PERBAIKAN] Flag untuk mencegah dialog muncul tumpuk
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    print('🚀 [DEBUG UI] HomePage initState berjalan. Memanggil DashboardStarted...'); // <--- DEBUG 7
    context.read<DashboardBloc>().add(DashboardStarted());
  }


  void _showPinDialog() {
    if (_isDialogShowing) return; // Safety check
    setState(() => _isDialogShowing = true);

    final authBloc = context.read<AuthBloc>();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: kBrandColor.withOpacity(0.5),
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: PinKasirDialog(
          onPinSubmitted: (pin) {
            authBloc.add(ValidatePinRequested(pin: pin));
            // Dialog akan ditutup oleh BlocListener saat status success
          },
        ),
      ),
    ).then((_) {
      if (mounted) setState(() => _isDialogShowing = false); // Reset Flag saat tutup
    });
  }

  void _showStartingBalanceDialog(String cashierId) {
    if (_isDialogShowing) return; // Safety check
    setState(() => _isDialogShowing = true);

    final authBloc = context.read<AuthBloc>();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: kBrandColor.withOpacity(0.5),
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: StartingBalanceDialog(
          onBalanceSaved: (amount) {
            if (!mounted) return;
            authBloc.add(
              OpenShiftRequested(cashierId: cashierId, openingCash: amount),
            );
            // Dialog akan ditutup oleh BlocListener saat status success
          },
        ),
      ),
    ).then((_) {
      if (mounted) setState(() => _isDialogShowing = false); // Reset Flag saat tutup
    });
  }

@override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cartWidth = screenWidth >= 1200 ? 430.0 : screenWidth * 0.32;

    return MultiBlocListener(
      listeners: [
        // --- 1. Listener Auth ---
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            print("🔔 [LISTENER AUTH] Status: ${state.status}, ShiftOpen: ${state.isShiftOpen}");
            
            if (state.status == AuthStatus.error) {
              final isPinError = state.errorMessage?.toLowerCase().contains('pin') == true;
              if (!isPinError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage ?? 'Terjadi kesalahan'), backgroundColor: Colors.red),
                );
              }
            }

            // PIN Sukses -> Saldo
            if (state.status == AuthStatus.success && state.isPinValidated && !state.isShiftOpen) {
              print("✅ [LOGIC] PIN Valid. Menutup dialog PIN & Buka Dialog Saldo.");
              if (_isDialogShowing) Navigator.of(context).pop();
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) _showStartingBalanceDialog(state.tempCashierId ?? '');
              });
            }

            // Shift Sukses
            if (state.status == AuthStatus.success && state.isShiftOpen) {
              print("✅ [LOGIC] Shift Terbuka! Simpan Sesi & Fetch Menu.");
              if (_isDialogShowing) Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shift berhasil dibuka!'), backgroundColor: Colors.green),
              );
              context.read<DashboardBloc>().add(SaveDashboardSession());
              context.read<DashboardBloc>().add(FetchMenuRequested());
            }

            // Logout
            if (state.status == AuthStatus.success && !state.isAuthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthPage()), (route) => false,
              );
            }
          },
        ),

        // --- 2. Listener Dashboard ---
        BlocListener<DashboardBloc, DashboardState>(
          listener: (context, state) {
            print("🔔 [LISTENER DASHBOARD] Status: ${state.status}, PinEntered: ${state.isPinEntered}");

            // Cek Sesi
            if (state.status == DashboardStatus.success) {
              final authState = context.read<AuthBloc>().state;
              if (!state.isPinEntered && !authState.isShiftOpen) {
                print("⚠️ [LOGIC] Sesi belum ada & Shift belum buka -> Show PIN Dialog");
                _showPinDialog();
              }
            }
            // Toasts...
            if (state.status == DashboardStatus.expenseSuccess) Fluttertoast.showToast(msg: "Pengeluaran Berhasil!", backgroundColor: Colors.green);
            if (state.status == DashboardStatus.queueSuccess) Fluttertoast.showToast(msg: "Antrian Disimpan!", backgroundColor: Colors.blue);
            if (state.status == DashboardStatus.error) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'Error'), backgroundColor: Colors.red));
          },
        ),
      ],
      // UI Builder
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, dashboardState) {
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              
              // LOGIKA LOADING (Penyebab Terkunci)
              final bool isAuthLoading = authState.status == AuthStatus.loading;
              final bool isDashLoading = dashboardState.status == DashboardStatus.loading;
              final bool isLoading = isAuthLoading || isDashLoading;

              // PRINT DEBUG UI SETIAP KALI REBUILD
              // Perhatikan log ini di console!
              print("🎨 [BUILD UI] ------------------------------------------------");
              print("   -> Auth Status      : ${authState.status} (Loading? $isAuthLoading)");
              print("   -> Dashboard Status : ${dashboardState.status} (Loading? $isDashLoading)");
              print("   -> Is Shift Open    : ${authState.isShiftOpen}");
              print("   -> Is Pin Entered   : ${dashboardState.isPinEntered}");
              print("   -> FINAL IS LOADING : $isLoading (Jika TRUE, Layar Terkunci!)");
              print("---------------------------------------------------------------");

              return Stack(
                children: [
                  Scaffold(
                    backgroundColor: kBackgroundColor,
                    resizeToAvoidBottomInset: false,
                    // [PENTING] AbsorbPointer DIHAPUS. Interaksi diatur oleh ModalBarrier di bawah.
                    body: SafeArea(
                      child: Stack(
                        children: [
                          if (_index == 0)
                            Positioned.fill(
                              top: 16, bottom: 16,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: SizedBox(width: cartWidth, child: const _CartAreaFullScreen()),
                              ),
                            ),
                          if (_index == 1) const Positioned.fill(child: ReportPage()),
                          if (_index == 2) const Positioned.fill(child: PrinterSettingsPage()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                            child: Column(
                              children: [
                                _TopHeaderGlobal(currentIndex: _index),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _SideMenu(index: _index, onTap: (i) => setState(() => _index = i)),
                                      const SizedBox(width: 16),
                                      if (_index == 0) const Expanded(child: _ProductOnlyArea()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // [OVERLAY LOADING]
                  // Jika isLoading == true, widget ini muncul menutupi layar -> Klik tidak tembus
                  // [OVERLAY LOADING: HANYA SPINNER]
                  if (isLoading)
                    Stack(
                      children: [
                        // Tembok transparan (tetap ada agar layar tidak bisa diklik)
                        const ModalBarrier(dismissible: false, color: Colors.black38),
                        
                        // Spinner langsung di tengah tanpa kotak putih
                        const Center(
                          child: CircularProgressIndicator(color: kBrandColor),
                        ),
                      ],
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ================== AREA PRODUK ==================

class _ProductOnlyArea extends StatelessWidget {
  const _ProductOnlyArea();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final productWidth = screenWidth * 0.582;

    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: productWidth,
              child: const _ProductAreaCombined(),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const _BottomActionsBar(),
      ],
    );
  }
}

class _ProductAreaCombined extends StatelessWidget {
  const _ProductAreaCombined();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6, top: 4, bottom: 4, right: 38),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER KATEGORI
          Container(
            height: 45,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: kBrandColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state.categories.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Memuat...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    final isSelected = category == state.selectedCategory;

                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: InkWell(
                        onTap: () {
                          context.read<DashboardBloc>().add(
                                SelectCategory(category),
                              );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? kWhiteColor : Colors.transparent,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(),
                              Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? kBrandColor
                                      : Colors.white.withOpacity(0.8),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                Container(
                                  height: 3,
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 0),
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(2),
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(height: 3),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // GRID PRODUK
          Expanded(
            child: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state.status == DashboardStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: kBrandColor),
                  );
                } else if (state.status == DashboardStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.errorMessage ?? 'Gagal memuat menu',
                          style: const TextStyle(color: kTextGrey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<DashboardBloc>().add(
                                FetchMenuRequested(),
                              ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                } else if (state.filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 48,
                          color: kTextGrey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada produk di kategori "${state.selectedCategory}"',
                          style: const TextStyle(color: kTextGrey),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    itemCount: state.filteredProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                    ),
                    itemBuilder: (context, index) {
                      final product = state.filteredProducts[index];
                      return _MenuCard(product: product);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final ProductModel product;

  const _MenuCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    const double cardRadius = 16.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl.startsWith('http')
                        ? product.imageUrl
                        : '${AppConstants.apiBaseUrl.replaceAll('/api', '')}/${product.imageUrl}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/nodata.png',
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset('assets/images/nodata.png', fit: BoxFit.cover),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatter.format(product.price),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: InkWell(
                onTap: () {
                  context.read<DashboardBloc>().add(AddToCart(product));
                },
                child: SvgPicture.asset(
                  'assets/icons/tambah.svg',
                  width: 21,
                  height: 21,
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(cardRadius),
                  onTap: () {
                    context.read<DashboardBloc>().add(AddToCart(product));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== [WIDGETS LAIN] ==================

class _BottomActionsBar extends StatelessWidget {
  const _BottomActionsBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: SizedBox(
        height: 55,
        child: Row(
          children: [
            _BottomButton(
              label: 'Void Mode',
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const VoidModePage()));
              },
            ),
            const SizedBox(width: 27),
            _BottomButton(
              label: 'Print Receipt',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PrintReceiptPage()),
                );
              },
            ),
            const SizedBox(width: 27),
            _BottomButton(
              label: 'Expense',
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  barrierColor: kBrandColor.withOpacity(0.5),
                  builder: (context) => ExpenseDialog(
                    // Update parameter callback
                    onSave: (desc, amount, imagePath) {
                      final cleanAmount = amount.replaceAll(
                        RegExp(r'[^0-9]'),
                        '',
                      );
                      final intAmount = int.tryParse(cleanAmount) ?? 0;

                      if (intAmount > 0 && desc.isNotEmpty) {
                        context.read<DashboardBloc>().add(
                              CreateExpenseRequested(
                                description: desc,
                                amount: intAmount,
                                imagePath: imagePath, // Teruskan path gambar
                              ),
                            );
                      }
                    },
                  ),
                );
              },
            ),
            const SizedBox(width: 27),
            _BottomButton(
              label: 'Queue List',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QueueListPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _BottomButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kWhiteColor,
          foregroundColor: kTextDark,
          elevation: 4,
          shadowColor: kBrandColor.withOpacity(0.25),
          minimumSize: const Size.fromHeight(55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

// ================== CART AREA ==================

class _CartAreaFullScreen extends StatelessWidget {
  const _CartAreaFullScreen();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        margin: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: kCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _CartHeader(),
            Expanded(child: _CartContent()),
          ],
        ),
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 73,
      decoration: const BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        border: Border(bottom: BorderSide(color: kBorderColor, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Cart',
            style: TextStyle(
              color: kTextDark,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/delete.svg',
              width: 24,
              height: 24,
            ),
            onPressed: () => context.read<DashboardBloc>().add(ClearCart()),
          ),
        ],
      ),
    );
  }
}

// --- BAGIAN INI YANG DIUBAH (SMART SAVE QUEUE) ---
class _CartContent extends StatelessWidget {
  const _CartContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state.cartItems.isEmpty) {
          return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text('Keranjang Kosong', style: TextStyle(color: kTextGrey)),
                ],
              ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.cartItems.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = state.cartItems[index];
                  return _CartItemRow(item: item);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: const _PromoCodeButton(),
              ),
            ),
            const SizedBox(height: 26),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _SummaryColumn(),
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: kBorderColor),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  // TOMBOL SAVE QUEUE (SMART LOGIC)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // Warna Oranye jika Edit Mode, Abu jika New Mode
                        backgroundColor: state.editingQueue != null
                            ? Colors.orange.shade700
                            : Colors.grey.shade400,
                        foregroundColor: kWhiteColor,
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        // 1. Cek Cart Kosong
                        if (state.cartItems.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Keranjang masih kosong!'),
                            ),
                          );
                          return;
                        }

                        // 2. CEK MODE EDIT ATAU BARU?
                        if (state.editingQueue != null) {
                          // --- MODE EDIT: UPDATE LANGSUNG (BYPASS DIALOG) ---
                          context.read<DashboardBloc>().add(
                                SaveQueueRequested(
                                  // Pakai data lama dari antrian yang sedang diedit
                                  tableNumber: state.editingQueue!.customerName,
                                  waiterName: "",
                                  orderNotes: state.editingQueue!.note,
                                ),
                              );
                        } else {
                          // --- MODE BARU: TAMPILKAN DIALOG ---
                          final result = await showDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: kBrandColor.withOpacity(0.5),
                            builder: (context) => const SaveQueueDialog(),
                          );

                          if (result != null && result is Map) {
                            context.read<DashboardBloc>().add(
                                  SaveQueueRequested(
                                    tableNumber: result['tableNumber'] ?? '',
                                    waiterName: result['waiterName'] ?? '',
                                    orderNotes: result['orderNotes'] ?? '',
                                  ),
                                );
                          }
                        }
                      },
                      // Ubah teks tombol sesuai mode
                      child: Text(state.editingQueue != null
                          ? 'Update Queue'
                          : 'Save Queue'),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // TOMBOL PAY NOW
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrandColor,
                        foregroundColor: kWhiteColor,
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PaymentPage(),
                          ),
                        );
                      },
                      child: const Text('Pay Now'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItem item;
  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 2,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  InkWell(
                    onTap: () => context.read<DashboardBloc>().add(
                          AddToCart(item.product),
                        ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: kBrandColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => context.read<DashboardBloc>().add(
                          RemoveFromCart(item.product),
                        ),
                    child: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: kTextDark,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Qty',
                    style: TextStyle(fontSize: 11, color: kTextGrey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: kTextDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Text(
                formatter.format(item.subtotal),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: kTextDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final subtotal = state.totalAmount;
        final discount = state.discountAmount; // Ambil nilai diskon dari State
        final total = state.finalTotalAmount;  // Ambil total akhir (Subtotal - Diskon)
        final tax = state.taxValue;            // [BARU] Pajak Real dari State
      

        final formatter = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Subtotal (Harga Barang)
            _SummaryRow(
              label: 'Subtotal', 
              value: formatter.format(subtotal)
            ),
            
            // 2. Diskon (Hanya muncul jika nilai diskon > 0)
            if (discount > 0)
              _SummaryRow(
                label: 'Discount (${state.appliedPromoCode ?? 'Promo'})',
                value: '- ${formatter.format(discount)}', // Tanda minus agar jelas
                textColor: Colors.green, // Warna hijau agar menonjol
              )
            else
              // Opsional: Jika ingin tetap menampilkan baris diskon meski 0
              const _SummaryRow(
                label: 'Discount', 
                value: 'Rp 0', 
                textColor: kTextGrey
              ),

            // 3. [UPDATE] Tax (Pajak) - Menggunakan Data Real
            _SummaryRow(
              // Jika ada pajak > 0%, tampilkan labelnya, misal: "Tax (11%)"
              label: state.taxPercentage > 0 
                  ? 'Tax (${state.taxPercentage.toStringAsFixed(0)}%)' 
                  : 'Tax',
              value: formatter.format(tax), 
            ),

            
            // 4. Total Akhir
            _SummaryRow(
              label: 'Total',
              value: formatter.format(total), // Total yang sudah dikurangi diskon
              isBold: true,
            ),
          ],
        );
      },
    );
  }
}
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? textColor; // [BARU] Tambahkan properti ini

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.textColor, // [BARU] Tambahkan di constructor
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      // Gunakan textColor jika ada, jika tidak gunakan kTextGrey (default)
      color: textColor ?? kTextGrey, 
      fontSize: 13,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
class _PromoCodeButton extends StatelessWidget {
  const _PromoCodeButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final hasPromo = state.appliedPromoCode != null;
        final activeColor = Colors.green;

        return SizedBox(
          height: 32,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(
                color: hasPromo ? activeColor : kBorderColor,
              ),
              backgroundColor: hasPromo ? activeColor.withOpacity(0.1) : null,
            ),
            onPressed: () {
              if (hasPromo) {
                // Hapus promo
                context.read<DashboardBloc>().add(RemovePromoCode());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Kode promo dihapus")),
                );
              } else {
                // Input promo (Panggil Dialog Baru)
                _showPromoInput(context);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/promocode.svg',
                  width: 16,
                  height: 16,
                  colorFilter: hasPromo 
                      ? ColorFilter.mode(activeColor, BlendMode.srcIn) 
                      : null,
                ),
                const SizedBox(width: 6),
                Text(
                  hasPromo ? state.appliedPromoCode! : 'Promo Code',
                  style: TextStyle(
                    color: hasPromo ? activeColor : kTextDark,
                    fontSize: 11,
                    fontWeight: hasPromo ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                if (hasPromo) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.close, size: 14, color: activeColor)
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  // [UPDATE] Menggunakan PromoCodeDialog yang baru
  void _showPromoInput(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: kBrandColor.withOpacity(0.5), // Efek overlay sesuai style app
      builder: (ctx) {
        return PromoCodeDialog(
          onApplyPromo: (code) {
            // Panggil Bloc saat tombol Enter ditekan
            context.read<DashboardBloc>().add(ApplyPromoCode(code));
          },
        );
      },
    );
  }
}
 
class _SideMenu extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _SideMenu({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kCardShadow,
      ),
      child: Column(
        children: [
          const SizedBox(height: 110),
          
          // --- Menu 1: Print ---
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onTap(0),
              // [PERBAIKAN] Padding dipindah ke dalam InkWell agar area sentuh luas
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                child: SvgPicture.asset(
                  'assets/icons/print.svg',
                  height: 28,
                  width: 28,
                  // Opsional: Beri warna jika sedang aktif (index == 0)
                  
                ),
              ),
            ),
          ),

          // --- Menu 2: Report ---
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onTap(1),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                child: SvgPicture.asset(
                  'assets/icons/document.svg',
                  height: 28,
                  width: 28,
                  
                ),
              ),
            ),
          ),

          // --- Menu 3: Settings ---
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onTap(2),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                child: SvgPicture.asset(
                  'assets/icons/settings.svg',
                  height: 22, // Ukuran asli icon settings
                  width: 22,
                
                ),
              ),
            ),
          ),

          const Spacer(),

          // --- Logout ---
          Padding(
            padding: const EdgeInsets.only(bottom: 24, top: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const _ShiftEndedDialog(),
                  );

                  if (shouldLogout == true) {
                    // ignore: use_build_context_synchronously
                    context.read<AuthBloc>().add(CloseShiftRequested());
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Padding untuk area sentuh
                  child: SvgPicture.asset(
                    'assets/icons/logout.svg',
                    height: 28,
                    width: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _ShiftEndedDialog extends StatelessWidget {
  const _ShiftEndedDialog();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
            child: Container(color: kBrandColor.withOpacity(0.35))),
        Center(
          child: Container(
            width: 420,
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 28),
            decoration: BoxDecoration(
              color: kWhiteColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Your shift has ended !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kTextDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please log in to start the next shift.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kTextGrey, fontSize: 14),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 160,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandColor,
                      foregroundColor: kWhiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TopHeaderGlobal extends StatelessWidget {
  final int currentIndex;

  const _TopHeaderGlobal({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isHomePage = currentIndex == 0;
    final headerWidth = isHomePage ? screenWidth * 0.628 : 80.0;

    return Align(
      alignment: Alignment.centerLeft,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        height: 80,
        width: headerWidth,
        child: Container(
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: kCardShadow,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: isHomePage
                ? _HeaderFullContent(key: const ValueKey('full'))
                : _HeaderLogoOnly(key: const ValueKey('logo')),
          ),
        ),
      ),
    );
  }
}

class _HeaderFullContent extends StatelessWidget {
  const _HeaderFullContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.png',
              width: 45,
              height: 45,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          
          // Judul (Bungkus Flexible agar bisa mengecil jika sempit)
          const Flexible(
            child: Text(
              'Horeka Pos+',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: kBrandColor,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          
          const Spacer(), // Pemisah fleksibel
          
          // Search Bar
          // [PERBAIKAN] Ubah Flexible ke Expanded atau sesuaikan constraints
          Container(
            // Hapus minWidth: 200 agar tidak overflow di layar kecil
            constraints: const BoxConstraints(maxWidth: 260), 
            height: 48,
            decoration: BoxDecoration(
              color: kWhiteColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: kCardShadow,
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Find menu',
                      hintStyle: TextStyle(color: kTextGrey, fontSize: 13), // Perkecil font sedikit
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: kBrandColor,
                  ),
                  child: const Icon(
                    Icons.search,
                    color: kWhiteColor,
                    size: 18, // Perkecil icon sedikit
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderLogoOnly extends StatelessWidget {
  const _HeaderLogoOnly({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/logo.png',
          width: 45,
          height: 45,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}