import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  const AppLocalizations(this.locale, this._translations);

  final Locale locale;
  final Map<String, String> _translations;

  static final _cache = <String, AppLocalizations>{};
  static const supportedLocales = [Locale('en', 'US'), Locale('ms', 'MY')];

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      const AppLocalizations(Locale('en', 'US'), {});

  static Future<AppLocalizations> load(Locale locale) {
    final fileName = locale.languageCode == 'ms' ? 'ms_MY' : 'en_US';
    final cached = _cache[fileName];
    if (cached != null) return SynchronousFuture(cached);
    return _loadAsset(locale, fileName);
  }

  static Future<AppLocalizations> _loadAsset(
    Locale locale,
    String fileName,
  ) async {
    final translations = <String, String>{};
    for (final directory in translationDirectories) {
      final source = await _loadTranslationFile(directory, fileName);
      if (source == null) continue;
      final json = jsonDecode(source) as Map<String, dynamic>;
      translations.addAll(
        json.map((key, value) => MapEntry(key, value.toString())),
      );
    }
    final localizations = AppLocalizations(
      locale,
      translations,
    );
    _cache[fileName] = localizations;
    return localizations;
  }

  static Future<String?> _loadTranslationFile(
    String directory,
    String fileName,
  ) async {
    try {
      return await rootBundle.loadString('$directory/$fileName.json');
    } on FlutterError {
      // Supports a hot-restarted build created before feature i18n files were
      // moved under presentation/. A full rebuild uses the canonical path.
      final legacyDirectory = directory.replaceFirst(
        '/presentation/i18n',
        '/i18n',
      );
      if (legacyDirectory == directory) return null;
      try {
        return await rootBundle.loadString('$legacyDirectory/$fileName.json');
      } on FlutterError {
        return null;
      }
    }
  }

  String text(String key) => _translations[key] ?? key;
}

/// Add a feature's i18n directory here when introducing a new feature.
const translationDirectories = [
  'lib/core/localization/translations',
  'lib/features/auth/presentation/i18n',
  'lib/features/menu/presentation/i18n',
];

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales
      .any((supported) => supported.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

const appLocalizationsDelegate = AppLocalizationsDelegate();

extension AppLocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String key) => l10n.text(key);
}
