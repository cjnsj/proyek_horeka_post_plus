import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_page.dart';
// IMPORT SERVICE KITA
import 'package:horeka_post_plus/features/auth_landing/services/auth_api_service.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  // State untuk data dari API
  bool _isLoading = true;
  String? _errorMessage;
  String _branchName = "";
  List<dynamic> _schedules = []; // Untuk menyimpan daftar shift
  String? _selectedShiftId;

  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isPasswordObscured = true;

  final _apiService = AuthApiService();

  // Definisikan warna
  final Color _brandColor = const Color(0xFF5A4FFB);
  final Color _darkTextColor = const Color(0xFF333333);
  final Color _lightTextColor = Colors.black.withOpacity(0.6);
  final Color _hintTextColor = Colors.grey.shade500;
  final Color _borderColor = Colors.grey.shade300;

  @override
  void initState() {
    super.initState();
    _fetchDeviceInfo();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _fetchDeviceInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _apiService.getDeviceInfo();
      setState(() {
        _branchName = data['branch_name'];
        _schedules = data['schedules'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _performLogin() async {
    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError("Username and Password must be filled.");
      return;
    }

    // Validasi shift
    if (_schedules.isNotEmpty && _selectedShiftId == null) {
      _showError("Please select a shift.");
      return;
    }

    final shiftIdToSubmit = _selectedShiftId ?? "";

    setState(() => _isLoading = true);

    try {
      await _apiService.login(
        _usernameController.text,
        _passwordController.text,
        shiftIdToSubmit,
      );

      // Jika sukses, token sudah disimpan oleh service
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardPage(),
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

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
        child: _isLoading
            ? _buildLoading()
            : _errorMessage != null
                ? _buildError()
                : _buildLoginForm(),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      heightFactor: 5,
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError() {
    return Center(
      heightFactor: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Error: $_errorMessage", style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchDeviceInfo,
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/logo.png', height: 60),
        const SizedBox(height: 16),
        Text(
          'Welcome to $_branchName.\nPlease log in to start.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            color: _darkTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          'Username',
          'Masukkan username',
          controller: _usernameController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Password',
          'Masukkan password',
          isObscure: _isPasswordObscured,
          controller: _passwordController,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
              color: _lightTextColor,
            ),
            onPressed: () {
              setState(() {
                _isPasswordObscured = !_isPasswordObscured;
              });
            },
          ),
        ),
        const SizedBox(height: 16), // Beri jarak sedikit
        
        // --- Panggil pembuat shift di sini ---
        _buildShiftSelector(),
        const SizedBox(height: 20), // Beri jarak setelah shift

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
          onPressed: _performLogin,
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
    );
  }

  Widget _buildTextField(String label, String hint,
      {bool isObscure = false,
      bool readOnly = false,
      TextEditingController? controller,
      Widget? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _darkTextColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          readOnly: readOnly,
          style: TextStyle(
            color: readOnly ? _lightTextColor : _darkTextColor,
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
            fillColor: readOnly ? _borderColor.withOpacity(0.3) : Colors.white,
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
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  String _formatShiftName(String apiName) {
    String lowerApiName = apiName.toLowerCase();
    if (lowerApiName.contains('shift 1') || lowerApiName.contains('pagi')) {
      return "Shift Pagi";
    }
    if (lowerApiName.contains('shift 2') || lowerApiName.contains('siang')) {
      return "Shift Siang";
    }
    if (lowerApiName.contains('shift 3') || lowerApiName.contains('malam')) {
      return "Shift Malam";
    }
    return apiName.split('(').first.trim();
  }

  // --- FUNGSI INI DIMODIFIKASI UNTUK MENAMBAHKAN LABEL ---
  Widget _buildShiftSelector() {
    // Jika tidak ada jadwal shift dari API, jangan tampilkan apa-apa
    if (_schedules.isEmpty) {
      return const SizedBox.shrink();
    }

    // Tampilkan sebagai Column: [Label] -> [Row Radio]
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. LABEL TEKS "Pilih jadwal shift"
        Text(
          "Pilih jadwal shift:",
          style: TextStyle(
            color: _darkTextColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8), // Jarak antara label dan radio

        // 2. BARIS HORIZONTAL UNTUK RADIO BUTTON
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _schedules.map((schedule) {
            final String shiftId = schedule['id'];
            final String apiShiftName = schedule['name'];
            final String displayShiftName = _formatShiftName(apiShiftName);

            // Buat widget kustom untuk (o) Label
            return _buildRadioOption(displayShiftName, shiftId);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String label, String value) {
    // Ubah label "Shift Pagi" -> "Shift 1" (sesuai gambar)
    String displayLabel = label.replaceAll("Shift Pagi", "Shift 1")
                               .replaceAll("Shift Siang", "Shift 2")
                               .replaceAll("Shift Malam", "Shift 3");

    return InkWell(
      onTap: () {
        setState(() {
          _selectedShiftId = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _selectedShiftId,
            onChanged: (String? newValue) {
              setState(() {
                _selectedShiftId = newValue;
              });
            },
            activeColor: _brandColor,
            visualDensity: VisualDensity.compact,
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return _brandColor;
              }
              return _lightTextColor;
            }),
          ),
          Text(
            displayLabel,
            style: TextStyle(
              color: _lightTextColor,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}