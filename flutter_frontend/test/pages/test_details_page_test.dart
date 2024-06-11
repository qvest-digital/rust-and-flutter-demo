import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/app_router.dart';
import 'package:flutter_frontend/core/app_router.gr.dart';
import 'package:flutter_frontend/data/models/task.dart';
import 'package:flutter_frontend/pages/task_details_page.dart';
import 'package:flutter_frontend/pages/task_details_page_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'testable_widget_wrapper.dart';

class MockAppRouter extends Mock implements AppRouter {}

class MockTaskDetailsPageModel extends Mock implements TaskDetailsPageModel {}

class MockPageRouteInfo extends Mock implements PageRouteInfo<dynamic> {}

void main() {
  final task = Task(
    id: 'testId',
    title: 'testTitle',
    created: DateTime.now(),
    done: false,
  );

  late MockAppRouter router;
  late MockTaskDetailsPageModel model;

  late TaskDetailsPage taskDetailsPage;

  late Widget wrappedWidget;

  setUpAll(() => registerFallbackValue(MockPageRouteInfo()));

  setUp(() {
    router = MockAppRouter();
    model = MockTaskDetailsPageModel();

    taskDetailsPage = TaskDetailsPage(task: task);
    wrappedWidget = TestableWidgetWrapper(
      testSubject: taskDetailsPage,
      providers: [
        ListenableProvider<AppRouter>.value(value: router),
        Provider<TaskDetailsPageModel>.value(value: model),
      ],
    );
  });

  group('TaskDetailsPage', () {
    testWidgets(
        'Should submit request & return to overview when `Mark as Done` is tapped',
        (tester) async {
      // given
      when(() => model.setTaskDone(any()))
          .thenAnswer((_) => Future.value(true));
      when(() =>
              router.pushAndPopUntil(any(), predicate: any(named: 'predicate')))
          .thenAnswer((_) => Future.value(MockPageRouteInfo()));

      // when
      await tester.pumpWidget(wrappedWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark as Done'));
      await tester.pumpAndSettle();

      // then
      verify(() => model.setTaskDone('testId'));
      final capture = verify(() => router.pushAndPopUntil(captureAny(),
          predicate: any(named: 'predicate'))).captured;
      expect(capture.first is TaskOverviewRoute, true);
    });
  });
}
