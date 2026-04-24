import 'package:go_router/go_router.dart';

import '../../features/app_state/golife_controller.dart';
import '../../features/capture/capture_screen.dart';
import '../../features/copilot/copilot_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/domains/domain_screens.dart';
import '../../features/settings/privacy_screen.dart';
import '../shell/app_shell_scaffold.dart';

GoRouter buildAppRouter(GoLifeController controller) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShellScaffold(
            controller: controller,
            currentLocation: state.uri.toString(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => DashboardScreen(controller: controller),
          ),
          GoRoute(
            path: '/capture',
            builder: (context, state) => CaptureScreen(controller: controller),
          ),
          GoRoute(
            path: '/week',
            builder: (context, state) => WeekScreen(controller: controller),
          ),
          GoRoute(
            path: '/habits',
            builder: (context, state) => HabitsScreen(controller: controller),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => TasksScreen(controller: controller),
          ),
          GoRoute(
            path: '/money',
            builder: (context, state) => MoneyScreen(controller: controller),
          ),
          GoRoute(
            path: '/pantry',
            builder: (context, state) => PantryScreen(controller: controller),
          ),
          GoRoute(
            path: '/closet',
            builder: (context, state) => ClosetScreen(controller: controller),
          ),
          GoRoute(
            path: '/copilot',
            builder: (context, state) => CopilotScreen(controller: controller),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => PrivacyScreen(controller: controller),
          ),
        ],
      ),
    ],
  );
}
