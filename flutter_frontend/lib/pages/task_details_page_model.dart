import 'package:flutter_frontend/domain/set_task_done_use_case.dart';

class TaskDetailsPageModel {
  final SetTaskDoneUseCase _setTaskDoneUseCase;

  TaskDetailsPageModel(this._setTaskDoneUseCase);

  Future<bool> setTaskDone(String id) async =>
      _setTaskDoneUseCase.execute(id: id);
}
