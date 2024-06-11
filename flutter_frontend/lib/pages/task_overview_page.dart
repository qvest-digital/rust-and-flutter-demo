import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/app_router.dart';
import 'package:flutter_frontend/core/app_router.gr.dart';
import 'package:flutter_frontend/data/models/task.dart';
import 'package:flutter_frontend/data/task_service.dart';
import 'package:flutter_frontend/pages/task_overview_page_model.dart';
import 'package:flutter_frontend/ui/common.dart';
import 'package:flutter_frontend/ui/components/centered_circular_progress_indicator.dart';
import 'package:flutter_frontend/ui/components/error_card.dart';
import 'package:flutter_frontend/ui/dialogs/create_task_dialog.dart';
import 'package:provider/provider.dart';

@RoutePage()
class TaskOverviewPage extends StatefulWidget {
  const TaskOverviewPage({super.key});

  @override
  State<TaskOverviewPage> createState() => _TaskOverviewPageState();
}

class _TaskOverviewPageState extends State<TaskOverviewPage> {
  bool isLoading = true;
  GetTasksResponse? tasksResponse;

  @override
  Widget build(BuildContext context) => Consumer<TaskOverviewPageModel>(
        builder: (context, model, _) {
          if (tasksResponse == null) {
            _reload(model);
          }
          if (isLoading) {
            return const Scaffold(
              body: CenteredCircularProgressIndicator(),
            );
          }
          if (tasksResponse is GetTasksResponseSuccess) {
            final tasks = (tasksResponse as GetTasksResponseSuccess).tasks;
            return Scaffold(
              resizeToAvoidBottomInset: false,
              body: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      mainAxisAlignment: tasks.isEmpty
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: _buildContent(model, tasks),
                    ),
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (_) => CreateTaskDialog(
                          createTask: (title, description) async {
                            setState(() => isLoading = true);
                            final result = await model.createTask(
                              title: title,
                              description: description,
                            );
                            _reload(model);
                            return result;
                          },
                        )),
                child: const Icon(
                  Icons.add,
                  size: 32,
                ),
              ),
            );
          }
          return Scaffold(
            body: ErrorCard(
              (tasksResponse! as GetTasksResponseFailure).e?.toString() ??
                  'Unknown error occurred.',
            ),
          );
        },
      );

  List<Widget> _buildContent(TaskOverviewPageModel model, List<Task> tasks) {
    if (tasks.isEmpty) {
      return [
        const Icon(
          Icons.checklist,
          color: Colors.black87,
          size: 48,
        ),
        const Center(
          child: Text('No Tasks'),
        ),
      ];
    }
    return [
      RefreshIndicator(
        onRefresh: () async => _reload(model),
        child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (context, i) => _TaskListItem(tasks[i], (id) async {
            setState(() => isLoading = true);
            await model.setTaskDone(id);
            _reload(model);
          }),
          separatorBuilder: (context, _) => const Divider(),
          itemCount: tasks.length,
        ),
      )
    ];
  }

  void _reload(TaskOverviewPageModel model) async {
    final result = await model.getTasks();
    setState(() {
      tasksResponse = result;
      isLoading = false;
    });
  }
}

class _TaskListItem extends StatelessWidget {
  final Task task;
  final void Function(String id) onSetDone;

  const _TaskListItem(this.task, this.onSetDone);

  @override
  Widget build(BuildContext context) => InkWell(
        key: Key('TaskListItem_${task.id}'),
        onTap: () =>
            context.read<AppRouter>().push(TaskDetailsRoute(task: task)),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16,
            right: 32,
            bottom: 16,
            left: 32,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  if (!task.done)
                    Checkbox(
                      key: Key('TaskListItem_Checkbox_${task.id}'),
                      value: false,
                      onChanged: (_) => onSetDone(task.id),
                    ),
                  if (task.done)
                    const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 32,
                    ),
                  const Text(
                    'Done?',
                    style: smallHintTextStyle,
                  ),
                ],
              ),
              Text(
                task.title,
                style: task.done ? titleDoneTextStyle : titleTextStyle,
              ),
              Text(
                  '${task.created.year}-${task.created.month}-${task.created.day}'),
            ],
          ),
        ),
      );
}
