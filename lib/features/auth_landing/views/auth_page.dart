import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Impor path yang benar sesuai instruksi Anda
import 'package:horeka_post_plus/features/auth_landing/controllers/auth_page_bloc.dart';
import 'package:horeka_post_plus/features/auth_landing/models/auth_page_state.dart';
import 'package:horeka_post_plus/features/auth_landing/views/welcome_widget.dart';
import 'package:horeka_post_plus/features/auth_landing/views/login_widget.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthPageBloc, AuthPageState>(
        builder: (context, state) {
          return Stack(
            children: [
              // 1. BACKGROUND
              _buildBackground(context, state.backgroundIndex),

              // 2. FOREGROUND (Welcome atau Login)
              _buildForeground(context, state.isShowingLogin),

              // 3. Logo "H" di kiri atas (Hanya tampil saat welcome screen)
              if (!state.isShowingLogin) // Tampilkan hanya saat bukan halaman login
                Positioned(
                  top: 40, // Jarak dari atas
                  left: 40, // Jarak dari kiri
                  child: Image.asset(
                    'assets/images/logo.png', // Pastikan ini adalah logo "H"
                    height: 50, // Ukuran logo
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Widget untuk Background (Tidak Berubah)
  Widget _buildBackground(BuildContext context, int index) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Container(
        key: ValueKey<int>(index),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AuthPageBloc.backgroundImages[index]),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // Widget untuk Foreground (INI ADALAH KODE LENGKAP YANG SUDAH DIPERBAIKI)
  Widget _buildForeground(BuildContext context, bool isShowingLogin) {
    return Align(
      // Selalu posisikan di tengah, baik itu WelcomeWidget atau LoginWidget
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: isShowingLogin
            ? const LoginWidget(key: ValueKey('login'))
            : const WelcomeWidget(key: ValueKey('welcome')),
      ),
    );
  }
}