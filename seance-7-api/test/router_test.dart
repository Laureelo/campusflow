import 'package:campusflow_api/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/test_app.dart';

Future<GoRouter> pumpRouter(WidgetTester tester) async {
  final router = buildRouter();
  addTearDown(router.dispose);

  await tester.pumpWidget(
    testScope(child: MaterialApp.router(routerConfig: router)),
  );
  await tester.pumpAndSettle();
  return router;
}

String currentPath(GoRouter router) {
  return router.routeInformationProvider.value.uri.path;
}

void main() {
  testWidgets('starts on the deadlines list', (tester) async {
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

  testWidgets('/login shows the sign in form without the navigation bar', (
    tester,
  ) async {
    final router = await pumpRouter(tester);

    router.go('/login');
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.enterText(find.byType(TextFormField).first, 'awa@campus.test');
    await tester.enterText(find.byType(TextFormField).last, 'secret');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(currentPath(router), '/taches');
  });
}
