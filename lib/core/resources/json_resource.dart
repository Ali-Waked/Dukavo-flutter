import '../api/api_client.dart';

/// A read-only view over one JSON object returned by the API.
///
/// The admin surfaces cover dozens of resources whose shapes differ only in a
/// handful of keys. Wrapping the map keeps the screens type-safe at the edges
/// without hand-writing a model for every platform table.
class JsonResource {
  const JsonResource(this.data);

  final JsonMap data;

  factory JsonResource.fromJson(JsonMap json) => JsonResource(json);

  int get id {
    final value = data['id'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  bool has(String key) => data.containsKey(key) && data[key] != null;

  String text(String key, {String fallback = ''}) {
    final value = data[key];
    if (value == null) return fallback;
    if (value is bool) return value ? 'true' : 'false';
    final text = '$value'.trim();
    return text.isEmpty ? fallback : text;
  }

  String? optionalText(String key) {
    final value = data[key];
    if (value == null) return null;
    final text = '$value'.trim();
    return text.isEmpty ? null : text;
  }

  bool flag(String key) {
    final value = data[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  }

  num? number(String key) {
    final value = data[key];
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  JsonMap? map(String key) {
    final value = data[key];
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  List<JsonMap> maps(String key) {
    final value = data[key];
    if (value is! List) return const <JsonMap>[];
    return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  List<String> strings(String key) {
    final value = data[key];
    if (value is! List) return const <String>[];
    return value.map((entry) => '$entry').toList();
  }
}
