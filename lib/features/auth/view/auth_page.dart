import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horeka_post_plus/core/utils/toast_utils.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_bloc.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_event.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_state.dart';
import 'package:horeka_post_plus/features/auth/view/widgets/activation_form.dart';
import 'package:horeka_post_plus/features/auth/view/widgets/login_form.dart';
import 'package:horeka_post_plus/features/dashboard/view/home_page.dart'; // [PENTING] Import HomePage

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final images = [
      'assets/images/Rectangle 5.png',
      'assets/images/Rectangle 6.png',
      'assets/images/Rectangle 7.png',
    ];

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        // listener hanya terpanggil saat status / aktivasi / auth berubah
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.isActivated != current.isActivated ||
            previous.isAuthenticated != current.isAuthenticated,
        listener: (context, state) {
          // Error umum
          if (state.status == AuthStatus.error) {
            ToastUtils.showErrorToast(
              state.errorMessage ?? 'Terjadi kesalahan',
            );
          }

          // Setelah aktivasi sukses → fetch device info sekali
          if (state.isActivated &&
              state.branchName.isEmpty &&
              state.schedules.isEmpty) {
            context.read<AuthBloc>().add(FetchDeviceInfoRequested());
          }

          // [PERBAIKAN UTAMA DISINI]
          // Jika Login Sukses & Authenticated -> PINDAH KE HOMEPAGE
          if (state.status == AuthStatus.authenticated &&
              state.isAuthenticated) {
            
            print("✅ [UI] Login Sukses! Navigasi ke HomePage...");
            
            // Pindah halaman dan hapus halaman login dari stack (agar tidak bisa back)
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final index =
                images.isEmpty ? 0 : state.backgroundIndex % images.length;

            return Stack(
              children: [
                // Background carousel
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: const Duration(seconds: 1),
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    child: Image.asset(
                      images[index],
                      key: ValueKey(index),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Overlay gelap
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
                // Logo kiri atas
                Positioned(
                  top: 40,
                  left: 40,
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 50,
                  ),
                ),
                // Konten tengah: activation atau login
                Center(
                  child: state.isActivated
                      ? const LoginForm()
                      : const ActivationForm(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}