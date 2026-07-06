import 'package:flutter/material.dart';

/// Palet warna terpusat aplikasi — diambil dari gaya yang sudah dipakai
/// di DashboardScreen, supaya semua screen konsisten (bukan tiap screen
/// punya konstanta warna sendiri-sendiri).
class AppColors {
  AppColors._();

  // ── Brand / Primary ──────────────────────────────────────────────────────
  static const primaryLight = Color(0xFF0F52BA);
  static const secondaryLight = Color(0xFF3B82F6);
  static const darkHeader1 = Color(0xFF0F172A); // Slate 900
  static const darkHeader2 = Color(0xFF1E293B); // Slate 800

  /// Warna primer sesuai brightness — dipakai untuk icon aktif, indikator, dll.
  static Color primary(bool isDark) => isDark ? darkHeader1 : primaryLight;

  /// Gradient header sesuai brightness (dipakai di AppBar/SliverAppBar custom).
  static List<Color> headerGradient(bool isDark) => isDark
      ? [darkHeader1, darkHeader2]
      : [primaryLight, secondaryLight];

  // ── Status Tiket (konsisten di semua screen: admin, list, card, tracking) ──
  static const statusOpen = Color(0xFFEF4444);
  static const statusAssigned = Color(0xFF3B82F6); // disamakan dgn secondaryLight
  static const statusInProgress = Color(0xFFF59E0B);
  static const statusClosed = Color(0xFF9CA3AF);

  // ── Netral / Surface ─────────────────────────────────────────────────────
  static const surfaceLight = Color(0xFFF6F8FC);
  static const surfaceDark = Color(0xFF14181F);
  static const cardDark = Color(0xFF1C212B);

  static Color surface(bool isDark) => isDark ? surfaceDark : surfaceLight;
  static Color card(bool isDark) => isDark ? cardDark : Colors.white;
}