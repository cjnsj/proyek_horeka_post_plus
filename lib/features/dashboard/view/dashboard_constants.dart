// lib/features/dashboard/view/dashboard_constants.dart
import 'package:flutter/material.dart';

const double kPagePadding = 16.0;
const double kGapLarge = 16.0;

// Background halaman utama
const Color kBackgroundColor = Color(0xFFF7F7FB);

// Brand & accent
const Color kBrandColor = Color(0xFF4B3FF6);
const Color kAccentColor = Color(0xFFDA4B4B);

// Teks
const Color kTextDark = Color(0xFF333333);
const Color kTextGrey = Color(0xFF666666);

// Panel / kartu
const Color kWhiteColor = Colors.white;
const Color kBorderColor = Color(0xFFDDDDDD);

final List<BoxShadow> kCardShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 18,
    offset: const Offset(0, 6),
  ),
];

BorderRadius kCardRadius([double r = 24]) => BorderRadius.circular(r);
