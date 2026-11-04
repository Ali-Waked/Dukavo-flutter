/// Typed view of `GET /platform/dashboard`.
///
/// The endpoint returns real SQL aggregates; nothing here is estimated. A
/// `null` comparison (no previous-period rows) stays unavailable rather than
/// being rendered as a 0% change.
class PlatformDashboard {
  const PlatformDashboard({
    required this.rangeKey,
    required this.bucket,
    required this.from,
    required this.until,
    required this.tenants,
    required this.users,
    required this.waitlist,
    required this.contactMessages,
    required this.newsletterSubscribers,
    required this.plans,
    required this.series,
    required this.status,
  });

  final String rangeKey;
  final String bucket;
  final String from;
  final String until;
  final PlatformMetric tenants;
  final PlatformMetric users;
  final PlatformMetric waitlist;
  final PlatformMetric contactMessages;
  final PlatformMetric newsletterSubscribers;
  final PlatformMetric plans;
  final List<PlatformSeriesPoint> series;
  final Map<String, List<PlatformStatusCount>> status;

  List<PlatformStatusCount> statusFor(String key) =>
      status[key] ?? const <PlatformStatusCount>[];

  /// Percentage growth from the previous window, or null when the previous
  /// window had no rows. Mirrors the honesty rule of the web dashboard.
  static double? growth(PlatformMetric metric) {
    final previous = metric.previousNew;
    final current = metric.newCount;
    if (previous == null || current == null || previous == 0) return null;
    return (current - previous) / previous * 100;
  }
}

class PlatformMetric {
  const PlatformMetric({
    required this.total,
    this.newCount,
    this.previousNew,
    this.extra = const <String, int>{},
  });

  final int total;
  final int? newCount;
  final int? previousNew;

  /// Status-specific counters (`active`, `suspended`, `unresolved`, …).
  final Map<String, int> extra;

  int extraValue(String key) => extra[key] ?? 0;
}

class PlatformSeriesPoint {
  const PlatformSeriesPoint({
    required this.bucket,
    required this.tenants,
    required this.users,
    required this.waitlist,
    required this.contactMessages,
    required this.newsletterSubscribers,
  });

  final String bucket;
  final int tenants;
  final int users;
  final int waitlist;
  final int contactMessages;
  final int newsletterSubscribers;
}

class PlatformStatusCount {
  const PlatformStatusCount({required this.value, required this.count});

  final String value;
  final int count;
}

abstract class PlatformRepository {
  Future<PlatformDashboard> dashboard({String range = '30d'});
}
