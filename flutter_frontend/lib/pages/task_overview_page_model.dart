import 'package:flutter_frontend/data/task_service.dart';
import 'package:flutter_frontend/domain/create_task_use_case.dart';
import 'package:flutter_frontend/domain/get_tasks_use_case.dart';
import 'package:flutter_frontend/domain/set_task_done_use_case.dart';

class TaskOverviewPageModel {
  final GetTasksUseCase _getTasksUseCase;
  final SetTaskDoneUseCase _setTaskDoneUseCase;
  final CreateTaskUseCase _createTaskUseCase;

  GetTasksResponse? _tasksResponse;

  TaskOverviewPageModel(
    this._getTasksUseCase,
    this._setTaskDoneUseCase,
    this._createTaskUseCase,
  );

  GetTasksResponse? get tasksResponse => _tasksResponse;

  Future<GetTasksResponse> getTasks() async => _getTasksUseCase.execute();

  Future<bool> setTaskDone(String id) async =>
      _setTaskDoneUseCase.execute(id: id);

  Future<bool> createTask({required String title, String? description}) async =>
      _createTaskUseCase.execute(title: title, description: description);
}
