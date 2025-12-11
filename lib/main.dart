// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_bloc.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_state.dart';
import 'package:horeka_post_plus/features/auth/data/auth_repository.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_event.dart';
import 'package:horeka_post_plus/features/auth/view/auth_page.dart';
import 'package:horeka_post_plus/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:horeka_post_plus/features/dashboard/data/dashboard_repository.dart';
import 'package:horeka_post_plus/features/dashboard/view/home_page.dart'; 

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(repository: AuthRepository())..add(AppStarted()),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(repository: DashboardRepository()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horeka Post Plus',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // [FIX] Gunakan 'state.isAuthenticated' (Boolean)
          // Ini mencegah HomePage di-refresh saat validasi PIN (status: success/loading)
          if (state.isAuthenticated) {
            return const HomePage();
          }

          // Jika tidak authenticated -> Ke AuthPage
          return const AuthPage();
        },
      ),
    );
  }
}