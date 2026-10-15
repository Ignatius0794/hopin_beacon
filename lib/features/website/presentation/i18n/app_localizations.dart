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
    final source = await rootBundle.loadString(
      'lib/features/website/presentation/i18n/$fileName.json',
    );
    final json = jsonDecode(source) as Map<String, dynamic>;
    final localizations = AppLocalizations(
      locale,
      json.map((key, value) => MapEntry(key, value.toString())),
    );
    _cache[fileName] = localizations;
    return localizations;
  }

  String text(String english) {
    final websiteError = RegExp(
      r'^The website returned an error(?: \((\d+)\))?\. Please try again later\.$',
    ).firstMatch(english);
    if (websiteError != null) {
      return websiteReturnedError(int.tryParse(websiteError.group(1) ?? ''));
    }
    return _translations[english] ?? english;
  }

  String websiteReturnedError(int? code) {
    final template = _translations['_websiteReturnedError'] ??
        'The website returned an error{code}. Please try again later.';
    return template.replaceAll('{code}', code == null ? '' : ' ($code)');
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales
      .any((supported) => supported.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

const appLocalizationsDelegate = _AppLocalizationsDelegate();

extension AppLocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String english) => l10n.text(english);
}
