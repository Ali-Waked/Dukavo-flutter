/// A normalised API failure.
///
/// The UI branches on [statusCode], [fields] and [code]; it never sees a Dio
/// type. That keeps the data layer replaceable and keeps error copy in one
/// vocabulary.
class ApiException implements Exception {
  ApiException(
    this.message, {
    this.statusCode = 0,
    this.fields,
    this.code,
    this.isNetworkError = false,
  });

  final String message;

  /// `0` when the request never reached the server.
  final int statusCode;

  /// Field-keyed validation messages from a 422 response.
  final Map<String, List<String>>? fields;

  /// Machine-readable business-rule code from a 409 response.
  final String? code;

  final bool isNetworkError;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidation => statusCode == 422 && fields != null;

  /// The app already knows the device cannot reach the server, so the request
  /// was refused locally instead of waiting for a timeout.
  bool get isOffline => code == 'offline';

  String? fieldError(String field) {
    final messages = fields?[field];
    if (messages == null || messages.isEmpty) return null;
    return messages.first;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
