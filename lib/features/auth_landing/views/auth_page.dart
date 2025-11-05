import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Impor BLoC, State, dan sub-view
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
              // 1. BACKGROUND (dari State/Model)
              _buildBackground(context, state.backgroundIndex),

              // 2. FOREGROUND (dari State/Model)
              _buildForeground(context, state.isShowingLogin),
            ],
          );
        },
      ),
    );
  }

  // Widget untuk Background
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
            // Ambil path gambar dari BLoC (Controller)
            image: AssetImage(AuthPageBloc.backgroundImages[index]),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // Widget untuk Foreground
  Widget _buildForeground(BuildContext context, bool isShowingLogin) {
    return Center(
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