import 'package:flutter/material.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';

class VoidModePage extends StatelessWidget {
  const VoidModePage({super.key});

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
                _VoidHeaderBar(),
                Divider(height: 1, thickness: 1, color: kBorderColor),
                Expanded(child: _VoidBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VoidHeaderBar extends StatelessWidget {
  const _VoidHeaderBar();

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
            'Void Mode',
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

class _VoidBody extends StatelessWidget {
  const _VoidBody();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(flex: 48, child: _LeftTransactionList()),
        VerticalDivider(width: 1, thickness: 1, color: kBorderColor),
        Expanded(flex: 52, child: _RightCartPreview()),
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
            itemCount: 3,
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
    return InkWell(
      onTap: () {
        // TODO: load transaction detail
      },
      child: SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'TR0511202510001',
                      style: TextStyle(
                        color: kTextDark,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '05-11-2025 09:13:15',
                      style: TextStyle(
                        color: kTextGrey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Rp. 18.000,00',
                    style: TextStyle(
                      color: kTextDark,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () {
                      // TODO: confirm delete
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F0FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: kBrandColor,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// RIGHT SIDE

class _RightCartPreview extends StatelessWidget {
  const _RightCartPreview();

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
                  'Please choose a transaction',
                  style: TextStyle(color: kTextGrey, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const _SummaryPanel(),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _row('Discount', '-Rp.0,00', label, value),
          _row('Subtotal', 'Rp.0,00', label, value),
          _row('Tax', '+Rp.0,00', label, value),
          const SizedBox(height: 4),
          _row(
            'Total',
            'Rp.0,00',
            label.copyWith(fontWeight: FontWeight.w700),
            value.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
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
