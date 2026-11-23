import 'package:campusflow_api/core/token_storage.dart';
import 'package:campusflow_api/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/test_app.dart';

Future<GoRouter> pumpRouter(
  WidgetTester tester, {
  TokenStorage? tokenStorage,
}) async {
  await tester.pumpWidget(buildTestApp(tokenStorage: tokenStorage));
  await tester.pumpAndSettle();

  final container = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  );
  return container.read(routerProvider);
}

String currentPath(GoRouter router) {
  return router.routeInformationProvider.value.uri.path;
}

void main() {
  testWidgets('starts on the deadlines list when signed in', (tester) async {
    final router = await pumpRouter(tester);

    expect(currentPath(router), '/taches');
    expect(find.text('Submit the Flutter assignment'), findsOneWidget);
  });

  testWidgets('the id in the path opens the matching task', (tester) async {
    final router = await pumpRouter(tester);

    router.go('/taches/2');
    await tester.pumpAndSettle();

    expect(find.text('Review the SQL joins'), findsOneWidget);
    expect(find.text('Status: Overdue'), findsOneWidget);
  });

  testWidgets('an unknown id shows a not found message', (tester) async {
    final router = await pumpRouter(tester);

    router.go('/taches/999');
    await tester.pumpAndSettle();
    expect(find.text('Task not found'), findsOneWidget);

    router.go('/taches/abc');
    await tester.pumpAndSettle();
    expect(find.text('Task not found'), findsOneWidget);
  });

  testWidgets('/taches/nouvelle opens the form and is not read as an id', (
    tester,
  ) async {
    final router = await pumpRouter(tester);

    router.go('/taches/nouvelle');
    await tester.pumpAndSettle();

    expect(find.text('New deadline'), findsOneWidget);
    expect(find.text('Task not found'), findsNothing);
  });

  testWidgets('the navigation bar switches between the three destinations', (
    tester,
  ) async {
    final router = await pumpRouter(tester);

    await tester.tap(find.text('Courses'));
    await tester.pumpAndSettle();
    expect(currentPath(router), '/cours');
    expect(find.text('Mobile Programming'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(currentPath(router), '/profil');
    expect(find.text('awa@campus.test'), findsOneWidget);

    await tester.tap(find.text('Deadlines'));
    await tester.pumpAndSettle();
    expect(currentPath(router), '/taches');
  });

  group('authentication', () {
    testWidgets('without a token the app opens on the login screen', (
      tester,
    ) async {
      final router = await pumpRouter(
        tester,
        tokenStorage: MemoryTokenStorage(),
      );

      expect(currentPath(router), '/login');
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('a protected address sends a signed out user to /login', (
      tester,
    ) async {
      final router = await pumpRouter(
        tester,
        tokenStorage: MemoryTokenStorage(),
      );

      router.go('/taches/2');
      await tester.pumpAndSettle();

      expect(currentPath(router), '/login');
    });

    testWidgets('a wrong password shows a message and stays on /login', (
      tester,
    ) async {
      final storage = MemoryTokenStorage();
      final router = await pumpRouter(tester, tokenStorage: storage);

      await tester.enterText(
        find.byType(TextFormField).first,
        'awa@campus.test',
      );
      await tester.enterText(find.byType(TextFormField).last, 'nope');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Wrong email or password'), findsOneWidget);
      expect(currentPath(router), '/login');
      expect(await storage.read(), isNull);
    });

    testWidgets('a good login stores the token and opens the list', (
      tester,
    ) async {
      final storage = MemoryTokenStorage();
      final router = await pumpRouter(tester, tokenStorage: storage);

      await tester.enterText(
        find.byType(TextFormField).first,
        'awa@campus.test',
      );
      await tester.enterText(find.byType(TextFormField).last, 'campus123');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(await storage.read(), 'fake-token');
      expect(currentPath(router), '/taches');
      expect(find.text('Submit the Flutter assignment'), findsOneWidget);
    });

    testWidgets('signing out clears the token and goes back to /login', (
      tester,
    ) async {
      final storage = signedInStorage();
      final router = await pumpRouter(tester, tokenStorage: storage);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(await storage.read(), isNull);
      expect(currentPath(router), '/login');
    });

    testWidgets('a signed in user opening /login is sent to the list', (
      tester,
    ) async {
      final router = await pumpRouter(tester);

      router.go('/login');
      await tester.pumpAndSettle();

      expect(currentPath(router), '/taches');
    });
  });
}
