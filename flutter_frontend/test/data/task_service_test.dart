import 'package:dio/dio.dart';
import 'package:flutter_frontend/data/models/create_task_dto.dart';
import 'package:flutter_frontend/data/task_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'tasks_service_test.fixtures.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response {}

void main() {
  late MockDio dio;
  late MockResponse response;

  late TaskService taskService;

  setUp(() {
    dio = MockDio();
    response = MockResponse();
    taskService = TaskService(dio);
  });

  group('getTasks', () {
    test(
        'Should return GetTasksResponse.success with tasks when response has status 200',
        () async {
      // given
      when(() => response.statusCode).thenReturn(200);
      when(() => response.data).thenReturn(getTasksResponse);
      when(() => dio.get('/tasks')).thenAnswer((_) => Future.value(response));

      // when
      final result = await taskService.getTasks();

      // then
      expect(result is GetTasksResponseSuccess, true);
      final tasks = (result as GetTasksResponseSuccess).tasks;
      expect(tasks.length, 2);
      expect(tasks.first.id, '0db40fee-9ebb-4af8-b216-1c90bcf33fed');
      expect(tasks.first.title, 'Test 1');
      expect(tasks.first.description, null);
      expect(tasks.first.created.toIso8601String(), '2023-10-24T13:23:18.000Z');
      expect(tasks.first.done, false);
      expect(tasks.last.id, 'a38d7b6b-c9d0-4ce4-9e34-8b845f93909e');
      expect(tasks.last.title, 'Test 2');
      expect(tasks.last.description, 'Test-description...');
      expect(tasks.last.created.toIso8601String(), '2023-10-23T13:15:00.000Z');
      expect(tasks.last.done, true);
    });

    test('Should return GetTasksResponse.failure when the response is not 200',
        () async {
      // given
      when(() => response.statusCode).thenReturn(400);
      when(() => dio.get('/tasks')).thenAnswer((_) => Future.value(response));

      // when
      final result = await taskService.getTasks();

      // then
      expect(result is GetTasksResponseFailure, true);
      expect((result as GetTasksResponseFailure).e, null);
    });

    test('Should return GetTasksResponse.failure when the request fails',
        () async {
      // given
      final e = DioException(requestOptions: RequestOptions());
      when(() => dio.get('/tasks')).thenThrow(e);

      // when
      final result = await taskService.getTasks();

      // then
      expect(result is GetTasksResponseFailure, true);
      expect((result as GetTasksResponseFailure).e, e);
    });
  });

  group('createTask', () {
    test('Should return true when request succeeds', () async {
      // given
      final task = CreateTaskDto(title: 'TestTask', description: 'test');
      when(() => response.statusCode).thenReturn(201);
      when(() => dio.post('/tasks', data: task.toJson()))
          .thenAnswer((_) => Future.value(response));

      // when
      final result = await taskService.createTask(task);

      // then
      expect(result, true);
    });

    test('Should return false when request fails', () async {
      // given
      final task = CreateTaskDto(title: 'TestTask');
      when(() => dio.post('/tasks', data: any(named: 'data')))
          .thenThrow(DioException(requestOptions: RequestOptions()));

      // when
      final result = await taskService.createTask(task);

      // then
      expect(result, false);
    });
  });

  group('markTaskAsDone', () {
    test('Should return true when requests succeeds', () async {
      // given
      when(() => response.statusCode).thenReturn(202);
      when(() => dio.delete('/tasks/testId'))
          .thenAnswer((_) => Future.value(response));

      // when
      final result = await taskService.markTaskAsDone('testId');

      expect(result, true);
    });

    test('Should return true when requests fails', () async {
      // given
      when(() => response.statusCode).thenReturn(404);
      when(() => dio.delete('/tasks/testId'))
          .thenAnswer((_) => Future.value(response));

      // when
      final result = await taskService.markTaskAsDone('testId');

      expect(result, false);
    });
  });
}
