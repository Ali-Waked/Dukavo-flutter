import 'package:intl/intl.dart';

/// Presentation-only formatting. The server owns every calculation and every
/// currency decision; these helpers only turn a number into a readable string.
class Formatters {
  const Formatters._();

  static String currency(
    num value,
    String currencyCode, {
    String? locale,
    bool compact = false,
  }) {
    final code = currencyCode.isEmpty ? 'USD' : currencyCode.toUpperCase();
    try {
      final format = compact
          ? NumberFormat.compactSimpleCurrency(name: code, locale: locale)
          : NumberFormat.simpleCurrency(name: code, locale: locale);
      return format.format(value);
    } catch (_) {
      final amount = compact
          ? NumberFormat.compact(locale: locale).format(value)
          : NumberFormat.decimalPattern(locale).format(value);
      return '$code $amount';
    }
  }

  static String number(num value, {String? locale}) {
    try {
      return NumberFormat.decimalPattern(locale).format(value);
    } catch (_) {
      return value.toString();
    }
  }

  static String percent(num value, {String? locale, int decimals = 1}) {
    try {
      final formatted = NumberFormat.decimalPatternDigits(
        locale: locale,
        decimalDigits: decimals,
      ).format(value);
      return '$formatted%';
    } catch (_) {
      return '${value.toStringAsFixed(decimals)}%';
    }
  }

  static String date(String? iso, {String? locale}) {
    final parsed = _parse(iso);
    if (parsed == null) return '—';
    try {
      return DateFormat.yMMMd(locale).format(parsed);
    } catch (_) {
      return DateFormat.yMMMd().format(parsed);
    }
  }

  static String dateTime(String? iso, {String? locale}) {
    final parsed = _parse(iso);
    if (parsed == null) return '—';
    try {
      return DateFormat.yMMMd(locale).add_jm().format(parsed);
    } catch (_) {
      return DateFormat.yMMMd().add_jm().format(parsed);
    }
  }

  static String time(String? iso, {String? locale}) {
    final parsed = _parse(iso);
    if (parsed == null) return '—';
    try {
      return DateFormat.jm(locale).format(parsed);
    } catch (_) {
      return DateFormat.jm().format(parsed);
    }
  }

  static String relative(String? iso, {String? locale}) {
    final parsed = _parse(iso);
    if (parsed == null) return '—';
    final difference = DateTime.now().difference(parsed);
    if (difference.inMinutes < 1) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    return date(iso, locale: locale);
  }

  static String initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  static DateTime? _parse(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    return DateTime.tryParse(iso)?.toLocal();
  }
}
