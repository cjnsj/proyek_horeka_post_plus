import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_event.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_state.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ReportLayout();
  }
}

// ================== LAYOUT UTAMA ==================

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

// ================== CONTENT AREA ==================

class _ReportContentArea extends StatefulWidget {
  const _ReportContentArea();

  @override
  State<_ReportContentArea> createState() => _ReportContentAreaState();
}

class _ReportContentAreaState extends State<_ReportContentArea> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(FetchAllReportsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 12,
          top: 24,
          bottom: 24,
          right: _tabIndex == 0 ? 420 : 24,
          child: _SalesReportCard(
            tabIndex: _tabIndex,
            onTabChanged: (i) => setState(() => _tabIndex = i),
          ),
        ),
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

// ================== CARD LAPORAN UTAMA ==================

class _SalesReportCard extends StatelessWidget {
  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  const _SalesReportCard({required this.tabIndex, required this.onTabChanged});

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
          // Tabs
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

          // Content
          Expanded(
            child: Builder(
              builder: (context) {
                if (tabIndex == 1) return const _ItemReportContent();
                if (tabIndex == 2) return const _ExpenditureReportContent();
                return const _SalesReportContent();
              },
            ),
          ),
        ],
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

// ================== SALES REPORT (TAB 0) ==================

class _SalesReportContent extends StatelessWidget {
  const _SalesReportContent();

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final bloc = context.read<DashboardBloc>();
    final state = bloc.state;
    final initialDate = isStart
        ? (state.reportStartDate ?? DateTime.now())
        : (state.reportEndDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      if (isStart) {
        bloc.add(
          ReportDateChanged(
            startDate: picked,
            endDate: state.reportEndDate ?? DateTime.now(),
          ),
        );
      } else {
        bloc.add(
          ReportDateChanged(
            startDate: state.reportStartDate ?? DateTime.now(),
            endDate: picked,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final report = state.salesReport;
        final allTransactions = report?.transactions ?? [];
        List<dynamic> filteredTransactions;

        // [LOGIKA FILTER BARU]
        if (state.isReportVoidFilter) {
          // Jika "Only Void" dicentang: Tampilkan yg SUDAH VOID atau SEDANG REQUEST
          filteredTransactions = allTransactions.where((tx) {
            final status = tx['status'];
            return status == 'VOIDED' || status == 'VOID_REQUESTED';
          }).toList();
        } else {
          // Jika TIDAK dicentang: Tampilkan yang BERHASIL (COMPLETED)
          filteredTransactions = allTransactions.where((tx) {
            final status = tx['status'];
            return status == 'COMPLETED';
          }).toList();
        }

        // Hitung ulang total berdasarkan list yang tampil
        int displayTotalSales = filteredTransactions.fold(0, (sum, tx) {
          final raw = tx['total_amount'].toString();
          return sum +
              (int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0);
        });

        // Format Tanggal
        final startStr = state.reportStartDate != null
            ? DateFormat('dd-MM-yyyy').format(state.reportStartDate!)
            : DateFormat('dd-MM-yyyy').format(DateTime.now());

        final endStr = state.reportEndDate != null
            ? DateFormat('dd-MM-yyyy').format(state.reportEndDate!)
            : DateFormat('dd-MM-yyyy').format(DateTime.now());

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: _DateFilterColumn(
                      label: 'Start date',
                      value: startStr,
                    ),
                  ),
                  const SizedBox(width: 32),
                  InkWell(
                    onTap: () => _selectDate(context, false),
                    child: _DateFilterColumn(label: 'End date', value: endStr),
                  ),
                  const SizedBox(width: 32),
                  _VoidFilterColumn(
                    isChecked: state.isReportVoidFilter,
                    onChanged: (val) {
                      context.read<DashboardBloc>().add(
                        ToggleReportVoidFilter(val ?? false),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: kBorderColor),

            Expanded(
              child: filteredTransactions.isEmpty
                  ? Center(
                      child: Text(
                        state.isReportVoidFilter
                            ? "No Void/Requested Transactions"
                            : "No Sales Data",
                        style: const TextStyle(color: kTextGrey),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      child: ListView.separated(
                        itemCount: filteredTransactions.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          thickness: 1,
                          color: kBorderColor,
                        ),
                        itemBuilder: (context, index) {
                          final tx = filteredTransactions[index];
                          final rawTotal = tx['total_amount'].toString();
                          final total =
                              int.tryParse(
                                rawTotal.replaceAll(RegExp(r'[^0-9]'), ''),
                              ) ??
                              0;
                          final noStruk = tx['receipt_number'] ?? '-';
                          final status = tx['status']; // Ambil status

                          String timeStr = '-';
                          try {
                            if (tx['transaction_time'] != null) {
                              final dt = DateTime.parse(tx['transaction_time']);
                              timeStr = DateFormat(
                                'HH:mm',
                              ).format(dt.toLocal());
                            }
                          } catch (_) {}

                          return _SalesRowItem(
                            receiptNumber: noStruk,
                            time: timeStr,
                            amount: currency.format(total),
                            status: status, // Kirim status ke row item
                          );
                        },
                      ),
                    ),
            ),

            const Divider(height: 1, thickness: 1, color: kBorderColor),

            Container(
              height: 70,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  const Text(
                    'Total amount', // Ubah teks agar general
                    style: TextStyle(
                      color: kTextDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currency.format(displayTotalSales),
                    style: TextStyle(
                      color: state.isReportVoidFilter ? Colors.red : kTextDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const _PrintSalesReportButton(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SalesRowItem extends StatelessWidget {
  final String receiptNumber;
  final String time;
  final String amount;
  final String status;

  const _SalesRowItem({
    required this.receiptNumber,
    required this.time,
    required this.amount,
    this.status = 'COMPLETED',
  });

  @override
  Widget build(BuildContext context) {
    // 1. Tentukan Kondisi
    final isVoided = status == 'VOIDED';
    final isRequested = status == 'VOID_REQUESTED';

    // 2. Tentukan Warna Utama
    Color mainColor = kTextDark;
    if (isVoided) mainColor = Colors.red; // Tetap Merah
    if (isRequested) mainColor = Colors.orange; // Tetap Oranye

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
                children: [
                  // Nomor Struk
                  Text(
                    receiptNumber,
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.w500,
                      // [UPDATE] Hapus decoration: isVoided ? TextDecoration.lineThrough : null,
                      decoration: null,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Row untuk Waktu & Label Status
                  Row(
                    children: [
                      Text(
                        time,
                        style: const TextStyle(color: kTextGrey, fontSize: 11),
                      ),

                      // Label untuk VOIDED
                      if (isVoided) ...[
                        const SizedBox(width: 8),
                        const Text(
                          'VOIDED',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]
                      // Label untuk VOID_REQUESTED
                      else if (isRequested) ...[
                        const SizedBox(width: 8),
                        const Text(
                          'WAITING APPROVAL',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Harga di Kanan
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              amount,
              style: TextStyle(
                color: mainColor,
                fontWeight: FontWeight.w500,
                // [UPDATE] Hapus decoration coret juga di sini
                decoration: null,
              ),
            ),
          ),
        ],
      ),
    );
  }
} // ================== ITEM REPORT CONTENT (TAB 1 - DINAMIS) ==================

// ================== ITEM REPORT CONTENT (TAB 1 - FINAL) ==================

// ================== ITEM REPORT CONTENT (TAB 1 - FINAL BLACK COLOR) ==================

class _ItemReportContent extends StatelessWidget {
  const _ItemReportContent();

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final bloc = context.read<DashboardBloc>();
    final state = bloc.state;
    final initialDate = isStart
        ? (state.reportStartDate ?? DateTime.now())
        : (state.reportEndDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      if (isStart) {
        bloc.add(
          ReportDateChanged(
            startDate: picked,
            endDate: state.reportEndDate ?? DateTime.now(),
          ),
        );
      } else {
        bloc.add(
          ReportDateChanged(
            startDate: state.reportStartDate ?? DateTime.now(),
            endDate: picked,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final items = state.itemReport;

        final startStr = state.reportStartDate != null
            ? DateFormat('dd-MM-yyyy').format(state.reportStartDate!)
            : DateFormat('dd-MM-yyyy').format(DateTime.now());
        final endStr = state.reportEndDate != null
            ? DateFormat('dd-MM-yyyy').format(state.reportEndDate!)
            : DateFormat('dd-MM-yyyy').format(DateTime.now());

        return Column(
          children: [
            // Bar atas (Filter)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: _DateFilterColumn(
                      label: 'Start Date',
                      value: startStr,
                    ),
                  ),
                  const SizedBox(width: 32),
                  InkWell(
                    onTap: () => _selectDate(context, false),
                    child: _DateFilterColumn(label: 'End Date', value: endStr),
                  ),
                  const SizedBox(width: 32),

                  // Filter Void Checkbox
                  _VoidFilterColumn(
                    isChecked: state.isReportVoidFilter,
                    onChanged: (val) {
                      context.read<DashboardBloc>().add(
                        ToggleReportVoidFilter(val ?? false),
                      );
                      context.read<DashboardBloc>().add(
                        FetchAllReportsRequested(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: kBorderColor),

            // Header Tabel
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Expanded(
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
                    child: BlocBuilder<DashboardBloc, DashboardState>(
                      builder: (context, state) {
                        // Judul berubah, tapi warna tetap hitam
                        return Text(
                          state.isReportVoidFilter
                              ? 'Quantity Void'
                              : 'Quantity Sold',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: kTextDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: kBorderColor),

            // List Item
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        state.isReportVoidFilter
                            ? "No voided items found"
                            : "No items sold",
                        style: const TextStyle(color: kTextGrey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: kBorderColor),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Text(
                                  item.productName,
                                  style: const TextStyle(
                                    color: kTextDark, // Tetap Hitam
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  item.quantitySold.toString(),
                                  style: const TextStyle(
                                    color:
                                        kTextDark, // Tetap Hitam (Permintaan Anda)
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            const Divider(height: 1, thickness: 1, color: kBorderColor),

            // Bottom bar
            Container(
              height: 64,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
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
                      onPressed: () {},
                      child: Text(
                        state.isReportVoidFilter
                            ? 'Print Void Items Recap'
                            : 'Print Item-wise Sales Recap',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

// ================== EXPENDITURE REPORT (FINAL FIX WITH END DATE) ==================

class _ExpenditureReportContent extends StatelessWidget {
  const _ExpenditureReportContent();

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final bloc = context.read<DashboardBloc>();
    final state = bloc.state;
    final initialDate = isStart
        ? (state.reportStartDate ?? DateTime.now())
        : (state.reportEndDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      if (isStart) {
        bloc.add(ReportDateChanged(
            startDate: picked,
            endDate: state.reportEndDate ?? DateTime.now()));
      } else {
        bloc.add(ReportDateChanged(
            startDate: state.reportStartDate ?? DateTime.now(),
            endDate: picked));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final report = state.expenseReport;
        final expenses = report?.expenses ?? [];

        final startStr = state.reportStartDate != null
            ? DateFormat('dd-MM-yyyy').format(state.reportStartDate!)
            : DateFormat('dd-MM-yyyy').format(DateTime.now());

        // [TAMBAHAN] Format End Date
        final endStr = state.reportEndDate != null
            ? DateFormat('dd-MM-yyyy').format(state.reportEndDate!)
            : DateFormat('dd-MM-yyyy').format(DateTime.now());

        return Column(
          children: [
            // Bar atas
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(
                children: [
                  // Start Date
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: _DateFilterColumn(label: 'Start Date', value: startStr),
                  ),
                  
                  const SizedBox(width: 32), // Jarak antar filter

                  // [PERBAIKAN] Tambahkan End Date Di Sini
                  InkWell(
                    onTap: () => _selectDate(context, false),
                    child: _DateFilterColumn(label: 'End Date', value: endStr),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: kBorderColor),

            // Header Tabel
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              alignment: Alignment.centerLeft,
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('Date',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: kTextDark)),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text('Notes',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: kTextDark)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Created By',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: kTextDark)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Amount',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: kTextDark)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: kBorderColor),

            // List Pengeluaran
            Expanded(
              child: expenses.isEmpty
                  ? const Center(
                      child: Text(
                      "No expense data available",
                      style: TextStyle(color: kTextGrey),
                    ))
                  : ListView.separated(
                      itemCount: expenses.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: kBorderColor),
                      itemBuilder: (context, index) {
                        final exp = expenses[index];
                        final amount =
                            int.tryParse(exp['amount'].toString()) ?? 0;

                        String dateStr = exp['expense_date'] ?? '-';
                        try {
                          final dt = DateTime.parse(dateStr);
                          dateStr = DateFormat('dd/MM/yyyy').format(dt);
                        } catch (_) {}

                        // Logika Nama
                        String displayName = 'System';
                        final shift = exp['shift'];
                        final user = exp['user'];

                        if (shift != null &&
                            shift['cashier'] != null &&
                            shift['cashier']['full_name'] != null) {
                          displayName = shift['cashier']['full_name'].toString();
                        }

                        if (displayName == 'System' &&
                            user != null &&
                            user['full_name'] != null) {
                          displayName = user['full_name'].toString();
                        }

                        // Debug Print (Bisa dihapus jika sudah aman)
                        // print("EXP ID: ${exp['expense_id']} -> Name: $displayName");

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(dateStr,
                                    style: const TextStyle(
                                        color: kTextDark,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(exp['description'] ?? '-',
                                    style: const TextStyle(
                                        color: kTextDark,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(displayName,
                                    style: const TextStyle(
                                        color: kTextDark,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(currency.format(amount),
                                    style: const TextStyle(
                                        color: kTextDark,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            const Divider(height: 1, thickness: 1, color: kBorderColor),

            // Footer total
            Container(
              height: 64,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Row(
                children: [
                  const Text(
                    'Total of Expense',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: kTextDark),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    currency.format(report?.totalExpense ?? 0),
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, color: kTextDark),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.print,
                        color: Color(0xFF26A645), size: 24),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrandColor,
                        foregroundColor: kWhiteColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Print Summary of Expense',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
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
}// ================== WIDGET PEMBANTU ==================

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
        Container(
          width: 170,
          height: 40,
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kBorderColor),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(color: kTextDark, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _VoidFilterColumn extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool?>? onChanged; // Callback saat ditekan

  const _VoidFilterColumn({this.isChecked = false, this.onChanged});

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
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: isChecked,
                onChanged: onChanged, // Gunakan callback
                activeColor: kBrandColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: kBorderColor, width: 1.5),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Only void',
              style: TextStyle(color: kTextDark, fontSize: 12),
            ),
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
          // Header
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

          // Content Area
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

          // Footer dengan Button
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
                child: const Text('Print receipt 1'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
