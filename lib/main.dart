import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horeka_post_plus/features/auth_landing/controllers/auth_page_bloc.dart';
import 'package:horeka_post_plus/features/auth_landing/views/auth_page.dart';

void main() {
  /// The line `runApp(const MyApp());` in the Dart code is responsible for running the Flutter
  /// application by creating an instance of the `MyApp` widget and passing it to the `runApp` function.
  /// The `MyApp` widget is the root widget of the Flutter application and it defines the overall
  /// structure and behavior of the app. By calling `runApp`, the Flutter framework starts the app and
  /// displays the UI defined in the `MyApp` widget on the screen.
  runApp(const MyApp());
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
      ),
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => AuthPageBloc(),
        child: const AuthPage(),
      ),
    );
  }
}