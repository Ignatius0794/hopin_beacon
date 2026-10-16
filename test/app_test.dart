import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sandbox/core/di/injection.dart';
import 'package:sandbox/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  tearDown(() => getIt.reset());

  testWidgets('logs in and logs out', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);

    await tester.enterText(find.bySemanticsLabel('Username'), 'admin');
    await tester.enterText(find.bySemanticsLabel('Password'), 'password');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Hello, admin'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);

    expect(
      Theme.of(tester.element(find.text('Home').last)).brightness,
      Brightness.light,
    );
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark mode'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Dark mode'))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
  });
}
