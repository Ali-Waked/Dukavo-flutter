import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/platform_domain.dart';

class PlatformRemoteDataSource {
  PlatformRemoteDataSource(this._api);

  final ApiClient _api;

  Future<PlatformDashboard> dashboard({String range = '30d'}) async {
    final data = await _api.get<JsonMap>(
      ApiPaths.platformDashboard,
      query: <String, dynamic>{'range': range},
      decode: _asMap,
    );
    return _dashboardFromJson(data);
  }
}

PlatformDashboard _dashboardFromJson(JsonMap json) {
  final range = json['range'];
  final rangeMap = range is Map
      ? Map<String, dynamic>.from(range)
      : const <String, dynamic>{};
  final rawSeries = json['series'];
  final rawStatus = json['status'];

  return PlatformDashboard(
    rangeKey: '${rangeMap['key'] ?? '30d'}',
    bucket: '${rangeMap['bucket'] ?? 'day'}',
    from: '${rangeMap['from'] ?? ''}',
    until: '${rangeMap['until'] ?? ''}',
    tenants: _metric(json['tenants']),
    users: _metric(json['users']),
    waitlist: _metric(json['waitlist']),
    contactMessages: _metric(json['contact_messages']),
    newsletterSubscribers: _metric(json['newsletter_subscribers']),
    plans: _metric(json['plans']),
    series: rawSeries is List
        ? rawSeries.whereType<Map>().map((entry) {
            final map = Map<String, dynamic>.from(entry);
            return PlatformSeriesPoint(
              bucket: '${map['bucket'] ?? ''}',
              tenants: _int(map['tenants']),
              users: _int(map['users']),
              waitlist: _int(map['waitlist']),
              contactMessages: _int(map['contact_messages']),
              newsletterSubscribers: _int(map['newsletter_subscribers']),
            );
          }).toList()
        : const <PlatformSeriesPoint>[],
    status: rawStatus is Map
        ? rawStatus.map<String, List<PlatformStatusCount>>((key, value) {
            if (value is! List) {
              return MapEntry(key, const <PlatformStatusCount>[]);
            }
            return MapEntry(
              key,
              value.whereType<Map>().map((entry) {
                final map = Map<String, dynamic>.from(entry);
                return PlatformStatusCount(
                  value: '${map['value'] ?? ''}',
                  count: _int(map['count']),
                );
              }).toList(),
            );
          })
        : const <String, List<PlatformStatusCount>>{},
  );
}

PlatformMetric _metric(Object? raw) {
  final map =
      raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
  final extras = <String, int>{};
  map.forEach((key, value) {
    if (key == 'total' || key == 'new' || key == 'previous_new') return;
    if (value is num) extras[key] = value.toInt();
  });
  return PlatformMetric(
    total: _int(map['total']),
    newCount: map['new'] == null ? null : _int(map['new']),
    previousNew: map['previous_new'] == null ? null : _int(map['previous_new']),
    extra: extras,
  );
}

int _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

JsonMap _asMap(Object? data) {
  if (data is Map) return Map<String, dynamic>.from(data);
  return const <String, dynamic>{};
}
