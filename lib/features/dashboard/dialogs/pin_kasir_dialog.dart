import 'package:flutter/material.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';

class PinKasirDialog extends StatefulWidget {
  final VoidCallback onPinVerified;

  const PinKasirDialog({
    super.key,
    required this.onPinVerified,
  });

  @override
  State<PinKasirDialog> createState() => _PinKasirDialogState();
}

class _PinKasirDialogState extends State<PinKasirDialog> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  bool _isError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (_isError) {
      setState(() {
        _isError = false;
      });
    }

    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verifyPin() {
    final enteredPin = _controllers.map((c) => c.text).join();

    if (enteredPin.length < 4) {
      setState(() {
        _isError = true;
      });
      return;
    }

    // TODO: ganti dengan verifikasi PIN dari API/SharedPreferences
    if (enteredPin == '1234') {
      widget.onPinVerified();
    } else {
      setState(() {
        _isError = true;
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    );

    final normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,  // batas lebar dialog
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter cashier PIN :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // 4 PIN boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : 8,
                      right: index == 3 ? 0 : 8,
                    ),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      obscureText: true,
                      obscuringCharacter: '●',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: _isError ? errorBorder : normalBorder,
                        enabledBorder: _isError ? errorBorder : normalBorder,
                        focusedBorder: _isError
                            ? errorBorder
                            : OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: kBrandColor,
                                  width: 2,
                                ),
                              ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) => _onChanged(value, index),
                      onTap: () {
                        _controllers[index].selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _controllers[index].text.length,
                        );
                      },
                    ),
                  );
                }),
              ),

              // error text
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _isError ? 32 : 0,
                child: _isError
                    ? const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'Your PIN is incorrect. Please try again !',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // Enter button
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
                  onPressed: _verifyPin,
                  child: const Text(
                    'Enter',
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
      ),
    );
  }
}
