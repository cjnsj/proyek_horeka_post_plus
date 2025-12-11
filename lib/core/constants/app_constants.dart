// lib/core/constants/app_constants.dart
class AppConstants {
  // API Base URL sesuai dokumentasi L0
  static const String apiBaseUrl = 'http://192.168.18.20:3001/api';
  
  // App Info
  static const String appName = 'Horeka Post Plus';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String activationCodeKey = 'activation_code';
  static const String usernameKey = 'username';
  static const String tokenKey = 'jwt_token';
  
  // Durations
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Background Images untuk Auth Page
  static const List<String> authBackgroundImages = [
    'assets/images/Rectangle 5.png',
    'assets/images/Rectangle 6.png',
    'assets/images/Rectangle 7.png',
  ];
}