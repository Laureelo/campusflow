import 'package:campusflow_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the deadlines list with the navigation bar', (tester) async {
    await tester.pumpWidget(const CampusFlowApp());

    expect(find.text('Submit the Flutter assignment'), findsOneWidget);
    expect(find.text('Overdue'), findsOneWidget);

    await tester.tap(find.text('Courses'));
    await tester.pump();

    expect(find.text('Mobile Programming'), findsOneWidget);
  });

  testWidgets('opens the detail screen and marks a task as done', (tester) async {
    await tester.pumpWidget(const CampusFlowApp());

    await tester.tap(find.text('Submit the Flutter assignment'));
    await tester.pumpAndSettle();

    expect(find.text('Mark as done'), findsOneWidget);
    expect(find.text('Status: To do'), findsOneWidget);

    await tester.tap(find.text('Mark as done'));
    await tester.pumpAndSettle();

    expect(find.text('Mark as done'), findsNothing);
    expect(find.text('Overdue'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
  });
}
