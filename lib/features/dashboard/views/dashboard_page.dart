// lib/features/dashboard/views/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:horeka_post_plus/features/dashboard/views/widgets/global_header_bar.dart';
import 'package:horeka_post_plus/features/dashboard/views/dashboard_constants.dart';
import 'package:horeka_post_plus/features/dashboard/views/dialogs/pin_kasir_dialog.dart';
import 'package:horeka_post_plus/features/dashboard/views/widgets/cart_panel.dart';
import 'package:horeka_post_plus/features/dashboard/views/widgets/main_content.dart';
import 'package:horeka_post_plus/features/dashboard/views/widgets/side_nav_rail.dart';

// BLoC menu
import 'package:horeka_post_plus/features/dashboard/controllers/menu_bloc/menu_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/controllers/menu_bloc/menu_event.dart';
import 'package:horeka_post_plus/features/dashboard/services/menu_api_service.dart';

// BLoC cart
import 'package:horeka_post_plus/features/dashboard/controllers/cart_bloc/cart_bloc.dart';

// Halaman lain
import 'package:horeka_post_plus/features/dashboard/views/pages/sales_report_page.dart';
import 'package:horeka_post_plus/features/dashboard/views/pages/printer_settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  /// 0 = Dashboard
  /// 1 = Sales report
  /// 2 = Printer settings
  int _selectedIndex = 0;

  bool get _isDashboardMode => _selectedIndex == 0;

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

  Widget _buildCenterPage() {
    switch (_selectedIndex) {
      case 0:
        return const MainContent();
      case 1:
         return const SalesReportContent(); // ganti nama, tanpa Scaffold
      case 2:
        return const PrinterSettingsPage();
      default:
        return const MainContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              MenuBloc(apiService: MenuApiService())..add(FetchMenuEvent()),
        ),
        BlocProvider(
          create: (context) => CartBloc(),
        ),
      ],
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // LAYER 1: layout utama (side nav + konten + cart)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kiri: side nav + konten utama, turun 80 px
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SideNavRail(
                            selectedIndex: _selectedIndex,
                            onItemSelected: (index) {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildCenterPage(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Kanan: cart, juga turun 80 px supaya sejajar
                 // Kanan: cart, juga turun 80 px, dan panelnya dibuat memanjang
// Kanan: cart
if (_isDashboardMode)
  Expanded(
    flex: 1,
    child: Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: Transform.translate(
        offset: const Offset(0, -45), // geser seluruh card sedikit ke atas
        child: FractionallySizedBox(
          heightFactor: 1.1, // atur kalau mau card sedikit lebih tinggi
          widthFactor: 1.0,
          child: const CartPanel(),
        ),
      ),
    ),
  ),

                ],
              ),
            ),

            // LAYER 2: header di atas kolom kiri saja
            Positioned(
              left: 24,
              top: 24,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;

                  // Total horizontal padding: 24 kiri + 24 kanan + 24 gap tengah
                  const double totalHorizontalPadding = 24 * 3;

                  // Lebar area kerja (tanpa padding luar + gap tengah)
                  final double contentWidth =
                      screenWidth - totalHorizontalPadding;

                  // Flex kiri:kanan = 2:1  → kolom kiri = 2/3 lebar konten
                  final double leftWidth = contentWidth * 2 / 3;

                  return SizedBox(
                    width: leftWidth,
                    child: GlobalHeaderBar(
                      isExpandedMode: _isDashboardMode,
                      onSearch: (value) {
                        // TODO: sambungkan ke pencarian menu jika dibutuhkan
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
