import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';
import 'package:intl/intl.dart';
import 'package:horeka_post_plus/features/dashboard/dialogs/konfirmasi_saldo_dialog.dart';

class StartingBalanceDialog extends StatefulWidget {
  final VoidCallback onBalanceSaved;

  const StartingBalanceDialog({
    super.key,
    required this.onBalanceSaved,
  });

  @override
  State<StartingBalanceDialog> createState() => _StartingBalanceDialogState();
}

class _StartingBalanceDialogState extends State<StartingBalanceDialog> {
  final TextEditingController _balanceController = TextEditingController();

  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  void _formatCurrency(String value) {
    if (value.isEmpty) {
      _balanceController.clear();
      return;
    }

    final numericString = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericString.isEmpty) {
      _balanceController.clear();
      return;
    }

    final number = int.tryParse(numericString);
    if (number != null) {
      final formatted = _formatter.format(number);
      _balanceController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _saveBalance() {
  final balanceText = _balanceController.text.trim();

  if (balanceText.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter the starting balance'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  final numericString = balanceText.replaceAll(RegExp(r'[^0-9]'), '');
  final amount = int.tryParse(numericString) ?? 0;
  if (amount <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting balance must be greater than 0'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  // SIMPAN context sebelum pop
  final rootContext = Navigator.of(context).context;

  // Tutup dialog saldo awal terlebih dulu
  Navigator.of(context).pop();

  // Baru buka dialog konfirmasi (single barrier)
  showGeneralDialog(
    context: rootContext,
    barrierDismissible: false,
    barrierColor: kBrandColor.withOpacity(0.5),
    pageBuilder: (ctx, animation, secondary) {
      return MediaQuery.removeViewInsets(
        removeBottom: true,
        removeTop: true,
        context: ctx,
        child: KonfirmasiSaldoDialog(
          onRetry: () {
            // Buka lagi dialog saldo awal untuk edit
            showGeneralDialog(
              context: rootContext,
              barrierDismissible: false,
              barrierColor: kBrandColor.withOpacity(0.5),
              transitionDuration: const Duration(milliseconds: 150),
              pageBuilder: (ctx2, a2, s2) {
                return MediaQuery.removeViewInsets(
                  removeBottom: true,
                  removeTop: true,
                  context: ctx2,
                  child: StartingBalanceDialog(
                    onBalanceSaved: widget.onBalanceSaved,
                  ),
                );
              },
            );
          },
          onConfirm: () {
            widget.onBalanceSaved();
          },
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please enter the starting balance :',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: _formatCurrency,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Enter the balance amount',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: kBrandColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveBalance,
                child: const Text(
                  'Save and open cashier',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
