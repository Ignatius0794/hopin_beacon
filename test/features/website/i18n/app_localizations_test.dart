import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qbyt/core/presentation/bloc/app_locale_cubit.dart';
import 'package:qbyt/features/website/presentation/i18n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads Malay translations from JSON', () async {
    final localizations = await AppLocalizations.load(
      const Locale('ms', 'MY'),
    );

    expect(localizations.text('Continue'), 'Teruskan');
    expect(
      localizations.text(
        'The website returned an error (503). Please try again later.',
      ),
      'Laman web mengembalikan ralat (503). Sila cuba lagi kemudian.',
    );
  });

  test('selected language persists for the next app launch', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final locale = AppLocaleCubit(preferences);

    expect(locale.state.languageCode, 'en');
    await locale.changeLanguage('ms');
    await locale.close();

    final restoredLocale = AppLocaleCubit(preferences);
    expect(restoredLocale.state.languageCode, 'ms');
    await restoredLocale.close();
  });
}
