import 'package:auto_route/auto_route.dart';
import 'package:flutter_frontend/core/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: TaskOverviewRoute.page, path: '/'),
        AutoRoute(page: TaskDetailsRoute.page, path: '/task'),
      ];
}
