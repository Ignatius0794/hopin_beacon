import 'dart:convert';

import 'package:qbyt/features/website/domain/entities/website_address.dart';

class WebsiteIdentity {
  const WebsiteIdentity({this.name, this.logoUrls = const []});

  final String? name;
  final List<String> logoUrls;

  String? get logoUrl => logoUrls.isEmpty ? null : logoUrls.first;

  static WebsiteIdentity? fromJavaScriptResult(
    Object? result,
    Uri pageUri,
  ) {
    try {
      dynamic decoded = result is String ? jsonDecode(result) : result;
      if (decoded is String) decoded = jsonDecode(decoded);
      if (decoded is! Map) return null;

      final rawName = decoded['name'];
      final rawLogos = decoded['logos'];
      final rawLogo = decoded['logo'];
      final name = rawName is String && rawName.trim().isNotEmpty
          ? rawName.trim()
          : null;
      final candidates = <Object?>[
        if (rawLogos is List) ...rawLogos,
        if (rawLogo is String) rawLogo,
        '/favicon.ico',
      ];
      final logoUrls = <String>[];
      for (final candidate in candidates) {
        if (candidate is! String || candidate.trim().isEmpty) continue;
        final logoUri = pageUri.resolve(candidate.trim());
        if (!WebsiteAddress.isWebUri(logoUri)) continue;
        final value = logoUri.toString();
        if (!logoUrls.contains(value)) logoUrls.add(value);
      }

      return WebsiteIdentity(name: name, logoUrls: logoUrls);
    } on FormatException {
      return null;
    }
  }
}
