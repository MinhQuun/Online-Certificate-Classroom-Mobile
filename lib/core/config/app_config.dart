/// Global configuration values for the mobile app.
class AppConfig {
  AppConfig._();

  static const String appName = 'Online Certificate Classroom';

  /// Laravel Student API base URL (dev).
  // static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // IP Quân
  static const String baseUrl = 'http://192.168.1.3:8000/api/v1';

  /// Returns the base student portal origin without `/api/vX`.
  static Uri get portalBaseUri {
    final uri = Uri.parse(baseUrl);
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
    );
  }

  /// Builds an absolute student portal URL from a relative [path].
  static Uri portalUri(String path) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return portalBaseUri.resolve(normalized);
  }
}
