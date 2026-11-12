import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'design_tokens.dart';

/// Material 3 themes built from the Dukavo design tokens.
///
/// Both themes share one type scale and one shape language; only colour roles
/// change. Everything a screen needs — cards, inputs, navigation, sheets,
/// status colours — is resolved here so individual screens never special-case
/// brightness.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        tokens: DukavoColors.light,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        tokens: DukavoColors.dark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required DukavoColors tokens,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme = _scheme(brightness, tokens);
    final textTheme = _textTheme(tokens);

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: tokens.background,
      canvasColor: tokens.background,
      cardColor: tokens.surface,
      dividerColor: tokens.border,
      shadowColor: tokens.shadow,
      hoverColor: scheme.primary.withValues(alpha: 0.06),
      highlightColor: scheme.primary.withValues(alpha: 0.08),
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[tokens],
    );

    return base.copyWith(
      primaryColor: tokens.primary,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: AppSizes.appBarHeight,
        backgroundColor: tokens.background,
        foregroundColor: tokens.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleSpacing: AppSpacing.md,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: tokens.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: tokens.textPrimary, size: 24),
        actionsIconTheme: IconThemeData(color: tokens.textPrimary, size: 24),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: tokens.background,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: tokens.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: tokens.border),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.inputFill,
        isDense: false,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
        hintStyle: textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
        ),
        helperStyle: textTheme.bodySmall?.copyWith(color: tokens.textMuted),
        errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
        prefixIconColor: tokens.textSecondary,
        suffixIconColor: tokens.textSecondary,
        border: _inputBorder(tokens.border),
        enabledBorder: _inputBorder(tokens.border),
        disabledBorder: _inputBorder(tokens.border.withValues(alpha: 0.6)),
        focusedBorder: _inputBorder(scheme.primary, width: 1.6),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(scheme.error, width: 1.6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppSizes.buttonHeight),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.input),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: tokens.surfaceHigh,
          disabledForegroundColor: tokens.textMuted,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppSizes.buttonHeight),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.input),
          side: BorderSide(color: tokens.border),
          foregroundColor: tokens.textPrimary,
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 14),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
          iconSize: const WidgetStatePropertyAll(22),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return tokens.textMuted;
            return tokens.textPrimary;
          }),
          overlayColor: WidgetStatePropertyAll(
            scheme.primary.withValues(alpha: 0.08),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: tokens.border),
        backgroundColor: tokens.surfaceLow,
        selectedColor: scheme.primaryContainer,
        secondarySelectedColor: scheme.primaryContainer,
        disabledColor: tokens.surfaceLow,
        labelStyle: textTheme.labelMedium?.copyWith(color: tokens.textPrimary),
        secondaryLabelStyle:
            textTheme.labelMedium?.copyWith(color: scheme.onPrimaryContainer),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
        shape: const StadiumBorder(),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppSizes.navBarHeight,
        elevation: 0,
        backgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelPadding: const EdgeInsetsDirectional.only(top: AppSpacing.xxs),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            fontSize: 12,
            height: 1.34,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.primary : tokens.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : tokens.textSecondary,
            size: 25,
          );
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
          textStyle: WidgetStatePropertyAll(
            textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.primaryContainer;
            }
            return tokens.surfaceLow;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.onPrimaryContainer;
            }
            return tokens.textPrimary;
          }),
          iconColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.onPrimaryContainer;
            }
            return tokens.textSecondary;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(
                color: scheme.primary.withValues(alpha: 0.45),
              );
            }
            return BorderSide(color: tokens.border);
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surfaceLow,
        modalBackgroundColor: tokens.surfaceLow,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: tokens.textMuted,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
        elevation: 0,
        modalElevation: 0,
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surfaceLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: tokens.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: tokens.textSecondary,
          height: 1.5,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: scheme.inversePrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        iconColor: tokens.textSecondary,
        textColor: tokens.textPrimary,
        titleTextStyle: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: tokens.textPrimary,
        ),
        subtitleTextStyle:
            textTheme.bodySmall?.copyWith(color: tokens.textSecondary),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        minVerticalPadding: 10,
        visualDensity: VisualDensity.standard,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: tokens.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: tokens.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: tokens.textSecondary,
        indicatorColor: scheme.primary,
        dividerColor: Colors.transparent,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        indicatorSize: TabBarIndicatorSize.label,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.onPrimary;
          return tokens.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return tokens.surfaceHighest;
        }),
        trackOutlineColor: WidgetStatePropertyAll(tokens.border),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
        side: BorderSide(color: tokens.border, width: 1.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return tokens.textSecondary;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: tokens.surfaceHigh,
        circularTrackColor: tokens.surfaceHigh,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: tokens.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: tokens.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(color: tokens.border),
        ),
        textStyle: textTheme.bodyMedium?.copyWith(color: tokens.textPrimary),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onInverseSurface,
        ),
        waitDuration: const Duration(milliseconds: 500),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          tokens.textMuted.withValues(alpha: 0.5),
        ),
        radius: const Radius.circular(AppRadius.pill),
        thickness: const WidgetStatePropertyAll(4),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: scheme.primary,
        collapsedIconColor: tokens.textSecondary,
        textColor: tokens.textPrimary,
        collapsedTextColor: tokens.textPrimary,
        childrenPadding: const EdgeInsetsDirectional.only(
          start: 4,
          end: 4,
          bottom: 12,
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: scheme.error,
        textColor: scheme.onError,
        textStyle: textTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: scheme.onError,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _DukavoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: _DukavoPageTransitionsBuilder(),
          TargetPlatform.windows: _DukavoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: _DukavoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ColorScheme _scheme(Brightness brightness, DukavoColors tokens) {
    final isDark = brightness == Brightness.dark;
    return ColorScheme(
      brightness: brightness,
      primary: tokens.primary,
      onPrimary: isDark ? const Color(0xFF062B26) : Colors.white,
      primaryContainer:
          isDark ? const Color(0xFF134E4A) : const Color(0xFFCCFBF1),
      onPrimaryContainer:
          isDark ? const Color(0xFF99F6E4) : AppColors.primaryDark,
      secondary: tokens.accent,
      onSecondary: const Color(0xFF1A2E05),
      secondaryContainer:
          isDark ? const Color(0xFF163C38) : const Color(0xFFDDF4F0),
      onSecondaryContainer:
          isDark ? const Color(0xFFB8F5EC) : const Color(0xFF0B3B37),
      tertiary: isDark ? const Color(0xFF5EEAD4) : AppColors.primaryDark,
      onTertiary: isDark ? const Color(0xFF062B26) : Colors.white,
      tertiaryContainer:
          isDark ? const Color(0xFF115E59) : const Color(0xFFD5F5F0),
      onTertiaryContainer:
          isDark ? const Color(0xFFCCFBF1) : const Color(0xFF0B3B37),
      error: tokens.danger,
      onError: tokens.onDanger,
      errorContainer: tokens.dangerContainer,
      onErrorContainer:
          isDark ? const Color(0xFFFECACA) : const Color(0xFF7F1D1D),
      surface: tokens.surface,
      onSurface: tokens.textPrimary,
      surfaceContainerLowest: tokens.background,
      surfaceContainerLow: tokens.surface,
      surfaceContainer: tokens.surfaceLow,
      surfaceContainerHigh: tokens.surfaceHigh,
      surfaceContainerHighest: tokens.surfaceHighest,
      onSurfaceVariant: tokens.textSecondary,
      outline: tokens.border,
      outlineVariant: tokens.border.withValues(alpha: isDark ? 1 : 0.7),
      shadow: tokens.shadow,
      scrim: Colors.black.withValues(alpha: 0.55),
      inverseSurface: isDark ? tokens.textPrimary : AppColors.text,
      onInverseSurface: isDark ? AppColors.text : Colors.white,
      inversePrimary: isDark ? AppColors.primary : const Color(0xFF5EEAD4),
      surfaceTint: tokens.primary,
    );
  }

  static TextTheme _textTheme(DukavoColors tokens) {
    final primary = tokens.textPrimary;
    final secondary = tokens.textSecondary;
    const fallback = <String>[
      'Noto Sans Arabic',
      'Noto Naskh Arabic',
      'Roboto',
    ];

    TextStyle style({
      required double size,
      required double height,
      FontWeight weight = FontWeight.w400,
      double letterSpacing = 0,
      Color? color,
    }) {
      return TextStyle(
        fontSize: size,
        height: height / size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        color: color ?? primary,
        fontFamilyFallback: fallback,
      );
    }

    return TextTheme(
      displayLarge: style(
        size: 40,
        height: 48,
        weight: FontWeight.w700,
        letterSpacing: -1.2,
      ),
      displayMedium: style(
        size: 34,
        height: 42,
        weight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      displaySmall: style(
        size: 30,
        height: 38,
        weight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      headlineLarge: style(
        size: 28,
        height: 36,
        weight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: style(
        size: 25,
        height: 32,
        weight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineSmall: style(
        size: 22,
        height: 30,
        weight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: style(
        size: 20,
        height: 28,
        weight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: style(size: 16, height: 24, weight: FontWeight.w600),
      titleSmall: style(size: 14, height: 20, weight: FontWeight.w600),
      bodyLarge: style(size: 16, height: 24),
      bodyMedium: style(size: 14, height: 21),
      bodySmall: style(size: 12, height: 18, color: secondary),
      labelLarge: style(size: 15, height: 20, weight: FontWeight.w700),
      labelMedium: style(
        size: 13,
        height: 18,
        weight: FontWeight.w600,
        color: secondary,
      ),
      labelSmall: style(
        size: 11,
        height: 16,
        weight: FontWeight.w600,
        letterSpacing: 0.2,
        color: secondary,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

/// A quiet fade-and-rise transition that matches the product's motion language.
class _DukavoPageTransitionsBuilder extends PageTransitionsBuilder {
  const _DukavoPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.isFirst ||
        MediaQuery.maybeOf(context)?.disableAnimations == true) {
      return child;
    }

    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
