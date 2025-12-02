import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_bloc.dart';
import 'package:horeka_post_plus/features/auth/data/auth_repository.dart';
import 'package:horeka_post_plus/features/auth/bloc/auth_event.dart';
import 'package:horeka_post_plus/features/auth/view/auth_page.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(repository: AuthRepository())
                ..add(CheckActivationStatusRequested()),
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
      home: const AuthPage(),
    );
  }
}
