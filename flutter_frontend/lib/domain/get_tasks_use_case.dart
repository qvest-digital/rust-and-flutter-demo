import 'package:flutter_frontend/data/task_service.dart';

class GetTasksUseCase {
  final TaskService service;

  GetTasksUseCase(this.service);

  Future<GetTasksResponse> execute() async => service.getTasks();
}
