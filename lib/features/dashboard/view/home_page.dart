import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horeka_post_plus/features/auth/view/auth_page.dart';
import 'package:horeka_post_plus/features/dashboard/dialogs/expense_dialog.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';
import 'package:horeka_post_plus/features/dashboard/view/print_receipt_page.dart';
import 'package:horeka_post_plus/features/dashboard/view/printer_settings_page.dart';
import 'package:horeka_post_plus/features/dashboard/view/queue_list_page.dart';
import 'package:horeka_post_plus/features/dashboard/view/report_page.dart';
import 'package:horeka_post_plus/features/dashboard/dialogs/pin_kasir_dialog.dart';
import 'package:horeka_post_plus/features/dashboard/dialogs/starting_balance_dialog.dart';
import 'package:horeka_post_plus/features/dashboard/view/void_mode_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  bool _isPinVerified = false;
  bool _isBalanceSet = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPinDialog();
    });
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: kBrandColor.withOpacity(0.5),
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: PinKasirDialog(
          onPinVerified: () {
            setState(() {
              _isPinVerified = true;
            });
            Navigator.of(context).pop();
            _showStartingBalanceDialog();
          },
        ),
      ),
    );
  }

  void _showStartingBalanceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: kBrandColor.withOpacity(0.5),
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: StartingBalanceDialog(
          onBalanceSaved: () {
            setState(() {
              _isBalanceSet = true;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cartWidth = screenWidth >= 1200 ? 430.0 : screenWidth * 0.32;

    final canInteract = _isPinVerified && _isBalanceSet;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: !canInteract,
          child: Stack(
            children: [
              // Cart area (hanya muncul di index 0)
              if (_index == 0)
                Positioned.fill(
                  top: 16,
                  bottom: 16,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: cartWidth,
                      child: const _CartAreaFullScreen(),
                    ),
                  ),
                ),

              // Report page (index 1) - FULL SCREEN tanpa padding dari HomePage
              if (_index == 1) const Positioned.fill(child: ReportPage()),

              // Printer settings (index 2) - FULL SCREEN tanpa padding dari HomePage
              if (_index == 2)
                const Positioned.fill(child: PrinterSettingsPage()),

              // Header + Side Menu + Product Area dengan padding (untuk semua index)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    _TopHeaderGlobal(currentIndex: _index),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SideMenu(
                            index: _index,
                            onTap: (i) => setState(() => _index = i),
                          ),
                          const SizedBox(width: 16),
                          // Product area hanya muncul di index 0
                          if (_index == 0)
                            const Expanded(child: _ProductOnlyArea()),
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
    );
  }
}
// ================== PRODUCT AREA ==================

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
          Container(
            height: 56,
            decoration: const BoxDecoration(
              color: kBrandColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: const BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: const Text(
                'Makanan',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 210,
                  height: 170,
                  child: const _MenuCard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kWhiteColor,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/images/nodata.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Mie',
                    style: TextStyle(
                      color: kTextDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rp.18.000,00',
                    style: TextStyle(color: kTextGrey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
                  barrierDismissible:
                      false, // Tidak bisa tutup dialog dengan klik luar
                  barrierColor: kBrandColor.withOpacity(
                    0.5,
                  ), // Transparansi warna sesuai kebutuhan
                  builder: (context) => ExpenseDialog(
                    onSave: (desc, amount) {
                      // aksi simpan expense
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

  const _BottomButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

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
          SvgPicture.asset('assets/icons/delete.svg', width: 24, height: 24),
        ],
      ),
    );
  }
}

class _CartContent extends StatelessWidget {
  const _CartContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add_circle_outline, size: 28, color: kBrandColor),
                  SizedBox(height: 8),
                  Text(
                    'New Order',
                    style: TextStyle(
                      color: kTextGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
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
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    foregroundColor: kWhiteColor,
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text('Save Queue'),
                ),
              ),
              const SizedBox(width: 16),
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
                  onPressed: () {},
                  child: const Text('Pay Now'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        _SummaryRow(label: 'Discount', value: '-Rp.0,00'),
        _SummaryRow(label: 'Subtotal', value: 'Rp.0,00'),
        _SummaryRow(label: 'Tax', value: '+Rp.0,00'),
        _SummaryRow(label: 'Total', value: 'Rp.0,00', isBold: true),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: kTextGrey,
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
    return SizedBox(
      height: 32,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: kBorderColor),
        ),
        onPressed: () {},
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/promocode.svg',
              width: 16,
              height: 16,
            ),
            const SizedBox(width: 6),
            const Text(
              'Promo Code',
              style: TextStyle(
                color: kTextDark,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== SIDE MENU & HEADER ==================

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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: InkWell(
              onTap: () => onTap(0),
              child: SvgPicture.asset(
                'assets/icons/print.svg',
                height: 28,
                width: 28,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: InkWell(
              onTap: () => onTap(1),
              child: SvgPicture.asset(
                'assets/icons/document.svg',
                height: 28,
                width: 28,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: InkWell(
              onTap: () => onTap(2),
              child: SvgPicture.asset(
                'assets/icons/settings.svg',
                height: 22,
                width: 22,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 24, top: 8),
            child: InkWell(
              // pada onTap logout
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false, // harus tekan OK
                  builder: (context) => const _ShiftEndedDialog(),
                );

                if (shouldLogout == true) {
                  // TODO: clear token / shift / state di sini

                  // Arahkan ke halaman login utama (ganti sesuai routing kamu)
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthPage()),
                    (route) => false,
                  );
                }
              },

              child: SvgPicture.asset(
                'assets/icons/logout.svg',
                height: 28,
                width: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiftEndedDialog extends StatelessWidget {
  const _ShiftEndedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Overlay ungu transparan
        Positioned.fill(
          child: Container(
            color: kBrandColor.withOpacity(0.35),
          ),
        ),
        // Dialog putih di tengah
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
                  style: TextStyle(
                    color: kTextGrey,
                    fontSize: 14,
                  ),
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
                    onPressed: () {
                      Navigator.of(context).pop(true); // konfirmasi logout
                    },
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

    // Hitung lebar header berdasarkan halaman
    final headerWidth = isHomePage
        ? screenWidth *
              0.628 // Lebar penuh untuk home
        : 80.0; // Hanya logo untuk halaman lain

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
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
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
          const Text(
            'Horeka Pos+',
            style: TextStyle(
              color: kBrandColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(), // ⬅️ Gunakan Spacer agar fleksibel
          // Search box dengan flexible width
          Flexible(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 260, // Maksimal 260
                minWidth: 200, // Minimal 200
              ),
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
                        hintStyle: TextStyle(color: kTextGrey, fontSize: 14),
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
                      size: 20,
                    ),
                  ),
                ],
              ),
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
