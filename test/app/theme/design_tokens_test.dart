import 'package:dukavo_mobile/app/theme/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.1 contrast ratio for two opaque colours.
double _contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  final lighter = a > b ? a : b;
  final darker = a > b ? b : a;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('status container text meets WCAG AA', () {
    for (final entry in {
      'light': DukavoColors.light,
      'dark': DukavoColors.dark,
    }.entries) {
      final name = entry.key;
      final colors = entry.value;

      test('$name warning banner', () {
        expect(
          _contrast(colors.onWarningContainer, colors.warningContainer),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('$name success banner', () {
        expect(
          _contrast(colors.onSuccessContainer, colors.successContainer),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('$name info banner', () {
        expect(
          _contrast(colors.onInfoContainer, colors.infoContainer),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('$name danger banner', () {
        expect(
          _contrast(colors.onDangerContainer, colors.dangerContainer),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('$name notification bell icon', () {
        expect(
          _contrast(colors.primary, colors.primarySurface),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('$name bottom navigation labels', () {
        expect(
          _contrast(colors.primary, colors.surface),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(colors.textSecondary, colors.surface),
          greaterThanOrEqualTo(4.5),
        );
      });
    }
  });

  group('revenue chart line meets WCAG AA for graphics', () {
    for (final entry in {
      'light': DukavoColors.light,
      'dark': DukavoColors.dark,
    }.entries) {
      final name = entry.key;
      final colors = entry.value;

      test('$name chart line over the hero gradient', () {
        expect(
          _contrast(colors.chartLine, colors.heroStart),
          greaterThanOrEqualTo(3.0),
        );
        expect(
          _contrast(colors.chartLine, colors.heroEnd),
          greaterThanOrEqualTo(3.0),
        );
      });
    }
  });
}
