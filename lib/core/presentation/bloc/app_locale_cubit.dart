import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class AppLocaleCubit extends Cubit<Locale> {
  AppLocaleCubit(this._preferences)
      : super(_localeFor(_preferences.getString(_key) ?? 'en'));

  static const _key = 'app_language';
  final SharedPreferences _preferences;

  Future<void> changeLanguage(String languageCode) async {
    if (state.languageCode == languageCode) return;
    await _preferences.setString(_key, languageCode);
    emit(_localeFor(languageCode));
  }

  static Locale _localeFor(String languageCode) => languageCode == 'ms'
      ? const Locale('ms', 'MY')
      : const Locale('en', 'US');
}
