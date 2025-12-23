import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Utility class untuk menampilkan toast dengan anti-double toast mechanism
/// Mencegah toast yang sama muncul berkali-kali dalam waktu singkat
class ToastUtils {
  static DateTime? _lastToastTime;
  static String? _lastToastMessage;
  static const int _toastDebounceMilliseconds = 500;

  // ==================== KONFIGURASI TATA LETAK TOAST ====================
  // ✨ UBAH NILAI DI BAWAH INI UNTUK MENGATUR TAMPILAN TOAST SECARA GLOBAL
  
  /// 📍 POSISI TOAST
  /// Pilihan: ToastGravity.TOP (atas), ToastGravity.CENTER (tengah), ToastGravity.BOTTOM (bawah)
  /// Rekomendasi untuk POS: TOP (agar tidak menghalangi tombol di bawah)
  static const ToastGravity defaultGravity = ToastGravity.TOP;
  
  /// 📏 UKURAN FONT
  /// Default: 16.0 | Range disarankan: 14.0 - 20.0
  static const double defaultFontSize = 16.0;
  
  /// ⏱️ DURASI TOAST (dalam detik untuk iOS/Web)
  static const int shortDuration = 4;  // Toast pendek (SUCCESS, INFO, WARNING)
  static const int longDuration = 4;   // Toast panjang (ERROR)
  
  /// 🎨 WARNA BACKGROUND UNTUK SETIAP TIPE TOAST
  static const Color successColor = Color(0xFF4CAF50);  // Hijau (✓ Sukses)
  static const Color errorColor = Color(0xFFF44336);    // Merah (✗ Error)
  static const Color warningColor = Color(0xFFFF9800);  // Orange (⚠ Warning)
  static const Color infoColor = Color(0xFF2196F3);     // Biru (ℹ Info)
  static const Color defaultColor = Color(0xFF333333);  // Abu-abu gelap (default)
  
  /// 🖊️ WARNA TEXT TOAST
  static const Color defaultTextColor = Colors.white;
  
  /// ⏲️ DEBOUNCE TIME (waktu minimum antara 2 toast yang sama, dalam milidetik)
  /// Tingkatkan jika toast masih sering double | Turunkan jika respons terlalu lambat
  static const int debounceTime = 500;  // 0.5 detik
  
  // ========================================================================

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
    ToastGravity? gravity,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
  }) {
    final now = DateTime.now();
    
    // Prevent double toast - skip jika pesan sama dan masih dalam debounce time
    if (_lastToastTime != null && 
        _lastToastMessage == message &&
        now.difference(_lastToastTime!).inMilliseconds < debounceTime) {
      return;
    }

    _lastToastTime = now;
    _lastToastMessage = message;

    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity ?? defaultGravity,
      timeInSecForIosWeb: toastLength == Toast.LENGTH_LONG ? longDuration : shortDuration,
      backgroundColor: backgroundColor ?? defaultColor,
      textColor: textColor ?? defaultTextColor,
      fontSize: fontSize ?? defaultFontSize,
    );
  }

  /// Menampilkan toast sukses (hijau)
  /// Digunakan untuk notifikasi operasi berhasil
  /// 
  /// Contoh: "Login berhasil", "Data tersimpan", "Pembayaran sukses"
  static void showSuccessToast(
    String message, {
    ToastGravity? gravity,
    Toast toastLength = Toast.LENGTH_SHORT,
  }) {
    showToast(
      message: message,
      backgroundColor: successColor,
      gravity: gravity ?? defaultGravity,
      toastLength: toastLength,
    );
  }

  /// Menampilkan toast error (merah)
  /// Digunakan untuk notifikasi error/gagal
  /// Durasi lebih lama agar user sempat membaca
  /// 
  /// Contoh: "Login gagal", "Koneksi error", "Validasi gagal"
  static void showErrorToast(
    String message, {
    ToastGravity? gravity,
    Toast toastLength = Toast.LENGTH_LONG,
  }) {
    showToast(
      message: message,
      backgroundColor: errorColor,
      toastLength: toastLength,
      gravity: gravity ?? defaultGravity,
    );
  }

  /// Menampilkan toast peringatan (orange)
  /// Digunakan untuk warning/peringatan
  /// 
  /// Contoh: "Field tidak boleh kosong", "Stok menipis", "Printer tidak terhubung"
  static void showWarningToast(
    String message, {
    ToastGravity? gravity,
    Toast toastLength = Toast.LENGTH_SHORT,
  }) {
    showToast(
      message: message,
      backgroundColor: warningColor,
      gravity: gravity ?? defaultGravity,
      toastLength: toastLength,
    );
  }

  /// Menampilkan toast informasi (biru)
  /// Digunakan untuk informasi umum
  /// 
  /// Contoh: "Data dimuat ke keranjang", "Menyimpan...", "Memproses pembayaran..."
  static void showInfoToast(
    String message, {
    ToastGravity? gravity,
    Toast toastLength = Toast.LENGTH_SHORT,
  }) {
    showToast(
      message: message,
      backgroundColor: infoColor,
      gravity: gravity ?? defaultGravity,
      toastLength: toastLength,
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
