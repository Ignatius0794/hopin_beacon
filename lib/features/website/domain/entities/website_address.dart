/// Validates website addresses without discarding paths, queries or fragments.
class WebsiteAddress {
  const WebsiteAddress._(this.value);
  final String value;

  static bool isWebUri(Uri uri) =>
      (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;

  static WebsiteAddress? tryParse(String input) {
    final value = input.trim();
    if (value.isEmpty || RegExp(r'\s').hasMatch(value)) return null;
    // A missing scheme defaults to HTTPS; explicit non-web schemes are rejected.
    final candidate = value.contains('://') ? value : 'https://$value';
    try {
      final uri = Uri.parse(candidate);
      if (!isWebUri(uri) ||
          uri.userInfo.isNotEmpty ||
          (uri.hasPort && (uri.port < 1 || uri.port > 65535))) {
        return null;
      }
      final host = uri.host;
      // Bare words are usually accidental input; explicit intranet URLs still work.
      if (!value.contains('://') &&
          !host.contains('.') &&
          !host.contains(':') &&
          host != 'localhost') {
        return null;
      }
      if (host.length > 253) return null;
      if (RegExp(r'^\d+\.\d+\.\d+\.\d+$').hasMatch(host) &&
          host.split('.').any((part) => int.parse(part) > 255)) {
        return null;
      }
      if (!host.contains(':') &&
          !host.split('.').every((label) =>
              label.isNotEmpty &&
              label.length <= 63 &&
              RegExp(r'^[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$')
                  .hasMatch(label))) {
        return null;
      }
      return WebsiteAddress._(uri.toString());
    } on FormatException {
      return null;
    }
  }
}
