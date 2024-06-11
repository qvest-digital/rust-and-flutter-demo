import 'package:flutter_frontend/data/task_service.dart';

class SetTaskDoneUseCase {
  final TaskService service;

  SetTaskDoneUseCase(this.service);

  Future<bool> execute({required String id}) async =>
      service.markTaskAsDone(id);
}
