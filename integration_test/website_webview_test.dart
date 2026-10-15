import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qbyt/features/website/data/datasources/website_local_datasource.dart';
import 'package:qbyt/features/website/presentation/widgets/website_menu_edge.dart';
import 'package:qbyt/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'a failed replacement URL can restore the previous native WebView page',
    (tester) async {
      if (!Platform.isAndroid && !Platform.isIOS) return;

      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      server.listen((request) {
        request.response
          ..headers.contentType = ContentType.html
          ..write('''
            <!doctype html>
            <html>
              <head><title>QBYT integration website</title></head>
              <body><h1>Previous website</h1></body>
            </html>
          ''')
          ..close();
      });

      final unusedServer =
          await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final unavailablePort = unusedServer.port;
      await unusedServer.close(force: true);

      final preferences = await SharedPreferences.getInstance();
      await preferences.clear();
      await app.main();
      await tester.pump(const Duration(seconds: 3));

      final previousUrl = 'http://127.0.0.1:${server.port}/';
      await tester.enterText(find.byType(TextFormField), previousUrl);
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(seconds: 3));

      await tester.tap(find.byType(WebsiteMenuEdge));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Change URL'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'http://127.0.0.1:$unavailablePort/',
      );
      await tester.tap(find.text('Change website'));
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('Restore previous website'), findsOneWidget);
      expect(find.text('127.0.0.1'), findsOneWidget);
      await tester.tap(find.text('Restore previous website'));
      await tester.pump(const Duration(seconds: 3));

      expect(
        preferences.getString(WebsiteLocalDataSource.addressKey),
        previousUrl,
      );
      await tester.tap(find.byType(WebsiteMenuEdge));
      await tester.pumpAndSettle();
      expect(find.text(previousUrl), findsOneWidget);
      expect(find.text('QBYT integration website'), findsOneWidget);
    },
  );
}
