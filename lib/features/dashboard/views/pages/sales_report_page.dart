// lib/features/dashboard/views/pages/sales_report_page.dart

import 'package:flutter/material.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';

class SalesReportContent extends StatelessWidget {
  const SalesReportContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KIRI: card utama laporan (rasio 2)
        Expanded(
          flex: 2,
          child: _buildTransactionListCard(),
        ),
        const SizedBox(width: 24),
        // KANAN: card detail (rasio 1)
        Expanded(
          flex: 1,
          child: _buildDetailsCard(),
        ),
      ],
    );
  }

  // ========== CARD KIRI (SALES REPORT) ==========

  Widget _buildTransactionListCard() {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: Column(
        children: [
          _buildHeaderWithTabs(),
          const Divider(height: 1, color: kBorderColor),
          Expanded(
            child: ListView(
              children: [
                _buildTransactionTile(
                  "TR0511202510001",
                  "05-11-2025 09:13:15",
                  "Rp. 18.000,00",
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: kBorderColor),
          _buildFooterTotal(),
        ],
      ),
    );
  }

  Widget _buildHeaderWithTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildActiveTab("Sales report"),
              _buildInactiveTab("Item report"),
              _buildInactiveTab("Expenditure report"),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDatePicker("Start date", "04-11-2025"),
              const SizedBox(width: 16),
              _buildDatePicker("Start date", "05-11-2025"),
              const SizedBox(width: 24),
              const Text(
                "Filter Void",
                style: TextStyle(
                  color: kDarkTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Checkbox(
                value: false,
                onChanged: (val) {},
                activeColor: kBrandColor,
              ),
              const Text(
                "Only void",
                style: TextStyle(color: kDarkTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTab(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: const BoxDecoration(
        color: kBrandColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: kWhiteColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInactiveTab(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: const BoxDecoration(
        color: kWhiteColor,
        border: Border(
          bottom: BorderSide(color: kBrandColor, width: 2),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: kDarkTextColor.withOpacity(0.7),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFooterTotal() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "Total sales amount",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                "Rp.18.000,00",
                style: TextStyle(
                  color: kDarkTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 45,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandColor,
                foregroundColor: kWhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text("Print sales report"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kDarkTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 150,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kBorderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  color: kDarkTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: kDarkTextColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(String id, String dateTime, String price) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorderColor, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                id,
                style: const TextStyle(
                  color: kDarkTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateTime,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            price,
            style: const TextStyle(
              color: kDarkTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ========== CARD KANAN (DETAIL) ==========

  Widget _buildDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Sales details",
                  style: TextStyle(
                    color: kDarkTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: kBorderColor),
          const Expanded(
            child: Center(
              child: _EmptyDetails(),
            ),
          ),
          const Divider(height: 1, color: kBorderColor),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: const [
                _TotalRow("Discount", "-Rp.0,00"),
                _TotalRow("Subtotal", "Rp.0,00"),
                _TotalRow("Tax", "+Rp.0,00"),
                Divider(height: 24),
                _TotalRow("Total", "Rp.0,00", isTotal: true),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandColor,
                  foregroundColor: kWhiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text("Print receipt"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDetails extends StatelessWidget {
  const _EmptyDetails();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_circle_outline, color: kBrandColor, size: 25),
        const SizedBox(height: 8),
        Text(
          "Please select a transaction",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String title;
  final String amount;
  final bool isTotal;

  const _TotalRow(this.title, this.amount, {this.isTotal = false, super.key});

  @override
  Widget build(BuildContext context) {
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
}
