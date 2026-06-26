import 'package:flutter/material.dart';

class AppColors {
  // ─── Brand Primary ─────────────────────────────────────────
  static const Color primary = Color(0xFF1E3A5F);        // Navy medium
  static const Color primaryDark = Color(0xFF0D1B2A);    // Navy gelap (background utama dark)
  static const Color primaryLight = Color(0xFF2C5282);   // Navy terang

  // ─── Accent / CTA ──────────────────────────────────────────
  static const Color accent = Color(0xFFF97316);         // Orange hangat
  static const Color accentLight = Color(0xFFFFAD70);    // Orange muda
  static const Color accentDark = Color(0xFFEA6A00);     // Orange gelap

  // ─── Light Mode ────────────────────────────────────────────
  static const Color background = Color(0xFFF0F4F8);     // Abu-biru sangat muda
  static const Color surface = Color(0xFFFFFFFF);        // Putih
  static const Color surfaceCard = Color(0xFFFFFFFF);    // Kartu putih
  static const Color surfaceVariant = Color(0xFFE8EDF2); // Input field

  static const Color textPrimary = Color(0xFF0D1B2A);    // Hampir hitam navy
  static const Color textSecondary = Color(0xFF4A6080);  // Abu-biru
  static const Color textHint = Color(0xFF8FA3BB);       // Abu muda

  static const Color divider = Color(0xFFD9E2EC);
  static const Color border = Color(0xFFCBD5E1);
  static const Color success = Color(0xFF10B981);        // Hijau
  static const Color error = Color(0xFFEF4444);          // Merah
  static const Color warning = Color(0xFFF59E0B);        // Kuning
  static const Color info = Color(0xFF3B82F6);           // Biru info

  // ─── Dark Mode ─────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0D1B2A);  // Navy gelap
  static const Color darkSurface = Color(0xFF1A2D42);     // Navy medium
  static const Color darkSurfaceCard = Color(0xFF1E3449); // Kartu navy
  static const Color darkSurfaceVariant = Color(0xFF243B55); // Input field dark

  static const Color darkTextPrimary = Color(0xFFF0F4F8);
  static const Color darkTextSecondary = Color(0xFF8FA3BB);
  static const Color darkTextHint = Color(0xFF4A6080);

  static const Color darkDivider = Color(0xFF243B55);
  static const Color darkBorder = Color(0xFF2C4A6E);

  // ─── Gradient Presets ──────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D1B2A), Color(0xFF1E3A5F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFEA6A00), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0D1B2A), Color(0xFF1E3A5F), Color(0xFF2C5282)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
