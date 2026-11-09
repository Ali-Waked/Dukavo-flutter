import 'package:flutter/material.dart';

/// Central design tokens for the Dukavo mobile product.
///
/// Screens should reach for these tokens (or the matching theme roles) instead
/// of inventing padding, radii or colours locally. The palette is intentionally
/// small: brand teal, a restrained lime accent, and semantic status colours.
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  /// Standard horizontal page inset on phones.
  static const EdgeInsetsGeometry page =
      EdgeInsetsDirectional.fromSTEB(16, 8, 16, 32);
  static const EdgeInsetsGeometry pageWide =
      EdgeInsetsDirectional.fromSTEB(20, 12, 20, 40);
}

class AppRadius {
  const AppRadius._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 28;
  static const double pill = 999;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get input => BorderRadius.circular(sm + 2);
  static BorderRadius get sheet =>
      const BorderRadius.vertical(top: Radius.circular(xxl));
}

class AppSizes {
  const AppSizes._();

  static const double touchTarget = 48;
  static const double buttonHeight = 52;
  static const double inputHeight = 52;
  static const double appBarHeight = 60;
  static const double navBarHeight = 70;
  static const double logo = 28;
  static const double avatar = 44;
  static const double pageMaxWidth = 720;
}

class AppDurations {
  const AppDurations._();

  static const Duration fast = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 360);
  static const Duration page = Duration(milliseconds: 280);
}

/// The full Dukavo palette for one brightness.
///
/// Exposed as a [ThemeExtension] so widgets can resolve semantic colours that
/// Material's [ColorScheme] does not model (status colours, layered surfaces,
/// input fills) without checking `Theme.of(context).brightness` everywhere.
@immutable
class DukavoColors extends ThemeExtension<DukavoColors> {
  const DukavoColors({
    required this.background,
    required this.surface,
    required this.surfaceLow,
    required this.surfaceHigh,
    required this.surfaceHighest,
    required this.inputFill,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.primary,
    required this.primaryPressed,
    required this.accent,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.danger,
    required this.onDanger,
    required this.dangerContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.heroStart,
    required this.heroEnd,
    required this.shadow,
  });

  final Color background;
  final Color surface;
  final Color surfaceLow;
  final Color surfaceHigh;
  final Color surfaceHighest;
  final Color inputFill;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color primary;
  final Color primaryPressed;
  final Color accent;
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color danger;
  final Color onDanger;
  final Color dangerContainer;
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color heroStart;
  final Color heroEnd;
  final Color shadow;

  static const DukavoColors light = DukavoColors(
    background: Color(0xFFF7F9F8),
    surface: Color(0xFFFFFFFF),
    surfaceLow: Color(0xFFF0F5F3),
    surfaceHigh: Color(0xFFEAF1EE),
    surfaceHighest: Color(0xFFE3ECE8),
    inputFill: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF142522),
    textSecondary: Color(0xFF687873),
    textMuted: Color(0xFF879791),
    border: Color(0xFFE5ECE9),
    primary: Color(0xFF0F766E),
    primaryPressed: Color(0xFF115E59),
    accent: Color(0xFFA3E635),
    success: Color(0xFF047857),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD1FAE5),
    warning: Color(0xFFB45309),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFEF3C7),
    danger: Color(0xFFDC2626),
    onDanger: Color(0xFFFFFFFF),
    dangerContainer: Color(0xFFFEE2E2),
    info: Color(0xFF2563EB),
    onInfo: Color(0xFFFFFFFF),
    infoContainer: Color(0xFFDBEAFE),
    heroStart: Color(0xFF0F766E),
    heroEnd: Color(0xFF115E59),
    shadow: Color(0x1A0F2A25),
  );

  /// Layered Premium Deep Teal. Never pure black, never one flat grey.
  static const DukavoColors dark = DukavoColors(
    background: Color(0xFF101816),
    surface: Color(0xFF17211E),
    surfaceLow: Color(0xFF1D2A26),
    surfaceHigh: Color(0xFF22332E),
    surfaceHighest: Color(0xFF2B3D36),
    inputFill: Color(0xFF1B2824),
    textPrimary: Color(0xFFF1F7F4),
    textSecondary: Color(0xFFA6B8B0),
    textMuted: Color(0xFF82968D),
    border: Color(0xFF2B3D36),
    primary: Color(0xFF2DD4BF),
    primaryPressed: Color(0xFF14B8A6),
    accent: Color(0xFFA3E635),
    success: Color(0xFF34D399),
    onSuccess: Color(0xFF042F24),
    successContainer: Color(0xFF123B2E),
    warning: Color(0xFFFBBF24),
    onWarning: Color(0xFF3B2500),
    warningContainer: Color(0xFF3E2E0B),
    danger: Color(0xFFF87171),
    onDanger: Color(0xFF3F0D0D),
    dangerContainer: Color(0xFF401C1C),
    info: Color(0xFF60A5FA),
    onInfo: Color(0xFF0B2447),
    infoContainer: Color(0xFF172B45),
    heroStart: Color(0xFF115E59),
    heroEnd: Color(0xFF0F766E),
    shadow: Color(0x66000000),
  );

  bool get isDark => background.computeLuminance() < 0.5;

  @override
  DukavoColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceLow,
    Color? surfaceHigh,
    Color? surfaceHighest,
    Color? inputFill,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? primary,
    Color? primaryPressed,
    Color? accent,
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? danger,
    Color? onDanger,
    Color? dangerContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? heroStart,
    Color? heroEnd,
    Color? shadow,
  }) {
    return DukavoColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceLow: surfaceLow ?? this.surfaceLow,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      surfaceHighest: surfaceHighest ?? this.surfaceHighest,
      inputFill: inputFill ?? this.inputFill,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      primary: primary ?? this.primary,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      heroStart: heroStart ?? this.heroStart,
      heroEnd: heroEnd ?? this.heroEnd,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  DukavoColors lerp(ThemeExtension<DukavoColors>? other, double t) {
    if (other is! DukavoColors) return this;
    return DukavoColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLow: Color.lerp(surfaceLow, other.surfaceLow, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      surfaceHighest: Color.lerp(surfaceHighest, other.surfaceHighest, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryPressed: Color.lerp(primaryPressed, other.primaryPressed, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension DukavoThemeX on BuildContext {
  /// Semantic colours for the current brightness.
  DukavoColors get dukavo =>
      Theme.of(this).extension<DukavoColors>() ?? DukavoColors.light;

  ColorScheme get scheme => Theme.of(this).colorScheme;

  TextTheme get texts => Theme.of(this).textTheme;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
