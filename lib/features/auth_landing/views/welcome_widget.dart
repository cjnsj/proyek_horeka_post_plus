import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Impor BLoC dan Event
import 'package:horeka_post_plus/features/auth_landing/controllers/auth_page_bloc.dart';
import 'package:horeka_post_plus/features/auth_landing/controllers/auth_page_event.dart';

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WELCOME!',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(blurRadius: 10.0, color: Colors.black54)],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'One Tap. One Table. Total Control',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              shadows: [Shadow(blurRadius: 8.0, color: Colors.black54)],
            ),
          ),
          const SizedBox(height: 32),
          // Tombol Start
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                  ),
                  onPressed: () {
                    // Kirim event StartPressed ke Controller (BLoC)
                    context.read<AuthPageBloc>().add(StartPressed());
                  },
                  child: const Text(
                    'Start',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}