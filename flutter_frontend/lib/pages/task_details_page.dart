import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/app_router.dart';
import 'package:flutter_frontend/core/app_router.gr.dart';
import 'package:flutter_frontend/data/models/task.dart';
import 'package:flutter_frontend/pages/task_details_page_model.dart';
import 'package:flutter_frontend/ui/common.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

@RoutePage()
class TaskDetailsPage extends StatelessWidget {
  final Task task;

  const TaskDetailsPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) => Consumer<TaskDetailsPageModel>(
        builder: (context, model, _) => Scaffold(
          appBar: AppBar(
            leading: InkWell(
              onTap: () => context.read<AppRouter>().pop(),
              child: const Icon(Icons.arrow_back),
            ),
            title: Text(
              task.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: headlineTextStyle,
                    ),
                    const Gap(8),
                    Text(task.created.toString()),
                    const Divider(),
                    const Gap(8),
                    const Text('Description:'),
                    const Gap(4),
                    Text(task.description ?? '-'),
                  ],
                ),
              ),
              if (!task.done)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: double.infinity),
                      child: ElevatedButton(
                        onPressed: () async {
                          final router = context.read<AppRouter>();
                          await model.setTaskDone(task.id);
                          router.pushAndPopUntil(
                            const TaskOverviewRoute(),
                            predicate: (_) => true,
                          );
                        },
                        child: const Text('Mark as Done'),
                      ),
                    ),
                  ),
                ),
              if (task.done)
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 48,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}
