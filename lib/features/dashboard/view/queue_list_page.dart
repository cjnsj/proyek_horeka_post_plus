import 'package:flutter/material.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';

class QueueListPage extends StatelessWidget {
  const QueueListPage({super.key});

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
              children: const [
                _QueueHeaderBar(),
                Divider(height: 1, thickness: 1, color: kBorderColor),
                Expanded(child: _QueueBody()),
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
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: kBrandColor,
          ),
          const SizedBox(width: 4),
          const Text(
            'Queue List',
            style: TextStyle(
              color: kBrandColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.print, color: kBrandColor, size: 22),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _QueueBody extends StatelessWidget {
  const _QueueBody();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(flex: 48, child: _LeftQueueList()),
        VerticalDivider(width: 1, thickness: 1, color: kBorderColor),
        Expanded(flex: 52, child: _RightCartArea()),
      ],
    );
  }
}

// LEFT SIDE

class _LeftQueueList extends StatelessWidget {
  const _LeftQueueList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 1,
      itemBuilder: (context, index) {
        return _QueueCard(
          number: '09',
          amount: 'Rp.18.000,00',
          isSelected: true,
          onTap: () {
            // TODO: load detail cart dari queue ini
          },
        );
      },
    );
  }
}

class _QueueCard extends StatelessWidget {
  final String number;
  final String amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _QueueCard({
    super.key,
    required this.number,
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? kBrandColor : kBorderColor;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 220,
        height: 110,
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number,
              style: const TextStyle(
                color: kTextDark,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              amount,
              style: const TextStyle(
                color: kTextGrey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// RIGHT SIDE

class _RightCartArea extends StatelessWidget {
  const _RightCartArea();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 48,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Text(
            'Cart',
            style: TextStyle(
              color: kTextDark,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: kBorderColor),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add_circle_outline, size: 24, color: kBrandColor),
                SizedBox(height: 8),
                Text(
                  'Please select a transaction',
                  style: TextStyle(color: kTextGrey, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const _SummaryPanel(),
        const _BottomButtonsBar(),
      ],
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel();

  @override
  Widget build(BuildContext context) {
    const label = TextStyle(color: kTextGrey, fontSize: 12);
    const value = TextStyle(color: kTextGrey, fontSize: 12);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _row('Discount', '-Rp.0,00', label, value),
          _row('Subtotal', 'Rp.18.000,00', label, value),
          _row('Tax', '+Rp.0,00', label, value),
          const SizedBox(height: 4),
          _row(
            'Total',
            'Rp.18.000,00',
            label.copyWith(fontWeight: FontWeight.w700),
            value.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  static Widget _row(String l, String v, TextStyle ls, TextStyle vs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: ls),
          Text(v, style: vs),
        ],
      ),
    );
  }
}

class _BottomButtonsBar extends StatelessWidget {
  const _BottomButtonsBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: kBorderColor, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B8B8B),
                foregroundColor: kWhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                // TODO: Add/Edit item dari queue
              },
              child: const Text(
                'Add/Edit Item',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandColor,
                foregroundColor: kWhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                // TODO: proses Pay Now
              },
              child: const Text(
                'Pay Now',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
