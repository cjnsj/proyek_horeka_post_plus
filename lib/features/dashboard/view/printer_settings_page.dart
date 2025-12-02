import 'package:flutter/material.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';

// ================= HALAMAN PRINTER SETTINGS =================

class PrinterSettingsPage extends StatelessWidget {
  const PrinterSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
   

    return Padding(
      padding: EdgeInsets.only(
        left: 126, // hindari side menu
        right: 24,
        top: 21,   // sejajar bawah logo (sesuai setting kamu)
        bottom: 16,
      ),
      child: const _PrinterSettingsCard(),
    );
  }
}

// ================= CARD BESAR PRINTER SETTINGS ===============

class _PrinterSettingsCard extends StatelessWidget {
  const _PrinterSettingsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER UNGU
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: kBrandColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: kWhiteColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Printer Settings',
                    style: TextStyle(
                      color: kBrandColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ISI (dua kolom dalam satu card)
          Expanded(
            child: Row(
              children: const [
                Expanded(child: _PrinterSettingsLeft()),
                VerticalDivider(width: 1, thickness: 1, color: kBorderColor),
                Expanded(child: _PrinterSettingsRight()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= KOLOM KIRI =================

class _PrinterSettingsLeft extends StatelessWidget {
  const _PrinterSettingsLeft();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // BLOK ATAS DENGAN PADDING
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Printer List',
                style: TextStyle(
                  color: kTextDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrandColor,
                          foregroundColor: kWhiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text('Add Bluetooth Printer'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrandColor,
                          foregroundColor: kWhiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text('Add USB Printer'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Bluetooth Printer',
                style: TextStyle(color: kTextGrey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'Bluetooth',
                    style: TextStyle(color: kTextGrey, fontSize: 12),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: kBrandColor,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: kBrandColor,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),

        // GARIS FULL KIRI–KANAN CARD
        const Divider(
          height: 1,
          thickness: 1,
          color: kBorderColor,
        ),

        const Expanded(child: SizedBox.expand()),
      ],
    );
  }
}

// ================= KOLOM KANAN =================

class _PrinterSettingsRight extends StatelessWidget {
  const _PrinterSettingsRight();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // BLOK ATAS DENGAN PADDING
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Printer List',
                style: TextStyle(
                  color: kTextDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Printer for Receipt',
                        style: TextStyle(
                          color: kTextDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Bluetooth Printer',
                        style: TextStyle(color: kTextGrey, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Choose Printer',
                      style: TextStyle(color: kBrandColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),

        // GARIS FULL KIRI–KANAN CARD
        const Divider(
          height: 1,
          thickness: 1,
          color: kBorderColor,
        ),

        // BLOK TENGAH DENGAN PADDING
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Printer for Receipt',
                      style: TextStyle(
                        color: kTextDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: kBorderColor, width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Enable kitchen printer',
                        style: TextStyle(color: kTextDark, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Bluetooth Printer',
                style: TextStyle(color: kTextGrey, fontSize: 12),
              ),
            ],
          ),
        ),

        const Spacer(),

        // FOOTER BUTTON DENGAN PADDING
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Choose Printer',
                style: TextStyle(color: kBrandColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
