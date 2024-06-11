import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/app_router.dart';
import 'package:flutter_frontend/data/client.dart';
import 'package:flutter_frontend/data/task_service.dart';
import 'package:flutter_frontend/domain/create_task_use_case.dart';
import 'package:flutter_frontend/domain/get_tasks_use_case.dart';
import 'package:flutter_frontend/domain/set_task_done_use_case.dart';
import 'package:flutter_frontend/pages/task_details_page_model.dart';
import 'package:flutter_frontend/pages/task_overview_page_model.dart';
import 'package:flutter_frontend/ui/app_theme.dart';
import 'package:flutter_frontend/ui/common.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final router = AppRouter();
  final dio = Client.get();
  final taskService = TaskService(dio);
  final getTasksUseCase = GetTasksUseCase(taskService);
  final setTaskDoneUseCase = SetTaskDoneUseCase(taskService);
  final createTaskUseCase = CreateTaskUseCase(taskService);

  runApp(MultiProvider(
    providers: [
      ListenableProvider<AppRouter>.value(value: router),
      Provider<TaskOverviewPageModel>.value(
        value: TaskOverviewPageModel(
          getTasksUseCase,
          setTaskDoneUseCase,
          createTaskUseCase,
        ),
      ),
      Provider<TaskDetailsPageModel>.value(
        value: TaskDetailsPageModel(
          setTaskDoneUseCase,
        ),
      ),
    ],
    child: App(router: router),
  ));
}

class App extends StatelessWidget {
  final AppRouter router;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  App({super.key, required this.router});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Demo ToDo App',
        routerDelegate: router.delegate(),
        routeInformationParser: router.defaultRouteParser(),
        builder: (context, routing) =>
            Provider<GlobalKey<NavigatorState>>.value(
          value: _navigatorKey,
          child: Theme(
            data: appTheme,
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                primaryColor: Colors.white,
                textTheme: CupertinoTextThemeData(
                  navTitleTextStyle: headlineTextStyle2,
                  navActionTextStyle: headlineTextStyle3,
                ),
              ),
              child: DefaultTextStyle(
                style: appTheme.textTheme.bodyMedium!,
                child: routing!,
              ),
            ),
          ),
        ),
      );
}
