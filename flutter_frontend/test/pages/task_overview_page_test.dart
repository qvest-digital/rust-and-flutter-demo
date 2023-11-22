import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/app_router.dart';
import 'package:flutter_frontend/core/app_router.gr.dart';
import 'package:flutter_frontend/data/models/task.dart';
import 'package:flutter_frontend/data/task_service.dart';
import 'package:flutter_frontend/pages/task_overview_page.dart';
import 'package:flutter_frontend/pages/task_overview_page_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'testable_widget_wrapper.dart';

class MockAppRouter extends Mock implements AppRouter {}

class MockTaskOverviewPageModel extends Mock implements TaskOverviewPageModel {}

class MockPageRouteInfo extends Mock implements PageRouteInfo<dynamic> {}

void main() {
  late MockAppRouter router;
  late MockTaskOverviewPageModel model;

  late TaskOverviewPage taskOverviewPage;

  late Widget wrappedWidget;

  setUpAll(() => registerFallbackValue(MockPageRouteInfo()));

  setUp(() {
    router = MockAppRouter();
    model = MockTaskOverviewPageModel();

    taskOverviewPage = const TaskOverviewPage();
    wrappedWidget = TestableWidgetWrapper(
      testSubject: taskOverviewPage,
      providers: [
        ListenableProvider<AppRouter>.value(value: router),
        Provider<TaskOverviewPageModel>.value(value: model),
      ],
    );
  });

  group('TaskOverviewPage', () {
    testWidgets('Should display according message when no tasks are present',
        (tester) async {
      // given
      when(() => model.getTasks()).thenAnswer(
        (_) => Future.value(
          const GetTasksResponse.success([]),
        ),
      );

      // when
      await tester.pumpWidget(wrappedWidget);
      await tester.pumpAndSettle();

      // then
      expect(find.text('No Tasks'), findsOneWidget);
      verifyZeroInteractions(router);
    });

    testWidgets('Should display error message when request fails',
        (tester) async {
      // given
      when(() => model.getTasks()).thenAnswer(
        (_) => Future.value(
          const GetTasksResponse.failure(null),
        ),
      );

      // when
      await tester.pumpWidget(wrappedWidget);
      await tester.pumpAndSettle();

      // then
      expect(find.text('Unknown error occurred.'), findsOneWidget);
      verifyZeroInteractions(router);
    });

    testWidgets('Should display task and set it done when Checkbox is clicked',
        (tester) async {
      // given
      when(() => model.getTasks()).thenAnswer(
        (_) => Future.value(
          GetTasksResponse.success([
            Task(
              id: 'testId',
              title: 'testTitle',
              created: DateTime.now(),
              done: false,
            ),
          ]),
        ),
      );
      when(() => model.setTaskDone(any()))
          .thenAnswer((_) => Future.value(true));

      // when
      await tester.pumpWidget(wrappedWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('TaskListItem_Checkbox_testId')));
      await tester.pumpAndSettle();

      // then
      verify(() => model.setTaskDone('testId'));
    });

    testWidgets('Should navigate to details view when task is clicked',
        (tester) async {
      // given
      when(() => model.getTasks()).thenAnswer(
        (_) => Future.value(
          GetTasksResponse.success([
            Task(
              id: 'testId',
              title: 'testTitle',
              created: DateTime.now(),
              done: false,
            ),
          ]),
        ),
      );
      when(() => router.push(any()))
          .thenAnswer((_) => Future.value(MockPageRouteInfo()));

      // when
      await tester.pumpWidget(wrappedWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('TaskListItem_testId')));
      await tester.pumpAndSettle();

      // then
      final capture = verify(() => router.push(captureAny())).captured;
      expect(capture.first is TaskDetailsRoute, true);
      expect((capture.first as TaskDetailsRoute).args?.task.id, 'testId');
    });
  });
}
