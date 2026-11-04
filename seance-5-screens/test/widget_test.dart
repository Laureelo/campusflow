import 'package:campusflow_app/main.dart';
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
}
