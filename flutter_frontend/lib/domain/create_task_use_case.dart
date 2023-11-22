import 'package:flutter_frontend/data/models/create_task_dto.dart';
import 'package:flutter_frontend/data/task_service.dart';

class CreateTaskUseCase {
  final TaskService service;

  CreateTaskUseCase(this.service);

  Future<bool> execute({required String title, String? description}) async =>
      service.createTask(CreateTaskDto(title: title, description: description));
}
