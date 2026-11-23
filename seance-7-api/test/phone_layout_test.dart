import 'package:campusflow_api/core/api_client.dart';
import 'package:campusflow_api/core/token_storage.dart';
import 'package:campusflow_api/router/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/test_app.dart';

void usePhone(WidgetTester tester, {required double textScale}) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

Future<GoRouter> pumpApp(WidgetTester tester, {TokenStorage? storage}) async {
  await tester.pumpWidget(buildTestApp(tokenStorage: storage));
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  );
  return container.read(routerProvider);
}

void main() {
  const paths = [
    '/taches',
    '/taches/2',
    '/taches/nouvelle',
    '/cours',
    '/cours/10',
    '/profil',
  ];

  for (final scale in [1.0, 2.0]) {
    group('360 x 800 with text at ${(scale * 100).round()} %', () {
      for (final path in paths) {
        testWidgets('$path has no overflow', (tester) async {
          usePhone(tester, textScale: scale);
          final router = await pumpApp(tester);

          router.go(path);
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        });
      }

      testWidgets('the login screen has no overflow', (tester) async {
        usePhone(tester, textScale: scale);
        await pumpApp(tester, storage: MemoryTokenStorage());

        expect(find.text('Sign in'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  }

  group('API address', () {
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('the Android emulator reaches the computer through 10.0.2.2', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      expect(defaultBaseUrl(), 'http://10.0.2.2:3000');
    });

    test('other platforms use localhost', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;

      expect(defaultBaseUrl(), 'http://localhost:3000');
    });
  });
}
