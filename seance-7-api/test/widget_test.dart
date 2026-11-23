import 'package:campusflow_api/core/api_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(buildTestApp());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the deadlines list with the navigation bar', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Submit the Flutter assignment'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.text('Overdue'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Courses'));
    await tester.pumpAndSettle();

    expect(find.text('Mobile Programming'), findsOneWidget);
  });

  testWidgets('shows a loading indicator until the tasks arrive', (
    tester,
  ) async {
    final repository = sampleRepository(delay: const Duration(seconds: 1));
    await tester.pumpWidget(buildTestApp(repository: repository));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Submit the Flutter assignment'), findsOneWidget);
  });

  testWidgets('shows the error with a Retry button that loads again', (
    tester,
  ) async {
    final repository = sampleRepository()
      ..failure = const ApiException('Cannot reach the server');
    await tester.pumpWidget(buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Cannot reach the server'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);

    repository.failure = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Cannot reach the server'), findsNothing);
    expect(find.text('Submit the Flutter assignment'), findsOneWidget);
  });

  testWidgets('a checkbox toggles the task everywhere', (tester) async {
    await pumpApp(tester);

    final first = find.byType(Checkbox).first;
    expect(tester.widget<Checkbox>(first).value, isFalse);

    await tester.tap(first);
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(first).value, isTrue);
  });

  testWidgets('a failed toggle shows a message and keeps the checkbox', (
    tester,
  ) async {
    final repository = sampleRepository();
    await tester.pumpWidget(buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    repository.failure = const ApiException('Cannot reach the server');
    final first = find.byType(Checkbox).first;
    await tester.tap(first);
    await tester.pumpAndSettle();

    expect(find.text('Cannot reach the server'), findsOneWidget);
    expect(tester.widget<Checkbox>(first).value, isFalse);
  });

  testWidgets('the detail screen marks the task as done in the list too', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Submit the Flutter assignment'));
    await tester.pumpAndSettle();

    expect(find.text('Status: To do'), findsOneWidget);

    await tester.tap(find.text('Mark as done'));
    await tester.pumpAndSettle();

    expect(find.text('Status: Done'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, isTrue);
  });

  testWidgets('deleting from the detail asks first then removes the task', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Review the SQL joins'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this deadline?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Review the SQL joins'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Delete'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Review the SQL joins'), findsNothing);
    expect(find.text('Submit the Flutter assignment'), findsOneWidget);
  });

  testWidgets('shows the list and the detail side by side on a wide screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpApp(tester);

    expect(find.text('Select a deadline'), findsOneWidget);

    await tester.tap(find.text('Submit the Flutter assignment'));
    await tester.pumpAndSettle();

    expect(find.text('Mark as done'), findsOneWidget);
    expect(find.text('Submit the Flutter assignment'), findsNWidgets(2));
  });

  testWidgets('the form validates then adds a deadline', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Title is required'), findsOneWidget);
    expect(find.text('Pick a due date'), findsOneWidget);
    expect(find.text('Pick a course'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'Write the report',
    );

    await tester.tap(find.byType(TextFormField).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Course'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Databases').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Write the report'), findsOneWidget);
    expect(find.text('Deadline added'), findsOneWidget);
  });
}
