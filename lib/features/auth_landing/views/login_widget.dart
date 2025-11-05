import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_page.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  int? _selectedShift = 1; // Default shift 1

  // Definisikan warna agar konsisten
  final Color _brandColor = const Color(0xFF5A4FFB); // Warna brand ungu
  final Color _darkTextColor = const Color(
    0xFF333333,
  ); // Teks gelap (bukan hitam pekat)
  final Color _lightTextColor = Colors.black.withOpacity(0.6); // Teks label
  final Color _hintTextColor = Colors.grey.shade500;
  final Color _borderColor = Colors.grey.shade300;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo.png', // Pastikan path logo "H" benar
              height: 60,
            ),
            const SizedBox(height: 16),

            // Judul
            Text(
              'Please log in to start using Horeka Pos+.\nHave a great day!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: _darkTextColor,
                fontWeight: FontWeight.bold, // Sesuai permintaan Anda
              ),
            ),
            const SizedBox(height: 24),

            // Form
            _buildTextField('Username', 'Masukkan username'),
            const SizedBox(height: 16),
            _buildTextField('Password', 'Masukkan password', isObscure: true),
            const SizedBox(height: 20),

            // Radio Button Shift
            _buildShiftSelector(),
            const SizedBox(height: 24),

            // Tombol Login
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                // TODO: Tambahkan logika login di sini

                // Setelah login berhasil, pindah ke Dashboard
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardPage(),
                  ),
                );
              },
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FUNGSI INI TELAH DIPERBARUI
  Widget _buildTextField(String label, String hint, {bool isObscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _darkTextColor, // Diubah agar lebih gelap
            fontSize: 14,
            fontWeight: FontWeight.bold, // Diubah ke bold
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: isObscure,
          style: TextStyle(
            color: _darkTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: _hintTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _borderColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _brandColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  // FUNGSI INI JUGA DISESUAIKAN
  Widget _buildShiftSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildRadioOption(1, 'Shift 1'),
        _buildRadioOption(2, 'Shift 2'),
        _buildRadioOption(3, 'Shift 3'),
      ],
    );
  }

  Widget _buildRadioOption(int value, String label) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: _selectedShift,
          onChanged: (int? newValue) {
            setState(() {
              _selectedShift = newValue;
            });
          },
          activeColor: _brandColor,
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return _brandColor;
            }
            return _lightTextColor;
          }),
        ),
        Text(
          label,
          style: TextStyle(
            color: _lightTextColor, // Diubah agar lebih tipis/terang
            fontSize: 16,
            fontWeight: FontWeight.w400, // Diubah ke regular (w400)
          ),
        ),
      ],
    );
  }
}
