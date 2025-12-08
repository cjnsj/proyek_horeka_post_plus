import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_bloc.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_event.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;
  String? _selectedShiftId;

  // Brand colors & styles
  final Color _brandColor = const Color(0xFF5A4FFB);
  final Color _darkTextColor = const Color(0xFF333333);
  final Color _lightTextColor = Colors.black.withOpacity(0.6);
  final Color _hintTextColor = Colors.grey.shade500;
  final Color _borderColor = Colors.grey.shade300;

  @override
  void initState() {
    super.initState();
    // PENTING: jangan panggil FetchDeviceInfoRequested di sini
    // supaya tidak spam request. Sudah dipanggil di AuthPage listener.
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _performLogin(BuildContext context, List<Map<String, dynamic>> schedules) {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showError(context, "Username and Password must be filled.");
      return;
    }

    if (schedules.isNotEmpty && _selectedShiftId == null) {
      _showError(context, "Please select a shift.");
      return;
    }

    final shiftIdToSubmit = _selectedShiftId ?? "";

    context.read<AuthBloc>().add(
          LoginRequested(
            username: username,
            password: password,
            shiftId: shiftIdToSubmit,
          ),
        );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatShiftName(String apiName) {
    String lowerApiName = apiName.toLowerCase();
    if (lowerApiName.contains('shift 1') || lowerApiName.contains('pagi')) {
      return "Shift 1";
    }
    if (lowerApiName.contains('shift 2') || lowerApiName.contains('siang')) {
      return "Shift 2";
      
    }
     if (lowerApiName.contains('shift 3') || lowerApiName.contains('sore')) {
      return "Shift 3";
    }
    if (lowerApiName.contains('shift 4') || lowerApiName.contains('malam')) {
      return "Shift 4";
    }
    return apiName.split('(').first.trim();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.error) {
          _showError(context, state.errorMessage ?? "Unknown error");
        }

        if (state.status == AuthStatus.authenticated) {
          // TODO: ganti dengan navigation ke dashboard
        }
      },
      builder: (context, state) {
        // Saat pertama load device-info
        if (state.status == AuthStatus.loading && state.branchName.isEmpty) {
          return Center(
            child: Container(
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
              child: const Center(
                heightFactor: 5,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        // Card login di tengah
        return Center(
          child: Container(
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
                  Image.asset('assets/images/logo.png', height: 60),
                  const SizedBox(height: 16),

                  // Welcome text with branch name
                  Text(
                    'Welcome to ${state.branchName}.\nPlease log in to start.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: _darkTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Username field
                  _buildTextField(
                    'Username',
                    'Masukkan username',
                    controller: _usernameController,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  _buildTextField(
                    'Password',
                    'Masukkan password',
                    isObscure: _isPasswordObscured,
                    controller: _passwordController,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: _lightTextColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscured = !_isPasswordObscured;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Shift selector (if schedules available)
                  _buildShiftSelector(state.schedules),
                  const SizedBox(height: 20),

                  // Login button
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
                    onPressed: state.status == AuthStatus.loading
                        ? null
                        : () => _performLogin(context, state.schedules),
                    child: state.status == AuthStatus.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
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
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    bool isObscure = false,
    bool readOnly = false,
    TextEditingController? controller,
    Widget? suffixIcon,
  }) {
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

  Widget _buildShiftSelector(List<Map<String, dynamic>> schedules) {
    if (schedules.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pilih jadwal shift:",
          style: TextStyle(
            color: _darkTextColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: schedules.map((schedule) {
            final String shiftId = schedule['id'];
            final String apiShiftName = schedule['name'];
            final String displayShiftName = _formatShiftName(apiShiftName);

            return _buildRadioOption(displayShiftName, shiftId);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String label, String value) {
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
            label,
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
