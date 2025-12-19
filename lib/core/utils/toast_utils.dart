import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Utility class untuk menampilkan toast dengan anti-double toast mechanism
/// Mencegah toast yang sama muncul berkali-kali dalam waktu singkat
class ToastUtils {
  static DateTime? _lastToastTime;
  static String? _lastToastMessage;
  static const int _toastDebounceMilliseconds = 500;

  /// Menampilkan toast dengan kustomisasi penuh
  /// 
  /// [message] - Pesan yang akan ditampilkan
  /// [toastLength] - Durasi toast (SHORT atau LONG)
  /// [gravity] - Posisi toast (TOP, CENTER, BOTTOM)
  /// [backgroundColor] - Warna background toast
  /// [textColor] - Warna text toast
  /// [fontSize] - Ukuran font toast
  static void showToast({
    required String message,
    Toast toastLength = Toast.LENGTH_SHORT,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Color backgroundColor = const Color(0xFF333333),
    Color textColor = Colors.white,
    double fontSize = 16.0,
  }) {
    final now = DateTime.now();
    
    // Prevent double toast - skip jika pesan sama dan masih dalam debounce time
    if (_lastToastTime != null && 
        _lastToastMessage == message &&
        now.difference(_lastToastTime!).inMilliseconds < _toastDebounceMilliseconds) {
      return;
    }

    _lastToastTime = now;
    _lastToastMessage = message;

    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      timeInSecForIosWeb: toastLength == Toast.LENGTH_LONG ? 5 : 2,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }

  /// Menampilkan toast sukses (hijau)
  /// Digunakan untuk notifikasi operasi berhasil
  static void showSuccessToast(String message) {
    showToast(
      message: message,
      backgroundColor: const Color(0xFF4CAF50), // Green
      gravity: ToastGravity.BOTTOM,
    );
  }

  /// Menampilkan toast error (merah)
  /// Digunakan untuk notifikasi error/gagal
  /// Durasi lebih lama agar user sempat membaca
  static void showErrorToast(String message) {
    showToast(
      message: message,
      backgroundColor: const Color(0xFFF44336), // Red
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
  }

  /// Menampilkan toast peringatan (orange)
  /// Digunakan untuk warning/peringatan
  static void showWarningToast(String message) {
    showToast(
      message: message,
      backgroundColor: const Color(0xFFFF9800), // Orange
      gravity: ToastGravity.BOTTOM,
    );
  }

  /// Menampilkan toast informasi (biru)
  /// Digunakan untuk informasi umum
  static void showInfoToast(String message) {
    showToast(
      message: message,
      backgroundColor: const Color(0xFF2196F3), // Blue
      gravity: ToastGravity.BOTTOM,
    );
  }

  /// Cancel semua toast yang sedang ditampilkan
  /// dan reset debounce mechanism
  static void cancelToast() {
    Fluttertoast.cancel();
    _lastToastTime = null;
    _lastToastMessage = null;
  }
}
