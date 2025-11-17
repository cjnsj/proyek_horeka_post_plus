// Salin dan Gantikan seluruh isi file
// lib/features/dashboard/views/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // <-- IMPORT BLOC
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';
import 'package:horeka_post_plus/features/dashboard/views/dialogs/pin_kasir_dialog.dart';
import 'package:horeka_post_plus/features/dashboard/views/widgets/cart_panel.dart';
import 'package:horeka_post_plus/features/dashboard/views/widgets/main_content.dart';
import 'package:horeka_post_plus/features/dashboard/views/widgets/side_nav_rail.dart';

// --- IMPORT BARU UNTUK MENU BLOC ---
import 'package:horeka_post_plus/features/dashboard/controllers/menu_bloc/menu_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/controllers/menu_bloc/menu_event.dart';
import 'package:horeka_post_plus/features/dashboard/services/menu_api_service.dart';
// --- AKHIR IMPORT BARU ---

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPinKasirDialog(context); 
    });
  }
  
  void _showPinKasirDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      barrierColor: const Color(0xFF4C45B5).withOpacity(0.4),
      builder: (BuildContext dialogContext) {
        return const PinKasirDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- DI SINILAH KITA MENYEDIAKAN BLOC ---
    return BlocProvider(
      // Kita buat MenuBloc di sini
      // dan langsung memicu event FetchMenuEvent
      // agar menu dimuat secara otomatis.
      create: (context) => MenuBloc(apiService: MenuApiService())
        ..add(FetchMenuEvent()),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. KOLOM UTAMA (Kiri & Tengah digabung)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1a. KARTU HEADER ATAS
                    _buildGlobalTopBar(),

                    const SizedBox(height: 24),

                    // 1b. ROW INTERNAL (Nav & Main)
                    const Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SideNavRail(),
                          SizedBox(width: 24),
                          Expanded(child: MainContent()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // 2. PANEL KERANJANG
              const Expanded(flex: 1, child: CartPanel()),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Top Bar (Tidak berubah)
  Widget _buildGlobalTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('assets/images/logo.png', height: 40),
              const SizedBox(width: 16),
              const Text(
                "Horeka Pos+",
                style: TextStyle(
                  color: kBrandColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 300,
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Find menu",
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SvgPicture.asset('assets/icons/search.svg'),
                ),
                filled: true,
                fillColor: kWhiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kBrandColor, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}