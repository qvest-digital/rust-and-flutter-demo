import 'package:dio/dio.dart';
import 'package:flutter_frontend/data/models/create_task_dto.dart';
import 'package:flutter_frontend/data/models/task.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_service.freezed.dart';

class TaskService {
  final Dio dio;

  TaskService(this.dio);

  Future<GetTasksResponse> getTasks() async {
    try {
      final response = await dio.get('/tasks');
      if (response.statusCode == 200) {
        final tasks = (response.data as List<dynamic>)
            .map((e) => Task.fromJson(e))
            .toList();
        return GetTasksResponse.success(tasks);
      }
    } on Exception catch (e) {
      return GetTasksResponse.failure(e);
    }
    return const GetTasksResponse.failure(null);
  }

  Future<bool> createTask(CreateTaskDto dto) async {
    try {
      final response = await dio.post('/tasks', data: dto.toJson());
      if (response.statusCode == 201) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> markTaskAsDone(String id) async {
    try {
      final response = await dio.delete('/tasks/$id');
      if (response.statusCode == 202) {
        return true;
      }
    } catch (_) {}
    return false;
  }
}

@freezed
class GetTasksResponse with _$GetTasksResponse {
  const factory GetTasksResponse.success(List<Task> tasks) =
      GetTasksResponseSuccess;

  const factory GetTasksResponse.failure(Exception? e) =
      GetTasksResponseFailure;
}
