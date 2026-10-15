import 'dart:convert';

import 'package:flutter/material.dart';

class WebsitePageColor {
  const WebsitePageColor._();

  static Color? fromJavaScriptResult(Object? result) {
    try {
      dynamic decoded = result is String ? jsonDecode(result) : result;
      if (decoded is String) decoded = jsonDecode(decoded);
      if (decoded is! List || decoded.length != 3) return null;

      final channels = decoded.map((value) {
        if (value is! num || !value.isFinite) return null;
        return value.round().clamp(0, 255).toInt();
      }).toList();
      if (channels.any((value) => value == null)) return null;

      return Color.fromARGB(
        255,
        channels[0]!,
        channels[1]!,
        channels[2]!,
      );
    } on FormatException {
      return null;
    }
  }
}
