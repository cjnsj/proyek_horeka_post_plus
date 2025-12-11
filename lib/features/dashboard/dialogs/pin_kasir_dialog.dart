import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_bloc.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_state.dart';
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';

class PinKasirDialog extends StatefulWidget {
  final Function(String) onPinSubmitted;

  const PinKasirDialog({
    super.key,
    required this.onPinSubmitted,
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
  String? _errorMessage; // [BARU] Menyimpan pesan error dari backend

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

  void _clearFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _onChanged(String value, int index) {
    if (_isError) {
      setState(() {
        _isError = false;
        _errorMessage = null; // Reset pesan error saat user mengetik lagi
      });
    }

    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _verifyPin() {
    final enteredPin = _controllers.map((c) => c.text).join();

    if (enteredPin.length < 4) {
      setState(() {
        _isError = true;
        _errorMessage = 'PIN harus 4 digit';
      });
      return;
    }

    widget.onPinSubmitted(enteredPin);
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

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.error) {
          setState(() {
            _isError = true;
            // [UPDATE] Ambil pesan error dari state (misal: "Akses Ditolak: Budi sedang aktif...")
            _errorMessage = state.errorMessage ?? 'PIN Salah. Silakan coba lagi.';
          });

          // Jeda agar user bisa baca pesan error sebelum field di-reset
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              _clearFields();
              // Opsional: Anda bisa membiarkan _isError true sampai user mengetik lagi
              // agar pesan error tetap terbaca.
            }
          });
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
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

                // [UPDATE] Tampilkan Pesan Error Dinamis
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  // Beri ruang lebih jika pesannya panjang (multi-line)
                  height: _isError ? 60 : 0, 
                  child: _isError
                      ? Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            _errorMessage ?? 'PIN Salah.', // Tampilkan pesan backend
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2, // Support pesan panjang 2 baris
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 16),

                // Enter button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state.status == AuthStatus.loading;
                    return SizedBox(
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
                        onPressed: isLoading ? null : _verifyPin,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Enter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}