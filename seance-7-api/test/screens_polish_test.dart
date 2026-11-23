import 'package:campusflow_api/core/token_storage.dart';
import 'package:campusflow_api/data/fake_task_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sample_data.dart';
import 'support/test_app.dart';

void main() {
  testWidgets('a course opens the list of its own deadlines', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Courses'));
    await tester.pumpAndSettle();
    expect(find.text('Mr. Moctar • 1 to do'), findsOneWidget);

    await tester.tap(find.text('Mobile Programming'));
    await tester.pumpAndSettle();

    expect(find.text('Mr. Moctar'), findsOneWidget);
    expect(find.text('Submit the Flutter assignment'), findsOneWidget);
    expect(find.text('Read chapter 4'), findsOneWidget);
    expect(find.text('Review the SQL joins'), findsNothing);

    await tester.tap(find.text('Submit the Flutter assignment'));
    await tester.pumpAndSettle();
    expect(find.text('Mark as done'), findsOneWidget);
  });

  testWidgets('a course without deadlines shows an empty message', (
    tester,
  ) async {
    final repository = FakeTaskRepository(
      tasks: buildSampleTasks().where((t) => t.courseId == 10).toList(),
    );
    await tester.pumpWidget(buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Courses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Networks'));
    await tester.pumpAndSettle();

    expect(find.text('No deadlines for this course'), findsOneWidget);
  });

  testWidgets('the header counts what is due and what is late', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('This week'), findsOneWidget);
    expect(find.textContaining('1 overdue'), findsOneWidget);
  });

  testWidgets('without any task the list invites to add one', (tester) async {
    await tester.pumpWidget(buildTestApp(repository: FakeTaskRepository()));
    await tester.pumpAndSettle();

    expect(find.text('No deadlines yet'), findsOneWidget);
    expect(find.text('Nothing due in the next 7 days'), findsOneWidget);
  });

  testWidgets('the eye button shows and hides the password', (tester) async {
    await tester.pumpWidget(buildTestApp(tokenStorage: MemoryTokenStorage()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).last, 'secret');
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    expect(find.text('secret'), findsOneWidget);
  });

  testWidgets('the profile summarizes the tasks', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Late'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(2));
  });
}
