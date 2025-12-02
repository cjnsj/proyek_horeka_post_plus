import 'package:flutter/material.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ReportLayout();
  }
}

// ================== LAYOUT UTAMA (LOGO KIRI, KONTEN KANAN) ==================

class _ReportLayout extends StatelessWidget {
  const _ReportLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _LogoColumn(),
        SizedBox(width: 16),
        Expanded(child: _ReportContentArea()),
      ],
    );
  }
}

// ================== LOGO COLUMN ==================

class _LogoColumn extends StatelessWidget {
  const _LogoColumn();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Align(
        alignment: const Alignment(-12, -0.94),
        child: const _LogoCard(),
      ),
    );
  }
}

class _LogoCard extends StatelessWidget {
  const _LogoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
      ),
      padding: const EdgeInsets.all(17.5),
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

// ================== AREA KONTEN KANAN ==================

class _ReportContentArea extends StatefulWidget {
  const _ReportContentArea();

  @override
  State<_ReportContentArea> createState() => _ReportContentAreaState();
}

class _ReportContentAreaState extends State<_ReportContentArea> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Card kiri: kalau tab 0 ada ruang untuk detail, kalau tab lain full
        Positioned(
          left: 12,
          top: 24,
          bottom: 24,
          // Jika tabIndex 0 (Sales report) sisakan ruang 380 + margin 24
          // Kalau tab lain, pakai full width (right: 24)
          right: _tabIndex == 0 ? 420 : 24,
          child: _SalesReportCard(
            tabIndex: _tabIndex,
            onTabChanged: (i) => setState(() => _tabIndex = i),
          ),
        ),

        // Card kanan (Sales details) hanya muncul di tab Sales report
        if (_tabIndex == 0)
          const Positioned(
            right: 24,
            top: 24,
            bottom: 24,
            width: 380,
            child: _SalesDetailCard(),
          ),
      ],
    );
  }
}
// ================== CARD LAPORAN KIRI ==================

class _SalesReportCard extends StatelessWidget {
  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  const _SalesReportCard({
    super.key,
    required this.tabIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs atas
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: kBrandColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => onTabChanged(0),
                    child: _ReportTab(
                      label: 'Sales report',
                      isActive: tabIndex == 0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => onTabChanged(1),
                    child: _ReportTab(
                      label: 'Item report',
                      isActive: tabIndex == 1,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => onTabChanged(2),
                    child: _ReportTab(
                      label: 'Expenditure report',
                      isActive: tabIndex == 2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Konten per tab
          Expanded(
            child: Builder(
              builder: (context) {
                if (tabIndex == 1) {
                  return const _ItemReportContent();
                } else if (tabIndex == 2) {
                  return const _ExpenditureReportContent();
                } else {
                  return const _SalesReportContent();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================== SALES REPORT CONTENT (TAB 0) ==================

class _SalesReportContent extends StatelessWidget {
  const _SalesReportContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _DateFilterColumn(label: 'Start date', value: '04-11-2025'),
              SizedBox(width: 32),
              _DateFilterColumn(label: 'End date', value: '05-11-2025'),
              SizedBox(width: 32),
              _VoidFilterColumn(),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: kBorderColor),
        // List transaksi
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, thickness: 1, color: kBorderColor),
              itemBuilder: (context, index) => const _SalesRowItem(),
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: kBorderColor),
        // Footer total + tombol
        Container(
          height: 70,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
          ),
          child: Row(
            children: const [
              SizedBox(width: 24),
              Text(
                'Total sales amount',
                style: TextStyle(color: kTextDark, fontWeight: FontWeight.w800),
              ),
              SizedBox(width: 8),
              Text(
                'Rp.18.000,00',
                style: TextStyle(color: kTextDark, fontWeight: FontWeight.w600),
              ),
              Spacer(),
              _PrintSalesReportButton(),
            ],
          ),
        ),
      ],
    );
  }
}

// ================== ITEM REPORT CONTENT (TAB 1) ==================

class _ItemReportContent extends StatelessWidget {
  const _ItemReportContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bar atas: Start / End / Filter (responsif)
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 700;

              if (isNarrow) {
                // Layout vertikal untuk layar sempit
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Expanded(
                          child: _ItemDateColumn(
                            label: 'Start Date',
                            value: '04-11-2025',
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _ItemDateColumn(
                            label: 'End Date',
                            value: '05-11-2025',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    _ItemVoidFilterRow(),
                  ],
                );
              }

              // Layout horizontal untuk layar lebar (seperti desain)
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _ItemDateColumn(label: 'Start Date', value: '04-11-2025'),
                  SizedBox(width: 40),
                  _ItemDateColumn(label: 'End Date', value: '05-11-2025'),
                  Spacer(),
                  _ItemVoidFilterRow(),
                ],
              );
            },
          ),
        ),
        const Divider(height: 1, thickness: 1, color: kBorderColor),
        // Header tabel
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          alignment: Alignment.centerLeft,
          child: const Row(
            children: [
              Expanded(
                flex: 6,
                child: Text(
                  'Item Name',
                  style: TextStyle(
                    color: kTextDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'Quantity Sold',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: kTextDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: kBorderColor),
        // Isi tabel (kosong)
        const Expanded(child: ColoredBox(color: kWhiteColor)),
        const Divider(height: 1, thickness: 1, color: kBorderColor),
        // Bottom bar (ikon print kiri + tombol kanan)
        Container(
          height: 64,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  // TODO: print langsung
                },
                icon: const Icon(
                  Icons.print,
                  color: Color(0xFF26A645),
                  size: 24,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrandColor,
                    foregroundColor: kWhiteColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    // TODO: print item-wise recap
                  },
                  child: const Text(
                    'Print Item-wise Sales Recap',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// helper untuk Item report
class _ItemDateColumn extends StatelessWidget {
  final String label;
  final String value;

  const _ItemDateColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kTextDark,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        _DisabledDateField(text: value),
      ],
    );
  }
}

class _ItemVoidFilterRow extends StatelessWidget {
  const _ItemVoidFilterRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Filter Void',
          style: TextStyle(
            color: kTextDark,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 18,
          height: 18,
          child: Checkbox(
            value: false,
            onChanged: (_) {},
            activeColor: kBrandColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Only void',
          style: TextStyle(color: kTextDark, fontSize: 13),
        ),
      ],
    );
  }
}

class _DisabledDateField extends StatelessWidget {
  final String text;

  const _DisabledDateField({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(text, style: const TextStyle(color: kTextGrey, fontSize: 13)),
    );
  }
}

// ================== EXPENDITURE PLACEHOLDER (TAB 2) ==================

class _ExpenditureReportContent extends StatelessWidget {
  const _ExpenditureReportContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bar atas: Start / End
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _ExpDateColumn(label: 'Start Date', value: '04-11-2025'),
              SizedBox(width: 40),
              _ExpDateColumn(label: 'End Date', value: '05-11-2025'),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: kBorderColor),

        // Header tabel
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          alignment: Alignment.centerLeft,
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Date',
                  style: TextStyle(
                    color: kTextDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'Notes',
                  style: TextStyle(
                    color: kTextDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Cashier',
                  style: TextStyle(
                    color: kTextDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Amount',
                  style: TextStyle(
                    color: kTextDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: kBorderColor),

        // Isi tabel (kosong dulu)
        const Expanded(child: ColoredBox(color: kWhiteColor)),

        const Divider(height: 1, thickness: 1, color: kBorderColor),

        // Footer total + ikon print + tombol
        Container(
          height: 64,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Row(
            children: [
              const Text(
                'Total of Expense',
                style: TextStyle(
                  color: kTextDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Rp.0,00',
                style: TextStyle(
                  color: kTextDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  // TODO: print detail pengeluaran
                },
                icon: const Icon(
                  Icons.print,
                  color: Color(0xFF26A645),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrandColor,
                    foregroundColor: kWhiteColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    // TODO: print summary of expense
                  },
                  child: const Text(
                    'Print Summary of Expense',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpDateColumn extends StatelessWidget {
  final String label;
  final String value;

  const _ExpDateColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: kTextDark,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          _DisabledDateField(text: value),
        ],
      ),
    );
  }
}

// ================== KOMPONEN UMUM SALES ==================

class _DateFilterColumn extends StatelessWidget {
  final String label;
  final String value;

  const _DateFilterColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kTextDark, fontSize: 12)),
        const SizedBox(height: 8),
        _DateBox(text: value),
      ],
    );
  }
}

class _VoidFilterColumn extends StatelessWidget {
  const _VoidFilterColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter Void',
          style: TextStyle(color: kTextDark, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            SizedBox(
              width: 18,
              height: 18,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  border: Border.fromBorderSide(
                    BorderSide(color: kBorderColor, width: 1.5),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Text('Only void', style: TextStyle(color: kTextDark, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _PrintSalesReportButton extends StatelessWidget {
  const _PrintSalesReportButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: SizedBox(
        width: 180,
        height: 40,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kBrandColor,
            foregroundColor: kWhiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () {},
          child: const Text('Print sales report'),
        ),
      ),
    );
  }
}

class _ReportTab extends StatelessWidget {
  final String label;
  final bool isActive;

  const _ReportTab({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? kWhiteColor : Colors.transparent,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? kBrandColor : kWhiteColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String text;

  const _DateBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 40,
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorderColor),
      ),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(color: kTextDark, fontSize: 12)),
    );
  }
}

class _SalesRowItem extends StatelessWidget {
  const _SalesRowItem();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'TR0511202510001',
                    style: TextStyle(
                      color: kTextDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '05-11-2025 09:13:15',
                    style: TextStyle(color: kTextGrey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Text(
              'Rp. 18.000,00',
              style: TextStyle(color: kTextDark, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ================== CARD DETAIL KANAN ==================

class _SalesDetailCard extends StatelessWidget {
  const _SalesDetailCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
      ),
      child: Column(
        children: [
          Container(
            height: 52,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              border: Border(bottom: BorderSide(color: kBorderColor, width: 1)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Sales details',
              style: TextStyle(color: kTextDark, fontWeight: FontWeight.w600),
            ),
          ),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline, color: kBrandColor, size: 28),
                  SizedBox(height: 8),
                  Text(
                    'Please select a transaction',
                    style: TextStyle(color: kTextGrey),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 70,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
              border: Border(top: BorderSide(color: kBorderColor, width: 1)),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: SizedBox(
              width: 160,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandColor,
                  foregroundColor: kWhiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {},
                child: const Text('Print receipt'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
