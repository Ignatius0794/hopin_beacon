import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class AppThemeCubit extends Cubit<ThemeMode> {
  AppThemeCubit(this._preferences)
      : super(_preferences.getBool(_key) ?? false
            ? ThemeMode.dark
            : ThemeMode.light);

  static const _key = 'dark_mode';
  final SharedPreferences _preferences;

  Future<void> setDarkMode(bool enabled) async {
    await _preferences.setBool(_key, enabled);
    emit(enabled ? ThemeMode.dark : ThemeMode.light);
  }
}
