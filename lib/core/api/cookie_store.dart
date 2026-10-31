import 'dart:convert';

/// A deliberately tiny cookie jar for Sanctum's CSRF handshake.
///
/// Only two cookies matter (`XSRF-TOKEN` and `laravel_session`) and they live
/// for the duration of the process. A full cookie-jar dependency would add
/// persistence and policy the app does not need; this keeps the transport
/// honest without hiding behaviour in a package.
class CookieStore {
  final Map<String, String> _cookies = <String, String>{};

  String? get xsrfToken => _cookies['XSRF-TOKEN'];

  bool get isEmpty => _cookies.isEmpty;

  void absorb(Iterable<String>? setCookieHeaders) {
    if (setCookieHeaders == null) return;
    for (final header in setCookieHeaders) {
      final first = header.split(';').first;
      final index = first.indexOf('=');
      if (index <= 0) continue;
      final name = first.substring(0, index).trim();
      final value = first.substring(index + 1).trim();
      if (value.isEmpty) {
        _cookies.remove(name);
      } else {
        _cookies[name] = value;
      }
    }
  }

  /// The decoded CSRF value Laravel expects in `X-XSRF-TOKEN`.
  String? get decodedXsrfToken {
    final raw = xsrfToken;
    if (raw == null) return null;
    try {
      return Uri.decodeComponent(raw);
    } on FormatException {
      return raw;
    }
  }

  String get cookieHeader => _cookies.entries
      .map((entry) => '${entry.key}=${entry.value}')
      .join('; ');

  void clear() => _cookies.clear();

  Map<String, String> toJson() => Map<String, String>.from(_cookies);

  @override
  String toString() => jsonEncode(_cookies.keys.toList());
}
