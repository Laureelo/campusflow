import 'package:campusflow_api/providers/filter_provider.dart';
import 'package:campusflow_api/providers/tasks_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

void main() {
  group('filteredTasksProvider', () {
    late ProviderContainer container;

    setUp(() async {
      container = testContainer(sampleRepository());
      addTearDown(container.dispose);
      await container.read(tasksProvider.future);
    });

    List<int> idsFor(TaskFilter filter) {
      container.read(filterProvider.notifier).select(filter);
      return container
          .read(filteredTasksProvider)
          .requireValue
          .map((t) => t.id)
          .toList();
    }

    test('all keeps every task', () {
      expect(idsFor(TaskFilter.all), [1, 2, 3, 4]);
    });

    test('todo keeps the tasks that are not done', () {
      expect(idsFor(TaskFilter.todo), [1, 2, 3]);
    });

    test('done keeps the finished tasks', () {
      expect(idsFor(TaskFilter.done), [4]);
    });

    test('overdue keeps the late tasks that are not done', () {
      expect(idsFor(TaskFilter.overdue), [2]);
    });

    test('the filtered list follows the tasks when one changes', () async {
      container.read(filterProvider.notifier).select(TaskFilter.overdue);
      expect(container.read(filteredTasksProvider).requireValue, hasLength(1));

      await container.read(tasksProvider.notifier).markDone(2);

      expect(container.read(filteredTasksProvider).requireValue, isEmpty);
    });
  });

  group('filter chips', () {
    testWidgets('the overdue chip keeps only the late task', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'Overdue'));
      await tester.pump();

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Review the SQL joins'), findsOneWidget);
      expect(find.text('Submit the Flutter assignment'), findsNothing);
    });

    testWidgets('an empty filter shows a message', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'Done'));
      await tester.pump();
      expect(find.byType(ListTile), findsOneWidget);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(find.text('No tasks for this filter'), findsOneWidget);
    });
  });
}
