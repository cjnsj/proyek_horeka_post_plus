import 'package:flutter/material.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';

class PrintReceiptPage extends StatelessWidget {
  const PrintReceiptPage({super.key});

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
                _PrintReceiptHeaderBar(),
                Divider(height: 1, thickness: 1, color: kBorderColor),
                Expanded(child: _PrintReceiptBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrintReceiptHeaderBar extends StatelessWidget {
  const _PrintReceiptHeaderBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: kBrandColor,
          ),
          const SizedBox(width: 4),
          const Text(
            'Print Receipt',
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

class _PrintReceiptBody extends StatelessWidget {
  const _PrintReceiptBody();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(flex: 48, child: _LeftTransactionList()),
        VerticalDivider(width: 1, thickness: 1, color: kBorderColor),
        Expanded(flex: 52, child: _RightCartDetail()),
      ],
    );
  }
}

// LEFT SIDE

class _LeftTransactionList extends StatelessWidget {
  const _LeftTransactionList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SearchBar(),
        const Divider(height: 1, thickness: 1, color: kBorderColor),
        Expanded(
          child: ListView.separated(
            itemCount: 1,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 1,
              color: kBorderColor,
            ),
            itemBuilder: (context, index) => const _TransactionItem(),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter transaction number',
                  hintStyle: const TextStyle(color: kTextGrey, fontSize: 13),
                  filled: true,
                  fillColor: kWhiteColor,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kBorderColor),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: kBrandColor, width: 2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 44,
            width: 130,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandColor,
                foregroundColor: kWhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {},
              child: const Text(
                'Search',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'TR0511202510001',
                style: TextStyle(
                  color: kTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '05-11-2025 09:13:15',
                style: TextStyle(
                  color: kTextGrey,
                  fontSize: 11,
                ),
              ),
              Text(
                'Rp. 18.000,00',
                style: TextStyle(
                  color: kTextDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 36,
              width: 140,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kBrandColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'View receipt',
                  style: TextStyle(
                    color: kBrandColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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

// RIGHT SIDE

class _RightCartDetail extends StatelessWidget {
  const _RightCartDetail();

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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _CartItem(),
                const Spacer(),
                const _SummaryPanel(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandColor,
                      foregroundColor: kWhiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // TODO: print receipt
                    },
                    child: const Text(
                      'Print Receipt',
                      style: TextStyle(
                        fontSize: 15,
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

class _CartItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kBorderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 5,
            child: Text(
              'Mie',
              style: TextStyle(
                color: kTextDark,
                fontSize: 13,
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              'Qty',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kTextGrey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  'Rp. 18.000,00',
                  style: TextStyle(
                    color: kTextDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel();

  @override
  Widget build(BuildContext context) {
    const label = TextStyle(color: kTextGrey, fontSize: 12);
    const value = TextStyle(color: kTextGrey, fontSize: 12);

    return Column(
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
    );
  }

  Widget _row(String l, String v, TextStyle ls, TextStyle vs) {
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
