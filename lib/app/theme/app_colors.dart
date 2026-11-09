import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// The Dukavo brand palette.
///
/// The brand values are shared with the web product. Screen code should prefer
/// the semantic roles from [DukavoColors] (`context.dukavo`) for surfaces and
/// status colours so light and dark mode both stay legible. The constants here
/// remain for brand gradients, illustrations and tests.
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF0F766E);
  static const Color primaryDark = Color(0xFF115E59);
  static const Color accent = Color(0xFFA3E635);

  static const Color background = Color(0xFFF7F9F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF142522);
  static const Color muted = Color(0xFF687873);
  static const Color border = Color(0xFFE5ECE9);

  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFB45309);
  static const Color success = Color(0xFF047857);
  static const Color info = Color(0xFF2563EB);

  static const Color darkBackground = Color(0xFF101816);
  static const Color darkSurface = Color(0xFF17211E);
  static const Color darkBorder = Color(0xFF2B3D36);
  static const Color darkText = Color(0xFFF1F7F4);
  static const Color darkMuted = Color(0xFFA6B8B0);

  /// A soft tint of a status colour, used for chips and icon wells.
  static Color tint(Color color, {double opacity = 0.12}) {
    return color.withValues(alpha: opacity);
  }
}
