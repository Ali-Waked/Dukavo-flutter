import 'package:flutter/material.dart';

/// The Dukavo brand palette.
///
/// These are the exact values used by the Vue application, so the mobile
/// product and the web product look like the same company rather than two
/// interpretations of one logo.
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF0F766E);
  static const Color primaryDark = Color(0xFF115E59);
  static const Color accent = Color(0xFFA3E635);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);
  static const Color success = Color(0xFF16A34A);
  static const Color info = Color(0xFF2563EB);

  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF111C2E);
  static const Color darkBorder = Color(0xFF1E293B);
  static const Color darkText = Color(0xFFF1F5F9);
  static const Color darkMuted = Color(0xFF94A3B8);

  /// A soft tint of a status colour, used for chips and icon wells.
  static Color tint(Color color, {double opacity = 0.12}) {
    return color.withValues(alpha: opacity);
  }
}
